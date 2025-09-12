import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../lib/presentation/bloc/products/products_bloc.dart';
import '../../../../lib/presentation/bloc/products/products_event.dart';
import '../../../../lib/presentation/bloc/products/products_state.dart';
import '../../../../lib/data/repositories/products_repository_simple.dart';
import '../../../../lib/data/models/product_models.dart';
import '../../../fixtures/test_data.dart';

// Generate mocks
@GenerateNiceMocks([MockSpec<ProductsRepository>(), MockSpec<RealtimeChannel>()])
import 'products_bloc_test.mocks.dart';

void main() {
  group('ProductsBloc Unit Tests', () {
    late ProductsBloc productsBloc;
    late MockProductsRepository mockRepository;
    late MockRealtimeChannel mockRealtimeChannel;

    setUp(() {
      mockRepository = MockProductsRepository();
      mockRealtimeChannel = MockRealtimeChannel();
      productsBloc = ProductsBloc(repository: mockRepository);
    });

    tearDown(() {
      productsBloc.close();
    });

    // =====================================================
    // INITIAL STATE TESTS
    // =====================================================

    test('initial state should be ProductsInitial', () {
      expect(productsBloc.state, equals(const ProductsInitial()));
    });

    // =====================================================
    // LOAD PRODUCTS TESTS
    // =====================================================

    group('LoadProducts Event', () {
      blocTest<ProductsBloc, ProductsState>(
        'should emit [ProductsLoading, ProductsLoaded] when LoadProducts succeeds',
        build: () {
          // Arrange mocks
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: TestData.sampleCatalogoCompleto,
            totalCount: 2,
            currentPage: 1,
            pageSize: 20,
          ));

          when(mockRepository.getMarcas()).thenAnswer((_) async => [
            Marca.fromJson(TestData.testMarcas[0]),
            Marca.fromJson(TestData.testMarcas[1]),
          ]);

          when(mockRepository.getCategorias()).thenAnswer((_) async => [
            Categoria.fromJson(TestData.testCategorias[0]),
          ]);

          when(mockRepository.getTallas()).thenAnswer((_) async => [
            Talla.fromJson(TestData.testTallas[0]),
          ]);

          return productsBloc;
        },
        act: (bloc) => bloc.add(const LoadProducts()),
        expect: () => [
          const ProductsLoading(),
          isA<ProductsLoaded>().having(
            (state) => state.products.length,
            'products length',
            equals(2),
          ),
        ],
      );

      blocTest<ProductsBloc, ProductsState>(
        'should emit [ProductsLoading, ProductsError] when LoadProducts fails',
        build: () {
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenThrow(Exception('Database connection error'));

          return productsBloc;
        },
        act: (bloc) => bloc.add(const LoadProducts()),
        expect: () => [
          const ProductsLoading(),
          isA<ProductsError>().having(
            (state) => state.message,
            'error message',
            contains('Database connection error'),
          ),
        ],
      );

      blocTest<ProductsBloc, ProductsState>(
        'should load products with filters correctly',
        build: () {
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: [TestData.sampleCatalogoCompleto[0]], // Filtered result
            totalCount: 1,
            currentPage: 1,
            pageSize: 20,
          ));

          when(mockRepository.getMarcas()).thenAnswer((_) async => []);
          when(mockRepository.getCategorias()).thenAnswer((_) async => []);
          when(mockRepository.getTallas()).thenAnswer((_) async => []);

          return productsBloc;
        },
        act: (bloc) => bloc.add(LoadProducts(
          filters: TestData.filtersWithSearch,
        )),
        expect: () => [
          const ProductsLoading(),
          isA<ProductsLoaded>().having(
            (state) => state.products.length,
            'filtered products length',
            equals(1),
          ),
        ],
      );
    });

    // =====================================================
    // SEARCH PRODUCTS TESTS
    // =====================================================

    group('SearchProducts Event', () {
      blocTest<ProductsBloc, ProductsState>(
        'should search products and update state correctly',
        build: () {
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: [TestData.sampleCatalogoCompleto[0]], // Search result
            totalCount: 1,
            currentPage: 1,
            pageSize: 20,
          ));

          return productsBloc;
        },
        seed: () => ProductsLoaded(
          products: TestData.sampleCatalogoCompleto,
          totalCount: 2,
          currentPage: 1,
          hasNextPage: false,
          filters: const ProductFilters(),
          pagination: const PaginationParams(),
          marcas: const [],
          categorias: const [],
          tallas: const [],
        ),
        act: (bloc) => bloc.add(const SearchProducts('Arley')),
        expect: () => [
          isA<ProductsLoaded>().having(
            (state) => state.isSearching,
            'is searching',
            isTrue,
          ),
          isA<ProductsLoaded>().having(
            (state) => state.filters.searchQuery,
            'search query',
            equals('Arley'),
          ),
        ],
      );

      blocTest<ProductsBloc, ProductsState>(
        'should clear search when query is empty',
        build: () {
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: TestData.sampleCatalogoCompleto,
            totalCount: 2,
            currentPage: 1,
            pageSize: 20,
          ));

          return productsBloc;
        },
        seed: () => ProductsLoaded(
          products: [TestData.sampleCatalogoCompleto[0]],
          totalCount: 1,
          currentPage: 1,
          hasNextPage: false,
          filters: TestData.filtersWithSearch,
          pagination: const PaginationParams(),
          marcas: const [],
          categorias: const [],
          tallas: const [],
        ),
        act: (bloc) => bloc.add(const SearchProducts('')),
        expect: () => [
          isA<ProductsLoaded>().having(
            (state) => state.isSearching,
            'is searching',
            isTrue,
          ),
          isA<ProductsLoaded>().having(
            (state) => state.filters.searchQuery,
            'search query cleared',
            isNull,
          ),
        ],
      );
    });

    // =====================================================
    // CREATE PRODUCT TESTS
    // =====================================================

    group('CreateProduct Event', () {
      blocTest<ProductsBloc, ProductsState>(
        'should create product successfully',
        build: () {
          final newProduct = ProductoMaster.fromJson(TestData.testProductosMaster[0]);
          
          when(mockRepository.createProductoMaster(any))
              .thenAnswer((_) async => newProduct);
          
          when(mockRepository.createArticulos(any, any))
              .thenAnswer((_) async => []);
          
          when(mockRepository.getArticulosByProductoId(any))
              .thenAnswer((_) async => []);

          // Mock for refresh after creation
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: TestData.sampleCatalogoCompleto,
            totalCount: 2,
            currentPage: 1,
            pageSize: 20,
          ));

          when(mockRepository.getMarcas()).thenAnswer((_) async => []);
          when(mockRepository.getCategorias()).thenAnswer((_) async => []);
          when(mockRepository.getTallas()).thenAnswer((_) async => []);

          return productsBloc;
        },
        act: (bloc) => bloc.add(CreateProduct(
          productData: TestData.testProductosMaster[0],
          colores: ['color-azul-001'],
          inventarioInicial: [],
        )),
        expect: () => [
          const ProductsCreating(),
          isA<ProductCreated>(),
          const ProductsLoading(), // From refresh
          isA<ProductsLoaded>(),
        ],
      );

      blocTest<ProductsBloc, ProductsState>(
        'should handle create product with inventory setup',
        build: () {
          final newProduct = ProductoMaster.fromJson(TestData.testProductosMaster[0]);
          final articulo = Articulo.fromJson(TestData.testArticulos[0]);
          
          when(mockRepository.createProductoMaster(any))
              .thenAnswer((_) async => newProduct);
          
          when(mockRepository.createArticulos(any, any))
              .thenAnswer((_) async => []);
          
          when(mockRepository.getArticulosByProductoId(any))
              .thenAnswer((_) async => [articulo]);

          // Simplificar mock para updateInventarioTienda
          when(mockRepository.updateInventarioTienda(any, any, any))
              .thenAnswer((_) async => {});

          // Mock refresh
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: TestData.sampleCatalogoCompleto,
            totalCount: 2,
            currentPage: 1,
            pageSize: 20,
          ));

          when(mockRepository.getMarcas()).thenAnswer((_) async => []);
          when(mockRepository.getCategorias()).thenAnswer((_) async => []);
          when(mockRepository.getTallas()).thenAnswer((_) async => []);

          return productsBloc;
        },
        act: (bloc) => bloc.add(CreateProduct(
          productData: TestData.testProductosMaster[0],
          colores: ['color-azul-001'],
          inventarioInicial: [
            {
              'tienda_id': 'tienda-gamarra-001',
              'stock_inicial': 50,
              'precio_local': 13.00,
            }
          ],
        )),
        expect: () => [
          const ProductsCreating(),
          isA<ProductCreated>(),
          const ProductsLoading(),
          isA<ProductsLoaded>(),
        ],
      );

      blocTest<ProductsBloc, ProductsState>(
        'should emit error when create product fails',
        build: () {
          when(mockRepository.createProductoMaster(any))
              .thenThrow(Exception('SKU already exists'));

          return productsBloc;
        },
        act: (bloc) => bloc.add(CreateProduct(
          productData: TestData.testProductosMaster[0],
          colores: ['color-azul-001'],
          inventarioInicial: [],
        )),
        expect: () => [
          const ProductsCreating(),
          isA<ProductsError>().having(
            (state) => state.message,
            'error message',
            contains('SKU already exists'),
          ),
        ],
      );
    });

    // =====================================================
    // UPDATE PRODUCT TESTS
    // =====================================================

    group('UpdateProduct Event', () {
      blocTest<ProductsBloc, ProductsState>(
        'should update product successfully',
        build: () {
          final updatedProduct = ProductoMaster.fromJson(TestData.testProductosMaster[0])
              .copyWith(nombre: 'Updated Product Name');
          
          when(mockRepository.updateProductoMaster(any, any))
              .thenAnswer((_) async => updatedProduct);

          return productsBloc;
        },
        seed: () => ProductsLoaded(
          products: TestData.sampleCatalogoCompleto,
          totalCount: 2,
          currentPage: 1,
          hasNextPage: false,
          filters: const ProductFilters(),
          pagination: const PaginationParams(),
          marcas: const [],
          categorias: const [],
          tallas: const [],
        ),
        act: (bloc) => bloc.add(UpdateProduct(
          productId: 'producto-arley-912-001',
          updateData: {'nombre': 'Updated Product Name'},
        )),
        expect: () => [
          isA<ProductUpdated>(),
          isA<ProductsLoaded>().having(
            (state) => state.products
                .firstWhere((p) => p.productoId == 'producto-arley-912-001')
                .productoNombre,
            'updated product name',
            equals('Updated Product Name'),
          ),
        ],
      );
    });

    // =====================================================
    // LOAD MORE PRODUCTS TESTS
    // =====================================================

    group('LoadMoreProducts Event', () {
      blocTest<ProductsBloc, ProductsState>(
        'should load more products and append to existing list',
        build: () {
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: [TestData.sampleCatalogoCompleto[1]], // Second page
            totalCount: 2,
            currentPage: 2,
            pageSize: 1,
          ));

          return productsBloc;
        },
        seed: () => ProductsLoaded(
          products: [TestData.sampleCatalogoCompleto[0]], // First page
          totalCount: 2,
          currentPage: 1,
          hasNextPage: true,
          filters: const ProductFilters(),
          pagination: const PaginationParams(pageSize: 1),
          marcas: const [],
          categorias: const [],
          tallas: const [],
        ),
        act: (bloc) => bloc.add(const LoadMoreProducts()),
        expect: () => [
          isA<ProductsLoaded>().having(
            (state) => state.isLoadingMore,
            'is loading more',
            isTrue,
          ),
          isA<ProductsLoaded>().having(
            (state) => state.products.length,
            'products length after load more',
            equals(2),
          ),
        ],
      );

      blocTest<ProductsBloc, ProductsState>(
        'should not load more when no next page',
        build: () => productsBloc,
        seed: () => ProductsLoaded(
          products: TestData.sampleCatalogoCompleto,
          totalCount: 2,
          currentPage: 1,
          hasNextPage: false, // No next page
          filters: const ProductFilters(),
          pagination: const PaginationParams(),
          marcas: const [],
          categorias: const [],
          tallas: const [],
        ),
        act: (bloc) => bloc.add(const LoadMoreProducts()),
        expect: () => [], // Should not emit any state
      );
    });

    // =====================================================
    // REALTIME UPDATES TESTS
    // =====================================================

    group('RealTime Updates', () {
      blocTest<ProductsBloc, ProductsState>(
        'should subscribe to realtime changes',
        build: () {
          // Simplificar mocks de suscripciones
          when(mockRepository.subscribeToProductsChanges())
              .thenAnswer((_) => Stream.value([]));

          when(mockRepository.subscribeToInventoryChanges(any))
              .thenAnswer((_) => Stream.value([]));

          return productsBloc;
        },
        act: (bloc) => bloc.add(const SubscribeToChanges()),
        expect: () => [],
        verify: (_) {
          verify(mockRepository.subscribeToProductsChanges()).called(1);
          verify(mockRepository.subscribeToInventoryChanges(any)).called(1);
        },
      );

      blocTest<ProductsBloc, ProductsState>(
        'should handle product deletion realtime update',
        build: () => productsBloc,
        seed: () => ProductsLoaded(
          products: TestData.sampleCatalogoCompleto,
          totalCount: 2,
          currentPage: 1,
          hasNextPage: false,
          filters: const ProductFilters(),
          pagination: const PaginationParams(),
          marcas: const [],
          categorias: const [],
          tallas: const [],
        ),
        act: (bloc) => bloc.add(ProductRealTimeUpdate(
          {'id': 'producto-arley-912-001'},
          'DELETE',
        )),
        expect: () => [
          isA<ProductsLoaded>().having(
            (state) => state.products.length,
            'products length after deletion',
            equals(1),
          ),
        ],
      );
    });

    // =====================================================
    // ERROR HANDLING TESTS
    // =====================================================

    group('Error Handling', () {
      blocTest<ProductsBloc, ProductsState>(
        'should handle repository errors gracefully',
        build: () {
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenThrow(Exception('Network timeout'));

          return productsBloc;
        },
        act: (bloc) => bloc.add(const LoadProducts()),
        expect: () => [
          const ProductsLoading(),
          isA<ProductsError>().having(
            (state) => state.message,
            'error message',
            contains('Network timeout'),
          ),
        ],
      );

      blocTest<ProductsBloc, ProductsState>(
        'should handle search errors without crashing',
        build: () {
          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenThrow(Exception('Search service unavailable'));

          return productsBloc;
        },
        seed: () => ProductsLoaded(
          products: TestData.sampleCatalogoCompleto,
          totalCount: 2,
          currentPage: 1,
          hasNextPage: false,
          filters: const ProductFilters(),
          pagination: const PaginationParams(),
          marcas: const [],
          categorias: const [],
          tallas: const [],
        ),
        act: (bloc) => bloc.add(const SearchProducts('test')),
        expect: () => [
          isA<ProductsLoaded>().having(
            (state) => state.isSearching,
            'is searching',
            isTrue,
          ),
          isA<ProductsLoaded>().having(
            (state) => state.error,
            'error message',
            contains('Search service unavailable'),
          ),
        ],
      );
    });

    // =====================================================
    // PERFORMANCE TESTS
    // =====================================================

    group('Performance Tests', () {
      blocTest<ProductsBloc, ProductsState>(
        'should handle large datasets efficiently',
        build: () {
          // Generate large dataset
          final largeDataset = List.generate(1000, (index) => 
            CatalogoCompleto(
              productoId: 'producto-$index',
              productoNombre: 'Producto $index',
              marcaNombre: 'Marca ${index % 10}',
              categoriaNombre: 'Categoria ${index % 5}',
              tallaValor: '${index % 3}-${(index % 3) + 3}',
              precioSugerido: 10.0 + (index % 50),
              totalArticulos: index % 5 + 1,
              stockTotal: index % 100,
              precioMinimo: 10.0 + (index % 50),
              precioMaximo: 15.0 + (index % 50),
              coloresDisponibles: ['COLOR${index % 5}'],
              tiendasConStock: index % 3 + 1,
            ),
          );

          when(mockRepository.getCatalogoCompleto(
            filters: anyNamed('filters'),
            pagination: anyNamed('pagination'),
          )).thenAnswer((_) async => PaginatedResult<CatalogoCompleto>(
            data: largeDataset,
            totalCount: 1000,
            currentPage: 1,
            pageSize: 1000,
          ));

          when(mockRepository.getMarcas()).thenAnswer((_) async => []);
          when(mockRepository.getCategorias()).thenAnswer((_) async => []);
          when(mockRepository.getTallas()).thenAnswer((_) async => []);

          return productsBloc;
        },
        act: (bloc) => bloc.add(const LoadProducts()),
        expect: () => [
          const ProductsLoading(),
          isA<ProductsLoaded>().having(
            (state) => state.products.length,
            'large dataset loaded',
            equals(1000),
          ),
        ],
      );
    });
  });
}