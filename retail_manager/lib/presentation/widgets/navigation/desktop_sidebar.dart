import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../common/theme_toggle_button.dart';
import '../common/safe_hover_widget.dart';
import '../../bloc/auth/auth_bloc.dart';

/// Sidebar para Desktop (≥1200px) con diseño corporativo optimizado
/// 
/// Características:
/// - Ancho fijo de 280px para experiencia desktop consistente
/// - Logo corporativo en la parte superior
/// - Navegación principal con iconos Material Design
/// - Información de usuario y logout en la parte inferior
/// - Estado activo destacado con color primary
/// - Hover effects suaves para mejor UX desktop
/// - Soporte para expansión/colapso (futuro)
class DesktopSidebar extends StatefulWidget {
  final bool isExpanded;
  final String currentRoute;
  final VoidCallback onToggle;
  final Function(String) onNavigate;

  const DesktopSidebar({
    super.key,
    required this.isExpanded,
    required this.currentRoute,
    required this.onToggle,
    required this.onNavigate,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  String? hoveredItem;

  // Items de navegación principales
  static const List<Map<String, dynamic>> navigationItems = [
    {'route': '/dashboard', 'icon': Icons.dashboard, 'title': 'Dashboard'},
    {'route': '/pos', 'icon': Icons.point_of_sale, 'title': 'Punto de Venta'},
    {'route': '/products', 'icon': Icons.inventory_2, 'title': 'Productos'},
    {'route': '/inventory', 'icon': Icons.warehouse, 'title': 'Inventario'},
    {'route': '/sales', 'icon': Icons.monetization_on, 'title': 'Ventas'},
    {'route': '/customers', 'icon': Icons.people, 'title': 'Clientes'},
    {'route': '/reports', 'icon': Icons.analytics, 'title': 'Reportes'},
    {'route': '/admin', 'icon': Icons.admin_panel_settings, 'title': 'Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Ancho fijo para desktop
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con logo corporativo
          _buildHeader(context),
          
          // Separador
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          
          // Items de navegación principal
          Expanded(
            child: _buildNavigationItems(context),
          ),
          
          // Separador
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          
          // Toggle de tema
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ThemeToggleButton(
              isExpanded: widget.isExpanded,
              showLabel: true,
            ),
          ),
          
          // Footer con información del usuario
          _buildUserFooter(context),
        ],
      ),
    );
  }

  /// Header con logo y branding corporativo
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo placeholder (aquí iría el logo real de la empresa)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.store,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Texto del brand
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Important: prevent overflow
              children: [
                Text(
                  'Retail Manager',
                  style: TextStyle(
                    fontSize: 14, // Reduced from 16
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Sistema POS',
                  style: TextStyle(
                    fontSize: 10, // Reduced from 12
                    color: AppTheme.textSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de items de navegación
  Widget _buildNavigationItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: navigationItems.map((item) {
        return _buildNavigationItem(
          context,
          route: item['route'] as String,
          icon: item['icon'] as IconData,
          title: item['title'] as String,
        );
      }).toList(),
    );
  }

  /// Item individual de navegación con estados hover y activo
  Widget _buildNavigationItem(
    BuildContext context, {
    required String route,
    required IconData icon,
    required String title,
  }) {
    final isActive = widget.currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: SafeHoverWidget(
        onHover: () {
          if (mounted) {
            setState(() => hoveredItem = route);
          }
        },
        onExit: () {
          if (mounted) {
            setState(() => hoveredItem = null);
          }
        },
        builder: (context, isHovered) {
          return GestureDetector(
            onTap: () => widget.onNavigate(route),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getItemBackgroundColor(isActive, isHovered),
                borderRadius: BorderRadius.circular(12),
                border: isActive ? Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ) : null,
              ),
              child: Row(
                children: [
                  // Icono
                  Icon(
                    icon,
                    size: 22,
                    color: _getItemIconColor(isActive, isHovered),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Título
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: _getItemTextColor(isActive, isHovered),
                      ),
                    ),
                  ),
                  
                  // Indicador de item activo
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Footer con información del usuario y logout
  Widget _buildUserFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // User info
          Row(
            children: [
              // Avatar placeholder
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Usuario',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    Text(
                      'admin@test.com',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Logout button
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, size: 20),
                tooltip: 'Cerrar sesión',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Obtiene el color de fondo del item según su estado
  Color _getItemBackgroundColor(bool isActive, bool isHovered) {
    if (isActive) {
      return AppTheme.primaryColor.withOpacity(0.15);
    }
    if (isHovered) {
      return Colors.grey.withOpacity(0.05);
    }
    return Colors.transparent;
  }

  /// Obtiene el color del icono según el estado del item
  Color _getItemIconColor(bool isActive, bool isHovered) {
    if (isActive) {
      return AppTheme.primaryColor;
    }
    if (isHovered) {
      return AppTheme.onSurfaceColor;
    }
    return AppTheme.textSecondaryColor;
  }

  /// Obtiene el color del texto según el estado del item
  Color _getItemTextColor(bool isActive, bool isHovered) {
    if (isActive) {
      return AppTheme.primaryColor;
    }
    if (isHovered) {
      return AppTheme.onSurfaceColor;
    }
    return AppTheme.textSecondaryColor;
  }

  /// Muestra diálogo de confirmación para logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  /// Ejecuta el logout y navega a la página de login
  void _performLogout(BuildContext context) {
    // Disparar el evento de logout al AuthBloc
    context.read<AuthBloc>().add(AuthLogout());
    
    // Navegar inmediatamente a login usando GoRouter
    context.go('/login');
  }
}