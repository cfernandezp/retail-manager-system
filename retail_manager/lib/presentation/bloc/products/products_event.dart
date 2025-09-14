part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar productos con filtros y paginación
class LoadProducts extends ProductsEvent {
  final ProductFilters? filters;
  final PaginationParams? pagination;

  const LoadProducts({
    this.filters,
    this.pagination,
  });

  @override
  List<Object?> get props => [filters, pagination];
}

/// Cargar detalles de un producto específico
class LoadProductDetails extends ProductsEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Buscar productos por texto
class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Aplicar filtros a los productos
class FilterProducts extends ProductsEvent {
  final ProductFilters filters;

  const FilterProducts(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Cargar más productos (paginación infinita)
class LoadMoreProducts extends ProductsEvent {
  const LoadMoreProducts();
}

/// Crear un nuevo producto
class CreateProduct extends ProductsEvent {
  final Map<String, dynamic> productData;
  final List<String> colores;
  final List<Map<String, dynamic>> inventarioInicial;

  const CreateProduct({
    required this.productData,
    this.colores = const [],
    this.inventarioInicial = const [],
  });

  @override
  List<Object?> get props => [productData, colores, inventarioInicial];
}

/// Actualizar un producto existente
class UpdateProduct extends ProductsEvent {
  final String productId;
  final Map<String, dynamic> updateData;

  const UpdateProduct({
    required this.productId,
    required this.updateData,
  });

  @override
  List<Object?> get props => [productId, updateData];
}

/// Eliminar un producto (soft delete)
class DeleteProduct extends ProductsEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Refrescar la lista de productos
class RefreshProducts extends ProductsEvent {
  const RefreshProducts();
}

/// Suscribirse a cambios en tiempo real
class SubscribeToChanges extends ProductsEvent {
  const SubscribeToChanges();
}

/// Desuscribirse de cambios en tiempo real
class UnsubscribeFromChanges extends ProductsEvent {
  const UnsubscribeFromChanges();
}

/// Evento interno para manejar updates en tiempo real
class ProductRealTimeUpdate extends ProductsEvent {
  final Map<String, dynamic> data;
  final String eventType; // INSERT, UPDATE, DELETE, INVENTORY_UPDATE

  const ProductRealTimeUpdate(this.data, this.eventType);

  @override
  List<Object?> get props => [data, eventType];
}

/// Limpiar filtros
class ClearFilters extends ProductsEvent {
  const ClearFilters();
}

/// Cambiar ordenamiento
class ChangeSorting extends ProductsEvent {
  final String orderBy;
  final bool descending;

  const ChangeSorting({
    required this.orderBy,
    this.descending = false,
  });

  @override
  List<Object?> get props => [orderBy, descending];
}

/// Exportar productos
class ExportProducts extends ProductsEvent {
  final ProductFilters? filters;
  final String format; // CSV, PDF, Excel

  const ExportProducts({
    this.filters,
    this.format = 'CSV',
  });

  @override
  List<Object?> get props => [filters, format];
}

/// Importar productos
class ImportProducts extends ProductsEvent {
  final List<Map<String, dynamic>> productsData;

  const ImportProducts(this.productsData);

  @override
  List<Object?> get props => [productsData];
}

/// Cargar datos iniciales para formularios (marcas, categorías, materiales, etc.)
class LoadInitialProductData extends ProductsEvent {
  const LoadInitialProductData();
}

/// Actualizar producto master específicamente
class UpdateProductoMaster extends ProductsEvent {
  final String productId;
  final Map<String, dynamic> updateData;

  const UpdateProductoMaster(this.productId, this.updateData);

  @override
  List<Object?> get props => [productId, updateData];
}
