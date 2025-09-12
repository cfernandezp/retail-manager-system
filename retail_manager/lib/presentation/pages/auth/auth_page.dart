import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/common/corporate_form_field.dart';
import '../../widgets/common/corporate_button.dart';
import '../../routes/app_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controladores para Login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  // Controladores para Registro
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreCompletoController = TextEditingController();

  // Form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {}); // Para actualizar los tabs visuales
    });
  }

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 500) {
      return baseSpacing * 0.75;
    } else if (screenWidth < 768) {
      return baseSpacing * 0.85;
    }
    return baseSpacing;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nombreCompletoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Fondo gris claro moderno
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Espaciado responsivo basado en el ancho de pantalla
              final isSmallScreen = constraints.maxWidth < 500;
              final isMediumScreen = constraints.maxWidth < 768;
              
              final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
              final cardPadding = isSmallScreen ? 24.0 : isMediumScreen ? 36.0 : 48.0;
              final cardMaxWidth = isSmallScreen ? double.infinity : isMediumScreen ? 480.0 : 500.0;
              
              return Container(
                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                margin: EdgeInsets.all(horizontalPadding),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Corporativo
                        _buildHeader(),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // Tabs
                        _buildTabs(),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        
                        // Forms
                        Flexible(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLoginForm(),
                              _buildRegisterForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Importadora Hiltex', // Título exacto de la imagen
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: const Color(0xFF1F2937), // Gris oscuro moderno
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _buildTabButton('Registro', 1)),
        Expanded(child: _buildTabButton('Ingresar', 0)),
      ],
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected 
                ? const Color(0xFF6366F1) // Azul como en la imagen
                : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF6366F1) // Azul cuando activo
                  : const Color(0xFF6B7280), // Gris cuando inactivo
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigateByRole(state.role);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is AuthPendingVerification) {
          _showPendingDialog(state.estado, state.email);
        } else if (state is AuthEmailResent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _loginFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenido', // Título exacto de la imagen
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 8)),
                Text(
                  'Ingrese sus credenciales para ingresar a la aplicación', // Descripción exacta
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 32)),
                
                CorporateFormField(
                  controller: _loginEmailController,
                  label: 'Email', // Label según la imagen
                  hintText: '',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 20)),
                
                CorporateFormField(
                  controller: _loginPasswordController,
                  label: 'Password', // Label según la imagen
                  hintText: '',
                  isPassword: true,
                  validator: (value) => value?.isEmpty ?? true 
                    ? 'La contraseña es requerida' 
                    : null,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 16)),

                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solo usuarios con cuentas aprobadas pueden acceder',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _getResponsiveSpacing(context, 32)),
                
                CorporateButton(
                  text: 'Ingresar',
                  isLoading: state is AuthLoading,
                  onPressed: _handleLogin,
                ),
                
                SizedBox(height: _getResponsiveSpacing(context, 16)),
                TextButton(
                  onPressed: () {
                    // TODO: Implementar recuperación de contraseña
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función próximamente disponible'),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?', // Exacto como en la imagen
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          _showRegistrationSuccess(state.message);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _registerFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crear cuenta', // Título exacto de la imagen
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 8)),
                Text(
                  'Crea una cuenta para ingresar a la aplicación.', // Descripción exacta
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 32)),
                
                CorporateFormField(
                  controller: _nombreCompletoController,
                  label: 'Nombre', // Label según la imagen
                  hintText: '',
                  validator: (value) => value?.isEmpty ?? true 
                    ? 'El nombre es requerido' 
                    : null,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 20)),
                
                CorporateFormField(
                  controller: _registerEmailController,
                  label: 'Email', // Label según la imagen
                  hintText: '',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 20)),
                
                CorporateFormField(
                  controller: _registerPasswordController,
                  label: 'Password', // Label según la imagen
                  hintText: '',
                  isPassword: true,
                  validator: _validatePassword,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 20)),
                
                CorporateFormField(
                  controller: _confirmPasswordController,
                  label: 'Password', // Segundo campo de password
                  hintText: '',
                  isPassword: true,
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: _getResponsiveSpacing(context, 32)),
                
                CorporateButton(
                  text: 'Crear', // Botón exacto de la imagen
                  isLoading: state is AuthLoading,
                  onPressed: _handleRegister,
                ),
                
                SizedBox(height: _getResponsiveSpacing(context, 16)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Se creará una cuenta de OPERARIO que debe ser aprobada por un administrador antes de poder usar el sistema.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogin() {
    if (_loginFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLogin(
          email: _loginEmailController.text.trim(),
          password: _loginPasswordController.text,
        ),
      );
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegister(
          email: _registerEmailController.text.trim(),
          password: _registerPasswordController.text,
          nombreCompleto: _nombreCompletoController.text.trim(),
        ),
      );
    }
  }

  void _navigateByRole(String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Bienvenido! Rol: $role',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Redirigir al dashboard
    context.go(AppRouter.dashboard);
  }

  void _showRegistrationSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Registro Exitoso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Pasos siguientes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('1. Verifique su email'),
            const Text('2. Espere la aprobación del administrador'),
            const Text('3. Podrá iniciar sesión una vez aprobado'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(0);
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
          ),
        ),
      ],
    );
  }

  void _showPendingDialog(String estado, String email) {
    String titulo;
    String mensaje;
    String subtitulo;
    IconData icono;
    Color colorIcono;
    List<Widget>? accionesAdicionales;
    String textoBoton = 'Entendido';
    
    switch (estado) {
      case 'PENDIENTE_EMAIL':
        titulo = 'Email Pendiente';
        subtitulo = 'Verificación requerida';
        mensaje = 'Debe verificar su email antes de continuar. Revise su bandeja de entrada y carpeta de spam.';
        icono = Icons.mark_email_unread;
        colorIcono = const Color(0xFF4ECDC4);
        textoBoton = 'Entendido';
        
        // Agregar sección de reenvío
        accionesAdicionales = [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF4ECDC4),
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  '¿No recibió el email?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF495057),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Podemos reenviarlo a:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF4ECDC4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<AuthBloc>().add(AuthResendVerificationEmail(email: email));
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reenviar Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
        break;
        
      case 'PENDIENTE_APROBACION':
        titulo = 'Cuenta Pendiente';
        subtitulo = 'Esperando aprobación';
        mensaje = 'Su cuenta está pendiente de aprobación por un administrador. Recibirá una notificación cuando sea aprobada.';
        icono = Icons.pending_actions;
        colorIcono = const Color(0xFFFF9800);
        
        accionesAdicionales = [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.schedule,
                  color: Color(0xFFFF9800),
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  'Tiempo estimado: 24-48 horas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF495057),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Le notificaremos por email cuando su cuenta sea aprobada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
        ];
        break;
        
      case 'SUSPENDIDA':
        titulo = 'Cuenta Suspendida';
        subtitulo = 'Acceso restringido';
        mensaje = 'Su cuenta ha sido suspendida. Contacte al administrador para más información.';
        icono = Icons.block;
        colorIcono = const Color(0xFFF44336);
        textoBoton = 'Contactar Admin';
        break;
        
      case 'RECHAZADA':
        titulo = 'Cuenta Rechazada';
        subtitulo = 'Solicitud denegada';
        mensaje = 'Su solicitud de cuenta ha sido rechazada. Puede intentar registrarse nuevamente con otra información.';
        icono = Icons.cancel;
        colorIcono = const Color(0xFFF44336);
        textoBoton = 'Intentar Nuevamente';
        break;
        
      default:
        titulo = 'Acceso Denegado';
        subtitulo = 'Cuenta inactiva';
        mensaje = 'Su cuenta no está activa. Contacte al administrador para más información.';
        icono = Icons.lock;
        colorIcono = Colors.grey;
        textoBoton = 'Contactar Admin';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icono, color: colorIcono),
            const SizedBox(width: 8),
            Text(titulo),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje),
            if (estado == 'PENDIENTE_EMAIL') ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(AuthResendVerificationEmail(email: email));
                },
                child: const Text('Reenviar Email'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textoBoton),
          ),
        ],
      ),
    );
  }

  // Validadores
  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'El email es requerido';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!)) {
      return 'Formato de email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'La contraseña es requerida';
    if (value!.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe incluir una mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Debe incluir un número';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Confirme la contraseña';
    if (value != _registerPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}