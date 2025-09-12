import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RegistrationSuccessModal extends StatefulWidget {
  final String email;
  final String message;
  final VoidCallback onClose;

  const RegistrationSuccessModal({
    super.key,
    required this.email,
    required this.message,
    required this.onClose,
  });

  @override
  State<RegistrationSuccessModal> createState() => _RegistrationSuccessModalState();
}

class _RegistrationSuccessModalState extends State<RegistrationSuccessModal> 
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _checkController;
  late AnimationController _timelineController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _timelineAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _timelineController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _timelineAnimation = CurvedAnimation(
      parent: _timelineController,
      curve: Curves.easeInOut,
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _timelineController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _checkController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: EdgeInsets.all(isSmallScreen ? 24 : 32),
                    constraints: BoxConstraints(
                      maxWidth: isSmallScreen ? double.infinity : 480,
                      maxHeight: screenSize.height * 0.8,
                    ),
                    child: Card(
                      elevation: 16,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              AppTheme.primaryTurquoise.withOpacity(0.02),
                            ],
                          ),
                        ),
                        child: _buildModalContent(isSmallScreen),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: isSmallScreen ? 24 : 32),
          _buildStatusCard(),
          SizedBox(height: isSmallScreen ? 24 : 32),
          _buildTimeline(),
          SizedBox(height: isSmallScreen ? 24 : 32),
          _buildNextSteps(),
          SizedBox(height: isSmallScreen ? 24 : 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _checkAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _checkAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.successColor,
                      AppTheme.successColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Registro Exitoso',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tu cuenta ha sido creada correctamente',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryTurquoise.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryTurquoise.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTurquoise,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pending_actions,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado Actual',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pendiente de Aprobación',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  color: AppTheme.primaryDark,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cuenta: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return AnimatedBuilder(
      animation: _timelineAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proceso de Aprobación',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              isCompleted: true,
              isActive: false,
              icon: Icons.person_add,
              title: 'Cuenta Creada',
              subtitle: 'Registro exitoso completado',
              progress: _timelineAnimation.value >= 0.33 ? 1.0 : _timelineAnimation.value * 3,
            ),
            _buildTimelineItem(
              isCompleted: false,
              isActive: true,
              icon: Icons.admin_panel_settings,
              title: 'Revisión Administrativa',
              subtitle: 'Verificación en proceso',
              progress: _timelineAnimation.value >= 0.66 ? 1.0 : 
                       _timelineAnimation.value >= 0.33 ? (_timelineAnimation.value - 0.33) * 3 : 0,
            ),
            _buildTimelineItem(
              isCompleted: false,
              isActive: false,
              icon: Icons.login,
              title: 'Acceso Habilitado',
              subtitle: 'Podrás iniciar sesión',
              progress: _timelineAnimation.value >= 1.0 ? 1.0 : 
                       _timelineAnimation.value >= 0.66 ? (_timelineAnimation.value - 0.66) * 3 : 0,
              isLast: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineItem({
    required bool isCompleted,
    required bool isActive,
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted 
                    ? AppTheme.successColor 
                    : isActive 
                        ? AppTheme.primaryTurquoise.withOpacity(progress)
                        : Colors.grey[300],
                border: Border.all(
                  color: isCompleted 
                      ? AppTheme.successColor
                      : isActive 
                          ? AppTheme.primaryTurquoise
                          : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: isCompleted 
                    ? Colors.white 
                    : isActive 
                        ? Colors.white.withOpacity(progress)
                        : Colors.grey[600],
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted 
                    ? AppTheme.successColor 
                    : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted || isActive 
                        ? AppTheme.textPrimary 
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextSteps() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.infoColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Próximos Pasos',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStepItem('Revisa tu email para confirmar el registro'),
          _buildStepItem('Espera la aprobación del administrador'),
          _buildStepItem('Recibirás una notificación cuando esté listo'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tiempo estimado: 24-48 horas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.infoColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTurquoise,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Ir a Inicio de Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // TODO: Implementar contacto con soporte
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Función próximamente disponible'),
                backgroundColor: AppTheme.infoColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text(
            '¿Necesitas ayuda? Contactar soporte',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// Función helper para mostrar el modal
void showRegistrationSuccessModal(
  BuildContext context, {
  required String email,
  required String message,
  required VoidCallback onClose,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (context) => RegistrationSuccessModal(
      email: email,
      message: message,
      onClose: () {
        Navigator.of(context).pop();
        onClose();
      },
    ),
  );
}