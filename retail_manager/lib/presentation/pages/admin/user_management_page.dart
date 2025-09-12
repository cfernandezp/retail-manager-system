import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/user_management/user_management_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/corporate_button.dart';
import '../../widgets/admin/user_metrics_dashboard.dart';
import '../../widgets/admin/enhanced_filters.dart';
import '../../widgets/admin/keyboard_shortcuts_help.dart';
import '../../widgets/admin/selection_toolbar.dart';
import '../../widgets/admin/enhanced_user_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String? selectedEstado = 'TODOS';
  String? selectedRol = 'TODOS';
  String searchQuery = '';
  bool showOnlyUrgent = false;
  bool selectionMode = false;
  Set<String> selectedUsers = {};
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<UserManagementBloc>().add(const LoadUsers());
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = AppTheme.isTablet(size.width);
    final isDesktop = AppTheme.isDesktop(size.width);

    return KeyboardShortcutsWrapper(
      onSelectionToggle: () {
        setState(() {
          selectionMode = !selectionMode;
          if (!selectionMode) {
            selectedUsers.clear();
          }
        });
      },
      onSelectAll: () => _selectAllVisible(context.read<UserManagementBloc>().state),
      onCancelSelection: () {
        setState(() {
          selectionMode = false;
          selectedUsers.clear();
        });
      },
      onRefresh: () {
        context.read<UserManagementBloc>().add(const LoadUsers());
      },
      onFocusSearch: () {
        _searchFocusNode.requestFocus();
      },
      child: Scaffold(
      appBar: AppBar(
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
          if (selectionMode)
            TextButton(
              onPressed: () {
                setState(() {
                  selectionMode = false;
                  selectedUsers.clear();
                });
              },
              child: const Text('Cancelar'),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() {
                  selectionMode = true;
                });
              },
              tooltip: 'Selección múltiple',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<UserManagementBloc>().add(const LoadUsers());
              },
            ),
          ],
        ],
      ),
      body: BlocConsumer<UserManagementBloc, UserManagementState>(
        listener: (context, state) {
          if (state is UserManagementActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
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
              // Dashboard de métricas mejorado
              if (state is UserManagementSuccess && !selectionMode)
                UserMetricsDashboard(
                  metrics: state.metrics,
                  onRefresh: () {
                    context.read<UserManagementBloc>().add(const RefreshMetrics());
                  },
                ),
              
              // Filtros mejorados
              if (!selectionMode)
                EnhancedFilters(
                  selectedEstado: selectedEstado,
                  selectedRol: selectedRol,
                  searchQuery: searchQuery,
                  showOnlyUrgent: showOnlyUrgent,
                  searchFocusNode: _searchFocusNode,
                  onEstadoChanged: (value) {
                    setState(() {
                      selectedEstado = value;
                    });
                    _applyFilters();
                  },
                  onRolChanged: (value) {
                    setState(() {
                      selectedRol = value;
                    });
                    _applyFilters();
                  },
                  onSearchChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _applyFilters();
                  },
                  onUrgentToggle: (value) {
                    setState(() {
                      showOnlyUrgent = value;
                    });
                    _applyFilters();
                  },
                  onClearFilters: () {
                    setState(() {
                      selectedEstado = 'TODOS';
                      selectedRol = 'TODOS';
                      searchQuery = '';
                      showOnlyUrgent = false;
                    });
                    context.read<UserManagementBloc>().add(const LoadUsers());
                  },
                ),
              
              // Atajos de teclado (solo en tablet/desktop)
              if (!selectionMode && (isTablet || isDesktop))
                const KeyboardShortcutsHelp(),
              
              // Toolbar de selección
              SelectionToolbar(
                selectedCount: selectedUsers.length,
                onSelectAll: () => _selectAllVisible(state),
                onClearSelection: () {
                  setState(() {
                    selectedUsers.clear();
                  });
                },
                onApproveSelected: _getSelectedCanBeApproved(state) ? () => _approveSelected() : null,
                onRejectSelected: _getSelectedCanBeRejected(state) ? () => _rejectSelected() : null,
                onSuspendSelected: _getSelectedCanBeSuspended(state) ? () => _suspendSelected() : null,
                canApproveSelected: _getSelectedCanBeApproved(state),
                canRejectSelected: _getSelectedCanBeRejected(state),
                canSuspendSelected: _getSelectedCanBeSuspended(state),
              ),
              
              // Lista de usuarios
              Expanded(
                child: _buildUsersList(context, state, isTablet),
              ),
            ],
          );
        },
      ),
    ),
    );
  }


  Widget _buildUsersList(BuildContext context, UserManagementState state, bool isTablet) {
    if (state is UserManagementLoading) {
      return _buildSkeletonLoading(context, isTablet);
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
            Text(
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
              onPressed: () {
                context.read<UserManagementBloc>().add(const LoadUsers());
              },
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

      // Aplicar búsqueda adicional si existe
      var displayUsers = state.filteredUsers;
      if (searchQuery.isNotEmpty) {
        displayUsers = displayUsers.where((user) {
          final nombre = (user['nombre_completo'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          return nombre.contains(searchQuery.toLowerCase()) || 
                 email.contains(searchQuery.toLowerCase());
        }).toList();
      }
      
      if (showOnlyUrgent) {
        displayUsers = displayUsers.where((user) {
          if (user['estado'] == 'PENDIENTE_APROBACION' && user['created_at'] != null) {
            final createdAt = DateTime.parse(user['created_at']);
            final daysSinceCreated = DateTime.now().difference(createdAt).inDays;
            return daysSinceCreated > 1;
          }
          return false;
        }).toList();
      }

      final size = MediaQuery.of(context).size;
      final crossAxisCount = AppTheme.getCrossAxisCount(size.width);
      
      if (crossAxisCount > 1 && displayUsers.length > 2) {
        // Grid layout para tablet/desktop con virtual scrolling optimizado
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: AppTheme.isDesktop(size.width) ? 1.4 : 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          // Optimizaciones de rendimiento
          cacheExtent: 1000,
          itemCount: displayUsers.length,
          itemBuilder: (context, index) {
            final user = displayUsers[index];
            return _buildEnhancedUserCard(user, !AppTheme.isMobile(size.width));
          },
        );
      } else {
        // Lista vertical para móvil o pocos usuarios con lazy loading
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          // Optimizaciones de rendimiento
          cacheExtent: 1000,
          itemExtent: 200, // Altura fija para mejor rendimiento
          itemCount: displayUsers.length,
          itemBuilder: (context, index) {
            final user = displayUsers[index];
            return _buildEnhancedUserCard(user, !AppTheme.isMobile(size.width));
          },
        );
      }
    }

    return const SizedBox();
  }


  String _getDisplayText(String value) {
    switch (value) {
      case 'TODOS': return 'Todos';
      case 'PENDIENTE_APROBACION': return 'Pendiente aprobación';
      case 'ACTIVA': return 'Activa';
      case 'SUSPENDIDA': return 'Suspendida';
      case 'RECHAZADA': return 'Rechazada';
      case 'SUPER_ADMIN': return 'Super Admin';
      case 'ADMIN': return 'Admin';
      case 'VENDEDOR': return 'Vendedor';
      case 'OPERARIO': return 'Operario';
      default: return value;
    }
  }

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

  // Nuevos métodos para la funcionalidad mejorada
  Widget _buildEnhancedUserCard(Map<String, dynamic> user, bool isTablet) {
    final userId = user['id'] as String;
    final isSelected = selectedUsers.contains(userId);
    
    return EnhancedUserCard(
      user: user,
      isSelected: isSelected,
      selectionMode: selectionMode,
      isTablet: isTablet,
      onTap: () => _showUserDetails(user),
      onSelectionToggle: () {
        setState(() {
          if (isSelected) {
            selectedUsers.remove(userId);
          } else {
            selectedUsers.add(userId);
          }
        });
      },
      onActionPressed: (action) => _handleUserAction(action, userId),
    );
  }

  void _applyFilters() {
    context.read<UserManagementBloc>().add(
      FilterUsers(estado: selectedEstado, rol: selectedRol),
    );
  }

  void _selectAllVisible(UserManagementState state) {
    if (state is UserManagementSuccess) {
      setState(() {
        selectedUsers.addAll(
          state.filteredUsers.map((user) => user['id'] as String),
        );
      });
    }
  }

  bool _getSelectedCanBeApproved(UserManagementState state) {
    if (state is! UserManagementSuccess) return false;
    
    return selectedUsers.any((userId) {
      final user = state.users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );
      return user['estado'] == 'PENDIENTE_APROBACION';
    });
  }

  bool _getSelectedCanBeRejected(UserManagementState state) {
    if (state is! UserManagementSuccess) return false;
    
    return selectedUsers.any((userId) {
      final user = state.users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );
      return user['estado'] == 'PENDIENTE_APROBACION';
    });
  }

  bool _getSelectedCanBeSuspended(UserManagementState state) {
    if (state is! UserManagementSuccess) return false;
    
    return selectedUsers.any((userId) {
      final user = state.users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );
      return user['estado'] == 'ACTIVA';
    });
  }

  void _approveSelected() {
    _showMassActionDialog(
      'Aprobar Usuarios Masivamente',
      '¿Está seguro que desea aprobar ${selectedUsers.length} usuarios seleccionados?\n\nEsta acción utilizará la función optimizada para procesar todos los usuarios de una vez.',
      () {
        // Usar Edge Function para aprobación masiva
        context.read<UserManagementBloc>().add(
          BulkApproveUsers(
            userIds: selectedUsers.toList(),
            reason: 'Aprobación masiva desde panel administrativo',
          ),
        );
        setState(() {
          selectedUsers.clear();
          selectionMode = false;
        });
      },
    );
  }

  void _rejectSelected() {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazo Masivo de Usuarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Está seguro que desea rechazar ${selectedUsers.length} usuarios seleccionados?'),
            const SizedBox(height: 8),
            const Text(
              'Esta acción utilizará la función optimizada para procesar todos los usuarios de una vez.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo (requerido para operación masiva)',
                border: OutlineInputBorder(),
                hintText: 'Ej: Documentos incompletos, información incorrecta, etc.',
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
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debe proporcionar un motivo para el rechazo masivo'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              // Usar Edge Function para rechazo masivo
              context.read<UserManagementBloc>().add(
                BulkRejectUsers(
                  userIds: selectedUsers.toList(),
                  reason: reason,
                ),
              );
              setState(() {
                selectedUsers.clear();
                selectionMode = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Rechazar Todos'),
          ),
        ],
      ),
    );
  }

  void _suspendSelected() {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspender Usuarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Está seguro que desea suspender ${selectedUsers.length} usuarios seleccionados?'),
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
              for (final userId in selectedUsers) {
                context.read<UserManagementBloc>().add(
                  SuspendUser(userId: userId, reason: reasonController.text.trim()),
                );
              }
              setState(() {
                selectedUsers.clear();
                selectionMode = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
            child: const Text('Suspender'),
          ),
        ],
      ),
    );
  }

  void _showMassActionDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, String userId) {
    switch (action) {
      case 'approve':
        _showApproveDialog(context, userId);
        break;
      case 'reject':
        _showRejectDialog(context, userId);
        break;
      case 'suspend':
        _showSuspendDialog(context, userId);
        break;
      case 'reactivate':
        _showReactivateDialog(context, userId);
        break;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUserDetailsModal(user),
    );
  }

  Widget _buildUserDetailsModal(Map<String, dynamic> user) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Detalles del Usuario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Nombre completo', user['nombre_completo'] ?? 'N/A'),
                  _buildDetailItem('Email', user['email'] ?? 'N/A'),
                  _buildDetailItem('Estado', user['estado'] ?? 'N/A'),
                  _buildDetailItem('Rol', user['roles']['nombre'] ?? 'N/A'),
                  if (user['created_at'] != null)
                    _buildDetailItem(
                      'Fecha de registro',
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(user['created_at'])),
                    ),
                  if (user['fecha_aprobacion'] != null)
                    _buildDetailItem(
                      'Fecha de aprobación',
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(user['fecha_aprobacion'])),
                    ),
                  if (user['motivo_rechazo'] != null && user['motivo_rechazo'].toString().isNotEmpty)
                    _buildDetailItem('Motivo de rechazo', user['motivo_rechazo']),
                  if (user['motivo_suspension'] != null && user['motivo_suspension'].toString().isNotEmpty)
                    _buildDetailItem('Motivo de suspensión', user['motivo_suspension']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }

  // Skeleton loading optimizado
  Widget _buildSkeletonLoading(BuildContext context, bool isTablet) {
    final size = MediaQuery.of(context).size;
    final crossAxisCount = AppTheme.getCrossAxisCount(size.width);
    
    if (crossAxisCount > 1) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: AppTheme.isDesktop(size.width) ? 1.4 : 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6, // Mostrar 6 elementos skeleton
        itemBuilder: (context, index) => _buildSkeletonCard(),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8, // Mostrar 8 elementos skeleton
        itemBuilder: (context, index) => _buildSkeletonCard(),
      );
    }
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              // Avatar skeleton
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Text skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status badges skeleton
          Row(
            children: [
              Container(
                height: 28,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const Spacer(),
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metadata skeleton
          Container(
            height: 12,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}