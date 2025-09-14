import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../config/dynamic_supabase_config.dart';

class SupabaseClientConfig {
  static late SupabaseClient _client;
  static Map<String, String>? _currentConfig;

  static SupabaseClient get client => _client;

  static Future<void> initialize() async {
    try {
      // Obtener configuración dinámica
      _currentConfig = await DynamicSupabaseConfig.getSupabaseConfig();

      print('🚀 [SupabaseClient] Inicializando con configuración dinámica:');
      print('   URL: ${_currentConfig!['url']}');
      print('   Studio: ${_currentConfig!['studioUrl']}');

      await Supabase.initialize(
        url: _currentConfig!['url']!,
        anonKey: _currentConfig!['anonKey']!,
      );

      _client = Supabase.instance.client;

      print('✅ [SupabaseClient] Inicialización completada exitosamente');

      // Intentar login automático para desarrollo
      await _attemptAutoLogin();

    } catch (e) {
      print('❌ [SupabaseClient] Error en inicialización dinámica: $e');
      print('🔄 [SupabaseClient] Intentando con configuración por defecto...');

      // Fallback a configuración estática
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );

      _client = Supabase.instance.client;
    }
  }

  /// Intenta login automático con credenciales por defecto para desarrollo
  static Future<void> _attemptAutoLogin() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser != null) {
        print('✅ [Auth] Usuario ya autenticado: ${currentUser.email}');
        return;
      }

      print('🔄 [Auth] Intentando login automático con admin@test.com...');
      final response = await _client.auth.signInWithPassword(
        email: 'admin@test.com',
        password: 'admin123',
      );

      if (response.user != null) {
        print('✅ [Auth] Login automático exitoso: ${response.user!.email}');
      } else {
        print('❌ [Auth] Login automático falló');
      }
    } catch (e) {
      print('❌ [Auth] Error en login automático: $e');
      // No relanzar el error, es solo un intento automático
    }
  }
  
  // Helper methods para operaciones comunes
  static User? get currentUser => _client.auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;
  
  static String get currentUserId => currentUser?.id ?? '';
  
  // Métodos de autenticación
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Métodos para realtime
  static RealtimeChannel subscribeToTable(String table) {
    return _client.channel('public:$table');
  }
}