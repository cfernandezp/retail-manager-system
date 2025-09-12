import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SuccessModal extends StatefulWidget {
  final String title;
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onClose;
  final String buttonText;
  final Color? iconColor;
  final List<Widget>? additionalActions;

  const SuccessModal({
    super.key,
    required this.title,
    required this.message,
    this.subtitle,
    this.icon = Icons.check_circle,
    this.onClose,
    this.buttonText = 'Entendido',
    this.iconColor,
    this.additionalActions,
  });

  @override
  State<SuccessModal> createState() => _SuccessModalState();
}

class _SuccessModalState extends State<SuccessModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _iconAnimation = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _iconController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 480 : size.width * 0.9,
            maxHeight: size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con gradiente sutil
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Stack(
                  children: [
                    // Círculos decorativos de fondo
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: -10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Icono principal con animación
                    Center(
                      child: ScaleTransition(
                        scale: _iconAnimation,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: widget.iconColor ?? AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (widget.iconColor ?? AppTheme.primaryColor)
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),

                      // Subtítulo si existe
                      if (widget.subtitle != null) ...[
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Mensaje principal
                      Text(
                        widget.message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Divider decorativo
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Acciones adicionales
                      if (widget.additionalActions != null) ...[
                        ...widget.additionalActions!,
                        const SizedBox(height: 16),
                      ],

                      // Botón principal
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onClose?.call();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            widget.buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? subtitle,
    IconData icon = Icons.check_circle,
    VoidCallback? onClose,
    String buttonText = 'Entendido',
    Color? iconColor,
    List<Widget>? additionalActions,
    bool barrierDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (context) => SuccessModal(
        title: title,
        message: message,
        subtitle: subtitle,
        icon: icon,
        onClose: onClose,
        buttonText: buttonText,
        iconColor: iconColor,
        additionalActions: additionalActions,
      ),
    );
  }
}