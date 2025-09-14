# Módulo de Autenticación - Sistema Retail Manager

## Descripción General
Sistema de autenticación completo para gestión retail con roles jerárquicos, multi-tenant y políticas de seguridad RLS.

## Arquitectura
- **Frontend**: Flutter con go_router para navegación protegida
- **Backend**: Supabase Auth + RLS policies
- **Base de Datos**: PostgreSQL con tabla `usuarios` extendida

## Modelos de Datos

### Usuario (auth.users + public.usuarios)
```sql
-- Extiende auth.users de Supabase
CREATE TABLE public.usuarios (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    nombre_completo TEXT NOT NULL,
    rol rol_usuario NOT NULL DEFAULT 'VENDEDOR',
    estado estado_usuario NOT NULL DEFAULT 'PENDIENTE_APROBACION',
    tienda_asignada UUID REFERENCES public.tiendas(id),
    fecha_creacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_suspension TIMESTAMPTZ,
    fecha_reactivacion TIMESTAMPTZ,
    motivo_rechazo TEXT,
    motivo_suspension TEXT,
    activo BOOLEAN DEFAULT FALSE
);
```

### Roles del Sistema
```dart
enum RolUsuario {
  ADMIN,           // Acceso total al sistema
  GERENTE,         // Gestión de tiendas asignadas
  SUPERVISOR,      // Supervisión de vendedores
  VENDEDOR,        // Operaciones de venta
  CLIENTE          // Solo consultas básicas
}

enum EstadoUsuario {
  PENDIENTE_APROBACION,
  ACTIVO,
  SUSPENDIDO,
  RECHAZADO
}
```

## Flujo de Autenticación

### 1. Registro de Usuario
```dart
// Proceso completo de registro
1. Usuario completa formulario registro
2. Supabase Auth crea entrada en auth.users
3. Trigger automático crea entrada en public.usuarios (estado: PENDIENTE_APROBACION)
4. Admin debe aprobar usuario para activar acceso
5. Email de confirmación enviado al usuario
```

### 2. Login y Navegación
```dart
// Validación de acceso por rutas
Map<String, List<RolUsuario>> rutasProtegidas = {
  '/admin': [RolUsuario.ADMIN],
  '/dashboard': [RolUsuario.ADMIN, RolUsuario.GERENTE, RolUsuario.SUPERVISOR],
  '/products': [RolUsuario.ADMIN, RolUsuario.GERENTE, RolUsuario.SUPERVISOR, RolUsuario.VENDEDOR],
  '/sales': [RolUsuario.VENDEDOR, RolUsuario.SUPERVISOR, RolUsuario.GERENTE],
  '/reports': [RolUsuario.ADMIN, RolUsuario.GERENTE],
};
```

## Políticas RLS (Row Level Security)

### Usuarios
```sql
-- Solo admins pueden ver todos los usuarios
CREATE POLICY "Admins can view all users" ON public.usuarios
FOR SELECT USING (
    EXISTS(SELECT 1 FROM public.usuarios WHERE id = auth.uid() AND rol = 'ADMIN')
);

-- Usuarios pueden ver su propio perfil
CREATE POLICY "Users can view own profile" ON public.usuarios
FOR SELECT USING (id = auth.uid());

-- Gerentes pueden ver usuarios de sus tiendas
CREATE POLICY "Managers can view store users" ON public.usuarios
FOR SELECT USING (
    tienda_asignada IN (
        SELECT id FROM public.tiendas
        WHERE manager_id = auth.uid()
    )
);
```

## Componentes Flutter

### AuthGuard
```dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<RolUsuario> rolesPermitidos;

  const AuthGuard({
    required this.child,
    required this.rolesPermitidos,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const LoginPage();
        }

        if (!rolesPermitidos.contains(state.usuario.rol)) {
          return const UnauthorizedPage();
        }

        return child;
      },
    );
  }
}
```

### LoginForm
```dart
class LoginForm extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: EmailValidator.validate,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            validator: PasswordValidator.validate,
            decoration: InputDecoration(labelText: 'Contraseña'),
          ),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
```

## Estados BLoC

### AuthBloc
```dart
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}
class LogoutRequested extends AuthEvent {}
class AuthStatusChanged extends AuthEvent {
  final AuthChangeEvent authChangeEvent;
}

abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final Usuario usuario;
  AuthAuthenticated(this.usuario);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

## Validaciones

### Frontend (Flutter)
```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida';
    }
    if (value.length < 8) {
      return 'Contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }
}
```

### Backend (RLS + Triggers)
```sql
-- Validar email único
CREATE UNIQUE INDEX unique_usuario_email ON public.usuarios(LOWER(email));

-- Validar rol válido
ALTER TABLE public.usuarios
ADD CONSTRAINT check_rol_valido
CHECK (rol IN ('ADMIN', 'GERENTE', 'SUPERVISOR', 'VENDEDOR', 'CLIENTE'));

-- Auto-sync con auth.users
CREATE OR REPLACE FUNCTION sync_user_email()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.email IS DISTINCT FROM NEW.email THEN
    UPDATE public.usuarios
    SET email = NEW.email
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_email_trigger
AFTER UPDATE OF email ON auth.users
FOR EACH ROW EXECUTE FUNCTION sync_user_email();
```

## Navegación Responsiva

### Rutas por Dispositivo
```dart
// Desktop: Sidebar con navegación completa
if (width >= 1200) {
  return Scaffold(
    body: Row(
      children: [
        NavigationSidebar(usuario: state.usuario),
        Expanded(child: child),
      ],
    ),
  );
}

// Tablet: NavigationRail colapsible
else if (width >= 768) {
  return Scaffold(
    body: Row(
      children: [
        NavigationRail(
          extended: _isExtended,
          destinations: _buildDestinations(state.usuario.rol),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

// Mobile: Drawer + BottomNavigation
else {
  return Scaffold(
    drawer: NavigationDrawer(usuario: state.usuario),
    body: child,
    bottomNavigationBar: RoleBasedBottomNavigation(rol: state.usuario.rol),
  );
}
```

## Manejo de Errores

### Errores Comunes
```dart
class AuthExceptions {
  static const String invalidCredentials = 'Credenciales inválidas';
  static const String userNotApproved = 'Usuario pendiente de aprobación';
  static const String userSuspended = 'Usuario suspendido';
  static const String sessionExpired = 'Sesión expirada';
  static const String insufficientPermissions = 'Permisos insuficientes';

  static String getLocalizedMessage(String error) {
    switch (error) {
      case 'Invalid login credentials':
        return invalidCredentials;
      case 'User not confirmed':
        return 'Email no verificado';
      case 'Too many requests':
        return 'Demasiados intentos. Intente más tarde';
      default:
        return 'Error de autenticación: $error';
    }
  }
}
```

## Configuración de Supabase

### Variables de Entorno
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321', // Local development
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key', // Local development
  );
}
```

## Testing

### Test Cases Críticos
```dart
void main() {
  group('AuthBloc Tests', () {
    test('login exitoso actualiza estado a authenticated', () async {
      // Given
      final authBloc = AuthBloc();

      // When
      authBloc.add(LoginRequested(
        email: 'admin@test.com',
        password: 'admin123',
      ));

      // Then
      expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ]),
      );
    });

    test('login con credenciales inválidas retorna error', () async {
      // Test de credenciales inválidas
    });

    test('usuario suspendido no puede acceder', () async {
      // Test de usuario suspendido
    });
  });
}
```

## Consideraciones de Seguridad

1. **Passwords**: Mínimo 8 caracteres, validación en frontend y backend
2. **Sesiones**: Auto-logout después de inactividad
3. **RLS**: Todas las tablas deben tener políticas RLS habilitadas
4. **Audit Trail**: Log de todos los cambios de permisos y estados
5. **Rate Limiting**: Supabase Auth maneja automáticamente
6. **Email Verification**: Obligatorio antes de activar cuenta

## Comandos Útiles

### Supabase CLI
```bash
# Ver usuarios registrados
supabase db shell
SELECT u.id, u.email, p.nombre_completo, p.rol, p.estado
FROM auth.users u
JOIN public.usuarios p ON u.id = p.id;

# Activar usuario pendiente
UPDATE public.usuarios
SET estado = 'ACTIVO', activo = true
WHERE email = 'usuario@email.com';
```

### Flutter
```bash
# Generar modelos de datos
flutter packages pub run build_runner build

# Ejecutar tests de autenticación
flutter test test/auth/
```