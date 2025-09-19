part of 'sales_bloc.dart';

/// Eventos del BLoC de ventas
abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

// ================== EVENTOS DE ESTRATEGIAS DE DESCUENTO ==================

/// Cargar estrategias de descuento
class LoadEstrategiasDescuento extends SalesEvent {
  final String? categoriaId;
  final String? tiendaId;
  final bool soloActivas;

  const LoadEstrategiasDescuento({
    this.categoriaId,
    this.tiendaId,
    this.soloActivas = true,
  });

  @override
  List<Object?> get props => [categoriaId, tiendaId, soloActivas];
}

/// Cargar estrategia para categoría específica
class LoadEstrategiaParaCategoria extends SalesEvent {
  final String categoriaId;
  final String? tiendaId;

  const LoadEstrategiaParaCategoria({
    required this.categoriaId,
    this.tiendaId,
  });

  @override
  List<Object?> get props => [categoriaId, tiendaId];
}

/// Crear nueva estrategia de descuento
class CreateEstrategiaDescuento extends SalesEvent {
  final Map<String, dynamic> estrategiaData;

  const CreateEstrategiaDescuento({required this.estrategiaData});

  @override
  List<Object?> get props => [estrategiaData];
}

// ================== EVENTOS DE PERMISOS ==================

/// Cargar permisos de descuento para un rol
class LoadPermisoDescuento extends SalesEvent {
  final String rolUsuario;

  const LoadPermisoDescuento({required this.rolUsuario});

  @override
  List<Object?> get props => [rolUsuario];
}

/// Cargar todos los permisos de descuento
class LoadAllPermisosDescuento extends SalesEvent {
  const LoadAllPermisosDescuento();
}

// ================== EVENTOS DE CARRITO/POS ==================

/// Agregar artículo al carrito
class AddArticuloToCarrito extends SalesEvent {
  final Articulo articulo;
  final int cantidad;

  const AddArticuloToCarrito({
    required this.articulo,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [articulo, cantidad];
}

/// Actualizar cantidad de artículo en carrito
class UpdateCantidadCarrito extends SalesEvent {
  final String articuloId;
  final int nuevaCantidad;

  const UpdateCantidadCarrito({
    required this.articuloId,
    required this.nuevaCantidad,
  });

  @override
  List<Object?> get props => [articuloId, nuevaCantidad];
}

/// Remover artículo del carrito
class RemoveArticuloFromCarrito extends SalesEvent {
  final String articuloId;

  const RemoveArticuloFromCarrito({required this.articuloId});

  @override
  List<Object?> get props => [articuloId];
}

/// Limpiar carrito
class ClearCarrito extends SalesEvent {
  const ClearCarrito();
}

/// Aplicar descuento a un artículo del carrito
class ApplyDescuentoToArticulo extends SalesEvent {
  final String articuloId;
  final double descuentoPorcentaje;
  final String? motivoDescuento;

  const ApplyDescuentoToArticulo({
    required this.articuloId,
    required this.descuentoPorcentaje,
    this.motivoDescuento,
  });

  @override
  List<Object?> get props => [articuloId, descuentoPorcentaje, motivoDescuento];
}

/// Calcular descuentos automáticos basados en cantidad
class CalcularDescuentosAutomaticos extends SalesEvent {
  const CalcularDescuentosAutomaticos();
}

// ================== EVENTOS DE VENTAS ==================

/// Crear nueva venta
class CreateVenta extends SalesEvent {
  final String tiendaId;
  final String vendedorId;
  final String? clienteId;
  final List<Map<String, dynamic>> detallesVenta;

  const CreateVenta({
    required this.tiendaId,
    required this.vendedorId,
    this.clienteId,
    required this.detallesVenta,
  });

  @override
  List<Object?> get props => [tiendaId, vendedorId, clienteId, detallesVenta];
}

/// Cargar venta por ID
class LoadVenta extends SalesEvent {
  final String ventaId;

  const LoadVenta({required this.ventaId});

  @override
  List<Object?> get props => [ventaId];
}

/// Cargar ventas con filtros
class LoadVentas extends SalesEvent {
  final String? tiendaId;
  final String? vendedorId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final EstadoVenta? estado;
  final int limit;
  final int offset;

  const LoadVentas({
    this.tiendaId,
    this.vendedorId,
    this.fechaInicio,
    this.fechaFin,
    this.estado,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [
    tiendaId, vendedorId, fechaInicio, fechaFin,
    estado, limit, offset
  ];
}

/// Actualizar estado de venta
class UpdateEstadoVenta extends SalesEvent {
  final String ventaId;
  final EstadoVenta nuevoEstado;

  const UpdateEstadoVenta({
    required this.ventaId,
    required this.nuevoEstado,
  });

  @override
  List<Object?> get props => [ventaId, nuevoEstado];
}

// ================== EVENTOS DE APROBACIONES ==================

/// Solicitar aprobación de descuento
class SolicitarAprobacionDescuento extends SalesEvent {
  final String ventaId;
  final String vendedorId;
  final double descuentoSolicitado;
  final String? motivoDescuento;

  const SolicitarAprobacionDescuento({
    required this.ventaId,
    required this.vendedorId,
    required this.descuentoSolicitado,
    this.motivoDescuento,
  });

  @override
  List<Object?> get props => [ventaId, vendedorId, descuentoSolicitado, motivoDescuento];
}

/// Cargar aprobaciones pendientes
class LoadAprobacionesPendientes extends SalesEvent {
  final String? supervisorId;

  const LoadAprobacionesPendientes({this.supervisorId});

  @override
  List<Object?> get props => [supervisorId];
}

/// Responder a solicitud de aprobación
class ResponderAprobacion extends SalesEvent {
  final String aprobacionId;
  final EstadoAprobacion estado;
  final String? comentarios;
  final String? supervisorId;

  const ResponderAprobacion({
    required this.aprobacionId,
    required this.estado,
    this.comentarios,
    this.supervisorId,
  });

  @override
  List<Object?> get props => [aprobacionId, estado, comentarios, supervisorId];
}

// ================== EVENTOS DE CÁLCULOS ==================

/// Calcular descuento por cantidad
class CalcularDescuentoPorCantidad extends SalesEvent {
  final String categoriaId;
  final int cantidad;
  final String? tiendaId;

  const CalcularDescuentoPorCantidad({
    required this.categoriaId,
    required this.cantidad,
    this.tiendaId,
  });

  @override
  List<Object?> get props => [categoriaId, cantidad, tiendaId];
}

/// Verificar permiso de descuento
class VerificarPermisoDescuento extends SalesEvent {
  final String rolUsuario;
  final double descuentoPorcentaje;

  const VerificarPermisoDescuento({
    required this.rolUsuario,
    required this.descuentoPorcentaje,
  });

  @override
  List<Object?> get props => [rolUsuario, descuentoPorcentaje];
}

// ================== EVENTOS DE REPORTES ==================

/// Cargar resumen de ventas
class LoadResumenVentas extends SalesEvent {
  final String? tiendaId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const LoadResumenVentas({
    this.tiendaId,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [tiendaId, fechaInicio, fechaFin];
}

// ================== EVENTOS DE ESTADO ==================

/// Resetear estado de ventas
class ResetSalesState extends SalesEvent {
  const ResetSalesState();
}

/// Limpiar errores
class ClearSalesErrors extends SalesEvent {
  const ClearSalesErrors();
}