part of 'user_management_bloc.dart';

sealed class UserManagementState extends Equatable {
  const UserManagementState();
  
  @override
  List<Object> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UserManagementSuccess extends UserManagementState {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> filteredUsers;
  final String? currentFilter;
  final String? currentRoleFilter;
  final Map<String, dynamic>? metrics;

  const UserManagementSuccess({
    required this.users,
    required this.filteredUsers,
    this.currentFilter,
    this.currentRoleFilter,
    this.metrics,
  });

  @override
  List<Object> get props => [
    users,
    filteredUsers,
    currentFilter ?? '',
    currentRoleFilter ?? '',
    metrics ?? {},
  ];

  UserManagementSuccess copyWith({
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? filteredUsers,
    String? currentFilter,
    String? currentRoleFilter,
    Map<String, dynamic>? metrics,
  }) {
    return UserManagementSuccess(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      currentFilter: currentFilter ?? this.currentFilter,
      currentRoleFilter: currentRoleFilter ?? this.currentRoleFilter,
      metrics: metrics ?? this.metrics,
    );
  }
}

class UserManagementActionSuccess extends UserManagementState {
  final String message;
  
  const UserManagementActionSuccess({required this.message});
  
  @override
  List<Object> get props => [message];
}

class UserManagementFailure extends UserManagementState {
  final String error;
  
  const UserManagementFailure({required this.error});
  
  @override
  List<Object> get props => [error];
}