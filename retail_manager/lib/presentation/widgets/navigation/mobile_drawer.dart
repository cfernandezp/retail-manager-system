import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';

/// Drawer para mobile (<768px) con navegación completa
class MobileDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const MobileDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

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
    return Drawer(
      child: Column(
        children: [
          // Header con branding
          _buildHeader(context),
          
          // Items de navegación
          Expanded(
            child: _buildNavigationItems(context),
          ),
          
          // Divider
          const Divider(),
          
          // Logout button
          _buildLogoutSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo y título
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retail Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sistema POS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User info
          const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white30,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'admin@test.com',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: navigationItems.map((item) {
        final isActive = currentRoute == item['route'];
        
        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: isActive ? AppTheme.primaryColor : Colors.grey[600],
          ),
          title: Text(
            item['title'] as String,
            style: TextStyle(
              color: isActive ? AppTheme.primaryColor : Colors.grey[800],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isActive,
          selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
          onTap: () => onNavigate(item['route'] as String),
        );
      }).toList(),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar Sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red[700],
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
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