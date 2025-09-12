part of 'user_management_bloc.dart';

sealed class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object> get props => [];
}

class LoadUsers extends UserManagementEvent {
  const LoadUsers();
}

class ApproveUser extends UserManagementEvent {
  final String userId;
  
  const ApproveUser({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class RejectUser extends UserManagementEvent {
  final String userId;
  final String? reason;
  
  const RejectUser({required this.userId, this.reason});
  
  @override
  List<Object> get props => [userId, reason ?? ''];
}

class SuspendUser extends UserManagementEvent {
  final String userId;
  final String? reason;
  
  const SuspendUser({required this.userId, this.reason});
  
  @override
  List<Object> get props => [userId, reason ?? ''];
}

class ReactivateUser extends UserManagementEvent {
  final String userId;
  
  const ReactivateUser({required this.userId});
  
  @override
  List<Object> get props => [userId];
}

class FilterUsers extends UserManagementEvent {
  final String? estado;
  final String? rol;
  
  const FilterUsers({this.estado, this.rol});
  
  @override
  List<Object> get props => [estado ?? '', rol ?? ''];
}

class SearchUsers extends UserManagementEvent {
  final String? searchTerm;
  final String? estado;
  final String? rol;
  final String? tiendaId;
  final int limit;
  final int offset;
  
  const SearchUsers({
    this.searchTerm,
    this.estado,
    this.rol,
    this.tiendaId,
    this.limit = 20,
    this.offset = 0,
  });
  
  @override
  List<Object> get props => [
    searchTerm ?? '',
    estado ?? '',
    rol ?? '',
    tiendaId ?? '',
    limit,
    offset,
  ];
}

class BulkApproveUsers extends UserManagementEvent {
  final List<String> userIds;
  final String? reason;
  
  const BulkApproveUsers({required this.userIds, this.reason});
  
  @override
  List<Object> get props => [userIds, reason ?? ''];
}

class BulkRejectUsers extends UserManagementEvent {
  final List<String> userIds;
  final String reason;
  
  const BulkRejectUsers({required this.userIds, required this.reason});
  
  @override
  List<Object> get props => [userIds, reason];
}

class BulkSuspendUsers extends UserManagementEvent {
  final List<String> userIds;
  final String reason;
  final int? durationDays;
  
  const BulkSuspendUsers({
    required this.userIds,
    required this.reason,
    this.durationDays,
  });
  
  @override
  List<Object> get props => [userIds, reason, durationDays ?? 0];
}

class LoadMetrics extends UserManagementEvent {
  const LoadMetrics();
}

class RefreshMetrics extends UserManagementEvent {
  const RefreshMetrics();
}