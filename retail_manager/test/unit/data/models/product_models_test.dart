import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/data/models/product_models.dart';
import '../../../fixtures/test_data.dart';

void main() {
  group('Product Models Unit Tests', () {
    
    // =====================================================
    // MARCA MODEL TESTS
    // =====================================================
    
    group('Marca Model', () {
      test('should create Marca from JSON correctly', () {
        // Arrange
        final marcaJson = TestData.testMarcas[0];
        
        // Act
        final marca = Marca.fromJson(marcaJson);
        
        // Assert
        expect(marca.id, equals('marca-arley-001'));
        expect(marca.nombre, equals('Arley'));
        expect(marca.descripcion, equals('Marca líder en medias deportivas'));
        expect(marca.activo, isTrue);
      });

      test('should convert Marca to JSON correctly', () {
        // Arrange
        final marca = Marca.fromJson(TestData.testMarcas[0]);
        
        // Act
        final json = marca.toJson();
        
        // Assert
        expect(json['id'], equals('marca-arley-001'));
        expect(json['nombre'], equals('Arley'));
        expect(json['activo'], isTrue);
      });

      test('should implement equatable correctly', () {
        // Arrange
        final marca1 = Marca.fromJson(TestData.testMarcas[0]);
        final marca2 = Marca.fromJson(TestData.testMarcas[0]);
        final marca3 = Marca.fromJson(TestData.testMarcas[1]);
        
        // Assert
        expect(marca1, equals(marca2));
        expect(marca1, isNot(equals(marca3)));
      });
    });

    // =====================================================
    // CATEGORIA MODEL TESTS
    // =====================================================
    
    group('Categoria Model', () {
      test('should create Categoria from JSON correctly', () {
        // Arrange
        final categoriaJson = TestData.testCategorias[0];
        
        // Act
        final categoria = Categoria.fromJson(categoriaJson);
        
        // Assert
        expect(categoria.id, equals('categoria-medias-001'));
        expect(categoria.nombre, equals('Medias'));
        expect(categoria.activo, isTrue);
      });

      test('should handle null description', () {
        // Arrange
        final categoriaJson = Map<String, dynamic>.from(TestData.testCategorias[0]);
        categoriaJson.remove('descripcion');
        
        // Act
        final categoria = Categoria.fromJson(categoriaJson);
        
        // Assert
        expect(categoria.descripcion, isNull);
      });
    });

    // =====================================================
    // TALLA MODEL TESTS
    // =====================================================
    
    group('Talla Model', () {
      test('should create Talla RANGO from JSON correctly', () {
        // Arrange
        final tallaJson = TestData.testTallas[0]; // 9-12 RANGO
        
        // Act
        final talla = Talla.fromJson(tallaJson);
        
        // Assert
        expect(talla.id, equals('talla-912-001'));
        expect(talla.valor, equals('9-12'));
        expect(talla.tipo, equals(TipoTalla.rango));
        expect(talla.displayName, equals('9-12'));
      });

      test('should create Talla UNICA from JSON correctly', () {
        // Arrange
        final tallaJson = TestData.testTallas[2]; // 3 UNICA
        
        // Act
        final talla = Talla.fromJson(tallaJson);
        
        // Assert
        expect(talla.tipo, equals(TipoTalla.unica));
        expect(talla.valor, equals('3'));
      });

      test('should convert tipo enum correctly', () {
        // Arrange
        final tallaRangoJson = TestData.testTallas[0];
        final tallaUnicaJson = TestData.testTallas[2];
        
        // Act
        final tallaRango = Talla.fromJson(tallaRangoJson);
        final tallaUnica = Talla.fromJson(tallaUnicaJson);
        
        // Assert
        expect(tallaRango.toJson()['tipo'], equals('RANGO'));
        expect(tallaUnica.toJson()['tipo'], equals('UNICA'));
      });
    });

    // =====================================================
    // PRODUCTO MASTER MODEL TESTS
    // =====================================================
    
    group('ProductoMaster Model', () {
      test('should create ProductoMaster from JSON correctly', () {
        // Arrange
        final productoJson = TestData.testProductosMaster[0];
        
        // Act
        final producto = ProductoMaster.fromJson(productoJson);
        
        // Assert
        expect(producto.id, equals('producto-arley-912-001'));
        expect(producto.nombre, equals('Media fútbol polyester Arley 9-12'));
        expect(producto.precioSugerido, equals(12.50));
        expect(producto.activo, isTrue);
      });

      test('should handle copyWith correctly', () {
        // Arrange
        final producto = ProductoMaster.fromJson(TestData.testProductosMaster[0]);
        
        // Act
        final updatedProducto = producto.copyWith(
          nombre: 'Nuevo Nombre',
          precioSugerido: 15.00,
        );
        
        // Assert
        expect(updatedProducto.nombre, equals('Nuevo Nombre'));
        expect(updatedProducto.precioSugerido, equals(15.00));
        expect(updatedProducto.id, equals(producto.id)); // No changed
        expect(updatedProducto.marcaId, equals(producto.marcaId)); // No changed
      });

      test('should include relations when provided', () {
        // Arrange
        final productoJson = Map<String, dynamic>.from(TestData.testProductosMaster[0]);
        productoJson['marcas'] = TestData.testMarcas[0];
        productoJson['categorias'] = TestData.testCategorias[0];
        
        // Act
        final producto = ProductoMaster.fromJson(productoJson);
        
        // Assert
        expect(producto.marca, isNotNull);
        expect(producto.marca!.nombre, equals('Arley'));
        expect(producto.categoria, isNotNull);
        expect(producto.categoria!.nombre, equals('Medias'));
      });
    });

    // =====================================================
    // ARTICULO MODEL TESTS
    // =====================================================
    
    group('Articulo Model', () {
      test('should create Articulo from JSON correctly', () {
        // Arrange
        final articuloJson = TestData.testArticulos[0];
        
        // Act
        final articulo = Articulo.fromJson(articuloJson);
        
        // Assert
        expect(articulo.id, equals('articulo-arley-912-azul'));
        expect(articulo.sku, equals('MED-ARL-912-AZU'));
        expect(articulo.nombreCompleto, equals('Media fútbol polyester Arley 9-12 AZUL'));
        expect(articulo.codigoBarras, equals('7501234567890'));
      });

      test('should validate SKU format', () {
        // Arrange
        final articuloJson = TestData.testArticulos[0];
        final articulo = Articulo.fromJson(articuloJson);
        
        // Assert - SKU should follow pattern: CAT-MAR-TALLA-COLOR
        final skuParts = articulo.sku.split('-');
        expect(skuParts.length, equals(4));
        expect(skuParts[0], equals('MED')); // Categoria
        expect(skuParts[1], equals('ARL')); // Marca
        expect(skuParts[2], equals('912')); // Talla
        expect(skuParts[3], equals('AZU')); // Color
      });
    });

    // =====================================================
    // INVENTARIO TIENDA MODEL TESTS
    // =====================================================
    
    group('InventarioTienda Model', () {
      test('should create InventarioTienda from JSON correctly', () {
        // Arrange
        final inventarioJson = TestData.testInventario[0];
        
        // Act
        final inventario = InventarioTienda.fromJson(inventarioJson);
        
        // Assert
        expect(inventario.articuloId, equals('articulo-arley-912-azul'));
        expect(inventario.tiendaId, equals('tienda-gamarra-001'));
        expect(inventario.stockActual, equals(50));
        expect(inventario.precioLocal, equals(13.00));
      });

      test('should validate stock constraints', () {
        // Arrange
        final inventario = InventarioTienda.fromJson(TestData.testInventario[0]);
        
        // Assert
        expect(inventario.stockActual, greaterThanOrEqualTo(0));
        expect(inventario.stockMinimo, greaterThanOrEqualTo(0));
        expect(inventario.precioLocal, greaterThan(0));
      });
    });

    // =====================================================
    // CATALOGO COMPLETO MODEL TESTS
    // =====================================================
    
    group('CatalogoCompleto Model', () {
      test('should create CatalogoCompleto correctly', () {
        // Arrange
        final catalogo = TestData.sampleCatalogoCompleto[0];
        
        // Assert
        expect(catalogo.productoId, equals('producto-arley-912-001'));
        expect(catalogo.productoNombre, contains('Arley'));
        expect(catalogo.totalArticulos, equals(3));
        expect(catalogo.stockTotal, equals(128));
        expect(catalogo.coloresDisponibles, contains('AZUL'));
        expect(catalogo.tiendasConStock, equals(2));
      });

      test('should validate price relationships', () {
        // Arrange
        final catalogo = TestData.sampleCatalogoCompleto[0];
        
        // Assert
        expect(catalogo.precioMinimo, lessThanOrEqualTo(catalogo.precioMaximo));
        expect(catalogo.precioSugerido, greaterThan(0));
      });

      test('should validate stock and store relationships', () {
        // Arrange
        final catalogo = TestData.sampleCatalogoCompleto[0];
        
        // Assert
        expect(catalogo.stockTotal, greaterThanOrEqualTo(0));
        expect(catalogo.tiendasConStock, greaterThanOrEqualTo(0));
        expect(catalogo.totalArticulos, greaterThan(0));
      });
    });

    // =====================================================
    // PRODUCT FILTERS MODEL TESTS
    // =====================================================
    
    group('ProductFilters Model', () {
      test('should create empty filters correctly', () {
        // Arrange
        final filters = TestData.emptyFilters;
        
        // Assert
        expect(filters.hasFilters, isFalse);
        expect(filters.searchQuery, isNull);
        expect(filters.marcaIds, isEmpty);
        expect(filters.soloActivos, isTrue); // Default value
      });

      test('should detect filters correctly', () {
        // Arrange
        final filtersWithSearch = TestData.filtersWithSearch;
        final filtersWithMarca = TestData.filtersWithMarca;
        final complexFilters = TestData.complexFilters;
        
        // Assert
        expect(filtersWithSearch.hasFilters, isTrue);
        expect(filtersWithMarca.hasFilters, isTrue);
        expect(complexFilters.hasFilters, isTrue);
      });

      test('should copyWith work correctly', () {
        // Arrange
        final originalFilters = TestData.filtersWithSearch;
        
        // Act
        final updatedFilters = originalFilters.copyWith(
          marcaIds: ['nueva-marca'],
          soloConStock: true,
        );
        
        // Assert
        expect(updatedFilters.searchQuery, equals('Arley')); // Preserved
        expect(updatedFilters.marcaIds, equals(['nueva-marca'])); // Updated
        expect(updatedFilters.soloConStock, isTrue); // Updated
      });

      test('should validate price range filters', () {
        // Arrange
        final priceFilters = TestData.filtersWithPriceRange;
        
        // Assert
        expect(priceFilters.precioMinimo, isNotNull);
        expect(priceFilters.precioMaximo, isNotNull);
        expect(priceFilters.precioMinimo!, lessThanOrEqualTo(priceFilters.precioMaximo!));
      });
    });

    // =====================================================
    // PAGINATION PARAMS MODEL TESTS
    // =====================================================
    
    group('PaginationParams Model', () {
      test('should create default pagination correctly', () {
        // Arrange
        const pagination = PaginationParams();
        
        // Assert
        expect(pagination.page, equals(1));
        expect(pagination.pageSize, equals(20));
        expect(pagination.offset, equals(0));
        expect(pagination.descending, isFalse);
      });

      test('should calculate offset correctly', () {
        // Arrange
        const page1 = PaginationParams(page: 1, pageSize: 10);
        const page2 = PaginationParams(page: 2, pageSize: 10);
        const page3 = PaginationParams(page: 3, pageSize: 15);
        
        // Assert
        expect(page1.offset, equals(0));
        expect(page2.offset, equals(10));
        expect(page3.offset, equals(30));
      });

      test('should copyWith work correctly', () {
        // Arrange
        const original = PaginationParams();
        
        // Act
        final updated = original.copyWith(
          page: 5,
          pageSize: 50,
        );
        
        // Assert
        expect(updated.page, equals(5));
        expect(updated.pageSize, equals(50));
        expect(updated.orderBy, isNull); // Preserved
      });
    });

    // =====================================================
    // PAGINATED RESULT MODEL TESTS
    // =====================================================
    
    group('PaginatedResult Model', () {
      test('should calculate pagination info correctly', () {
        // Arrange
        const result = PaginatedResult<String>(
          data: ['item1', 'item2', 'item3'],
          totalCount: 25,
          currentPage: 2,
          pageSize: 10,
        );
        
        // Assert
        expect(result.hasNextPage, isTrue); // 2 * 10 = 20 < 25
        expect(result.hasPreviousPage, isTrue); // page 2 > 1
        expect(result.totalPages, equals(3)); // ceil(25 / 10)
      });

      test('should handle edge cases correctly', () {
        // Arrange - First page
        const firstPage = PaginatedResult<String>(
          data: ['item1'],
          totalCount: 5,
          currentPage: 1,
          pageSize: 10,
        );
        
        // Arrange - Last page
        const lastPage = PaginatedResult<String>(
          data: ['item1'],
          totalCount: 5,
          currentPage: 1,
          pageSize: 5,
        );
        
        // Assert
        expect(firstPage.hasPreviousPage, isFalse);
        expect(firstPage.hasNextPage, isFalse);
        expect(lastPage.hasNextPage, isFalse);
      });
    });

    // =====================================================
    // INTEGRATION TESTS FOR RELATED MODELS
    // =====================================================
    
    group('Model Integration Tests', () {
      test('should work together in complex scenarios', () {
        // Arrange
        final filters = TestData.complexFilters;
        final pagination = TestData.customPagination;
        final productos = TestData.sampleCatalogoCompleto;
        
        // Act
        final result = PaginatedResult(
          data: productos,
          totalCount: 100,
          currentPage: pagination.page,
          pageSize: pagination.pageSize,
        );
        
        // Assert
        expect(result.data.length, equals(2));
        expect(result.currentPage, equals(2));
        expect(filters.hasFilters, isTrue);
        expect(filters.marcaIds.length, equals(2));
      });

      test('should maintain data consistency across models', () {
        // Arrange
        final productoMaster = ProductoMaster.fromJson(TestData.testProductosMaster[0]);
        final articulo = Articulo.fromJson(TestData.testArticulos[0]);
        final inventario = InventarioTienda.fromJson(TestData.testInventario[0]);
        
        // Assert - Check relationships
        expect(articulo.productoId, equals(productoMaster.id));
        expect(inventario.articuloId, equals(articulo.id));
      });
    });

    // =====================================================
    // ERROR HANDLING TESTS
    // =====================================================
    
    group('Error Handling', () {
      test('should handle malformed JSON gracefully', () {
        // Arrange
        final malformedJson = <String, dynamic>{
          'id': null, // Invalid ID
          'nombre': '', // Empty name
        };
        
        // Act & Assert
        expect(
          () => Marca.fromJson(malformedJson),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle missing required fields', () {
        // Arrange
        final incompleteJson = <String, dynamic>{
          'id': 'test-id',
          // Missing 'nombre' field
        };
        
        // Act & Assert
        expect(
          () => Marca.fromJson(incompleteJson),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}