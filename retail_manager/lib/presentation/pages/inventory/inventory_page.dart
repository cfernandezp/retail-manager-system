import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Página de gestión de inventario
/// 
/// Funcionalidades clave (placeholder):
/// - Control de stock por variante
/// - Alertas de stock bajo
/// - Movimientos de inventario
/// - Reportes de rotación
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

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
                      'Inventario',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Control y gestión de stock',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_box),
                  label: const Text('Entrada Stock'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Total Productos',
                    '1,234',
                    Icons.inventory,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    'Stock Bajo',
                    '15',
                    Icons.warning,
                    AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    'Sin Stock',
                    '3',
                    Icons.error,
                    AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Content placeholder
            Expanded(
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warehouse,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Control de Inventario',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestiona el stock de todos tus productos\ny recibe alertas automáticas',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}