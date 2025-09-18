import 'package:equatable/equatable.dart';

/// Modelo para Marca
class Marca extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? logoUrl;
  final bool activo;
  final DateTime createdAt;

  const Marca({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.logoUrl,
    this.activo = true,
    required this.createdAt,
  });

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      logoUrl: json['logo_url'],
      activo: json['activo'] ?? true, // BD usa 'activo' (boolean)
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'logo_url': logoUrl,
      'activo': activo, // BD usa 'activo'
    };
  }

  @override
  List<Object?> get props => [id, nombre, descripcion, logoUrl, activo];
}

/// Modelo para Categoría
class Categoria extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime createdAt;

  const Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.activo = true,
    required this.createdAt,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      activo: json['activo'] ?? true, // CORREGIDO: BD usa 'activo'
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [id, nombre, descripcion, activo];
}

/// Modelo para Material
class MaterialModel extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? codigo;
  final bool activo;
  final DateTime createdAt;

  const MaterialModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.codigo,
    this.activo = true,
    required this.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      codigo: json['codigo'],
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo': codigo,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [id, nombre, descripcion, codigo, activo];
}

/// Enum para tipo de talla
enum TipoTalla { rango, unica }

/// Modelo para Color
class ColorData extends Equatable {
  final String id;
  final String nombre;
  final String hexColor;
  final String? codigoAbrev;
  final bool activo; // Cambiado a 'activo' para coincidir con BD
  final DateTime createdAt;

  const ColorData({
    required this.id,
    required this.nombre,
    required this.hexColor,
    this.codigoAbrev,
    this.activo = true, // Cambiado a 'activo'
    required this.createdAt,
  });

  factory ColorData.fromJson(Map<String, dynamic> json) {
    return ColorData(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      hexColor: json['hex_color'] ?? json['codigo_hex'] ?? '#000000',
      codigoAbrev: json['codigo_abrev'],
      activo: json['activo'] ?? true, // BD y model usan 'activo'
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo_hex': hexColor, // BD usa 'codigo_hex' como campo principal
      'codigo_abrev': codigoAbrev,
      'activo': activo, // BD y model usan 'activo'
    };
  }

  @override
  List<Object?> get props => [id, nombre, hexColor, codigoAbrev, activo];
}

/// Modelo para Talla
class Talla extends Equatable {
  final String id;
  final String codigo;
  final String valor;
  final String? nombre;
  final String tipo;
  final int? ordenDisplay;
  final bool activo;
  final DateTime createdAt;

  const Talla({
    required this.id,
    required this.codigo,
    required this.valor,
    this.nombre,
    required this.tipo,
    this.ordenDisplay,
    this.activo = true,
    required this.createdAt,
  });

  factory Talla.fromJson(Map<String, dynamic> json) {
    return Talla(
      id: json['id'] ?? '',
      codigo: json['codigo'] ?? json['valor'] ?? 'S/T',
      valor: json['valor'] ?? json['codigo'] ?? 'S/T',
      nombre: json['nombre'],
      tipo: json['tipo'] ?? 'ROPA',
      ordenDisplay: json['orden_display'],
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'valor': valor,
      'nombre': nombre,
      'tipo': tipo,
      'orden_display': ordenDisplay,
      'activo': activo,
    };
  }

  String get displayName => valor;

  @override
  List<Object?> get props => [id, codigo, valor, nombre, tipo, ordenDisplay, activo];
}

/// Modelo para Producto Master
class ProductoMaster extends Equatable {
  final String id;
  final String nombre;
  final String marcaId;
  final String categoriaId;
  final String tallaId;
  final String? materialId; // Nuevo campo para materiales
  final double precioSugerido;
  final bool activo;
  final DateTime createdAt;
  
  // Relaciones (opcional, para cuando se incluyen en las consultas)
  final Marca? marca;
  final Categoria? categoria;
  final Talla? talla;
  final MaterialModel? material; // Nueva relación con material
  final List<Articulo>? articulos;

  const ProductoMaster({
    required this.id,
    required this.nombre,
    required this.marcaId,
    required this.categoriaId,
    required this.tallaId,
    this.materialId, // Nuevo campo opcional
    required this.precioSugerido,
    this.activo = true,
    required this.createdAt,
    this.marca,
    this.categoria,
    this.talla,
    this.material, // Nueva relación
    this.articulos,
  });

  factory ProductoMaster.fromJson(Map<String, dynamic> json) {
    return ProductoMaster(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      marcaId: json['marca_id'] ?? '',
      categoriaId: json['categoria_id'] ?? '',
      tallaId: json['talla_id'] ?? '',
      materialId: json['material_id'],
      precioSugerido: json['precio_sugerido'] != null ? (json['precio_sugerido'] as num).toDouble() : 0.0,
      activo: (json['estado'] ?? json['activo']) == 'ACTIVO' || (json['activo'] ?? false),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      marca: json['marcas'] != null ? Marca.fromJson(json['marcas']) : null,
      categoria: json['categorias'] != null ? Categoria.fromJson(json['categorias']) : null,
      talla: json['tallas'] != null ? Talla.fromJson(json['tallas']) : null,
      material: json['materiales'] != null ? MaterialModel.fromJson(json['materiales']) : null,
      articulos: json['articulos'] != null
          ? (json['articulos'] as List).map((e) => Articulo.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'nombre': nombre,
      'marca_id': marcaId,
      'categoria_id': categoriaId,
      'talla_id': tallaId,
      'precio_sugerido': precioSugerido,
      'estado': activo ? 'ACTIVO' : 'INACTIVO',
    };
    
    // Agregar material_id solo si está presente
    if (materialId != null) {
      map['material_id'] = materialId!;
    }
    
    return map;
  }

  ProductoMaster copyWith({
    String? nombre,
    String? marcaId,
    String? categoriaId,
    String? tallaId,
    String? materialId,
    double? precioSugerido,
    bool? activo,
  }) {
    return ProductoMaster(
      id: id,
      nombre: nombre ?? this.nombre,
      marcaId: marcaId ?? this.marcaId,
      categoriaId: categoriaId ?? this.categoriaId,
      tallaId: tallaId ?? this.tallaId,
      materialId: materialId ?? this.materialId,
      precioSugerido: precioSugerido ?? this.precioSugerido,
      activo: activo ?? this.activo,
      createdAt: createdAt,
      marca: marca,
      categoria: categoria,
      talla: talla,
      material: material,
      articulos: articulos,
    );
  }

  @override
  List<Object?> get props => [
    id, nombre, marcaId, categoriaId, tallaId, materialId,
    precioSugerido, activo, createdAt
  ];
}

/// Modelo para Artículo (variante por color de un producto)
class Articulo extends Equatable {
  final String id;
  final String productoId;
  final String? colorId;  // Cambiado a colorId
  final String skuAuto;
  final double precioSugerido;
  final bool activo;
  final DateTime createdAt;
  
  // Relaciones
  final ProductoMaster? producto;
  final ColorData? color;  // Agregado el objeto color
  final List<InventarioTienda>? inventarios;

  const Articulo({
    required this.id,
    required this.productoId,
    this.colorId,
    required this.skuAuto,
    required this.precioSugerido,
    this.activo = true,
    required this.createdAt,
    this.producto,
    this.color,
    this.inventarios,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'],
      productoId: json['producto_master_id'] ?? json['producto_id'],
      colorId: json['color_id'],
      skuAuto: json['sku_auto'] ?? json['sku'] ?? 'SKU-AUTO',
      precioSugerido: (json['precio_sugerido'] as num).toDouble(),
      activo: json['activo'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      producto: json['productos_master'] != null 
          ? ProductoMaster.fromJson(json['productos_master']) 
          : null,
      color: json['colores'] != null 
          ? ColorData.fromJson(json['colores']) 
          : null,
      inventarios: json['inventario_tienda'] != null
          ? (json['inventario_tienda'] as List)
              .map((e) => InventarioTienda.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_master_id': productoId,
      'color_id': colorId,
      'sku_auto': skuAuto,
      'precio_sugerido': precioSugerido,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [
    id, productoId, colorId, skuAuto, precioSugerido, activo
  ];
}

/// Modelo para Tienda
class Tienda extends Equatable {
  final String id;
  final String nombre;
  final String direccion;
  final String? adminTiendaId;
  final bool activo;
  final DateTime createdAt;

  const Tienda({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.adminTiendaId,
    this.activo = true,
    required this.createdAt,
  });

  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      direccion: json['direccion'] ?? 'Sin dirección',
      adminTiendaId: json['admin_tienda_id'] ?? json['manager_id'], // CORREGIDO: Usar ambos nombres posibles
      activo: json['activo'] ?? true, // CORREGIDO: BD usa 'activo'
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'manager_id': adminTiendaId, // CORREGIDO: BD usa 'manager_id'
      'activo': activo, // CORREGIDO: BD usa 'activo'
    };
  }

  @override
  List<Object?> get props => [id, nombre, direccion, adminTiendaId, activo];
}

/// Modelo para Inventario por Tienda
class InventarioTienda extends Equatable {
  final String tiendaId;
  final String articuloId;
  final int stockActual;
  final double precioLocal;
  final DateTime updatedAt;
  
  // Relaciones
  final Tienda? tienda;
  final Articulo? articulo;

  const InventarioTienda({
    required this.tiendaId,
    required this.articuloId,
    required this.stockActual,
    required this.precioLocal,
    required this.updatedAt,
    this.tienda,
    this.articulo,
  });

  factory InventarioTienda.fromJson(Map<String, dynamic> json) {
    return InventarioTienda(
      tiendaId: json['tienda_id'],
      articuloId: json['articulo_id'],
      stockActual: json['stock_actual'],
      precioLocal: (json['precio_local'] ?? json['precio_venta'] ?? 0).toDouble(),
      updatedAt: DateTime.parse(json['updated_at']),
      tienda: json['tiendas'] != null ? Tienda.fromJson(json['tiendas']) : null,
      articulo: json['articulos'] != null ? Articulo.fromJson(json['articulos']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tienda_id': tiendaId,
      'articulo_id': articuloId,
      'stock_actual': stockActual,
      'precio_local': precioLocal,
    };
  }

  @override
  List<Object?> get props => [tiendaId, articuloId, stockActual, precioLocal];
}

/// Modelo para vista consolidada de catálogo (vw_catalogo_completo)
class CatalogoCompleto extends Equatable {
  final String productoId;
  final String productoNombre;
  final String marcaNombre;
  final String categoriaNombre;
  final String tallaValor;
  final double precioSugerido;
  final int totalArticulos;
  final int stockTotal;
  final double precioMinimo;
  final double precioMaximo;
  final List<String> coloresDisponibles;
  final int tiendasConStock;

  const CatalogoCompleto({
    required this.productoId,
    required this.productoNombre,
    required this.marcaNombre,
    required this.categoriaNombre,
    required this.tallaValor,
    required this.precioSugerido,
    required this.totalArticulos,
    required this.stockTotal,
    required this.precioMinimo,
    required this.precioMaximo,
    required this.coloresDisponibles,
    required this.tiendasConStock,
  });

  factory CatalogoCompleto.fromJson(Map<String, dynamic> json) {
    return CatalogoCompleto(
      productoId: json['producto_id'],
      productoNombre: json['producto_nombre'],
      marcaNombre: json['marca_nombre'],
      categoriaNombre: json['categoria_nombre'],
      tallaValor: json['talla_valor'],
      precioSugerido: (json['precio_sugerido'] as num).toDouble(),
      totalArticulos: json['total_articulos'],
      stockTotal: json['stock_total'],
      precioMinimo: (json['precio_minimo'] as num).toDouble(),
      precioMaximo: (json['precio_maximo'] as num).toDouble(),
      coloresDisponibles: List<String>.from(json['colores_disponibles'] ?? []),
      tiendasConStock: json['tiendas_con_stock'],
    );
  }

  @override
  List<Object?> get props => [
    productoId, productoNombre, marcaNombre, categoriaNombre, 
    tallaValor, precioSugerido, totalArticulos, stockTotal,
    precioMinimo, precioMaximo, coloresDisponibles, tiendasConStock
  ];
}

/// Modelo para filtros de productos
class ProductFilters extends Equatable {
  final String? searchQuery;
  final List<String> marcaIds;
  final List<String> categoriaIds;
  final List<String> tallaIds;
  final bool? soloConStock;
  final double? precioMinimo;
  final double? precioMaximo;
  final bool? soloActivos;

  const ProductFilters({
    this.searchQuery,
    this.marcaIds = const [],
    this.categoriaIds = const [],
    this.tallaIds = const [],
    this.soloConStock,
    this.precioMinimo,
    this.precioMaximo,
    this.soloActivos = true,
  });

  ProductFilters copyWith({
    String? searchQuery,
    List<String>? marcaIds,
    List<String>? categoriaIds,
    List<String>? tallaIds,
    bool? soloConStock,
    double? precioMinimo,
    double? precioMaximo,
    bool? soloActivos,
  }) {
    return ProductFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      marcaIds: marcaIds ?? this.marcaIds,
      categoriaIds: categoriaIds ?? this.categoriaIds,
      tallaIds: tallaIds ?? this.tallaIds,
      soloConStock: soloConStock ?? this.soloConStock,
      precioMinimo: precioMinimo ?? this.precioMinimo,
      precioMaximo: precioMaximo ?? this.precioMaximo,
      soloActivos: soloActivos ?? this.soloActivos,
    );
  }

  bool get hasFilters =>
      searchQuery?.isNotEmpty == true ||
      marcaIds.isNotEmpty ||
      categoriaIds.isNotEmpty ||
      tallaIds.isNotEmpty ||
      soloConStock != null ||
      precioMinimo != null ||
      precioMaximo != null;

  @override
  List<Object?> get props => [
    searchQuery, marcaIds, categoriaIds, tallaIds,
    soloConStock, precioMinimo, precioMaximo, soloActivos
  ];
}

/// Modelo para paginación
class PaginationParams extends Equatable {
  final int page;
  final int pageSize;
  final String? orderBy;
  final bool descending;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.orderBy,
    this.descending = false,
  });

  int get offset => (page - 1) * pageSize;

  PaginationParams copyWith({
    int? page,
    int? pageSize,
    String? orderBy,
    bool? descending,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      orderBy: orderBy ?? this.orderBy,
      descending: descending ?? this.descending,
    );
  }

  @override
  List<Object?> get props => [page, pageSize, orderBy, descending];
}

/// Resultado paginado
class PaginatedResult<T> extends Equatable {
  final List<T> data;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const PaginatedResult({
    required this.data,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  bool get hasNextPage => currentPage * pageSize < totalCount;
  bool get hasPreviousPage => currentPage > 1;
  int get totalPages => (totalCount / pageSize).ceil();

  @override
  List<Object?> get props => [data, totalCount, currentPage, pageSize];
}