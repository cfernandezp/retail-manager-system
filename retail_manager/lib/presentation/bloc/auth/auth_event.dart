part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthLogin({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegister extends AuthEvent {
  final String email;
  final String password;
  final String? nombreCompleto;

  const AuthRegister({
    required this.email,
    required this.password,
    this.nombreCompleto,
  });

  @override
  List<Object?> get props => [email, password, nombreCompleto];
}

class AuthLogout extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthEmailVerified extends AuthEvent {
  final String userId;

  const AuthEmailVerified({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AuthResendVerificationEmail extends AuthEvent {
  final String email;

  const AuthResendVerificationEmail({required this.email});

  @override
  List<Object?> get props => [email];
}