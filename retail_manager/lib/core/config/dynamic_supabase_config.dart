import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DynamicSupabaseConfig {
  static Map<String, String>? _cachedConfig;
  static DateTime? _lastFetch;
  static const Duration _cacheValidTime = Duration(minutes: 5);

  /// Obtiene la configuración dinámica de Supabase desde `supabase status --output json`
  static Future<Map<String, String>> getSupabaseConfig() async {
    // Verificar cache válido
    if (_cachedConfig != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheValidTime) {
      return _cachedConfig!;
    }

    try {
      if (kIsWeb) {
        // En web, usar configuración por defecto con detección de puertos comunes
        return await _detectWebConfig();
      } else {
        // En desktop/mobile, ejecutar comando supabase status
        return await _getConfigFromCommand();
      }
    } catch (e) {
      print('⚠️ [DynamicConfig] Error obteniendo configuración: $e');
      return _getFallbackConfig();
    }
  }

  /// Obtiene configuración ejecutando supabase status --output json
  static Future<Map<String, String>> _getConfigFromCommand() async {
    try {
      final result = await Process.run(
        'supabase',
        ['status', '--output', 'json'],
        workingDirectory: Directory.current.parent.path,
      );

      if (result.exitCode == 0) {
        final config = json.decode(result.stdout as String) as Map<String, dynamic>;

        final dynamicConfig = {
          'url': config['API_URL'] as String? ?? 'http://127.0.0.1:54321',
          'anonKey': config['ANON_KEY'] as String? ?? _getDefaultAnonKey(),
          'dbUrl': config['DB_URL'] as String? ?? 'postgresql://postgres:postgres@127.0.0.1:54322/postgres',
          'studioUrl': config['STUDIO_URL'] as String? ?? 'http://127.0.0.1:54323',
        };

        _cachedConfig = dynamicConfig;
        _lastFetch = DateTime.now();

        print('✅ [DynamicConfig] Configuración obtenida dinámicamente:');
        print('   API URL: ${dynamicConfig['url']}');
        print('   Studio: ${dynamicConfig['studioUrl']}');

        return dynamicConfig;
      } else {
        throw Exception('supabase status failed: ${result.stderr}');
      }
    } catch (e) {
      print('❌ [DynamicConfig] Error ejecutando supabase status: $e');
      return _getFallbackConfig();
    }
  }

  /// Detecta configuración para entorno web probando puertos comunes
  static Future<Map<String, String>> _detectWebConfig() async {
    final commonPorts = [54321, 54320, 54322, 3000, 8000];

    for (final port in commonPorts) {
      try {
        final url = 'http://127.0.0.1:$port';
        // En web no podemos hacer requests directos por CORS, usar configuración por defecto
        print('🌐 [DynamicConfig] Usando configuración web con puerto $port');
        return {
          'url': url,
          'anonKey': _getDefaultAnonKey(),
          'dbUrl': 'postgresql://postgres:postgres@127.0.0.1:${port + 1}/postgres',
          'studioUrl': 'http://127.0.0.1:${port + 2}',
        };
      } catch (e) {
        continue;
      }
    }

    return _getFallbackConfig();
  }

  /// Configuración de fallback cuando todo falla
  static Map<String, String> _getFallbackConfig() {
    print('⚠️ [DynamicConfig] Usando configuración de fallback');
    return {
      'url': 'http://127.0.0.1:54321',
      'anonKey': _getDefaultAnonKey(),
      'dbUrl': 'postgresql://postgres:postgres@127.0.0.1:54322/postgres',
      'studioUrl': 'http://127.0.0.1:54323',
    };
  }

  /// Anon key por defecto de Supabase local
  static String _getDefaultAnonKey() {
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
  }

  /// Limpia el cache para forzar nueva detección
  static void clearCache() {
    _cachedConfig = null;
    _lastFetch = null;
    print('🔄 [DynamicConfig] Cache limpiado');
  }

  /// Valida si una configuración funciona
  static Future<bool> validateConfig(String url, String anonKey) async {
    try {
      if (kIsWeb) {
        // En web, asumir válido para evitar problemas CORS
        return true;
      }

      // En desktop/mobile, intentar conexión básica
      final socket = await Socket.connect('127.0.0.1', Uri.parse(url).port);
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }
}