import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user_management/user_management_bloc.dart';
import '../../../core/theme/app_theme.dart';

class DashboardMetrics {
  final int totalUsers;
  final int pendingApproval;
  final int activeUsers;
  final int suspendedUsers;
  final int rejectedUsers;
  final int urgentPending;
  final int newThisWeek;
  final double weeklyGrowthRate;
  final double avgApprovalDays;
  final Map<String, int> usersByStore;

  const DashboardMetrics({
    required this.totalUsers,
    required this.pendingApproval,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.rejectedUsers,
    required this.urgentPending,
    required this.newThisWeek,
    required this.weeklyGrowthRate,
    required this.avgApprovalDays,
    required this.usersByStore,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalUsers: json['total_users'] ?? 0,
      pendingApproval: json['pending_approval'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      suspendedUsers: json['suspended_users'] ?? 0,
      rejectedUsers: json['rejected_users'] ?? 0,
      urgentPending: json['urgent_pending'] ?? 0,
      newThisWeek: json['new_this_week'] ?? 0,
      weeklyGrowthRate: (json['weekly_growth_rate'] ?? 0.0).toDouble(),
      avgApprovalDays: (json['avg_approval_days'] ?? 0.0).toDouble(),
      usersByStore: Map<String, int>.from(json['users_by_store'] ?? {}),
    );
  }
}

class MetricsDashboard extends StatelessWidget {
  final DashboardMetrics? metrics;
  final VoidCallback? onRefresh;

  const MetricsDashboard({
    super.key,
    this.metrics,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    if (metrics == null) {
      return _buildLoadingSkeleton(context, isTablet);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          if (isDesktop)
            _buildDesktopMetrics(context)
          else if (isTablet)
            _buildTabletMetrics(context)
          else
            _buildMobileMetrics(context),
          if (metrics!.urgentPending > 0) ...[
            const SizedBox(height: 16),
            _buildUrgentAlert(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.dashboard_outlined,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'Panel de Control',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const Spacer(),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
      onPressed: onRefresh,
      tooltip: 'Actualizar métricas',
    );
  }

  Widget _buildDesktopMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard(
          title: 'Total Usuarios',
          value: metrics!.totalUsers.toString(),
          subtitle: _buildTrendIndicator(metrics!.weeklyGrowthRate),
          icon: Icons.people_outline,
          color: AppTheme.primaryColor,
          onTap: () => _showAllUsers(context),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard(
          title: 'Pendientes',
          value: metrics!.pendingApproval.toString(),
          subtitle: _buildUrgencyBar(metrics!.urgentPending, metrics!.pendingApproval),
          icon: Icons.schedule,
          color: _getPendingColor(metrics!.urgentPending),
          onTap: () => _showPendingUsers(context),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard(
          title: 'Activos',
          value: metrics!.activeUsers.toString(),
          subtitle: Text(
            '${((metrics!.activeUsers / metrics!.totalUsers) * 100).toStringAsFixed(1)}% del total',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          icon: Icons.check_circle_outline,
          color: AppTheme.successColor,
          onTap: () => _showActiveUsers(context),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard(
          title: 'Suspendidos',
          value: metrics!.suspendedUsers.toString(),
          subtitle: metrics!.suspendedUsers > 0
              ? const Text('Requiere revisión', style: TextStyle(fontSize: 12, color: Colors.orange))
              : const Text('Todo normal', style: TextStyle(fontSize: 12, color: Colors.grey)),
          icon: Icons.pause_circle_outline,
          color: AppTheme.warningColor,
          onTap: () => _showSuspendedUsers(context),
        )),
      ],
    );
  }

  Widget _buildTabletMetrics(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              title: 'Total',
              value: metrics!.totalUsers.toString(),
              subtitle: _buildTrendIndicator(metrics!.weeklyGrowthRate),
              icon: Icons.people_outline,
              color: AppTheme.primaryColor,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              title: 'Pendientes',
              value: metrics!.pendingApproval.toString(),
              subtitle: _buildUrgencyBar(metrics!.urgentPending, metrics!.pendingApproval),
              icon: Icons.schedule,
              color: _getPendingColor(metrics!.urgentPending),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              title: 'Activos',
              value: metrics!.activeUsers.toString(),
              subtitle: Text('${((metrics!.activeUsers / metrics!.totalUsers) * 100).toStringAsFixed(1)}%'),
              icon: Icons.check_circle_outline,
              color: AppTheme.successColor,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              title: 'Suspendidos',
              value: metrics!.suspendedUsers.toString(),
              subtitle: const Text('Casos'),
              icon: Icons.pause_circle_outline,
              color: AppTheme.warningColor,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileMetrics(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCompactMetricCard(
              title: 'Total',
              value: metrics!.totalUsers.toString(),
              icon: Icons.people_outline,
              color: AppTheme.primaryColor,
            )),
            const SizedBox(width: 8),
            Expanded(child: _buildCompactMetricCard(
              title: 'Pendientes',
              value: metrics!.pendingApproval.toString(),
              icon: Icons.schedule,
              color: _getPendingColor(metrics!.urgentPending),
            )),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildCompactMetricCard(
              title: 'Activos',
              value: metrics!.activeUsers.toString(),
              icon: Icons.check_circle_outline,
              color: AppTheme.successColor,
            )),
            const SizedBox(width: 8),
            Expanded(child: _buildCompactMetricCard(
              title: 'Suspendidos',
              value: metrics!.suspendedUsers.toString(),
              icon: Icons.pause_circle_outline,
              color: AppTheme.warningColor,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    Widget? subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              subtitle,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(double growthRate) {
    final isPositive = growthRate >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 2),
        Text(
          '${growthRate.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          ' esta semana',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUrgencyBar(int urgent, int total) {
    if (total == 0) return const Text('Sin pendientes', style: TextStyle(fontSize: 12, color: Colors.grey));
    
    final urgentPercent = urgent / total;
    Color barColor;
    if (urgentPercent > 0.5) {
      barColor = Colors.red;
    } else if (urgentPercent > 0.2) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (urgent > 0)
          Text(
            '$urgent urgentes',
            style: TextStyle(fontSize: 12, color: barColor, fontWeight: FontWeight.w600),
          )
        else
          const Text('Todos recientes', style: TextStyle(fontSize: 12, color: Colors.green)),
        const SizedBox(height: 2),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: urgentPercent,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${metrics!.urgentPending} usuarios llevan más de 3 días esperando aprobación',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showUrgentUsers(context),
            child: Text(
              'REVISAR',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 120,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isTablet)
            Row(
              children: List.generate(4, (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
            )
          else
            Column(
              children: List.generate(2, (rowIndex) => Container(
                margin: EdgeInsets.only(bottom: rowIndex < 1 ? 8 : 0),
                child: Row(
                  children: List.generate(2, (colIndex) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: colIndex < 1 ? 8 : 0),
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )),
                ),
              )),
            ),
        ],
      ),
    );
  }

  Color _getPendingColor(int urgent) {
    if (urgent > 5) return Colors.red;
    if (urgent > 0) return Colors.orange;
    return Colors.green;
  }

  void _showAllUsers(BuildContext context) {
    context.read<UserManagementBloc>().add(const FilterUsers());
  }

  void _showPendingUsers(BuildContext context) {
    context.read<UserManagementBloc>().add(const FilterUsers(estado: 'PENDIENTE_APROBACION'));
  }

  void _showActiveUsers(BuildContext context) {
    context.read<UserManagementBloc>().add(const FilterUsers(estado: 'ACTIVA'));
  }

  void _showSuspendedUsers(BuildContext context) {
    context.read<UserManagementBloc>().add(const FilterUsers(estado: 'SUSPENDIDA'));
  }

  void _showUrgentUsers(BuildContext context) {
    // Implementar filtro para usuarios urgentes
    context.read<UserManagementBloc>().add(const FilterUsers(estado: 'PENDIENTE_APROBACION'));
  }
}