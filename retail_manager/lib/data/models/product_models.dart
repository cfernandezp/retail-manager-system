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
  final String tipoColor; // NUEVO: 'UNICO' | 'VARIOS'
  final List<String>? coloresComponentes; // NUEVO: IDs de colores base
  final String? descripcionCompleta; // NUEVO
  final bool activo; // Cambiado a 'activo' para coincidir con BD
  final DateTime createdAt;

  // Getters de conveniencia
  bool get esColorUnico => tipoColor == 'UNICO';
  bool get esColorMultiple => tipoColor == 'VARIOS';
  int get cantidadColores => esColorUnico ? 1 : (coloresComponentes?.length ?? 0);

  const ColorData({
    required this.id,
    required this.nombre,
    required this.hexColor,
    this.codigoAbrev,
    required this.tipoColor, // NUEVO - requerido
    this.coloresComponentes, // NUEVO - opcional
    this.descripcionCompleta, // NUEVO - opcional
    this.activo = true, // Cambiado a 'activo'
    required this.createdAt,
  });

  factory ColorData.fromJson(Map<String, dynamic> json) {
    return ColorData(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      hexColor: json['hex_color'] ?? json['codigo_hex'] ?? '#000000',
      codigoAbrev: json['codigo_abrev'],
      tipoColor: json['tipo_color'] ?? 'UNICO', // Backward compatibility
      coloresComponentes: json['colores_componentes'] != null
          ? List<String>.from(json['colores_componentes'])
          : null,
      descripcionCompleta: json['descripcion_completa'],
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
      'tipo_color': tipoColor,
      'colores_componentes': coloresComponentes,
      'descripcion_completa': descripcionCompleta,
      'activo': activo, // BD y model usan 'activo'
    };
  }

  @override
  List<Object?> get props => [
    id, nombre, hexColor, codigoAbrev, tipoColor,
    coloresComponentes, descripcionCompleta, activo
  ];
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

// =====================================================
// MODELOS DEL MÓDULO DE VENTAS
// =====================================================

/// Modelo para Estrategia de Descuento
class EstrategiaDescuento extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? categoriaId;
  final String? tiendaId;
  final List<RangoDescuento> rangosDescuento;
  final bool activa;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relaciones
  final Categoria? categoria;
  final Tienda? tienda;

  const EstrategiaDescuento({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    this.tiendaId,
    required this.rangosDescuento,
    this.activa = true,
    required this.createdAt,
    this.updatedAt,
    this.categoria,
    this.tienda,
  });

  factory EstrategiaDescuento.fromJson(Map<String, dynamic> json) {
    List<RangoDescuento> rangos = [];
    if (json['rangos_cantidad'] != null) {
      if (json['rangos_cantidad'] is List) {
        rangos = (json['rangos_cantidad'] as List)
            .map((r) => RangoDescuento.fromJson(r))
            .toList();
      }
    }

    return EstrategiaDescuento(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      categoriaId: json['categoria_id'],
      tiendaId: json['tienda_id'],
      rangosDescuento: rangos,
      activa: json['activa'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      categoria: json['categorias'] != null ? Categoria.fromJson(json['categorias']) : null,
      tienda: json['tiendas'] != null ? Tienda.fromJson(json['tiendas']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'tienda_id': tiendaId,
      'rangos_cantidad': rangosDescuento.map((r) => r.toJson()).toList(),
      'activa': activa,
    };
  }

  /// Calcula el descuento para una cantidad específica
  double calcularDescuento(int cantidad) {
    for (final rango in rangosDescuento) {
      if (cantidad >= rango.cantidadMin && cantidad <= rango.cantidadMax) {
        return rango.descuentoPorcentaje;
      }
    }
    return 0.0;
  }

  @override
  List<Object?> get props => [
    id, nombre, descripcion, categoriaId, tiendaId,
    rangosDescuento, activa, createdAt
  ];
}

/// Modelo para Rango de Descuento
class RangoDescuento extends Equatable {
  final int cantidadMin;
  final int cantidadMax;
  final double descuentoPorcentaje;

  const RangoDescuento({
    required this.cantidadMin,
    required this.cantidadMax,
    required this.descuentoPorcentaje,
  });

  factory RangoDescuento.fromJson(Map<String, dynamic> json) {
    return RangoDescuento(
      cantidadMin: json['cantidad_min'] ?? 0,
      cantidadMax: json['cantidad_max'] ?? 0,
      descuentoPorcentaje: (json['descuento_porcentaje'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cantidad_min': cantidadMin,
      'cantidad_max': cantidadMax,
      'descuento_porcentaje': descuentoPorcentaje,
    };
  }

  @override
  List<Object?> get props => [cantidadMin, cantidadMax, descuentoPorcentaje];
}

/// Modelo para Permisos de Descuento
class PermisoDescuento extends Equatable {
  final String id;
  final String rolUsuario;
  final double descuentoMaximoPorcentaje;
  final bool requiereAprobacion;
  final bool puedeAprobarDescuentos;
  final bool activo;
  final DateTime createdAt;

  const PermisoDescuento({
    required this.id,
    required this.rolUsuario,
    required this.descuentoMaximoPorcentaje,
    required this.requiereAprobacion,
    required this.puedeAprobarDescuentos,
    this.activo = true,
    required this.createdAt,
  });

  factory PermisoDescuento.fromJson(Map<String, dynamic> json) {
    return PermisoDescuento(
      id: json['id'] ?? '',
      rolUsuario: json['rol_usuario'] ?? '',
      descuentoMaximoPorcentaje: (json['descuento_maximo_porcentaje'] ?? 0.0).toDouble(),
      requiereAprobacion: json['requiere_aprobacion'] ?? false,
      puedeAprobarDescuentos: json['puede_aprobar_descuentos'] ?? false,
      activo: json['activo'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rol_usuario': rolUsuario,
      'descuento_maximo_porcentaje': descuentoMaximoPorcentaje,
      'requiere_aprobacion': requiereAprobacion,
      'puede_aprobar_descuentos': puedeAprobarDescuentos,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [
    id, rolUsuario, descuentoMaximoPorcentaje,
    requiereAprobacion, puedeAprobarDescuentos, activo
  ];
}

/// Enum para estado de venta
enum EstadoVenta { pendiente, completada, cancelada, devuelta }

/// Modelo para Venta
class Venta extends Equatable {
  final String id;
  final String numeroVenta;
  final String tiendaId;
  final String vendedorId;
  final String? clienteId;
  final double subtotal;
  final double descuentoTotal;
  final double impuestos;
  final double montoTotal;
  final EstadoVenta estado;
  final DateTime fechaVenta;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relaciones
  final Tienda? tienda;
  final List<DetalleVenta>? detalles;

  const Venta({
    required this.id,
    required this.numeroVenta,
    required this.tiendaId,
    required this.vendedorId,
    this.clienteId,
    required this.subtotal,
    required this.descuentoTotal,
    required this.impuestos,
    required this.montoTotal,
    required this.estado,
    required this.fechaVenta,
    required this.createdAt,
    this.updatedAt,
    this.tienda,
    this.detalles,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    EstadoVenta estado;
    switch (json['estado']?.toString().toLowerCase()) {
      case 'completada':
        estado = EstadoVenta.completada;
        break;
      case 'cancelada':
        estado = EstadoVenta.cancelada;
        break;
      case 'devuelta':
        estado = EstadoVenta.devuelta;
        break;
      default:
        estado = EstadoVenta.pendiente;
    }

    return Venta(
      id: json['id'] ?? '',
      numeroVenta: json['numero_venta'] ?? '',
      tiendaId: json['tienda_id'] ?? '',
      vendedorId: json['vendedor_id'] ?? '',
      clienteId: json['cliente_id'],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      descuentoTotal: (json['descuento_total'] ?? 0.0).toDouble(),
      impuestos: (json['impuestos'] ?? 0.0).toDouble(),
      montoTotal: (json['monto_total'] ?? 0.0).toDouble(),
      estado: estado,
      fechaVenta: DateTime.parse(json['fecha_venta']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      tienda: json['tiendas'] != null ? Tienda.fromJson(json['tiendas']) : null,
      detalles: json['detalles_venta'] != null
          ? (json['detalles_venta'] as List)
              .map((d) => DetalleVenta.fromJson(d))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String estadoStr;
    switch (estado) {
      case EstadoVenta.completada:
        estadoStr = 'completada';
        break;
      case EstadoVenta.cancelada:
        estadoStr = 'cancelada';
        break;
      case EstadoVenta.devuelta:
        estadoStr = 'devuelta';
        break;
      default:
        estadoStr = 'pendiente';
    }

    return {
      'id': id,
      'numero_venta': numeroVenta,
      'tienda_id': tiendaId,
      'vendedor_id': vendedorId,
      'cliente_id': clienteId,
      'subtotal': subtotal,
      'descuento_total': descuentoTotal,
      'impuestos': impuestos,
      'monto_total': montoTotal,
      'estado': estadoStr,
      'fecha_venta': fechaVenta.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id, numeroVenta, tiendaId, vendedorId, clienteId,
    subtotal, descuentoTotal, impuestos, montoTotal,
    estado, fechaVenta
  ];
}

/// Modelo para Detalle de Venta
class DetalleVenta extends Equatable {
  final String id;
  final String ventaId;
  final String articuloId;
  final int cantidad;
  final double precioUnitario;
  final double descuentoPorcentaje;
  final double descuentoMonto;
  final double subtotal;
  final DateTime createdAt;

  // Relaciones
  final Articulo? articulo;

  const DetalleVenta({
    required this.id,
    required this.ventaId,
    required this.articuloId,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuentoPorcentaje,
    required this.descuentoMonto,
    required this.subtotal,
    required this.createdAt,
    this.articulo,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      id: json['id'] ?? '',
      ventaId: json['venta_id'] ?? '',
      articuloId: json['articulo_id'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: (json['precio_unitario'] ?? 0.0).toDouble(),
      descuentoPorcentaje: (json['descuento_porcentaje'] ?? 0.0).toDouble(),
      descuentoMonto: (json['descuento_monto'] ?? 0.0).toDouble(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      articulo: json['articulos'] != null ? Articulo.fromJson(json['articulos']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venta_id': ventaId,
      'articulo_id': articuloId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'descuento_porcentaje': descuentoPorcentaje,
      'descuento_monto': descuentoMonto,
      'subtotal': subtotal,
    };
  }

  @override
  List<Object?> get props => [
    id, ventaId, articuloId, cantidad, precioUnitario,
    descuentoPorcentaje, descuentoMonto, subtotal
  ];
}

/// Enum para estado de aprobación
enum EstadoAprobacion { pendiente, aprobada, rechazada }

/// Modelo para Aprobación de Descuento
class AprobacionDescuento extends Equatable {
  final String id;
  final String ventaId;
  final String vendedorId;
  final String? supervisorId;
  final double descuentoSolicitado;
  final String? motivoDescuento;
  final EstadoAprobacion estado;
  final String? comentariosSupervisor;
  final DateTime fechaSolicitud;
  final DateTime? fechaRespuesta;
  final DateTime createdAt;

  const AprobacionDescuento({
    required this.id,
    required this.ventaId,
    required this.vendedorId,
    this.supervisorId,
    required this.descuentoSolicitado,
    this.motivoDescuento,
    required this.estado,
    this.comentariosSupervisor,
    required this.fechaSolicitud,
    this.fechaRespuesta,
    required this.createdAt,
  });

  factory AprobacionDescuento.fromJson(Map<String, dynamic> json) {
    EstadoAprobacion estado;
    switch (json['estado']?.toString().toLowerCase()) {
      case 'aprobada':
        estado = EstadoAprobacion.aprobada;
        break;
      case 'rechazada':
        estado = EstadoAprobacion.rechazada;
        break;
      default:
        estado = EstadoAprobacion.pendiente;
    }

    return AprobacionDescuento(
      id: json['id'] ?? '',
      ventaId: json['venta_id'] ?? '',
      vendedorId: json['vendedor_id'] ?? '',
      supervisorId: json['supervisor_id'],
      descuentoSolicitado: (json['descuento_solicitado'] ?? 0.0).toDouble(),
      motivoDescuento: json['motivo_descuento'],
      estado: estado,
      comentariosSupervisor: json['comentarios_supervisor'],
      fechaSolicitud: DateTime.parse(json['fecha_solicitud']),
      fechaRespuesta: json['fecha_respuesta'] != null ? DateTime.parse(json['fecha_respuesta']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    String estadoStr;
    switch (estado) {
      case EstadoAprobacion.aprobada:
        estadoStr = 'aprobada';
        break;
      case EstadoAprobacion.rechazada:
        estadoStr = 'rechazada';
        break;
      default:
        estadoStr = 'pendiente';
    }

    return {
      'id': id,
      'venta_id': ventaId,
      'vendedor_id': vendedorId,
      'supervisor_id': supervisorId,
      'descuento_solicitado': descuentoSolicitado,
      'motivo_descuento': motivoDescuento,
      'estado': estadoStr,
      'comentarios_supervisor': comentariosSupervisor,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_respuesta': fechaRespuesta?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id, ventaId, vendedorId, supervisorId, descuentoSolicitado,
    motivoDescuento, estado, comentariosSupervisor,
    fechaSolicitud, fechaRespuesta
  ];
}