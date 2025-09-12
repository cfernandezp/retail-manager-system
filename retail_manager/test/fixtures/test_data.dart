/// Test Data Fixtures para MVP1 Testing
/// Datos consistentes para testing del módulo productos multi-tienda

import '../../lib/data/models/product_models.dart';

class TestData {
  // =====================================================
  // USUARIOS DE PRUEBA POR ROL
  // =====================================================
  
  static const Map<String, dynamic> superAdminUser = {
    'id': '11111111-1111-1111-1111-111111111111',
    'email': 'super@retailmedias.com',
    'nombre_completo': 'Super Admin Test',
    'rol': 'SUPER_ADMIN',
    'tienda_id': null,
    'activo': true,
  };

  static const Map<String, dynamic> adminTiendaGamarraUser = {
    'id': '22222222-2222-2222-2222-222222222222',
    'email': 'admin.gamarra@retailmedias.com',
    'nombre_completo': 'Admin Gamarra Test',
    'rol': 'ADMIN_TIENDA',
    'tienda_id': 'tienda-gamarra-001',
    'activo': true,
  };

  static const Map<String, dynamic> adminTiendaMesaRedondaUser = {
    'id': '33333333-3333-3333-3333-333333333333',
    'email': 'admin.mesa@retailmedias.com',
    'nombre_completo': 'Admin Mesa Redonda Test',
    'rol': 'ADMIN_TIENDA',
    'tienda_id': 'tienda-mesa-001',
    'activo': true,
  };

  static const Map<String, dynamic> vendedorGamarraUser = {
    'id': '44444444-4444-4444-4444-444444444444',
    'email': 'vendedor.gamarra@retailmedias.com',
    'nombre_completo': 'Vendedor Gamarra Test',
    'rol': 'VENDEDOR',
    'tienda_id': 'tienda-gamarra-001',
    'activo': true,
  };

  static const Map<String, dynamic> vendedorMesaRedondaUser = {
    'id': '55555555-5555-5555-5555-555555555555',
    'email': 'vendedor.mesa@retailmedias.com',
    'nombre_completo': 'Vendedor Mesa Redonda Test',
    'rol': 'VENDEDOR',
    'tienda_id': 'tienda-mesa-001',
    'activo': true,
  };

  // =====================================================
  // TIENDAS DE PRUEBA
  // =====================================================
  
  static const List<Map<String, dynamic>> testStores = [
    {
      'id': 'tienda-gamarra-001',
      'nombre': 'Gamarra Centro',
      'codigo': 'GAM',
      'direccion': 'Jr. Gamarra 123, La Victoria, Lima',
      'telefono': '01-123-4567',
      'email': 'gamarra@retailmedias.com',
      'admin_tienda_id': '22222222-2222-2222-2222-222222222222',
      'activo': true,
    },
    {
      'id': 'tienda-mesa-001',
      'nombre': 'Mesa Redonda',
      'codigo': 'MES',
      'direccion': 'Mesa Redonda 456, Cercado de Lima',
      'telefono': '01-765-4321',
      'email': 'mesa@retailmedias.com',
      'admin_tienda_id': '33333333-3333-3333-3333-333333333333',
      'activo': true,
    },
    {
      'id': 'tienda-wilson-001',
      'nombre': 'Wilson Mayorista',
      'codigo': 'WIL',
      'direccion': 'Jr. Wilson 789, Cercado de Lima',
      'telefono': '01-987-6543',
      'email': 'wilson@retailmedias.com',
      'admin_tienda_id': null, // Sin admin asignado para testing
      'activo': true,
    },
  ];

  // =====================================================
  // MARCAS DE PRUEBA
  // =====================================================
  
  static const List<Map<String, dynamic>> testMarcas = [
    {
      'id': 'marca-arley-001',
      'nombre': 'Arley',
      'descripcion': 'Marca líder en medias deportivas',
      'prefijo_sku': 'ARL',
      'activo': true,
    },
    {
      'id': 'marca-nike-001',
      'nombre': 'Nike',
      'descripcion': 'Marca internacional deportiva',
      'prefijo_sku': 'NIK',
      'activo': true,
    },
    {
      'id': 'marca-adidas-001',
      'nombre': 'Adidas',
      'descripcion': 'Marca deportiva alemana',
      'prefijo_sku': 'ADI',
      'activo': true,
    },
    {
      'id': 'marca-inactiva-001',
      'nombre': 'Marca Inactiva',
      'descripcion': 'Marca para testing de filtros',
      'prefijo_sku': 'INA',
      'activo': false,
    },
  ];

  // =====================================================
  // CATEGORÍAS DE PRUEBA
  // =====================================================
  
  static const List<Map<String, dynamic>> testCategorias = [
    {
      'id': 'categoria-medias-001',
      'nombre': 'Medias',
      'descripcion': 'Medias de algodón y polyester',
      'prefijo_sku': 'MED',
      'activo': true,
    },
    {
      'id': 'categoria-calcetines-001',
      'nombre': 'Calcetines',
      'descripcion': 'Calcetines deportivos',
      'prefijo_sku': 'CAL',
      'activo': true,
    },
    {
      'id': 'categoria-tobilleras-001',
      'nombre': 'Tobilleras',
      'descripcion': 'Medias tobilleras',
      'prefijo_sku': 'TOB',
      'activo': true,
    },
  ];

  // =====================================================
  // TALLAS DE PRUEBA
  // =====================================================
  
  static const List<Map<String, dynamic>> testTallas = [
    {
      'id': 'talla-912-001',
      'codigo': '9-12',
      'tipo': 'RANGO',
      'talla_min': 9,
      'talla_max': 12,
      'talla_unica': null,
      'orden_display': 1,
      'activo': true,
    },
    {
      'id': 'talla-68-001',
      'codigo': '6-8',
      'tipo': 'RANGO',
      'talla_min': 6,
      'talla_max': 8,
      'talla_unica': null,
      'orden_display': 2,
      'activo': true,
    },
    {
      'id': 'talla-3-001',
      'codigo': '3',
      'tipo': 'UNICA',
      'talla_min': null,
      'talla_max': null,
      'talla_unica': 3,
      'orden_display': 3,
      'activo': true,
    },
    {
      'id': 'talla-adulto-001',
      'codigo': 'ADULTO',
      'tipo': 'UNICA',
      'talla_min': null,
      'talla_max': null,
      'talla_unica': 99, // Valor especial para adulto
      'orden_display': 4,
      'activo': true,
    },
  ];

  // =====================================================
  // COLORES DE PRUEBA
  // =====================================================
  
  static const List<Map<String, dynamic>> testColores = [
    {
      'id': 'color-azul-001',
      'nombre': 'Azul',
      'codigo_hex': '#0066CC',
      'prefijo_sku': 'AZU',
      'activo': true,
    },
    {
      'id': 'color-rojo-001',
      'nombre': 'Rojo',
      'codigo_hex': '#CC0000',
      'prefijo_sku': 'ROJ',
      'activo': true,
    },
    {
      'id': 'color-negro-001',
      'nombre': 'Negro',
      'codigo_hex': '#000000',
      'prefijo_sku': 'NEG',
      'activo': true,
    },
    {
      'id': 'color-blanco-001',
      'nombre': 'Blanco',
      'codigo_hex': '#FFFFFF',
      'prefijo_sku': 'BLA',
      'activo': true,
    },
    {
      'id': 'color-verde-001',
      'nombre': 'Verde',
      'codigo_hex': '#00CC00',
      'prefijo_sku': 'VER',
      'activo': true,
    },
  ];

  // =====================================================
  // PRODUCTOS MASTER DE PRUEBA
  // =====================================================
  
  static const List<Map<String, dynamic>> testProductosMaster = [
    {
      'id': 'producto-arley-912-001',
      'nombre': 'Media fútbol polyester Arley 9-12',
      'descripcion': 'Media deportiva de alta calidad para fútbol',
      'marca_id': 'marca-arley-001',
      'categoria_id': 'categoria-medias-001',
      'talla_id': 'talla-912-001',
      'precio_sugerido': 12.50,
      'estado': 'ACTIVO',
      'imagen_principal_url': 'https://example.com/media-arley-912.jpg',
    },
    {
      'id': 'producto-nike-68-001',
      'nombre': 'Calcetín deportivo Nike 6-8',
      'descripcion': 'Calcetín Nike para niños',
      'marca_id': 'marca-nike-001',
      'categoria_id': 'categoria-calcetines-001',
      'talla_id': 'talla-68-001',
      'precio_sugerido': 25.00,
      'estado': 'ACTIVO',
      'imagen_principal_url': 'https://example.com/calcetín-nike-68.jpg',
    },
    {
      'id': 'producto-adidas-adulto-001',
      'nombre': 'Tobillera Adidas Adulto',
      'descripcion': 'Tobillera deportiva para adultos',
      'marca_id': 'marca-adidas-001',
      'categoria_id': 'categoria-tobilleras-001',
      'talla_id': 'talla-adulto-001',
      'precio_sugerido': 18.00,
      'estado': 'ACTIVO',
      'imagen_principal_url': 'https://example.com/tobillera-adidas.jpg',
    },
  ];

  // =====================================================
  // ARTÍCULOS DE PRUEBA (Variantes por color)
  // =====================================================
  
  static const List<Map<String, dynamic>> testArticulos = [
    // Arley 9-12 en diferentes colores
    {
      'id': 'articulo-arley-912-azul',
      'producto_master_id': 'producto-arley-912-001',
      'color_id': 'color-azul-001',
      'sku': 'MED-ARL-912-AZU',
      'nombre_completo': 'Media fútbol polyester Arley 9-12 AZUL',
      'codigo_barras': '7501234567890',
      'estado': 'ACTIVO',
    },
    {
      'id': 'articulo-arley-912-rojo',
      'producto_master_id': 'producto-arley-912-001',
      'color_id': 'color-rojo-001',
      'sku': 'MED-ARL-912-ROJ',
      'nombre_completo': 'Media fútbol polyester Arley 9-12 ROJO',
      'codigo_barras': '7501234567891',
      'estado': 'ACTIVO',
    },
    {
      'id': 'articulo-arley-912-negro',
      'producto_master_id': 'producto-arley-912-001',
      'color_id': 'color-negro-001',
      'sku': 'MED-ARL-912-NEG',
      'nombre_completo': 'Media fútbol polyester Arley 9-12 NEGRO',
      'codigo_barras': '7501234567892',
      'estado': 'ACTIVO',
    },
    // Nike 6-8
    {
      'id': 'articulo-nike-68-blanco',
      'producto_master_id': 'producto-nike-68-001',
      'color_id': 'color-blanco-001',
      'sku': 'CAL-NIK-68-BLA',
      'nombre_completo': 'Calcetín deportivo Nike 6-8 BLANCO',
      'codigo_barras': '7501234567893',
      'estado': 'ACTIVO',
    },
    // Adidas Adulto
    {
      'id': 'articulo-adidas-adulto-verde',
      'producto_master_id': 'producto-adidas-adulto-001',
      'color_id': 'color-verde-001',
      'sku': 'TOB-ADI-ADULTO-VER',
      'nombre_completo': 'Tobillera Adidas Adulto VERDE',
      'codigo_barras': '7501234567894',
      'estado': 'ACTIVO',
    },
  ];

  // =====================================================
  // INVENTARIO DE PRUEBA POR TIENDA
  // =====================================================
  
  static const List<Map<String, dynamic>> testInventario = [
    // Inventario Gamarra
    {
      'articulo_id': 'articulo-arley-912-azul',
      'tienda_id': 'tienda-gamarra-001',
      'stock_actual': 50,
      'stock_minimo': 10,
      'stock_maximo': 100,
      'precio_venta': 13.00, // Precio local diferente al sugerido
      'precio_costo': 8.00,
      'ubicacion_fisica': 'Estante A1',
      'activo': true,
    },
    {
      'articulo_id': 'articulo-arley-912-rojo',
      'tienda_id': 'tienda-gamarra-001',
      'stock_actual': 5, // Stock bajo para testing
      'stock_minimo': 10,
      'stock_maximo': 100,
      'precio_venta': 13.00,
      'precio_costo': 8.00,
      'ubicacion_fisica': 'Estante A1',
      'activo': true,
    },
    {
      'articulo_id': 'articulo-nike-68-blanco',
      'tienda_id': 'tienda-gamarra-001',
      'stock_actual': 0, // Sin stock para testing
      'stock_minimo': 5,
      'stock_maximo': 50,
      'precio_venta': 26.00,
      'precio_costo': 18.00,
      'ubicacion_fisica': 'Estante B2',
      'activo': true,
    },
    // Inventario Mesa Redonda
    {
      'articulo_id': 'articulo-arley-912-azul',
      'tienda_id': 'tienda-mesa-001',
      'stock_actual': 75,
      'stock_minimo': 15,
      'stock_maximo': 150,
      'precio_venta': 12.80, // Precio diferente a Gamarra
      'precio_costo': 8.00,
      'ubicacion_fisica': 'Zona C',
      'activo': true,
    },
    {
      'articulo_id': 'articulo-nike-68-blanco',
      'tienda_id': 'tienda-mesa-001',
      'stock_actual': 30,
      'stock_minimo': 10,
      'stock_maximo': 60,
      'precio_venta': 25.50,
      'precio_costo': 18.00,
      'ubicacion_fisica': 'Zona D',
      'activo': true,
    },
    {
      'articulo_id': 'articulo-adidas-adulto-verde',
      'tienda_id': 'tienda-mesa-001',
      'stock_actual': 20,
      'stock_minimo': 5,
      'stock_maximo': 40,
      'precio_venta': 19.00,
      'precio_costo': 12.00,
      'ubicacion_fisica': 'Zona E',
      'activo': true,
    },
  ];

  // =====================================================
  // MOVIMIENTOS DE STOCK DE PRUEBA
  // =====================================================
  
  static const List<Map<String, dynamic>> testMovimientosStock = [
    {
      'articulo_id': 'articulo-arley-912-azul',
      'tienda_id': 'tienda-gamarra-001',
      'tipo_movimiento': 'ENTRADA',
      'cantidad': 50,
      'stock_anterior': 0,
      'stock_nuevo': 50,
      'precio_unitario': 8.00,
      'motivo': 'Stock inicial de prueba',
      'referencia_externa': 'INIT-001',
    },
    {
      'articulo_id': 'articulo-arley-912-azul',
      'tienda_id': 'tienda-gamarra-001',
      'tipo_movimiento': 'VENTA',
      'cantidad': -2,
      'stock_anterior': 50,
      'stock_nuevo': 48,
      'precio_unitario': 13.00,
      'motivo': 'Venta de prueba',
      'referencia_externa': 'VENTA-001',
    },
  ];

  // =====================================================
  // DATOS PARA TESTING DE FILTROS
  // =====================================================
  
  static ProductFilters get emptyFilters => const ProductFilters();
  
  static ProductFilters get filtersWithSearch => const ProductFilters(
    searchQuery: 'Arley',
  );
  
  static ProductFilters get filtersWithMarca => const ProductFilters(
    marcaIds: ['marca-arley-001'],
  );
  
  static ProductFilters get filtersWithStock => const ProductFilters(
    soloConStock: true,
  );
  
  static ProductFilters get filtersWithPriceRange => const ProductFilters(
    precioMinimo: 10.0,
    precioMaximo: 20.0,
  );
  
  static ProductFilters get complexFilters => const ProductFilters(
    searchQuery: 'Media',
    marcaIds: ['marca-arley-001', 'marca-nike-001'],
    categoriaIds: ['categoria-medias-001'],
    soloConStock: true,
    precioMinimo: 10.0,
    precioMaximo: 30.0,
  );

  // =====================================================
  // DATOS PARA TESTING DE PAGINACIÓN
  // =====================================================
  
  static const PaginationParams defaultPagination = PaginationParams();
  
  static const PaginationParams customPagination = PaginationParams(
    page: 2,
    pageSize: 10,
    orderBy: 'nombre',
    descending: false,
  );

  // =====================================================
  // CATÁLOGO COMPLETO MOCK RESPONSES
  // =====================================================
  
  static List<CatalogoCompleto> get sampleCatalogoCompleto => [
    const CatalogoCompleto(
      productoId: 'producto-arley-912-001',
      productoNombre: 'Media fútbol polyester Arley 9-12',
      marcaNombre: 'Arley',
      categoriaNombre: 'Medias',
      tallaValor: '9-12',
      precioSugerido: 12.50,
      totalArticulos: 3,
      stockTotal: 128, // Suma de todas las tiendas
      precioMinimo: 12.80,
      precioMaximo: 13.00,
      coloresDisponibles: ['AZUL', 'ROJO', 'NEGRO'],
      tiendasConStock: 2,
    ),
    const CatalogoCompleto(
      productoId: 'producto-nike-68-001',
      productoNombre: 'Calcetín deportivo Nike 6-8',
      marcaNombre: 'Nike',
      categoriaNombre: 'Calcetines',
      tallaValor: '6-8',
      precioSugerido: 25.00,
      totalArticulos: 1,
      stockTotal: 30,
      precioMinimo: 25.50,
      precioMaximo: 26.00,
      coloresDisponibles: ['BLANCO'],
      tiendasConStock: 1,
    ),
  ];

  // =====================================================
  // UTILIDADES DE TESTING
  // =====================================================
  
  /// Obtiene usuario por rol para testing
  static Map<String, dynamic> getUserByRole(String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return superAdminUser;
      case 'ADMIN_TIENDA_GAMARRA':
        return adminTiendaGamarraUser;
      case 'ADMIN_TIENDA_MESA':
        return adminTiendaMesaRedondaUser;
      case 'VENDEDOR_GAMARRA':
        return vendedorGamarraUser;
      case 'VENDEDOR_MESA':
        return vendedorMesaRedondaUser;
      default:
        throw ArgumentError('Rol no encontrado: $role');
    }
  }
  
  /// Obtiene tienda por código
  static Map<String, dynamic> getStoreByCode(String code) {
    return testStores.firstWhere(
      (store) => store['codigo'] == code,
      orElse: () => throw ArgumentError('Tienda no encontrada: $code'),
    );
  }
  
  /// Obtiene inventario por tienda
  static List<Map<String, dynamic>> getInventoryByStore(String tiendaId) {
    return testInventario
        .where((inv) => inv['tienda_id'] == tiendaId)
        .toList();
  }
  
  /// Limpia todos los datos de testing (para tearDown)
  static void cleanup() {
    // Implementar lógica de limpieza si es necesario
    // Por ejemplo, eliminar datos de test de la base de datos
  }
}