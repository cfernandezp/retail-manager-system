import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase;
  final Dio _dio;

  AuthBloc({
    required SupabaseClient supabase,
    required Dio dio,
  })  : _supabase = supabase,
        _dio = dio,
        super(AuthInitial()) {
    on<AuthLogin>(_onLogin);
    on<AuthRegister>(_onRegister);
    on<AuthLogout>(_onLogout);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthEmailVerified>(_onEmailVerified);
    on<AuthResendVerificationEmail>(_onResendVerificationEmail);

    // Verificar estado inicial
    add(AuthCheckStatus());
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      // 1. Intentar login con Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user == null) {
        emit(const AuthFailure(error: 'Credenciales inválidas'));
        return;
      }

      // 2. Obtener datos del usuario desde la tabla usuarios
      final userData = await _supabase
          .from('usuarios')
          .select('*')
          .eq('id', response.user!.id)
          .single();

      if (userData == null) {
        emit(const AuthFailure(error: 'Usuario no encontrado en la base de datos'));
        return;
      }

      // 3. Obtener datos del rol por separado
      final roleData = await _supabase
          .from('roles')
          .select('nombre, descripcion, permisos')
          .eq('id', userData['rol_id'])
          .single();

      if (roleData == null) {
        emit(const AuthFailure(error: 'Rol de usuario no encontrado'));
        return;
      }

      // 4. Verificar estado de la cuenta
      final estado = userData['estado'] as String? ?? 'INACTIVA';
      final emailVerificado = userData['email_verificado'] as bool? ?? false;

      if (!emailVerificado) {
        emit(AuthPendingVerification(
          email: event.email,
          estado: 'PENDIENTE_EMAIL',
        ));
        return;
      }

      if (estado != 'ACTIVA') {
        String mensaje;
        switch (estado) {
          case 'PENDIENTE_APROBACION':
            mensaje = 'Su cuenta está pendiente de aprobación por un administrador';
            break;
          case 'SUSPENDIDA':
            mensaje = 'Su cuenta ha sido suspendida. Contacte al administrador';
            break;
          case 'RECHAZADA':
            mensaje = 'Su solicitud de cuenta ha sido rechazada';
            break;
          default:
            mensaje = 'Su cuenta no está activa. Contacte al administrador';
        }

        emit(AuthPendingVerification(
          email: event.email,
          estado: estado,
        ));
        return;
      }

      // 5. Actualizar último acceso
      await _supabase
          .from('usuarios')
          .update({
            'ultimo_acceso': DateTime.now().toIso8601String(),
            'intentos_fallidos': 0,
          })
          .eq('id', response.user!.id);

      // 6. Login exitoso
      emit(AuthSuccess(
        user: response.user!,
        role: roleData['nombre'] as String? ?? 'DESCONOCIDO',
        estado: estado,
      ));

    } catch (e) {
      print('Error en login: $e'); // Debug log
      
      if (e is AuthException) {
        print('AuthException: ${e.message}'); // Debug log
        
        // Verificar si es por email no confirmado
        if (e.message.toLowerCase().contains('email not confirmed') || 
            e.message.toLowerCase().contains('email_not_confirmed')) {
          emit(AuthPendingVerification(
            email: event.email,
            estado: 'PENDIENTE_EMAIL',
          ));
          return;
        }
        
        String errorMessage = 'Error de conexión';
        switch (e.message.toLowerCase()) {
          case 'invalid login credentials':
            errorMessage = 'Credenciales inválidas';
            break;
          default:
            errorMessage = e.message;
        }
        emit(AuthFailure(error: errorMessage));
      } else {
        emit(AuthFailure(error: 'Error de conexión: $e'));
      }
    }
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      // Validaciones básicas
      if (!_isValidEmail(event.email)) {
        emit(const AuthFailure(error: 'Formato de email inválido'));
        return;
      }

      if (!_isValidPassword(event.password)) {
        emit(const AuthFailure(error: 'La contraseña debe tener al menos 8 caracteres, incluir una mayúscula y un número'));
        return;
      }

      // 1. Registrar en auth.users usando Supabase
      final authResponse = await _supabase.auth.signUp(
        email: event.email,
        password: event.password,
      );

      if (authResponse.user == null) {
        emit(const AuthFailure(error: 'Error al crear la cuenta de usuario'));
        return;
      }

      // 2. Insertar en tabla usuarios
      await _supabase.from('usuarios').insert({
        'id': authResponse.user!.id,
        'email': event.email,
        'nombre_completo': event.nombreCompleto,
        'rol_id': await _getOperarioRoleId(),
        'estado': 'PENDIENTE_APROBACION',
        'email_verificado': false,
      });

      emit(AuthRegisterSuccess(
        message: 'Usuario registrado exitosamente. Pendiente de aprobación por administrador.',
        email: event.email,
      ));

    } catch (e) {
      String errorMessage = 'Error de conexión';

      if (e is PostgrestException) {
        errorMessage = 'Error de base de datos: ${e.message}';
      } else if (e is AuthException) {
        errorMessage = 'Error de autenticación: ${e.message}';
      }

      emit(AuthFailure(error: errorMessage));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    try {
      await _supabase.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthFailure(error: 'Error cerrando sesión'));
    }
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Verificar datos del usuario
      final userData = await _supabase
          .from('usuarios')
          .select('''
            *,
            roles!inner(
              nombre,
              descripcion,
              permisos
            )
          ''')
          .eq('id', currentUser.id)
          .single();

      final estado = userData['estado'] as String? ?? 'INACTIVA';

      if (estado == 'ACTIVA') {
        final roleName = userData['roles'] != null ? 
          userData['roles']['nombre'] as String? ?? 'DESCONOCIDO' : 
          'DESCONOCIDO';
          
        emit(AuthSuccess(
          user: currentUser,
          role: roleName,
          estado: estado,
        ));
      } else {
        emit(AuthPendingVerification(
          email: currentUser.email ?? '',
          estado: estado,
        ));
      }

    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onEmailVerified(AuthEmailVerified event, Emitter<AuthState> emit) async {
    try {
      // Actualizar estado a PENDIENTE_APROBACION
      await _supabase
          .from('usuarios')
          .update({
            'email_verificado': true,
            'estado': 'PENDIENTE_APROBACION',
          })
          .eq('id', event.userId);

      // Verificar estado actualizado
      add(AuthCheckStatus());

    } catch (e) {
      emit(const AuthFailure(error: 'Error verificando email'));
    }
  }

  // Validaciones auxiliares
  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Al menos 8 caracteres, 1 mayúscula, 1 número
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  Future<String> _getOperarioRoleId() async {
    final role = await _supabase
        .from('roles')
        .select('id')
        .eq('nombre', 'OPERARIO')
        .single();
    return role['id'];
  }

  Future<void> _onResendVerificationEmail(AuthResendVerificationEmail event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      print('Intentando reenviar email a: ${event.email}'); // Debug log
      
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: event.email,
      );
      
      print('Email reenviado exitosamente'); // Debug log
      emit(AuthEmailResent(message: 'Email de verificación reenviado exitosamente'));
      
      // Regresar al estado de pending después de un momento
      Future.delayed(const Duration(seconds: 2), () {
        add(AuthCheckStatus());
      });
      
    } catch (e) {
      print('Error reenviando email: $e'); // Debug log
      String errorMessage = 'Error enviando email de verificación: $e';
      
      if (e is AuthException) {
        errorMessage = 'Error de autenticación: ${e.message}';
      } else if (e is PostgrestException) {
        errorMessage = 'Error de base de datos: ${e.message}';
      }
      
      emit(AuthFailure(error: errorMessage));
    }
  }
}