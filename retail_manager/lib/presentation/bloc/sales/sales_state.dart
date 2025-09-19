part of 'sales_bloc.dart';

/// Estados del BLoC de ventas
abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class SalesInitial extends SalesState {
  const SalesInitial();
}

/// Estado de carga
class SalesLoading extends SalesState {
  const SalesLoading();
}

/// Estado cargado exitosamente
class SalesLoaded extends SalesState {
  final List<EstrategiaDescuento> estrategias;
  final List<PermisoDescuento> permisos;
  final PermisoDescuento? permisoActual;
  final EstrategiaDescuento? estrategiaActual;
  final List<Venta> ventas;
  final Venta? ventaActual;
  final List<AprobacionDescuento> aprobacionesPendientes;
  final CarritoState carrito;
  final Map<String, dynamic>? resumenVentas;
  final double? descuentoCalculado;
  final bool? permisoVerificado;

  const SalesLoaded({
    this.estrategias = const [],
    this.permisos = const [],
    this.permisoActual,
    this.estrategiaActual,
    this.ventas = const [],
    this.ventaActual,
    this.aprobacionesPendientes = const [],
    this.carrito = const CarritoState(),
    this.resumenVentas,
    this.descuentoCalculado,
    this.permisoVerificado,
  });

  @override
  List<Object?> get props => [
    estrategias,
    permisos,
    permisoActual,
    estrategiaActual,
    ventas,
    ventaActual,
    aprobacionesPendientes,
    carrito,
    resumenVentas,
    descuentoCalculado,
    permisoVerificado,
  ];

  SalesLoaded copyWith({
    List<EstrategiaDescuento>? estrategias,
    List<PermisoDescuento>? permisos,
    PermisoDescuento? permisoActual,
    EstrategiaDescuento? estrategiaActual,
    List<Venta>? ventas,
    Venta? ventaActual,
    List<AprobacionDescuento>? aprobacionesPendientes,
    CarritoState? carrito,
    Map<String, dynamic>? resumenVentas,
    double? descuentoCalculado,
    bool? permisoVerificado,
  }) {
    return SalesLoaded(
      estrategias: estrategias ?? this.estrategias,
      permisos: permisos ?? this.permisos,
      permisoActual: permisoActual ?? this.permisoActual,
      estrategiaActual: estrategiaActual ?? this.estrategiaActual,
      ventas: ventas ?? this.ventas,
      ventaActual: ventaActual ?? this.ventaActual,
      aprobacionesPendientes: aprobacionesPendientes ?? this.aprobacionesPendientes,
      carrito: carrito ?? this.carrito,
      resumenVentas: resumenVentas ?? this.resumenVentas,
      descuentoCalculado: descuentoCalculado ?? this.descuentoCalculado,
      permisoVerificado: permisoVerificado ?? this.permisoVerificado,
    );
  }
}

/// Estado de error
class SalesError extends SalesState {
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? details;

  const SalesError({
    required this.message,
    this.errorCode,
    this.details,
  });

  @override
  List<Object?> get props => [message, errorCode, details];
}

/// Estado de creación exitosa
class SalesCreated extends SalesState {
  final Venta venta;
  final String message;

  const SalesCreated({
    required this.venta,
    required this.message,
  });

  @override
  List<Object?> get props => [venta, message];
}

/// Estado de actualización exitosa
class SalesUpdated extends SalesState {
  final String message;
  final dynamic updatedData;

  const SalesUpdated({
    required this.message,
    this.updatedData,
  });

  @override
  List<Object?> get props => [message, updatedData];
}

/// Estado específico del carrito de compras
class CarritoState extends Equatable {
  final List<CarritoItem> items;
  final double subtotal;
  final double descuentoTotal;
  final double impuestos;
  final double montoTotal;
  final bool tieneDescuentosEspeciales;

  const CarritoState({
    this.items = const [],
    this.subtotal = 0.0,
    this.descuentoTotal = 0.0,
    this.impuestos = 0.0,
    this.montoTotal = 0.0,
    this.tieneDescuentosEspeciales = false,
  });

  @override
  List<Object?> get props => [
    items, subtotal, descuentoTotal, impuestos,
    montoTotal, tieneDescuentosEspeciales
  ];

  CarritoState copyWith({
    List<CarritoItem>? items,
    double? subtotal,
    double? descuentoTotal,
    double? impuestos,
    double? montoTotal,
    bool? tieneDescuentosEspeciales,
  }) {
    return CarritoState(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      descuentoTotal: descuentoTotal ?? this.descuentoTotal,
      impuestos: impuestos ?? this.impuestos,
      montoTotal: montoTotal ?? this.montoTotal,
      tieneDescuentosEspeciales: tieneDescuentosEspeciales ?? this.tieneDescuentosEspeciales,
    );
  }

  /// Verifica si el carrito está vacío
  bool get isEmpty => items.isEmpty;

  /// Verifica si el carrito tiene artículos
  bool get isNotEmpty => items.isNotEmpty;

  /// Obtiene la cantidad total de artículos
  int get totalCantidad => items.fold(0, (sum, item) => sum + item.cantidad);

  /// Busca un artículo específico en el carrito
  CarritoItem? findItem(String articuloId) {
    try {
      return items.firstWhere((item) => item.articulo.id == articuloId);
    } catch (e) {
      return null;
    }
  }

  /// Verifica si un artículo está en el carrito
  bool containsArticulo(String articuloId) {
    return findItem(articuloId) != null;
  }

  /// Obtiene el índice de un artículo en la lista
  int getItemIndex(String articuloId) {
    return items.indexWhere((item) => item.articulo.id == articuloId);
  }
}

/// Representa un artículo en el carrito
class CarritoItem extends Equatable {
  final Articulo articulo;
  final int cantidad;
  final double precioUnitario;
  final double descuentoPorcentaje;
  final double descuentoMonto;
  final double subtotal;
  final String? motivoDescuento;
  final bool esDescuentoAutomatico;

  const CarritoItem({
    required this.articulo,
    required this.cantidad,
    required this.precioUnitario,
    this.descuentoPorcentaje = 0.0,
    this.descuentoMonto = 0.0,
    required this.subtotal,
    this.motivoDescuento,
    this.esDescuentoAutomatico = false,
  });

  @override
  List<Object?> get props => [
    articulo, cantidad, precioUnitario, descuentoPorcentaje,
    descuentoMonto, subtotal, motivoDescuento, esDescuentoAutomatico
  ];

  CarritoItem copyWith({
    Articulo? articulo,
    int? cantidad,
    double? precioUnitario,
    double? descuentoPorcentaje,
    double? descuentoMonto,
    double? subtotal,
    String? motivoDescuento,
    bool? esDescuentoAutomatico,
  }) {
    return CarritoItem(
      articulo: articulo ?? this.articulo,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      descuentoPorcentaje: descuentoPorcentaje ?? this.descuentoPorcentaje,
      descuentoMonto: descuentoMonto ?? this.descuentoMonto,
      subtotal: subtotal ?? this.subtotal,
      motivoDescuento: motivoDescuento ?? this.motivoDescuento,
      esDescuentoAutomatico: esDescuentoAutomatico ?? this.esDescuentoAutomatico,
    );
  }

  /// Calcula el precio sin descuento
  double get precioSinDescuento => precioUnitario * cantidad;

  /// Calcula el precio final con descuento
  double get precioFinal => precioSinDescuento - descuentoMonto;

  /// Verifica si tiene descuento aplicado
  bool get tieneDescuento => descuentoPorcentaje > 0;

  /// Obtiene el ahorro total
  double get ahorro => descuentoMonto;

  /// Convierte a Map para guardar en base de datos
  Map<String, dynamic> toDetalleVenta(String ventaId) {
    return {
      'venta_id': ventaId,
      'articulo_id': articulo.id,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'descuento_porcentaje': descuentoPorcentaje,
      'descuento_monto': descuentoMonto,
      'subtotal': subtotal,
    };
  }
}

/// Estados específicos para operaciones de descuento
class DescuentoValidationState extends SalesState {
  final bool esValido;
  final bool requiereAprobacion;
  final String? mensaje;
  final PermisoDescuento? permiso;

  const DescuentoValidationState({
    required this.esValido,
    required this.requiereAprobacion,
    this.mensaje,
    this.permiso,
  });

  @override
  List<Object?> get props => [esValido, requiereAprobacion, mensaje, permiso];
}

/// Estado para resultado de cálculo de descuento
class DescuentoCalculationState extends SalesState {
  final double descuentoPorcentaje;
  final double descuentoMonto;
  final String categoriaId;
  final int cantidad;
  final EstrategiaDescuento? estrategiaAplicada;

  const DescuentoCalculationState({
    required this.descuentoPorcentaje,
    required this.descuentoMonto,
    required this.categoriaId,
    required this.cantidad,
    this.estrategiaAplicada,
  });

  @override
  List<Object?> get props => [
    descuentoPorcentaje, descuentoMonto, categoriaId,
    cantidad, estrategiaAplicada
  ];
}

/// Estado para aprobaciones pendientes
class AprobacionesPendientesState extends SalesState {
  final List<AprobacionDescuento> aprobaciones;
  final int totalPendientes;

  const AprobacionesPendientesState({
    required this.aprobaciones,
    required this.totalPendientes,
  });

  @override
  List<Object?> get props => [aprobaciones, totalPendientes];
}

/// Estado para resumen de ventas
class ResumenVentasState extends SalesState {
  final double totalVentas;
  final int totalTransacciones;
  final int ventasCompletadas;
  final int ventasCanceladas;
  final double ticketPromedio;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const ResumenVentasState({
    required this.totalVentas,
    required this.totalTransacciones,
    required this.ventasCompletadas,
    required this.ventasCanceladas,
    required this.ticketPromedio,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [
    totalVentas, totalTransacciones, ventasCompletadas,
    ventasCanceladas, ticketPromedio, fechaInicio, fechaFin
  ];
}