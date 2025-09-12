import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final SupabaseClient _supabase;

  UserManagementBloc({
    required SupabaseClient supabase,
  }) : _supabase = supabase,
       super(UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<ApproveUser>(_onApproveUser);
    on<RejectUser>(_onRejectUser);
    on<SuspendUser>(_onSuspendUser);
    on<ReactivateUser>(_onReactivateUser);
    on<FilterUsers>(_onFilterUsers);
    on<BulkApproveUsers>(_onBulkApproveUsers);
    on<BulkRejectUsers>(_onBulkRejectUsers);
    on<BulkSuspendUsers>(_onBulkSuspendUsers);
    on<LoadMetrics>(_onLoadMetrics);
    on<RefreshMetrics>(_onRefreshMetrics);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      // Usar la vista optimizada en lugar de la consulta manual
      final usersData = await _supabase
          .from('usuarios_lista_optimizada')
          .select('*')
          .order('priority_score', ascending: false)
          .order('created_at', ascending: false);

      final users = List<Map<String, dynamic>>.from(usersData);

      // También cargar métricas del dashboard
      final metricsResponse = await _supabase.rpc('get_dashboard_metrics');
      final metrics = metricsResponse as Map<String, dynamic>?;

      emit(UserManagementSuccess(
        users: users,
        filteredUsers: users,
        metrics: metrics,
      ));

    } catch (e) {
      emit(UserManagementFailure(error: 'Error cargando usuarios: $e'));
    }
  }

  Future<void> _onApproveUser(ApproveUser event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      await _supabase
          .from('usuarios')
          .update({
            'estado': 'ACTIVA',
            'fecha_aprobacion': DateTime.now().toIso8601String(),
          })
          .eq('id', event.userId);

      emit(const UserManagementActionSuccess(message: 'Usuario aprobado exitosamente'));
      
      add(const LoadUsers());

    } catch (e) {
      emit(UserManagementFailure(error: 'Error aprobando usuario: $e'));
    }
  }

  Future<void> _onRejectUser(RejectUser event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      await _supabase
          .from('usuarios')
          .update({
            'estado': 'RECHAZADA',
            'motivo_rechazo': event.reason,
            'fecha_rechazo': DateTime.now().toIso8601String(),
          })
          .eq('id', event.userId);

      emit(const UserManagementActionSuccess(message: 'Usuario rechazado'));
      
      add(const LoadUsers());

    } catch (e) {
      emit(UserManagementFailure(error: 'Error rechazando usuario: $e'));
    }
  }

  Future<void> _onSuspendUser(SuspendUser event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      await _supabase
          .from('usuarios')
          .update({
            'estado': 'SUSPENDIDA',
            'motivo_suspension': event.reason,
            'fecha_suspension': DateTime.now().toIso8601String(),
          })
          .eq('id', event.userId);

      emit(const UserManagementActionSuccess(message: 'Usuario suspendido'));
      
      add(const LoadUsers());

    } catch (e) {
      emit(UserManagementFailure(error: 'Error suspendiendo usuario: $e'));
    }
  }

  Future<void> _onReactivateUser(ReactivateUser event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      await _supabase
          .from('usuarios')
          .update({
            'estado': 'ACTIVA',
            'motivo_suspension': null,
            'fecha_suspension': null,
            'fecha_reactivacion': DateTime.now().toIso8601String(),
          })
          .eq('id', event.userId);

      emit(const UserManagementActionSuccess(message: 'Usuario reactivado exitosamente'));
      
      add(const LoadUsers());

    } catch (e) {
      emit(UserManagementFailure(error: 'Error reactivando usuario: $e'));
    }
  }

  Future<void> _onFilterUsers(FilterUsers event, Emitter<UserManagementState> emit) async {
    final currentState = state;
    if (currentState is! UserManagementSuccess) return;

    var filteredUsers = currentState.users.where((user) {
      final matchesEstado = event.estado == null || 
                           event.estado == 'TODOS' || 
                           user['estado'] == event.estado;
                           
      final matchesRol = event.rol == null || 
                        event.rol == 'TODOS' || 
                        user['rol_nombre'] == event.rol;

      return matchesEstado && matchesRol;
    }).toList();

    emit(currentState.copyWith(
      filteredUsers: filteredUsers,
      currentFilter: event.estado,
      currentRoleFilter: event.rol,
    ));
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      // Usar la función de búsqueda optimizada
      final searchResults = await _supabase.rpc('search_usuarios', params: {
        'search_term': event.searchTerm,
        'limite': event.limit,
        'offset_val': event.offset,
        'filtro_estado': event.estado,
        'filtro_rol': event.rol,
        'filtro_tienda': event.tiendaId,
      });

      final users = List<Map<String, dynamic>>.from(searchResults);

      emit(UserManagementSuccess(
        users: users,
        filteredUsers: users,
        currentFilter: event.estado,
        currentRoleFilter: event.rol,
      ));

    } catch (e) {
      emit(UserManagementFailure(error: 'Error en búsqueda: $e'));
    }
  }

  Future<void> _onBulkApproveUsers(BulkApproveUsers event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      // Llamar a Edge Function para aprobación masiva
      final response = await _supabase.functions.invoke(
        'user-operations/bulk-approve',
        body: {
          'user_ids': event.userIds,
          'approval_reason': event.reason,
        },
      );

      if (response.data['success'] == true) {
        emit(UserManagementActionSuccess(
          message: 'Aprobación masiva completada: ${response.data['affected_users']} usuarios',
        ));
        add(const LoadUsers());
      } else {
        throw Exception(response.data['error'] ?? 'Error en aprobación masiva');
      }

    } catch (e) {
      emit(UserManagementFailure(error: 'Error en aprobación masiva: $e'));
    }
  }

  Future<void> _onBulkRejectUsers(BulkRejectUsers event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      final response = await _supabase.functions.invoke(
        'user-operations/bulk-reject',
        body: {
          'user_ids': event.userIds,
          'reason': event.reason,
        },
      );

      if (response.data['success'] == true) {
        emit(UserManagementActionSuccess(
          message: 'Rechazo masivo completado: ${response.data['affected_users']} usuarios',
        ));
        add(const LoadUsers());
      } else {
        throw Exception(response.data['error'] ?? 'Error en rechazo masivo');
      }

    } catch (e) {
      emit(UserManagementFailure(error: 'Error en rechazo masivo: $e'));
    }
  }

  Future<void> _onBulkSuspendUsers(BulkSuspendUsers event, Emitter<UserManagementState> emit) async {
    try {
      emit(UserManagementLoading());

      final response = await _supabase.functions.invoke(
        'user-operations/bulk-suspend',
        body: {
          'user_ids': event.userIds,
          'reason': event.reason,
          'duration_days': event.durationDays,
        },
      );

      if (response.data['success'] == true) {
        emit(UserManagementActionSuccess(
          message: 'Suspensión masiva completada: ${response.data['affected_users']} usuarios',
        ));
        add(const LoadUsers());
      } else {
        throw Exception(response.data['error'] ?? 'Error en suspensión masiva');
      }

    } catch (e) {
      emit(UserManagementFailure(error: 'Error en suspensión masiva: $e'));
    }
  }

  Future<void> _onLoadMetrics(LoadMetrics event, Emitter<UserManagementState> emit) async {
    try {
      final metricsResponse = await _supabase.functions.invoke('user-operations/metrics');
      final metrics = metricsResponse.data as Map<String, dynamic>;

      final currentState = state;
      if (currentState is UserManagementSuccess) {
        emit(currentState.copyWith(metrics: metrics));
      }
    } catch (e) {
      // No emitir error para métricas, solo log
      print('Error cargando métricas: $e');
    }
  }

  Future<void> _onRefreshMetrics(RefreshMetrics event, Emitter<UserManagementState> emit) async {
    try {
      // Refrescar vista materializada
      await _supabase.rpc('refresh_user_metrics');
      
      // Recargar métricas
      add(const LoadMetrics());
    } catch (e) {
      print('Error refrescando métricas: $e');
    }
  }
}