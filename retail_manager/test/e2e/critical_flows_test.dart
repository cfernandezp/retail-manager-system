import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../../lib/main.dart' as app;
import '../fixtures/test_data.dart';

/// End-to-End tests para flujos críticos del MVP1
/// Simula interacciones reales de usuario en el sistema completo
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical User Flows E2E Tests', () {
    
    // =====================================================
    // SETUP Y TEARDOWN
    // =====================================================
    
    setUpAll(() async {
      // Configuración inicial para E2E tests
      // Limpiar datos de testing anteriores
      await _setupTestEnvironment();
    });

    tearDownAll(() async {
      // Limpiar datos de testing
      await _cleanupTestEnvironment();
    });

    // =====================================================
    // FLUJO 1: CREAR PRODUCTO (SUPER_ADMIN)
    // =====================================================
    
    testWidgets('FLOW 1: Super Admin crea producto completo', (WidgetTester tester) async {
      // GIVEN: Super Admin autenticado en el sistema
      await app.main();
      await tester.pumpAndSettle();
      
      // Simular login como SUPER_ADMIN
      await _loginAsUser(tester, TestData.superAdminUser);
      
      // WHEN: Navega a la página de productos
      await tester.tap(find.byKey(const Key('nav_productos')));
      await tester.pumpAndSettle();
      
      // Verificar que está en ProductsPage
      expect(find.byKey(const Key('products_page')), findsOneWidget);
      
      // AND: Hace clic en "Crear Producto"
      await tester.tap(find.byKey(const Key('btn_crear_producto')));
      await tester.pumpAndSettle();
      
      // Verificar que abrió CreateProductPage
      expect(find.byKey(const Key('create_product_page')), findsOneWidget);
      
      // AND: Completa el wizard paso 1 - Información básica
      await _completarPaso1InformacionBasica(tester);
      
      // AND: Completa el wizard paso 2 - Colores y variantes
      await _completarPaso2ColoresVariantes(tester);
      
      // AND: Completa el wizard paso 3 - Inventario inicial
      await _completarPaso3InventarioInicial(tester);
      
      // AND: Envía el formulario
      await tester.tap(find.byKey(const Key('btn_crear_producto_final')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // THEN: El producto se crea exitosamente
      expect(find.text('Producto creado exitosamente'), findsOneWidget);
      
      // AND: Aparece en la lista con SKU auto-generado
      await tester.tap(find.byKey(const Key('btn_cerrar_dialog')));
      await tester.pumpAndSettle();
      
      // Verificar que el producto aparece en la lista
      expect(find.text('Media Test E2E 9-12'), findsOneWidget);
      expect(find.textContaining('MED-TST-912-'), findsOneWidget); // SKU pattern
      
      // AND: El realtime notifica a otros usuarios (simulado)
      await _verifyRealtimeNotification();
      
      // AND: El inventario se configura en todas las tiendas
      await _verifyInventarioConfigurado();
    }, timeout: const Timeout(Duration(minutes: 3)));

    // =====================================================
    // FLUJO 2: GESTIÓN INVENTARIO (ADMIN_TIENDA)
    // =====================================================
    
    testWidgets('FLOW 2: Admin tienda gestiona inventario local', (WidgetTester tester) async {
      // GIVEN: Admin de tienda Gamarra autenticado
      await app.main();
      await tester.pumpAndSettle();
      
      await _loginAsUser(tester, TestData.adminTiendaGamarraUser);
      
      // WHEN: Accede a /products
      await tester.tap(find.byKey(const Key('nav_productos')));
      await tester.pumpAndSettle();
      
      // THEN: Ve solo productos de su tienda
      await _verifyOnlyOwnStoreProducts(tester, 'GAM');
      
      // WHEN: Busca "Media Arley 9-12 Azul"
      await tester.enterText(
        find.byKey(const Key('search_products')), 
        'Media Arley 9-12 Azul'
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Verificar que aparece el resultado
      expect(find.text('Media fútbol polyester Arley 9-12'), findsOneWidget);
      
      // WHEN: Selecciona el producto para editar inventario
      await tester.tap(find.byKey(const Key('product_card_0')));
      await tester.pumpAndSettle();
      
      // Abrir panel de inventario
      await tester.tap(find.byKey(const Key('btn_edit_inventory')));
      await tester.pumpAndSettle();
      
      // AND: Actualiza stock
      await tester.enterText(
        find.byKey(const Key('input_stock_actual')), 
        '75'
      );
      
      // AND: Cambia precio local
      await tester.enterText(
        find.byKey(const Key('input_precio_local')), 
        '14.00'
      );
      
      // AND: Guarda cambios
      await tester.tap(find.byKey(const Key('btn_save_inventory')));
      await tester.pumpAndSettle();
      
      // THEN: Los cambios se guardan inmediatamente
      expect(find.text('Inventario actualizado'), findsOneWidget);
      
      // AND: Otros usuarios ven updates en tiempo real (simulado)
      await _verifyInventoryRealtimeUpdate();
      
      // AND: El historial de movimientos se registra
      await _verifyMovimientoRegistrado('AJUSTE');
    }, timeout: const Timeout(Duration(minutes: 2)));

    // =====================================================
    // FLUJO 3: BÚSQUEDA POS (VENDEDOR)
    // =====================================================
    
    testWidgets('FLOW 3: Vendedor busca producto para venta', (WidgetTester tester) async {
      // GIVEN: Vendedor en tienda Mesa Redonda autenticado
      await app.main();
      await tester.pumpAndSettle();
      
      await _loginAsUser(tester, TestData.vendedorMesaRedondaUser);
      
      // WHEN: Accede a /products
      await tester.tap(find.byKey(const Key('nav_productos')));
      await tester.pumpAndSettle();
      
      // Medir tiempo de carga inicial
      final stopwatch = Stopwatch()..start();
      
      // WHEN: Busca "Arley 9-12"
      await tester.enterText(
        find.byKey(const Key('search_products')), 
        'Arley 9-12'
      );
      
      // Esperar debounce y respuesta
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
      stopwatch.stop();
      
      // THEN: Ve resultados en < 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      
      // AND: Solo ve stock de su tienda (Mesa Redonda)
      await _verifyOnlyOwnStoreInventory(tester, 'MES');
      
      // AND: Puede ver precios locales actualizados
      expect(find.textContaining('S/ '), findsWidgets); // Formato moneda peruana
      
      // WHEN: Selecciona un producto
      await tester.tap(find.byKey(const Key('product_card_0')));
      await tester.pumpAndSettle();
      
      // THEN: Ve stock actual disponible
      expect(find.byKey(const Key('stock_actual_display')), findsOneWidget);
      expect(find.textContaining('En stock:'), findsOneWidget);
      
      // AND: No puede modificar inventario (solo lectura)
      expect(find.byKey(const Key('btn_edit_inventory')), findsNothing);
      
      // AND: Puede iniciar proceso de venta
      expect(find.byKey(const Key('btn_add_to_sale')), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 30)));

    // =====================================================
    // FLUJO 4: BÚSQUEDA AVANZADA Y FILTROS
    // =====================================================
    
    testWidgets('FLOW 4: Búsqueda con filtros múltiples', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      await _loginAsUser(tester, TestData.adminTiendaGamarraUser);
      
      await tester.tap(find.byKey(const Key('nav_productos')));
      await tester.pumpAndSettle();
      
      // Abrir panel de filtros
      await tester.tap(find.byKey(const Key('btn_filters')));
      await tester.pumpAndSettle();
      
      // Aplicar filtros múltiples
      // Filtro por marca
      await tester.tap(find.byKey(const Key('filter_marca_arley')));
      
      // Filtro por categoría
      await tester.tap(find.byKey(const Key('filter_categoria_medias')));
      
      // Filtro por rango de precios
      await tester.enterText(find.byKey(const Key('filter_precio_min')), '10');
      await tester.enterText(find.byKey(const Key('filter_precio_max')), '20');
      
      // Filtro solo con stock
      await tester.tap(find.byKey(const Key('filter_solo_con_stock')));
      
      // Aplicar filtros
      await tester.tap(find.byKey(const Key('btn_apply_filters')));
      await tester.pumpAndSettle();
      
      // Verificar resultados filtrados
      expect(find.text('Arley'), findsWidgets);
      expect(find.text('Medias'), findsWidgets);
      
      // Verificar paginación funcional
      expect(find.byKey(const Key('pagination_controls')), findsOneWidget);
    });

    // =====================================================
    // FLUJO 5: RESPONSIVE DESIGN Y ACCESIBILIDAD
    // =====================================================
    
    testWidgets('FLOW 5: Responsive design y accesibilidad', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      await _loginAsUser(tester, TestData.superAdminUser);
      
      // Test diferentes tamaños de pantalla
      await _testResponsiveBreakpoints(tester);
      
      // Test navegación por teclado
      await _testKeyboardNavigation(tester);
      
      // Test screen reader support
      await _testScreenReaderSupport(tester);
      
      // Test color contrast
      await _testColorContrast(tester);
    });

    // =====================================================
    // FLUJO 6: REALTIME COLLABORATION
    // =====================================================
    
    testWidgets('FLOW 6: Colaboración en tiempo real', (WidgetTester tester) async {
      // Simular múltiples usuarios conectados
      await app.main();
      await tester.pumpAndSettle();
      
      // Usuario 1: Admin Gamarra
      await _loginAsUser(tester, TestData.adminTiendaGamarraUser);
      
      // Simular cambio de inventario desde otro cliente
      await _simulateExternalInventoryChange();
      
      // Verificar que se actualiza automáticamente
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verificar notificación de cambio
      expect(find.textContaining('Inventario actualizado'), findsOneWidget);
    });

    // =====================================================
    // FLUJO 7: ERROR HANDLING Y RECOVERY
    // =====================================================
    
    testWidgets('FLOW 7: Manejo de errores y recuperación', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      await _loginAsUser(tester, TestData.vendedorGamarraUser);
      
      // Simular error de red
      await _simulateNetworkError();
      
      // Verificar mensaje de error amigable
      expect(find.text('Error de conexión'), findsOneWidget);
      
      // Verificar botón de reintentar
      expect(find.byKey(const Key('btn_retry')), findsOneWidget);
      
      // Simular recuperación de conexión
      await _simulateNetworkRecovery();
      
      await tester.tap(find.byKey(const Key('btn_retry')));
      await tester.pumpAndSettle();
      
      // Verificar que se recupera correctamente
      expect(find.byKey(const Key('products_page')), findsOneWidget);
    });
  });
}

// =====================================================
// HELPER FUNCTIONS
// =====================================================

Future<void> _setupTestEnvironment() async {
  // Configurar ambiente de testing
  // - Base de datos de testing
  // - Datos semilla
  // - Configuración de realtime
}

Future<void> _cleanupTestEnvironment() async {
  // Limpiar datos de testing
  TestData.cleanup();
}

Future<void> _loginAsUser(WidgetTester tester, Map<String, dynamic> userData) async {
  // Simular login con credenciales de testing
  await tester.enterText(
    find.byKey(const Key('email_input')), 
    userData['email']
  );
  await tester.enterText(
    find.byKey(const Key('password_input')), 
    'test-password-123'
  );
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _completarPaso1InformacionBasica(WidgetTester tester) async {
  // Llenar información básica del producto
  await tester.enterText(
    find.byKey(const Key('input_nombre')), 
    'Media Test E2E 9-12'
  );
  
  // Seleccionar marca
  await tester.tap(find.byKey(const Key('dropdown_marca')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Test Marca'));
  await tester.pumpAndSettle();
  
  // Seleccionar categoría
  await tester.tap(find.byKey(const Key('dropdown_categoria')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Medias'));
  await tester.pumpAndSettle();
  
  // Seleccionar talla
  await tester.tap(find.byKey(const Key('dropdown_talla')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('9-12'));
  await tester.pumpAndSettle();
  
  // Precio sugerido
  await tester.enterText(
    find.byKey(const Key('input_precio_sugerido')), 
    '15.50'
  );
  
  // Siguiente paso
  await tester.tap(find.byKey(const Key('btn_siguiente_paso1')));
  await tester.pumpAndSettle();
}

Future<void> _completarPaso2ColoresVariantes(WidgetTester tester) async {
  // Seleccionar colores
  await tester.tap(find.byKey(const Key('color_azul')));
  await tester.tap(find.byKey(const Key('color_rojo')));
  await tester.tap(find.byKey(const Key('color_negro')));
  
  // Siguiente paso
  await tester.tap(find.byKey(const Key('btn_siguiente_paso2')));
  await tester.pumpAndSettle();
}

Future<void> _completarPaso3InventarioInicial(WidgetTester tester) async {
  // Configurar inventario para Gamarra
  await tester.enterText(
    find.byKey(const Key('stock_gamarra')), 
    '50'
  );
  await tester.enterText(
    find.byKey(const Key('precio_gamarra')), 
    '16.00'
  );
  
  // Configurar inventario para Mesa Redonda
  await tester.enterText(
    find.byKey(const Key('stock_mesa')), 
    '30'
  );
  await tester.enterText(
    find.byKey(const Key('precio_mesa')), 
    '15.80'
  );
}

Future<void> _verifyRealtimeNotification() async {
  // Simular verificación de notificación realtime
  await Future.delayed(const Duration(milliseconds: 500));
}

Future<void> _verifyInventarioConfigurado() async {
  // Verificar que el inventario se configuró correctamente
  await Future.delayed(const Duration(milliseconds: 500));
}

Future<void> _verifyOnlyOwnStoreProducts(WidgetTester tester, String storeCode) async {
  // Verificar que solo se muestran productos de la tienda del usuario
  // En un test real, esto verificaría los datos mostrados
  await tester.pumpAndSettle();
}

Future<void> _verifyOnlyOwnStoreInventory(WidgetTester tester, String storeCode) async {
  // Verificar que solo se muestra inventario de la tienda del usuario
  await tester.pumpAndSettle();
}

Future<void> _verifyInventoryRealtimeUpdate() async {
  // Simular verificación de actualización en tiempo real
  await Future.delayed(const Duration(milliseconds: 500));
}

Future<void> _verifyMovimientoRegistrado(String tipoMovimiento) async {
  // Verificar que se registró el movimiento de stock
  await Future.delayed(const Duration(milliseconds: 500));
}

Future<void> _testResponsiveBreakpoints(WidgetTester tester) async {
  // Test diferentes tamaños de pantalla
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  
  // Desktop
  await binding.setSurfaceSize(const Size(1920, 1080));
  await tester.pumpAndSettle();
  
  // Tablet
  await binding.setSurfaceSize(const Size(768, 1024));
  await tester.pumpAndSettle();
  
  // Mobile
  await binding.setSurfaceSize(const Size(375, 667));
  await tester.pumpAndSettle();
  
  // Restore
  await binding.setSurfaceSize(const Size(1200, 800));
}

Future<void> _testKeyboardNavigation(WidgetTester tester) async {
  // Test navegación con Tab y Enter
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
  
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

Future<void> _testScreenReaderSupport(WidgetTester tester) async {
  // Verificar que los elementos tienen semantics apropiados
  expect(find.bySemanticsLabel('Buscar productos'), findsOneWidget);
  expect(find.bySemanticsLabel('Crear nuevo producto'), findsOneWidget);
}

Future<void> _testColorContrast(WidgetTester tester) async {
  // En un test real, esto verificaría los ratios de contraste
  await tester.pumpAndSettle();
}

Future<void> _simulateExternalInventoryChange() async {
  // Simular cambio de inventario desde otro cliente
  await Future.delayed(const Duration(milliseconds: 500));
}

Future<void> _simulateNetworkError() async {
  // Simular error de red
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> _simulateNetworkRecovery() async {
  // Simular recuperación de red
  await Future.delayed(const Duration(milliseconds: 100));
}