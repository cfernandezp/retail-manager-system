import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class UserMetricsDashboard extends StatefulWidget {
  final Map<String, dynamic>? metrics;
  final VoidCallback? onRefresh;

  const UserMetricsDashboard({
    super.key,
    this.metrics,
    this.onRefresh,
  });

  @override
  State<UserMetricsDashboard> createState() => _UserMetricsDashboardState();
}

class _UserMetricsDashboardState extends State<UserMetricsDashboard> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Getters para métricas del backend
  int get totalUsers => widget.metrics?['total_usuarios'] ?? 0;
  int get pendingApproval => widget.metrics?['pendiente_aprobacion'] ?? 0;
  int get activeUsers => widget.metrics?['activos'] ?? 0;
  int get suspendedUsers => widget.metrics?['suspendidos'] ?? 0;
  int get rejectedUsers => widget.metrics?['rechazados'] ?? 0;
  int get unverifiedEmail => widget.metrics?['email_no_verificado'] ?? 0;
  int get newThisWeek => widget.metrics?['nuevos_esta_semana'] ?? 0;
  int get urgentCount => widget.metrics?['urgentes'] ?? 0;
  double get weeklyGrowth => (widget.metrics?['crecimiento_semanal'] ?? 0.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Usuarios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Métricas principales
          isTablet 
              ? _buildTabletLayout()
              : _buildMobileLayout(),
          
          const SizedBox(height: 16),
          
          // Alertas y acciones rápidas
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        // Primera fila: métricas principales
        Row(
          children: [
            Expanded(child: _buildEnhancedMetricCard(
              'Total Usuarios',
              totalUsers.toString(),
              Icons.people,
              AppTheme.primaryColor,
              subtitle: '+$newThisWeek esta semana',
              showMiniChart: true,
              trend: weeklyGrowth,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildEnhancedMetricCard(
              'Pendientes',
              pendingApproval.toString(),
              Icons.hourglass_empty,
              AppTheme.warningColor,
              isUrgent: urgentCount > 0,
              urgentCount: urgentCount,
              subtitle: urgentCount > 0 ? '$urgentCount urgentes' : 'Todo al día',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildEnhancedMetricCard(
              'Activos',
              activeUsers.toString(),
              Icons.check_circle,
              AppTheme.successColor,
              subtitle: '${((activeUsers / (totalUsers > 0 ? totalUsers : 1)) * 100).toStringAsFixed(1)}% del total',
              showPercentage: true,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildEnhancedMetricCard(
              'Suspendidos',
              suspendedUsers.toString(),
              Icons.pause_circle,
              AppTheme.errorColor,
              subtitle: suspendedUsers > 0 ? 'Requiere atención' : 'Sin incidentes',
            )),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Segunda fila: métricas adicionales
        Row(
          children: [
            Expanded(child: _buildQuickStatCard(
              'Email no verificado',
              unverifiedEmail.toString(),
              Icons.mark_email_unread,
              AppTheme.infoColor,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickStatCard(
              'Rechazados',
              rejectedUsers.toString(),
              Icons.cancel,
              Colors.grey.shade600,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              'Total',
              totalUsers.toString(),
              Icons.people,
              AppTheme.primaryColor,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              'Pendientes',
              pendingApproval.toString(),
              Icons.hourglass_empty,
              AppTheme.warningColor,
              isUrgent: pendingApproval > 5,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              'Activos',
              activeUsers.toString(),
              Icons.check_circle,
              AppTheme.successColor,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              'Suspendidos',
              suspendedUsers.toString(),
              Icons.pause_circle,
              AppTheme.errorColor,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUrgent 
            ? Border.all(color: AppTheme.errorColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'URGENTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMetricCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isUrgent = false,
    int? urgentCount,
    String? subtitle,
    bool showMiniChart = false,
    bool showPercentage = false,
    double? trend,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent && urgentCount != null && urgentCount > 0 
              ? _pulseAnimation.value 
              : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isUrgent && urgentCount != null && urgentCount > 0
                  ? Border.all(color: AppTheme.errorColor, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isUrgent && urgentCount != null && urgentCount > 0
                      ? AppTheme.errorColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 24),
                    if (isUrgent && urgentCount != null && urgentCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'URGENTE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (trend != null && !isUrgent)
                      Icon(
                        trend > 0 ? Icons.trending_up : Icons.trending_down,
                        color: trend > 0 ? AppTheme.successColor : AppTheme.errorColor,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
                if (showMiniChart && trend != null) ...[
                  const SizedBox(height: 8),
                  _buildMiniChart(trend),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: widget.onRefresh,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.refresh,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            const Text(
              'Actualizar métricas',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(double trend) {
    return SizedBox(
      height: 20,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(7, (index) {
                return FlSpot(index.toDouble(), trend > 0 ? index * 0.3 : 6 - index * 0.3);
              }),
              isCurved: true,
              color: trend > 0 ? AppTheme.successColor : AppTheme.errorColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    if (pendingApproval == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.successColor.withOpacity(0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Todas las solicitudes están procesadas',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: urgentCount > 0 ? AppTheme.errorColor.withOpacity(0.1) : AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: urgentCount > 0 ? AppTheme.errorColor.withOpacity(0.3) : AppTheme.warningColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                urgentCount > 0 ? Icons.priority_high : Icons.info,
                color: urgentCount > 0 ? AppTheme.errorColor : AppTheme.warningColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  urgentCount > 0 
                      ? 'CRÍTICO: $urgentCount usuarios requieren atención inmediata'
                      : 'Tienes $pendingApproval usuarios pendientes de aprobación',
                  style: TextStyle(
                    color: urgentCount > 0 ? AppTheme.errorColor : AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (urgentCount > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Usuarios con más de 3 días pendientes pueden perder interés. Procesar inmediatamente.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}