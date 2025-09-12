import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    // Inicializar Supabase
    await Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    );

    final client = Supabase.instance.client;
    print('🔄 Probando conexión Supabase...');

    // Test 1: Marcas
    print('\n📝 Test 1: Consultando marcas...');
    final marcasResponse = await client
        .from('marcas')
        .select('*')
        .eq('activa', true)
        .order('nombre');
    print('✅ Marcas: ${marcasResponse.length} registros');
    if (marcasResponse.isNotEmpty) {
      print('   Primera marca: ${marcasResponse[0]}');
    }

    // Test 2: Categorías
    print('\n📝 Test 2: Consultando categorías...');
    final categoriasResponse = await client
        .from('categorias')
        .select('*')
        .eq('activa', true)
        .order('nombre');
    print('✅ Categorías: ${categoriasResponse.length} registros');
    if (categoriasResponse.isNotEmpty) {
      print('   Primera categoría: ${categoriasResponse[0]}');
    }

    // Test 3: Tallas
    print('\n📝 Test 3: Consultando tallas...');
    final tallasResponse = await client
        .from('tallas')
        .select('*')
        .eq('activa', true)
        .order('orden_display');
    print('✅ Tallas: ${tallasResponse.length} registros');
    if (tallasResponse.isNotEmpty) {
      print('   Primera talla: ${tallasResponse[0]}');
    }

    // Test 4: Materiales (categorías con tipo MATERIAL)
    print('\n📝 Test 4: Consultando materiales...');
    final materialesResponse = await client
        .from('categorias')
        .select('*')
        .eq('activa', true)
        .eq('tipo', 'MATERIAL')
        .order('nombre');
    print('✅ Materiales: ${materialesResponse.length} registros');
    if (materialesResponse.isNotEmpty) {
      print('   Primer material: ${materialesResponse[0]}');
    }

    // Test 5: Tiendas
    print('\n📝 Test 5: Consultando tiendas...');
    final tiendasResponse = await client
        .from('tiendas')
        .select('*')
        .eq('activa', true)
        .order('nombre');
    print('✅ Tiendas: ${tiendasResponse.length} registros');
    if (tiendasResponse.isNotEmpty) {
      print('   Primera tienda: ${tiendasResponse[0]}');
    }

    print('\n🎉 Todas las consultas completadas exitosamente');

  } catch (e, stackTrace) {
    print('❌ Error durante las pruebas: $e');
    print('📜 Stack trace: $stackTrace');
  }
}