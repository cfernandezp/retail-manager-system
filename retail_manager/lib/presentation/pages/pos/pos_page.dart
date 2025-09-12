import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Página del Punto de Venta (POS)
/// 
/// Funcionalidades clave (placeholder):
/// - Scanner de códigos de barras
/// - Carrito de compras
/// - Cálculo de totales
/// - Procesamiento de pagos
/// - Impresión de tickets
class PosPage extends StatelessWidget {
  const PosPage({super.key});

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
                      'Punto de Venta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistema de ventas integrado',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Escanear'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // POS Interface
            Expanded(
              child: Row(
                children: [
                  // Product Search & Cart Section
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carrito de Compras',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Search bar
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar producto por nombre o código...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.qr_code_scanner),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Cart items placeholder
                            Expanded(
                              child: _buildCartPlaceholder(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Payment Section
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildTotalSection(),
                            
                            const SizedBox(height: 20),
                            
                            // Payment buttons
                            Expanded(
                              child: _buildPaymentButtons(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Carrito vacío',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escanea o busca productos para agregarlos',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      children: [
        _buildTotalRow('Subtotal:', 'S/ 0.00'),
        const SizedBox(height: 8),
        _buildTotalRow('IGV (18%):', 'S/ 0.00'),
        const Divider(),
        _buildTotalRow('Total:', 'S/ 0.00', isTotal: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primaryColor : AppTheme.onSurfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButtons() {
    return Column(
      children: [
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.payment),
            label: const Text('Procesar Pago'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar Carrito'),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Efectivo'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Tarjeta'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}