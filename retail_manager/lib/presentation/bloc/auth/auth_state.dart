part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final String role;
  final String estado;

  const AuthSuccess({
    required this.user,
    required this.role,
    required this.estado,
  });

  @override
  List<Object?> get props => [user, role, estado];
}

class AuthRegisterSuccess extends AuthState {
  final String message;
  final String email;

  const AuthRegisterSuccess({
    required this.message,
    required this.email,
  });

  @override
  List<Object?> get props => [message, email];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class AuthUnauthenticated extends AuthState {}

class AuthPendingVerification extends AuthState {
  final String email;
  final String estado;

  const AuthPendingVerification({
    required this.email,
    required this.estado,
  });

  @override
  List<Object?> get props => [email, estado];
}

class AuthEmailResent extends AuthState {
  final String message;

  const AuthEmailResent({required this.message});

  @override
  List<Object?> get props => [message];
}