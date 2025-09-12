import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Página principal de administración
/// 
/// Panel de control para administradores del sistema con acceso a:
/// - Gestión de usuarios
/// - Configuración del sistema
/// - Logs y auditoría
/// - Respaldos
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administración',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Panel de control del sistema',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                  label: const Text('Configuración'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Admin modules grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildAdminCard(
                    'Gestión de Usuarios',
                    'Administrar cuentas y permisos',
                    Icons.people_alt,
                    AppTheme.primaryColor,
                    () => _navigateToUserManagement(context),
                  ),
                  _buildAdminCard(
                    'Configuración',
                    'Ajustes generales del sistema',
                    Icons.settings,
                    AppTheme.infoColor,
                    () {},
                  ),
                  _buildAdminCard(
                    'Logs del Sistema',
                    'Auditoría y registro de eventos',
                    Icons.article,
                    AppTheme.warningColor,
                    () {},
                  ),
                  _buildAdminCard(
                    'Respaldos',
                    'Backup y restauración de datos',
                    Icons.backup,
                    AppTheme.successColor,
                    () {},
                  ),
                  _buildAdminCard(
                    'Métricas',
                    'Performance y uso del sistema',
                    Icons.analytics,
                    AppTheme.secondaryColor,
                    () {},
                  ),
                  _buildAdminCard(
                    'Soporte',
                    'Herramientas de diagnóstico',
                    Icons.support_agent,
                    AppTheme.textSecondaryColor,
                    () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserManagement(BuildContext context) {
    context.go('/admin/users');
  }
}