import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/dashboard/chart_card.dart';
import '../../widgets/dashboard/quick_actions.dart';
import '../../widgets/dashboard/recent_transactions.dart';

/// Dashboard principal del sistema POS optimizado para web (≥1200px)
/// 
/// Características:
/// - Layout web-first con área de contenido que considera sidebar de 280px
/// - 4 KPI Cards principales con métricas del negocio
/// - 2 secciones de gráficos dummy (líneas y barras)
/// - Lista de transacciones recientes
/// - Acciones rápidas para navegación a módulos principales
/// - Colores corporativos turquesa y Material Design 3
/// - Estados de loading y interacciones hover optimizadas
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  DateTime _lastRefresh = DateTime.now();

  // Datos dummy para los gráficos
  final List<ChartDataPoint> _salesData = [
    ChartDataPoint(label: 'Ene', value: 2400),
    ChartDataPoint(label: 'Feb', value: 1800),
    ChartDataPoint(label: 'Mar', value: 3200),
    ChartDataPoint(label: 'Abr', value: 2800),
    ChartDataPoint(label: 'May', value: 4100),
    ChartDataPoint(label: 'Jun', value: 3600),
  ];

  final List<ChartDataPoint> _productsData = [
    ChartDataPoint(label: 'Medias Ejecutivas', value: 145),
    ChartDataPoint(label: 'Medias Deportivas', value: 98),
    ChartDataPoint(label: 'Calcetines Algodón', value: 87),
    ChartDataPoint(label: 'Medias Compresión', value: 65),
    ChartDataPoint(label: 'Pantys', value: 52),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 32),
            
            // KPI Cards Row
            _buildKpiCards(),
            
            const SizedBox(height: 24),
            
            // Main Content Grid
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Título y subtitle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Buenos días! Aquí tienes el resumen de tu negocio.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Controles del header
        Row(
          children: [
            // Indicador de última actualización
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Actualizado hace ${DateTime.now().difference(_lastRefresh).inMinutes}m',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Botón de actualizar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleRefresh,
              icon: _isLoading 
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(_isLoading ? 'Actualizando...' : 'Actualizar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCards() {
    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: KpiCard(
              title: 'Ventas de Hoy',
              value: 'S/ 2,450.00',
              subtitle: '+12.5% vs ayer',
              icon: Icons.monetization_on,
              color: AppTheme.successColor,
              isIncreasing: true,
              trendingValue: '+12.5%',
              isLoading: _isLoading,
              onTap: () => context.go('/sales'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: KpiCard(
              title: 'Productos en Stock',
              value: '1,247',
              subtitle: '8 productos con stock bajo',
              icon: Icons.inventory_2,
              color: AppTheme.primaryColor,
              isIncreasing: false,
              trendingValue: '-3.2%',
              isLoading: _isLoading,
              onTap: () => context.go('/inventory'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: KpiCard(
              title: 'Clientes Activos',
              value: '324',
              subtitle: 'Registrados este mes',
              icon: Icons.people,
              color: AppTheme.infoColor,
              isIncreasing: true,
              trendingValue: '+8.1%',
              isLoading: _isLoading,
              onTap: () => context.go('/customers'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: KpiCard(
              title: 'Órdenes Pendientes',
              value: '15',
              subtitle: 'Requieren atención',
              icon: Icons.pending_actions,
              color: AppTheme.warningColor,
              isIncreasing: false,
              trendingValue: '-5 hoy',
              isLoading: _isLoading,
              onTap: () => context.go('/sales'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda (2/3 del ancho)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Gráficos
              Row(
                children: [
                  // Gráfico de ventas por mes (líneas)
                  Expanded(
                    child: SizedBox(
                      height: 320,
                      child: ChartCard(
                        title: 'Ventas por Mes',
                        subtitle: 'Evolución mensual de ingresos',
                        chartType: ChartType.line,
                        data: _salesData,
                        isLoading: _isLoading,
                        onRefresh: _handleRefresh,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Gráfico de productos más vendidos (barras)
                  Expanded(
                    child: SizedBox(
                      height: 320,
                      child: ChartCard(
                        title: 'Productos Más Vendidos',
                        subtitle: 'Top 5 productos del mes',
                        chartType: ChartType.bar,
                        data: _productsData,
                        isLoading: _isLoading,
                        onRefresh: _handleRefresh,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Transacciones recientes
              SizedBox(
                height: 400,
                child: RecentTransactions(
                  transactions: const [], // Usando datos dummy del widget
                  isLoading: _isLoading,
                  onViewAll: () => context.go('/sales'),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Columna derecha (1/3 del ancho) - Acciones rápidas
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 744, // Altura total para coincidir con la columna izquierda
            child: QuickActions(
              onNavigate: (route) => context.go(route),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _lastRefresh = DateTime.now();
      });
    }

    // Mostrar mensaje de éxito
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Dashboard actualizado exitosamente'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}