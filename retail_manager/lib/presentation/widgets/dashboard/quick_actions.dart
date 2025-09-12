import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget para acciones rápidas del dashboard
/// 
/// Características:
/// - Botones de acceso directo a módulos principales
/// - Grid layout responsivo
/// - Iconos Material Design
/// - Efectos hover para web
/// - Navegación directa a rutas específicas
class QuickActions extends StatelessWidget {
  final Function(String) onNavigate;

  const QuickActions({
    super.key,
    required this.onNavigate,
  });

  static const List<QuickAction> _actions = [
    QuickAction(
      title: 'Nueva Venta',
      description: 'Iniciar punto de venta',
      icon: Icons.point_of_sale,
      color: AppTheme.primaryTurquoise,
      route: '/pos',
    ),
    QuickAction(
      title: 'Productos',
      description: 'Gestionar catálogo',
      icon: Icons.inventory_2,
      color: Color(0xFF6366F1),
      route: '/products',
    ),
    QuickAction(
      title: 'Inventario',
      description: 'Control de stock',
      icon: Icons.warehouse,
      color: Color(0xFF8B5CF6),
      route: '/inventory',
    ),
    QuickAction(
      title: 'Clientes',
      description: 'Base de datos',
      icon: Icons.people,
      color: Color(0xFF06B6D4),
      route: '/customers',
    ),
    QuickAction(
      title: 'Reportes',
      description: 'Análisis y métricas',
      icon: Icons.analytics,
      color: Color(0xFF10B981),
      route: '/reports',
    ),
    QuickAction(
      title: 'Configuración',
      description: 'Ajustes del sistema',
      icon: Icons.settings,
      color: Color(0xFF64748B),
      route: '/admin',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Icon(
                  Icons.rocket_launch,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Grid de acciones
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _actions.length,
                itemBuilder: (context, index) {
                  return QuickActionTile(
                    action: _actions[index],
                    onTap: () => onNavigate(_actions[index].route),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionTile extends StatefulWidget {
  final QuickAction action;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.action,
    required this.onTap,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.action.color.withOpacity(0.1),
                      widget.action.color.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: _isHovered
                        ? widget.action.color.withOpacity(0.3)
                        : widget.action.color.withOpacity(0.1),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.action.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.action.icon,
                          size: 24,
                          color: widget.action.color,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Título
                      Text(
                        widget.action.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 4),

                      // Descripción
                      Text(
                        widget.action.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (_isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}

class QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}