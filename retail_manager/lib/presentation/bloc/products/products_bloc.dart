import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository _repository;

  ProductsBloc({required ProductsRepository repository})
      : _repository = repository,
        super(const ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProducts>(_onFilterProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<RefreshProducts>(_onRefreshProducts);
    on<SubscribeToChanges>(_onSubscribeToChanges);
    on<UnsubscribeFromChanges>(_onUnsubscribeFromChanges);
    on<ProductRealTimeUpdate>(_onProductRealTimeUpdate);
    on<LoadInitialProductData>(_onLoadInitialProductData);
    on<UpdateProductoMaster>(_onUpdateProductoMaster);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      print('🔄 [ProductsBloc] Iniciando carga de productos...');
      
      print('🔄 [ProductsBloc] Cargando catálogo completo...');
      final result = await _repository.getCatalogoCompleto(
        filters: event.filters,
        pagination: event.pagination,
      );
      print('✅ [ProductsBloc] Catálogo cargado: ${result.data.length} productos');

      print('🔄 [ProductsBloc] Cargando marcas...');
      final marcas = await _repository.getMarcas();
      print('✅ [ProductsBloc] Marcas cargadas: ${marcas.length} marcas');

      print('🔄 [ProductsBloc] Cargando categorías...');
      final categorias = await _repository.getCategorias();
      print('✅ [ProductsBloc] Categorías cargadas: ${categorias.length} categorías');

      print('🔄 [ProductsBloc] Cargando tallas...');
      final tallas = await _repository.getTallas();
      print('✅ [ProductsBloc] Tallas cargadas: ${tallas.length} tallas');

      print('✅ [ProductsBloc] Emitiendo ProductsLoaded...');
      emit(ProductsLoaded(
        products: result.data,
        totalCount: result.totalCount,
        currentPage: result.currentPage,
        hasNextPage: result.hasNextPage,
        filters: event.filters ?? const ProductFilters(),
        pagination: event.pagination ?? const PaginationParams(),
        marcas: marcas,
        categorias: categorias,
        tallas: tallas,
      ));
      print('🎉 [ProductsBloc] ProductsLoaded emitido exitosamente');
    } catch (e, stackTrace) {
      print('❌ [ProductsBloc] Error al cargar productos: $e');
      print('📊 [ProductsBloc] StackTrace: $stackTrace');
      emit(ProductsError('Error al cargar productos: $e'));
    }
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      emit((state as ProductsLoaded).copyWith(isLoadingDetails: true));
    }

    try {
      final producto = await _repository.getProductoMasterById(event.productId);
      final articulos = await _repository.getArticulosByProductoId(event.productId);

      if (state is ProductsLoaded) {
        emit((state as ProductsLoaded).copyWith(
          selectedProduct: producto,
          selectedProductArticulos: articulos,
          isLoadingDetails: false,
        ));
      } else {
        // Si no hay estado previo, cargar con solo el producto seleccionado
        if (producto != null) {
          emit(ProductDetailsLoaded(
            product: producto,
            articulos: articulos,
          ));
        } else {
          emit(ProductsError('Producto no encontrado'));
        }
      }
    } catch (e) {
      if (state is ProductsLoaded) {
        emit((state as ProductsLoaded).copyWith(
          isLoadingDetails: false,
          error: 'Error al cargar detalles: $e',
        ));
      } else {
        emit(ProductsError('Error al cargar producto: $e'));
      }
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final newFilters = currentState.filters.copyWith(
        searchQuery: event.query.isEmpty ? null : event.query,
      );

      emit(currentState.copyWith(isSearching: true));

      try {
        final result = await _repository.getCatalogoCompleto(
          filters: newFilters,
          pagination: const PaginationParams(),
        );

        emit(currentState.copyWith(
          products: result.data,
          totalCount: result.totalCount,
          currentPage: 1,
          hasNextPage: result.hasNextPage,
          filters: newFilters,
          pagination: const PaginationParams(),
          isSearching: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isSearching: false,
          error: 'Error en búsqueda: $e',
        ));
      }
    }
  }

  Future<void> _onFilterProducts(
    FilterProducts event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      emit(currentState.copyWith(isLoading: true));

      try {
        final result = await _repository.getCatalogoCompleto(
          filters: event.filters,
          pagination: const PaginationParams(),
        );

        emit(currentState.copyWith(
          products: result.data,
          totalCount: result.totalCount,
          currentPage: 1,
          hasNextPage: result.hasNextPage,
          filters: event.filters,
          pagination: const PaginationParams(),
          isLoading: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoading: false,
          error: 'Error al filtrar: $e',
        ));
      }
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      
      if (!currentState.hasNextPage || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final nextPage = currentState.currentPage + 1;
        final newPagination = currentState.pagination.copyWith(page: nextPage);

        final result = await _repository.getCatalogoCompleto(
          filters: currentState.filters,
          pagination: newPagination,
        );

        final allProducts = [...currentState.products, ...result.data];

        emit(currentState.copyWith(
          products: allProducts,
          currentPage: nextPage,
          hasNextPage: result.hasNextPage,
          pagination: newPagination,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isLoadingMore: false,
          error: 'Error al cargar más productos: $e',
        ));
      }
    }
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      print('');
      print('🏭 [PRODUCTS_BLOC] ==================== CREAR PRODUCTO ====================');
      print('📋 Datos recibidos:');
      print('   • productData: ${event.productData}');
      print('   • colores: ${event.colores} (${event.colores.length} colores)');
      print('   • inventarioInicial: ${event.inventarioInicial.length} entradas');
      print('');

      emit(const ProductsCreating());

      print('🔧 [PASO_1] Creando producto master...');
      final producto = await _repository.createProductoMaster(event.productData);
      print('✅ Producto master creado con ID: ${producto.id}');
      print('   Nombre: ${producto.nombre}');
      print('');

      // Si se especificaron colores, crear los artículos
      if (event.colores.isNotEmpty) {
        print('🎨 [PASO_2] Creando artículos para ${event.colores.length} colores...');
        print('   Colores IDs: ${event.colores}');

        final articulosCreados = await _repository.createArticulos(producto.id, event.colores);

        print('✅ Artículos creados: ${articulosCreados.length}');
        for (int i = 0; i < articulosCreados.length; i++) {
          final articulo = articulosCreados[i];
          print('   ${i+1}. ID: ${articulo.id} | SKU: ${articulo.skuAuto} | Color ID: ${articulo.colorId}');
        }
        print('');
      } else {
        print('⚠️ [PASO_2] No se especificaron colores - NO se crearán artículos');
      }

      // Configurar inventario inicial si se especificó
      if (event.inventarioInicial.isNotEmpty) {
        print('🏪 [PASO_3] Configurando inventario inicial...');
        final articulos = await _repository.getArticulosByProductoId(producto.id);
        print('   Artículos encontrados para inventario: ${articulos.length}');

        for (final articulo in articulos) {
          print('   Configurando inventario para artículo: ${articulo.skuAuto}');

          for (final inventario in event.inventarioInicial) {
            if (inventario['tienda_id'] != null) {
              final stockInicial = inventario['stock_inicial'] ?? 0;
              final precioLocal = inventario['precio_local'] ?? articulo.precioSugerido;

              print('     • Tienda ID: ${inventario['tienda_id']}');
              print('       Stock inicial: $stockInicial');
              print('       Precio local: $precioLocal');

              await _repository.updateInventarioTienda(
                articulo.id,
                inventario['tienda_id'],
                {
                  'stock_actual': stockInicial,
                  'precio_venta': precioLocal,
                },
              );
              print('       ✅ Inventario configurado');
            }
          }
        }
        print('✅ Inventario inicial configurado para todos los artículos');
        print('');
      } else {
        print('⚠️ [PASO_3] No se especificó inventario inicial');
      }

      print('🎉 [PRODUCTS_BLOC] ¡PRODUCTO CREADO EXITOSAMENTE!');
      print('==================== FIN CREAR PRODUCTO ====================');
      print('');

      emit(ProductCreated(producto));

      // Recargar la lista
      add(RefreshProducts());
    } catch (e) {
      print('❌ [PRODUCTS_BLOC] ERROR al crear producto: $e');
      emit(ProductsError('Error al crear producto: $e'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final producto = await _repository.updateProductoMaster(
        event.productId,
        event.updateData,
      );

      emit(ProductUpdated(producto));

      // Actualizar el estado actual si existe
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = currentState.products.map((p) {
          if (p.productoId == event.productId) {
            // Crear una nueva instancia de CatalogoCompleto con los datos actualizados
            return CatalogoCompleto(
              productoId: p.productoId,
              productoNombre: event.updateData['nombre'] ?? p.productoNombre,
              marcaNombre: p.marcaNombre,
              categoriaNombre: p.categoriaNombre,
              tallaValor: p.tallaValor,
              precioSugerido: event.updateData['precio_sugerido']?.toDouble() ?? p.precioSugerido,
              totalArticulos: p.totalArticulos,
              stockTotal: p.stockTotal,
              precioMinimo: p.precioMinimo,
              precioMaximo: p.precioMaximo,
              coloresDisponibles: p.coloresDisponibles,
              tiendasConStock: p.tiendasConStock,
            );
          }
          return p;
        }).toList();

        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductsError('Error al actualizar producto: $e'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      await _repository.deleteProductoMaster(event.productId);
      
      emit(const ProductDeleted());

      // Recargar la lista
      add(RefreshProducts());
    } catch (e) {
      emit(ProductsError('Error al eliminar producto: $e'));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      add(LoadProducts(
        filters: currentState.filters,
        pagination: const PaginationParams(),
      ));
    } else {
      add(const LoadProducts());
    }
  }

  Future<void> _onSubscribeToChanges(
    SubscribeToChanges event,
    Emitter<ProductsState> emit,
  ) async {
    // Simplificar las suscripciones por ahora para que compile
    try {
      _repository.subscribeToProductsChanges().listen((productos) {
        add(ProductRealTimeUpdate({}, 'PRODUCTS_UPDATED'));
      });
      
      _repository.subscribeToInventoryChanges('11111111-1111-1111-1111-111111111111').listen((inventarios) {
        add(ProductRealTimeUpdate({}, 'INVENTORY_UPDATED'));
      });
    } catch (e) {
      // Ignorar errores de suscripción por ahora
    }
  }

  Future<void> _onUnsubscribeFromChanges(
    UnsubscribeFromChanges event,
    Emitter<ProductsState> emit,
  ) async {
    // Simplificar por ahora - no hay canales que cancelar
  }

  void _onProductRealTimeUpdate(
    ProductRealTimeUpdate event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      
      switch (event.eventType) {
        case 'INSERT':
        case 'UPDATE':
          // Recargar los productos para mantener la consistencia
          add(RefreshProducts());
          break;
        case 'DELETE':
          // Remover el producto eliminado de la lista actual
          final updatedProducts = currentState.products
              .where((p) => p.productoId != event.data['id'])
              .toList();
          
          emit(currentState.copyWith(
            products: updatedProducts,
            totalCount: currentState.totalCount - 1,
          ));
          break;
        case 'INVENTORY_UPDATE':
          // Para cambios de inventario, se podría actualizar solo los stocks
          // Por simplicidad, recargamos todo
          add(RefreshProducts());
          break;
      }
    }
  }

  /// Handler para cargar datos iniciales para formularios
  Future<void> _onLoadInitialProductData(
    LoadInitialProductData event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final marcas = await _repository.getMarcas();
      final categorias = await _repository.getCategorias();
      final materiales = await _repository.getMateriales();
      final tallas = await _repository.getTallas();
      final colores = await _repository.getColores();

      emit(InitialProductDataLoaded(
        marcas: marcas,
        categorias: categorias,
        materiales: materiales,
        tallas: tallas,
        colores: colores,
      ));
    } catch (e) {
      emit(ProductsError("Error al cargar datos iniciales: $e"));
    }
  }

  /// Handler para actualizar producto master específicamente
  Future<void> _onUpdateProductoMaster(
    UpdateProductoMaster event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      final updatedProduct = await _repository.updateProductoMaster(
        event.productId,
        event.updateData,
      );
      emit(ProductUpdated(updatedProduct));
    } catch (e) {
      emit(ProductsError("Error al actualizar producto: $e"));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}