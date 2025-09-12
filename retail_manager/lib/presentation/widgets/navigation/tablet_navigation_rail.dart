import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';

/// NavigationRail para tablets (768-1199px) con Material 3 style
class TabletNavigationRail extends StatelessWidget {
  final bool isExpanded;
  final String currentRoute;
  final VoidCallback onToggle;
  final Function(String) onNavigate;

  const TabletNavigationRail({
    super.key,
    required this.isExpanded,
    required this.currentRoute,
    required this.onToggle,
    required this.onNavigate,
  });

  // Items de navegación principales
  static const List<Map<String, dynamic>> navigationItems = [
    {'route': '/dashboard', 'icon': Icons.dashboard_outlined, 'selectedIcon': Icons.dashboard, 'label': 'Dashboard'},
    {'route': '/pos', 'icon': Icons.point_of_sale_outlined, 'selectedIcon': Icons.point_of_sale, 'label': 'POS'},
    {'route': '/products', 'icon': Icons.inventory_2_outlined, 'selectedIcon': Icons.inventory_2, 'label': 'Productos'},
    {'route': '/inventory', 'icon': Icons.warehouse_outlined, 'selectedIcon': Icons.warehouse, 'label': 'Inventario'},
    {'route': '/sales', 'icon': Icons.monetization_on_outlined, 'selectedIcon': Icons.monetization_on, 'label': 'Ventas'},
    {'route': '/customers', 'icon': Icons.people_outline, 'selectedIcon': Icons.people, 'label': 'Clientes'},
    {'route': '/reports', 'icon': Icons.analytics_outlined, 'selectedIcon': Icons.analytics, 'label': 'Reportes'},
    {'route': '/admin', 'icon': Icons.admin_panel_settings_outlined, 'selectedIcon': Icons.admin_panel_settings, 'label': 'Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with logo
          _buildHeader(context),
          
          const Divider(height: 1),
          
          // Navigation items
          Expanded(
            child: _buildNavigationRail(context),
          ),
          
          const Divider(height: 1),
          
          // User section with logout
          _buildUserSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.store,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Retail Manager',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sistema POS',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final destinations = navigationItems.map((item) {
      return NavigationRailDestination(
        icon: Icon(item['icon'] as IconData),
        selectedIcon: Icon(item['selectedIcon'] as IconData),
        label: Text(item['label'] as String),
      );
    }).toList();

    final selectedIndex = navigationItems.indexWhere(
      (item) => item['route'] == currentRoute,
    );

    return NavigationRail(
      extended: isExpanded,
      destinations: destinations,
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      onDestinationSelected: (index) {
        if (index < navigationItems.length) {
          onNavigate(navigationItems[index]['route'] as String);
        }
      },
      labelType: isExpanded 
          ? NavigationRailLabelType.none 
          : NavigationRailLabelType.selected,
      backgroundColor: Colors.transparent,
      selectedIconTheme: const IconThemeData(
        color: AppTheme.primaryColor,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.grey[600],
        size: 24,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.grey[600],
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // User info row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'admin@test.com',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Logout button
          SizedBox(
            width: double.infinity,
            child: isExpanded 
                ? OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Salir', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                : IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, size: 20),
                    color: Colors.red[600],
                    tooltip: 'Cerrar sesión',
                  ),
          ),
        ],
      ),
    );
  }

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

  void _performLogout(BuildContext context) {
    // Disparar el evento de logout al AuthBloc
    context.read<AuthBloc>().add(AuthLogout());
    
    // Navegar inmediatamente a login usando GoRouter
    context.go('/login');
  }
}