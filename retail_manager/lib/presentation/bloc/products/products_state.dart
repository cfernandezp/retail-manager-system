part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

/// Estado de carga
class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

/// Estado con productos cargados
class ProductsLoaded extends ProductsState {
  final List<CatalogoCompleto> products;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;
  final ProductFilters filters;
  final PaginationParams pagination;
  final List<Marca> marcas;
  final List<Categoria> categorias;
  final List<Talla> tallas;
  final bool isLoading;
  final bool isSearching;
  final bool isLoadingMore;
  final bool isLoadingDetails;
  final ProductoMaster? selectedProduct;
  final List<Articulo>? selectedProductArticulos;
  final String? error;

  const ProductsLoaded({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.hasNextPage,
    required this.filters,
    required this.pagination,
    required this.marcas,
    required this.categorias,
    required this.tallas,
    this.isLoading = false,
    this.isSearching = false,
    this.isLoadingMore = false,
    this.isLoadingDetails = false,
    this.selectedProduct,
    this.selectedProductArticulos,
    this.error,
  });

  ProductsLoaded copyWith({
    List<CatalogoCompleto>? products,
    int? totalCount,
    int? currentPage,
    bool? hasNextPage,
    ProductFilters? filters,
    PaginationParams? pagination,
    List<Marca>? marcas,
    List<Categoria>? categorias,
    List<Talla>? tallas,
    bool? isLoading,
    bool? isSearching,
    bool? isLoadingMore,
    bool? isLoadingDetails,
    ProductoMaster? selectedProduct,
    List<Articulo>? selectedProductArticulos,
    String? error,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      filters: filters ?? this.filters,
      pagination: pagination ?? this.pagination,
      marcas: marcas ?? this.marcas,
      categorias: categorias ?? this.categorias,
      tallas: tallas ?? this.tallas,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedProductArticulos: selectedProductArticulos ?? this.selectedProductArticulos,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        products,
        totalCount,
        currentPage,
        hasNextPage,
        filters,
        pagination,
        marcas,
        categorias,
        tallas,
        isLoading,
        isSearching,
        isLoadingMore,
        isLoadingDetails,
        selectedProduct,
        selectedProductArticulos,
        error,
      ];
}

/// Estado de detalles de producto cargados (para cuando no hay lista previa)
class ProductDetailsLoaded extends ProductsState {
  final ProductoMaster product;
  final List<Articulo> articulos;

  const ProductDetailsLoaded({
    required this.product,
    required this.articulos,
  });

  @override
  List<Object?> get props => [product, articulos];
}

/// Estado de creación de producto
class ProductsCreating extends ProductsState {
  const ProductsCreating();
}

/// Estado de producto creado exitosamente
class ProductCreated extends ProductsState {
  final ProductoMaster product;

  const ProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Estado de producto actualizado exitosamente
class ProductUpdated extends ProductsState {
  final ProductoMaster product;

  const ProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Estado de producto eliminado exitosamente
class ProductDeleted extends ProductsState {
  const ProductDeleted();
}

/// Estado de error
class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de exportación
class ProductsExporting extends ProductsState {
  const ProductsExporting();
}

/// Estado de exportación completada
class ProductsExported extends ProductsState {
  final String filePath;
  final String format;

  const ProductsExported({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object?> get props => [filePath, format];
}

/// Estado de importación
class ProductsImporting extends ProductsState {
  const ProductsImporting();
}

/// Estado de importación completada
class ProductsImported extends ProductsState {
  final int importedCount;
  final int errorCount;
  final List<String>? errors;

  const ProductsImported({
    required this.importedCount,
    required this.errorCount,
    this.errors,
  });

  @override
  List<Object?> get props => [importedCount, errorCount, errors];
}

/// Estado de datos iniciales cargados para formularios
class InitialProductDataLoaded extends ProductsState {
  final List<Marca> marcas;
  final List<Categoria> categorias;
  final List<MaterialModel> materiales;
  final List<Talla> tallas;
  final List<ColorData> colores;

  const InitialProductDataLoaded({
    required this.marcas,
    required this.categorias,
    required this.materiales,
    required this.tallas,
    required this.colores,
  });

  @override
  List<Object?> get props => [marcas, categorias, materiales, tallas, colores];
}

/// Estado optimizado para carga de datos de edición
class EditProductDataLoaded extends ProductsState {
  final ProductoMaster product;
  final List<Marca> marcas;
  final List<Categoria> categorias;
  final List<Talla> tallas;
  final List<MaterialModel> materiales;

  const EditProductDataLoaded({
    required this.product,
    required this.marcas,
    required this.categorias,
    required this.tallas,
    required this.materiales,
  });

  @override
  List<Object?> get props => [product, marcas, categorias, tallas, materiales];
}
