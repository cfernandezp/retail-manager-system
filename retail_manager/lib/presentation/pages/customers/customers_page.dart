import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Página de gestión de clientes
class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clientes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestión de base de clientes',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo Cliente'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gestión de Clientes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Base de datos de clientes con DNI/RUC validado',
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
}