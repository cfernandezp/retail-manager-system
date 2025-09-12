import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/user_management/user_management_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/corporate_button.dart';
import '../../widgets/admin/metrics_dashboard.dart';
import '../../widgets/admin/enhanced_filter_panel.dart';

class UserManagementPageOptimized extends StatefulWidget {
  const UserManagementPageOptimized({super.key});

  @override
  State<UserManagementPageOptimized> createState() => _UserManagementPageOptimizedState();
}

class _UserManagementPageOptimizedState extends State<UserManagementPageOptimized> {
  DashboardMetrics? currentMetrics;
  bool isSelectionMode = false;
  Set<String> selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<UserManagementBloc>().add(const LoadUsers());
    _loadMetrics();
  }

  void _loadMetrics() async {
    try {
      // TODO: Conectar con la función get_dashboard_metrics() del backend
      // Por ahora usamos datos simulados
      setState(() {
        currentMetrics = const DashboardMetrics(
          totalUsers: 125,
          pendingApproval: 8,
          activeUsers: 98,
          suspendedUsers: 2,
          rejectedUsers: 17,
          urgentPending: 3,
          newThisWeek: 12,
          weeklyGrowthRate: 8.5,
          avgApprovalDays: 2.3,
          usersByStore: {
            'T001': 35,
            'T002': 28,
            'T003': 31,
            'T004': 31,
          },
        );
      });
    } catch (e) {
      debugPrint('Error cargando métricas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocConsumer<UserManagementBloc, UserManagementState>(
        listener: (context, state) {
          if (state is UserManagementActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadMetrics(); // Actualizar métricas después de acciones
          } else if (state is UserManagementFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Dashboard de métricas
              MetricsDashboard(
                metrics: currentMetrics,
                onRefresh: _loadMetrics,
              ),
              
              // Panel de filtros
              const EnhancedFilterPanel(),
              
              // Toolbar de selección masiva (si está activo)
              if (isSelectionMode && selectedUsers.isNotEmpty)
                _buildSelectionToolbar(context),
              
              // Lista de usuarios
              Expanded(
                child: _buildUsersList(context, state, isTablet),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Gestión de Usuarios'),
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.onSurfaceColor,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      actions: [
        // Toggle selección masiva
        IconButton(
          icon: Icon(
            isSelectionMode ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelectionMode ? AppTheme.primaryColor : Colors.grey,
          ),
          onPressed: _toggleSelectionMode,
          tooltip: isSelectionMode ? 'Salir selección masiva' : 'Selección masiva',
        ),
        
        // Refresh
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Actualizar',
        ),
        
        // Ayuda
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showKeyboardShortcuts(context),
          tooltip: 'Atajos de teclado',
        ),
      ],
    );
  }

  Widget _buildSelectionToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            '${selectedUsers.length} seleccionados',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const Spacer(),
          
          // Acciones masivas
          Row(
            children: [
              _buildBulkActionButton(
                'Aprobar',
                Icons.check_circle,
                Colors.green,
                () => _bulkApprove(selectedUsers.toList()),
              ),
              const SizedBox(width: 8),
              _buildBulkActionButton(
                'Rechazar',
                Icons.cancel,
                Colors.red,
                () => _bulkReject(selectedUsers.toList()),
              ),
              const SizedBox(width: 8),
              _buildBulkActionButton(
                'Suspender',
                Icons.pause_circle,
                Colors.orange,
                () => _bulkSuspend(selectedUsers.toList()),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              setState(() {
                selectedUsers.clear();
                isSelectionMode = false;
              });
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, UserManagementState state, bool isTablet) {
    if (state is UserManagementLoading) {
      return _buildLoadingSkeleton(isTablet);
    }

    if (state is UserManagementFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error cargando usuarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            CorporateButton(
              text: 'Reintentar',
              onPressed: _loadData,
            ),
          ],
        ),
      );
    }

    if (state is UserManagementSuccess) {
      if (state.filteredUsers.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No hay usuarios para mostrar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return _buildResponsiveGrid(context, state.filteredUsers);
    }

    return const SizedBox();
  }

  Widget _buildResponsiveGrid(BuildContext context, List<Map<String, dynamic>> users) {
    final size = MediaQuery.of(context).size;
    
    if (size.width < 600) {
      // Móvil: Lista vertical
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(context, user, isCompact: true);
        },
      );
    } else if (size.width < 1024) {
      // Tablet: Grid 2 columnas
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(context, user);
        },
      );
    } else {
      // Desktop: Grid 3 columnas
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(context, user);
        },
      );
    }
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user, {bool isCompact = false}) {
    final estado = user['estado'] as String;
    final emailVerificado = user['email_verificado'] as bool? ?? false;
    final userId = user['id'] as String;
    final isSelected = selectedUsers.contains(userId);
    
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          setState(() {
            if (isSelected) {
              selectedUsers.remove(userId);
            } else {
              selectedUsers.add(userId);
            }
          });
        } else {
          _showUserDetails(context, user);
        }
      },
      child: Container(
        margin: isCompact ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelectionMode) ...[
                    Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? AppTheme.primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildAvatar(user['nombre_completo'] ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['nombre_completo'] ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildEstadoBadge(estado, emailVerificado),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip('Rol', user['roles']['nombre'] ?? 'N/A'),
                  const SizedBox(width: 8),
                  if (user['created_at'] != null)
                    _buildInfoChip(
                      'Registro',
                      DateFormat('dd/MM/yyyy').format(
                        DateTime.parse(user['created_at']),
                      ),
                    ),
                ],
              ),
              if (!isCompact && _shouldShowActions(estado)) ...[
                const SizedBox(height: 12),
                _buildActionButtons(context, user),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    String initials = '';
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      initials = parts.length > 1 
          ? '${parts[0][0]}${parts[1][0]}'
          : parts[0].substring(0, 1);
    }

    return CircleAvatar(
      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
      radius: 16,
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(String estado, bool emailVerificado) {
    Color color;
    String text;
    IconData? icon;

    switch (estado) {
      case 'ACTIVA':
        color = AppTheme.successColor;
        text = 'Activa';
        icon = Icons.check_circle;
        break;
      case 'PENDIENTE_APROBACION':
        color = AppTheme.warningColor;
        text = emailVerificado ? 'Pendiente' : 'Sin email';
        icon = emailVerificado ? Icons.schedule : Icons.mail_outline;
        break;
      case 'SUSPENDIDA':
        color = AppTheme.errorColor;
        text = 'Suspendida';
        icon = Icons.pause_circle;
        break;
      case 'RECHAZADA':
        color = Colors.grey;
        text = 'Rechazada';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = estado;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> user) {
    final estado = user['estado'] as String;
    final userId = user['id'] as String;

    return Row(
      children: [
        if (estado == 'PENDIENTE_APROBACION') ...[
          Expanded(
            child: CorporateButton(
              text: 'Aprobar',
              height: 28,
              icon: Icons.check,
              onPressed: () => _showApproveDialog(context, userId),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CorporateButton(
              text: 'Rechazar',
              height: 28,
              isSecondary: true,
              icon: Icons.close,
              onPressed: () => _showRejectDialog(context, userId),
            ),
          ),
        ],
        if (estado == 'ACTIVA') ...[
          Expanded(
            child: CorporateButton(
              text: 'Suspender',
              height: 28,
              isSecondary: true,
              icon: Icons.pause,
              onPressed: () => _showSuspendDialog(context, userId),
            ),
          ),
        ],
        if (estado == 'SUSPENDIDA') ...[
          Expanded(
            child: CorporateButton(
              text: 'Reactivar',
              height: 28,
              icon: Icons.play_arrow,
              onPressed: () => _showReactivateDialog(context, userId),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingSkeleton(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 2 : 1,
          childAspectRatio: isTablet ? 1.2 : 3.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (isSelectionMode && selectedUsers.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () => _showBulkActionsDialog(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.bolt),
        label: Text('Acciones (${selectedUsers.length})'),
      );
    }
    return null;
  }

  bool _shouldShowActions(String estado) {
    return estado == 'PENDIENTE_APROBACION' || 
           estado == 'ACTIVA' || 
           estado == 'SUSPENDIDA';
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedUsers.clear();
      }
    });
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    // TODO: Implementar modal de detalles de usuario
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['nombre_completo'] ?? 'Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email'] ?? 'N/A'}'),
            Text('Estado: ${user['estado'] ?? 'N/A'}'),
            Text('Rol: ${user['roles']['nombre'] ?? 'N/A'}'),
            if (user['created_at'] != null)
              Text('Registro: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(user['created_at']))}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atajos de Teclado'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('F5 - Actualizar'),
            Text('Ctrl+A - Seleccionar todos'),
            Text('Alt+A - Aprobar seleccionados'),
            Text('Alt+R - Rechazar seleccionados'),
            Text('Alt+S - Suspender seleccionados'),
            Text('Escape - Salir selección masiva'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Acciones individuales
  void _showApproveDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprobar Usuario'),
        content: const Text('¿Está seguro que desea aprobar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserManagementBloc>().add(ApproveUser(userId: userId));
            },
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String userId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Está seguro que desea rechazar este usuario?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserManagementBloc>().add(
                RejectUser(userId: userId, reason: reasonController.text.trim()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(BuildContext context, String userId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspender Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Está seguro que desea suspender este usuario?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo de la suspensión (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserManagementBloc>().add(
                SuspendUser(userId: userId, reason: reasonController.text.trim()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
            child: const Text('Suspender'),
          ),
        ],
      ),
    );
  }

  void _showReactivateDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivar Usuario'),
        content: const Text('¿Está seguro que desea reactivar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserManagementBloc>().add(ReactivateUser(userId: userId));
            },
            child: const Text('Reactivar'),
          ),
        ],
      ),
    );
  }

  // Acciones masivas
  void _showBulkActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acciones Masivas (${selectedUsers.length} usuarios)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Aprobar seleccionados'),
              onTap: () {
                Navigator.pop(context);
                _bulkApprove(selectedUsers.toList());
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Rechazar seleccionados'),
              onTap: () {
                Navigator.pop(context);
                _bulkReject(selectedUsers.toList());
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause_circle, color: Colors.orange),
              title: const Text('Suspender seleccionados'),
              onTap: () {
                Navigator.pop(context);
                _bulkSuspend(selectedUsers.toList());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _bulkApprove(List<String> userIds) {
    // TODO: Implementar con Edge Function
    for (String userId in userIds) {
      context.read<UserManagementBloc>().add(ApproveUser(userId: userId));
    }
    setState(() {
      selectedUsers.clear();
      isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aprobando ${userIds.length} usuarios...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _bulkReject(List<String> userIds) {
    // TODO: Implementar con Edge Function
    for (String userId in userIds) {
      context.read<UserManagementBloc>().add(RejectUser(userId: userId));
    }
    setState(() {
      selectedUsers.clear();
      isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rechazando ${userIds.length} usuarios...'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _bulkSuspend(List<String> userIds) {
    // TODO: Implementar con Edge Function
    for (String userId in userIds) {
      context.read<UserManagementBloc>().add(SuspendUser(userId: userId));
    }
    setState(() {
      selectedUsers.clear();
      isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suspendiendo ${userIds.length} usuarios...'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}