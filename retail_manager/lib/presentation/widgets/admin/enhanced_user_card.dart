import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../common/corporate_button.dart';

class EnhancedUserCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onSelectionToggle;
  final Function(String action)? onActionPressed;
  final bool isTablet;

  const EnhancedUserCard({
    super.key,
    required this.user,
    this.isSelected = false,
    this.selectionMode = false,
    this.onTap,
    this.onSelectionToggle,
    this.onActionPressed,
    this.isTablet = false,
  });

  @override
  State<EnhancedUserCard> createState() => _EnhancedUserCardState();
}

class _EnhancedUserCardState extends State<EnhancedUserCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.user['estado'] as String;
    final emailVerificado = widget.user['email_verificado'] as bool? ?? false;
    
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: widget.selectionMode && widget.isSelected 
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isSelected ? 0.12 : _isHovered ? 0.08 : 0.06),
                  blurRadius: widget.isSelected ? 12 : _isHovered ? 10 : 8,
                  offset: Offset(0, widget.isSelected ? 4 : _isHovered ? 3 : 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.selectionMode ? widget.onSelectionToggle : widget.onTap,
                onHover: (hovering) {
                  setState(() {
                    _isHovered = hovering;
                  });
                  if (hovering) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildUserInfo(estado, emailVerificado),
                const SizedBox(height: 16),
                _buildMetadata(),
                if (_shouldShowActions(estado) && !widget.selectionMode) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(estado),
                ],
              ],
            ),
          ),
        ),
      ),
      );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (widget.selectionMode)
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                width: 2,
              ),
              color: widget.isSelected ? AppTheme.primaryColor : Colors.transparent,
            ),
            child: widget.isSelected 
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        
        // Avatar con inicial
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            _getInitials(widget.user['nombre_completo'] ?? 'U'),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.user['nombre_completo'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriorityIndicator(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.user['email'] ?? '',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(String estado, bool emailVerificado) {
    return Row(
      children: [
        _buildEnhancedEstadoBadge(estado, emailVerificado),
        const Spacer(),
        _buildRolChip(),
      ],
    );
  }

  Widget _buildEnhancedEstadoBadge(String estado, bool emailVerificado) {
    late Color color;
    late String text;
    late IconData icon;

    switch (estado) {
      case 'ACTIVA':
        color = AppTheme.successColor;
        text = 'Activa';
        icon = Icons.check_circle;
        break;
      case 'PENDIENTE_APROBACION':
        color = AppTheme.warningColor;
        text = emailVerificado ? 'Pendiente aprobación' : 'Email no verificado';
        icon = emailVerificado ? Icons.hourglass_empty : Icons.mark_email_unread;
        break;
      case 'SUSPENDIDA':
        color = AppTheme.errorColor;
        text = 'Suspendida';
        icon = Icons.pause_circle;
        break;
      case 'RECHAZADA':
        color = Colors.grey.shade600;
        text = 'Rechazada';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey.shade600;
        text = estado;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolChip() {
    final rolNombre = widget.user['roles']['nombre'] ?? 'N/A';
    final rolColor = _getRolColor(rolNombre);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: rolColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRolIcon(rolNombre), size: 14, color: rolColor),
          const SizedBox(width: 4),
          Text(
            _getDisplayRol(rolNombre),
            style: TextStyle(
              fontSize: 11,
              color: rolColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        if (widget.user['created_at'] != null) ...[
          Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            'Registro: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.user['created_at']))}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        const Spacer(),
        if (widget.user['ultimo_acceso'] != null) ...[
          Icon(Icons.login, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            'Último acceso: ${DateFormat('dd/MM').format(DateTime.parse(widget.user['ultimo_acceso']))}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(String estado) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (estado == 'PENDIENTE_APROBACION') ...[
          CorporateButton(
            text: 'Aprobar',
            height: 36,
            width: widget.isTablet ? 120 : null,
            icon: Icons.check,
            onPressed: () => widget.onActionPressed?.call('approve'),
          ),
          CorporateButton(
            text: 'Rechazar',
            height: 36,
            width: widget.isTablet ? 120 : null,
            isSecondary: true,
            icon: Icons.close,
            onPressed: () => widget.onActionPressed?.call('reject'),
          ),
        ],
        if (estado == 'ACTIVA') ...[
          CorporateButton(
            text: 'Suspender',
            height: 36,
            width: widget.isTablet ? 120 : null,
            isSecondary: true,
            icon: Icons.pause,
            onPressed: () => widget.onActionPressed?.call('suspend'),
          ),
        ],
        if (estado == 'SUSPENDIDA') ...[
          CorporateButton(
            text: 'Reactivar',
            height: 36,
            width: widget.isTablet ? 120 : null,
            icon: Icons.play_arrow,
            onPressed: () => widget.onActionPressed?.call('reactivate'),
          ),
        ],
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    final estado = widget.user['estado'] as String;
    
    if (estado == 'PENDIENTE_APROBACION') {
      final createdAt = DateTime.parse(widget.user['created_at']);
      final daysSinceCreated = DateTime.now().difference(createdAt).inDays;
      
      if (daysSinceCreated > 3) {
        // Dot pulsante rojo para casos urgentes
        return _buildPulsingDot(AppTheme.errorColor);
      } else if (daysSinceCreated > 1) {
        // Dot pulsante naranja para casos de atención
        return _buildPulsingDot(AppTheme.warningColor);
      }
    }
    
    return const SizedBox();
  }

  Widget _buildPulsingDot(Color color) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.5, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color.withOpacity(value),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: value * 4,
                  spreadRadius: value * 2,
                ),
              ],
            ),
          ),
        );
      },
      onEnd: () {
        // Reiniciar la animación infinitamente
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  bool _shouldShowActions(String estado) {
    return estado == 'PENDIENTE_APROBACION' || 
           estado == 'ACTIVA' || 
           estado == 'SUSPENDIDA';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return 'U';
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'SUPER_ADMIN': return Colors.purple;
      case 'ADMIN': return Colors.blue;
      case 'VENDEDOR': return Colors.green;
      case 'OPERARIO': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getRolIcon(String rol) {
    switch (rol) {
      case 'SUPER_ADMIN': return Icons.admin_panel_settings;
      case 'ADMIN': return Icons.manage_accounts;
      case 'VENDEDOR': return Icons.point_of_sale;
      case 'OPERARIO': return Icons.engineering;
      default: return Icons.person;
    }
  }

  String _getDisplayRol(String rol) {
    switch (rol) {
      case 'SUPER_ADMIN': return 'Super Admin';
      case 'ADMIN': return 'Admin';
      case 'VENDEDOR': return 'Vendedor';
      case 'OPERARIO': return 'Operario';
      default: return rol;
    }
  }
}