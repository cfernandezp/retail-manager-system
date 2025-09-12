import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseClientConfig {
  static late SupabaseClient _client;
  
  static SupabaseClient get client => _client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    
    _client = Supabase.instance.client;
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