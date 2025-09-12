import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../fixtures/test_data.dart';

/// Tests críticos de Row Level Security (RLS)
/// Valida que las políticas de seguridad funcionen correctamente por rol
void main() {
  group('RLS Security Tests - MVP1', () {
    late SupabaseClient supabaseClient;

    setUpAll(() async {
      // Configurar cliente Supabase para testing
      // En un entorno real, usar una base de datos de testing
      supabaseClient = SupabaseClient(
        'https://your-project.supabase.co', // Testing URL
        'your-anon-key', // Testing anon key
      );
    });

    tearDownAll(() async {
      await supabaseClient.dispose();
    });

    // =====================================================
    // SUPER_ADMIN SECURITY TESTS
    // =====================================================

    group('SUPER_ADMIN Role Security', () {
      setUp(() async {
        // Simular autenticación como SUPER_ADMIN
        await _authenticateAs(supabaseClient, TestData.superAdminUser);
      });

      test('should have full access to all products', () async {
        // Act
        final response = await supabaseClient
            .from('productos_master')
            .select('*');

        // Assert
        expect(response.data, isNotNull);
        expect(response.error, isNull);
        // SUPER_ADMIN debería ver todos los productos
      });

      test('should be able to create products', () async {
        // Arrange
        final productData = Map<String, dynamic>.from(TestData.testProductosMaster[0]);
        productData['id'] = 'test-product-super-admin';

        // Act
        final response = await supabaseClient
            .from('productos_master')
            .insert(productData);

        // Assert
        expect(response.error, isNull);
      });

      test('should have access to all stores inventory', () async {
        // Act
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('*, tiendas(nombre)')
            .limit(100);

        // Assert
        expect(response.data, isNotNull);
        expect(response.error, isNull);
        
        // Verificar que puede ver inventario de múltiples tiendas
        final inventarios = response.data as List;
        final uniqueStores = inventarios
            .map((inv) => inv['tienda_id'])
            .toSet();
        
        expect(uniqueStores.length, greaterThan(1));
      });

      test('should be able to manage all user profiles', () async {
        // Act
        final response = await supabaseClient
            .from('perfiles_usuario')
            .select('*');

        // Assert
        expect(response.data, isNotNull);
        expect(response.error, isNull);
      });

      test('should be able to create/update/delete in master tables', () async {
        // Test crear marca
        final marcaData = {
          'id': 'test-marca-super',
          'nombre': 'Test Marca Super',
          'prefijo_sku': 'TST',
          'activo': true,
        };

        final createResponse = await supabaseClient
            .from('marcas')
            .insert(marcaData);

        expect(createResponse.error, isNull);

        // Test actualizar marca
        final updateResponse = await supabaseClient
            .from('marcas')
            .update({'nombre': 'Test Marca Updated'})
            .eq('id', 'test-marca-super');

        expect(updateResponse.error, isNull);

        // Test eliminar marca
        final deleteResponse = await supabaseClient
            .from('marcas')
            .delete()
            .eq('id', 'test-marca-super');

        expect(deleteResponse.error, isNull);
      });
    });

    // =====================================================
    // ADMIN_TIENDA SECURITY TESTS
    // =====================================================

    group('ADMIN_TIENDA Role Security', () {
      setUp(() async {
        // Simular autenticación como ADMIN_TIENDA de Gamarra
        await _authenticateAs(supabaseClient, TestData.adminTiendaGamarraUser);
      });

      test('should only see active products, not create them', () async {
        // Test lectura (permitida)
        final readResponse = await supabaseClient
            .from('productos_master')
            .select('*')
            .eq('estado', 'ACTIVO');

        expect(readResponse.error, isNull);

        // Test creación (prohibida)
        final productData = Map<String, dynamic>.from(TestData.testProductosMaster[0]);
        productData['id'] = 'test-product-admin-tienda';

        final createResponse = await supabaseClient
            .from('productos_master')
            .insert(productData);

        // Debería fallar por RLS
        expect(createResponse.error, isNotNull);
      });

      test('should only access own store inventory', () async {
        // Act
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('*, tiendas(nombre, codigo)')
            .eq('tienda_id', TestData.adminTiendaGamarraUser['tienda_id']);

        // Assert
        expect(response.error, isNull);
        
        final inventarios = response.data as List;
        
        // Verificar que solo ve inventario de su tienda
        for (final inv in inventarios) {
          expect(inv['tienda_id'], equals(TestData.adminTiendaGamarraUser['tienda_id']));
        }
      });

      test('should NOT access other stores inventory', () async {
        // Intentar acceder al inventario de Mesa Redonda
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('*')
            .eq('tienda_id', 'tienda-mesa-001'); // Mesa Redonda

        // Assert - No debería devolver datos por RLS
        final inventarios = response.data as List;
        expect(inventarios, isEmpty);
      });

      test('should be able to update own store inventory', () async {
        // Arrange - Primero crear un registro de inventario para su tienda
        final inventarioData = {
          'articulo_id': TestData.testArticulos[0]['id'],
          'tienda_id': TestData.adminTiendaGamarraUser['tienda_id'],
          'stock_actual': 25,
          'precio_venta': 14.50,
        };

        await supabaseClient
            .from('inventario_tienda')
            .upsert(inventarioData);

        // Act - Actualizar stock
        final updateResponse = await supabaseClient
            .from('inventario_tienda')
            .update({'stock_actual': 30})
            .eq('articulo_id', TestData.testArticulos[0]['id'])
            .eq('tienda_id', TestData.adminTiendaGamarraUser['tienda_id']);

        // Assert
        expect(updateResponse.error, isNull);
      });

      test('should NOT be able to update other stores inventory', () async {
        // Act - Intentar actualizar inventario de otra tienda
        final updateResponse = await supabaseClient
            .from('inventario_tienda')
            .update({'stock_actual': 999})
            .eq('tienda_id', 'tienda-mesa-001'); // Mesa Redonda

        // Assert - Debería fallar por RLS
        expect(updateResponse.error, isNotNull);
      });

      test('should be able to create stock movements for own store', () async {
        // Arrange
        final movimientoData = {
          'articulo_id': TestData.testArticulos[0]['id'],
          'tienda_id': TestData.adminTiendaGamarraUser['tienda_id'],
          'tipo_movimiento': 'ENTRADA',
          'cantidad': 10,
          'stock_anterior': 20,
          'stock_nuevo': 30,
          'motivo': 'Test movement',
        };

        // Act
        final response = await supabaseClient
            .from('movimientos_stock')
            .insert(movimientoData);

        // Assert
        expect(response.error, isNull);
      });

      test('should only see users from own store', () async {
        // Act
        final response = await supabaseClient
            .from('perfiles_usuario')
            .select('*');

        // Assert
        expect(response.error, isNull);
        
        final usuarios = response.data as List;
        
        // Debería ver solo usuarios de su tienda + su propio perfil
        for (final usuario in usuarios) {
          final tiendaId = usuario['tienda_id'];
          expect(
            tiendaId == TestData.adminTiendaGamarraUser['tienda_id'] || 
            tiendaId == null, // Su propio perfil
            isTrue,
          );
        }
      });
    });

    // =====================================================
    // VENDEDOR SECURITY TESTS
    // =====================================================

    group('VENDEDOR Role Security', () {
      setUp(() async {
        // Simular autenticación como VENDEDOR de Gamarra
        await _authenticateAs(supabaseClient, TestData.vendedorGamarraUser);
      });

      test('should only read active products, no modifications', () async {
        // Test lectura permitida
        final readResponse = await supabaseClient
            .from('productos_master')
            .select('*')
            .eq('estado', 'ACTIVO');

        expect(readResponse.error, isNull);

        // Test modificación prohibida
        final updateResponse = await supabaseClient
            .from('productos_master')
            .update({'nombre': 'Unauthorized Update'})
            .eq('id', TestData.testProductosMaster[0]['id']);

        expect(updateResponse.error, isNotNull);
      });

      test('should only read active inventory from own store', () async {
        // Act
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('*')
            .eq('activo', true);

        // Assert
        expect(response.error, isNull);
        
        final inventarios = response.data as List;
        
        // Verificar que solo ve inventario activo de su tienda
        for (final inv in inventarios) {
          expect(inv['tienda_id'], equals(TestData.vendedorGamarraUser['tienda_id']));
          expect(inv['activo'], isTrue);
        }
      });

      test('should NOT be able to modify inventory', () async {
        // Act - Intentar actualizar stock
        final updateResponse = await supabaseClient
            .from('inventario_tienda')
            .update({'stock_actual': 999})
            .eq('tienda_id', TestData.vendedorGamarraUser['tienda_id']);

        // Assert - Debería fallar por RLS
        expect(updateResponse.error, isNotNull);
      });

      test('should be able to create sales movements only', () async {
        // Test movimiento de venta (permitido)
        final ventaData = {
          'articulo_id': TestData.testArticulos[0]['id'],
          'tienda_id': TestData.vendedorGamarraUser['tienda_id'],
          'tipo_movimiento': 'VENTA',
          'cantidad': -1,
          'stock_anterior': 20,
          'stock_nuevo': 19,
          'motivo': 'Venta POS',
        };

        final ventaResponse = await supabaseClient
            .from('movimientos_stock')
            .insert(ventaData);

        expect(ventaResponse.error, isNull);

        // Test movimiento de entrada (prohibido)
        final entradaData = {
          'articulo_id': TestData.testArticulos[0]['id'],
          'tienda_id': TestData.vendedorGamarraUser['tienda_id'],
          'tipo_movimiento': 'ENTRADA',
          'cantidad': 10,
          'stock_anterior': 20,
          'stock_nuevo': 30,
          'motivo': 'Entrada no autorizada',
        };

        final entradaResponse = await supabaseClient
            .from('movimientos_stock')
            .insert(entradaData);

        expect(entradaResponse.error, isNotNull);
      });

      test('should only see recent movements from own store', () async {
        // Act
        final response = await supabaseClient
            .from('movimientos_stock')
            .select('*')
            .order('created_at', ascending: false)
            .limit(100);

        // Assert
        expect(response.error, isNull);
        
        final movimientos = response.data as List;
        
        // Verificar que solo ve movimientos de su tienda
        for (final mov in movimientos) {
          expect(mov['tienda_id'], equals(TestData.vendedorGamarraUser['tienda_id']));
          
          // Verificar que son movimientos recientes (últimos 30 días)
          final createdAt = DateTime.parse(mov['created_at']);
          final daysDiff = DateTime.now().difference(createdAt).inDays;
          expect(daysDiff, lessThanOrEqualTo(30));
        }
      });

      test('should NOT access master data modification', () async {
        // Test acceso a marcas (solo lectura)
        final readMarcas = await supabaseClient
            .from('marcas')
            .select('*')
            .eq('activo', true);

        expect(readMarcas.error, isNull);

        // Test modificación marcas (prohibida)
        final updateMarca = await supabaseClient
            .from('marcas')
            .update({'nombre': 'Unauthorized'})
            .eq('id', TestData.testMarcas[0]['id']);

        expect(updateMarca.error, isNotNull);
      });
    });

    // =====================================================
    // CROSS-TENANT ISOLATION TESTS
    // =====================================================

    group('Cross-Tenant Data Isolation', () {
      test('admin from one store cannot access another store data', () async {
        // Autenticar como Admin de Gamarra
        await _authenticateAs(supabaseClient, TestData.adminTiendaGamarraUser);

        // Intentar acceder a datos de Mesa Redonda
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('*')
            .eq('tienda_id', 'tienda-mesa-001');

        final inventarios = response.data as List;
        expect(inventarios, isEmpty);
      });

      test('vendor from one store cannot see another store inventory', () async {
        // Autenticar como Vendedor de Mesa Redonda
        await _authenticateAs(supabaseClient, TestData.vendedorMesaRedondaUser);

        // Intentar acceder a inventario de Gamarra
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('*')
            .eq('tienda_id', 'tienda-gamarra-001');

        final inventarios = response.data as List;
        expect(inventarios, isEmpty);
      });

      test('users cannot escalate privileges', () async {
        // Autenticar como vendedor
        await _authenticateAs(supabaseClient, TestData.vendedorGamarraUser);

        // Intentar cambiar su propio rol (prohibido)
        final updateResponse = await supabaseClient
            .from('perfiles_usuario')
            .update({'rol': 'SUPER_ADMIN'})
            .eq('id', TestData.vendedorGamarraUser['id']);

        expect(updateResponse.error, isNotNull);

        // Intentar cambiar su tienda asignada (prohibido)
        final updateTiendaResponse = await supabaseClient
            .from('perfiles_usuario')
            .update({'tienda_id': 'tienda-mesa-001'})
            .eq('id', TestData.vendedorGamarraUser['id']);

        expect(updateTiendaResponse.error, isNotNull);
      });
    });

    // =====================================================
    // SQL INJECTION PREVENTION TESTS
    // =====================================================

    group('SQL Injection Prevention', () {
      test('should prevent SQL injection in search queries', () async {
        await _authenticateAs(supabaseClient, TestData.vendedorGamarraUser);

        // Intentar inyección SQL en búsqueda de productos
        final maliciousQuery = "'; DROP TABLE productos_master; --";
        
        final response = await supabaseClient
            .from('productos_master')
            .select('*')
            .ilike('nombre', '%$maliciousQuery%');

        // La consulta debería ejecutarse sin problemas (sin inyección)
        expect(response.error, isNull);
        
        // Verificar que la tabla sigue existiendo
        final verifyResponse = await supabaseClient
            .from('productos_master')
            .select('count(*)')
            .limit(1);
            
        expect(verifyResponse.error, isNull);
      });

      test('should sanitize user input in filters', () async {
        await _authenticateAs(supabaseClient, TestData.adminTiendaGamarraUser);

        // Intentar inyección en filtros
        final maliciousFilter = "1=1 OR 1=1";
        
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('*')
            .eq('tienda_id', maliciousFilter);

        // No debería devolver datos de otras tiendas
        final inventarios = response.data as List;
        expect(inventarios, isEmpty);
      });
    });

    // =====================================================
    // PERFORMANCE UNDER SECURITY CONSTRAINTS
    // =====================================================

    group('RLS Performance Tests', () {
      test('should maintain performance with RLS policies', () async {
        await _authenticateAs(supabaseClient, TestData.vendedorGamarraUser);

        final stopwatch = Stopwatch()..start();
        
        // Consulta típica de POS
        final response = await supabaseClient
            .from('inventario_tienda')
            .select('''
              *,
              articulos(
                sku,
                nombre_completo,
                productos_master(
                  nombre,
                  marcas(nombre),
                  categorias(nombre),
                  tallas(codigo)
                )
              )
            ''')
            .eq('activo', true)
            .gt('stock_actual', 0)
            .limit(50);

        stopwatch.stop();

        expect(response.error, isNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // < 1 segundo
      });
    });
  });
}

/// Helper para simular autenticación con diferentes roles
Future<void> _authenticateAs(SupabaseClient client, Map<String, dynamic> userData) async {
  // En un entorno real, esto sería una autenticación real
  // Para testing, podemos usar mocks o una base de datos de testing
  
  // Ejemplo de implementación para testing:
  try {
    await client.auth.signInWithPassword(
      email: userData['email'],
      password: 'test-password-123', // Password de testing
    );
  } catch (e) {
    // Si el usuario no existe, crear uno para testing
    await client.auth.signUp(
      email: userData['email'],
      password: 'test-password-123',
      data: userData,
    );
  }
}

/// Helper para limpiar datos de testing
Future<void> _cleanupTestData(SupabaseClient client) async {
  // Limpiar datos creados durante testing
  await client.from('movimientos_stock').delete().like('motivo', '%Test%');
  await client.from('inventario_tienda').delete().eq('ubicacion_fisica', 'TEST');
  await client.from('productos_master').delete().like('id', 'test-%');
  await client.from('marcas').delete().like('id', 'test-%');
}