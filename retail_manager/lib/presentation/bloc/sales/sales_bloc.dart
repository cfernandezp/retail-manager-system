import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../core/utils/sales_calculations.dart';

part 'sales_event.dart';
part 'sales_state.dart';

/// BLoC para manejo del módulo de ventas
/// Gestiona estrategias de descuento, permisos, carrito, ventas y aprobaciones
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _repository;

  SalesBloc({required SalesRepository repository})
      : _repository = repository,
        super(const SalesInitial()) {

    // Eventos de estrategias de descuento
    on<LoadEstrategiasDescuento>(_onLoadEstrategiasDescuento);
    on<LoadEstrategiaParaCategoria>(_onLoadEstrategiaParaCategoria);
    on<CreateEstrategiaDescuento>(_onCreateEstrategiaDescuento);

    // Eventos de permisos
    on<LoadPermisoDescuento>(_onLoadPermisoDescuento);
    on<LoadAllPermisosDescuento>(_onLoadAllPermisosDescuento);

    // Eventos de carrito/POS
    on<AddArticuloToCarrito>(_onAddArticuloToCarrito);
    on<UpdateCantidadCarrito>(_onUpdateCantidadCarrito);
    on<RemoveArticuloFromCarrito>(_onRemoveArticuloFromCarrito);
    on<ClearCarrito>(_onClearCarrito);
    on<ApplyDescuentoToArticulo>(_onApplyDescuentoToArticulo);
    on<CalcularDescuentosAutomaticos>(_onCalcularDescuentosAutomaticos);

    // Eventos de ventas
    on<CreateVenta>(_onCreateVenta);
    on<LoadVenta>(_onLoadVenta);
    on<LoadVentas>(_onLoadVentas);
    on<UpdateEstadoVenta>(_onUpdateEstadoVenta);

    // Eventos de aprobaciones
    on<SolicitarAprobacionDescuento>(_onSolicitarAprobacionDescuento);
    on<LoadAprobacionesPendientes>(_onLoadAprobacionesPendientes);
    on<ResponderAprobacion>(_onResponderAprobacion);

    // Eventos de cálculos
    on<CalcularDescuentoPorCantidad>(_onCalcularDescuentoPorCantidad);
    on<VerificarPermisoDescuento>(_onVerificarPermisoDescuento);

    // Eventos de reportes
    on<LoadResumenVentas>(_onLoadResumenVentas);

    // Eventos de estado
    on<ResetSalesState>(_onResetSalesState);
    on<ClearSalesErrors>(_onClearSalesErrors);
  }

  // ================== ESTRATEGIAS DE DESCUENTO ==================

  Future<void> _onLoadEstrategiasDescuento(
    LoadEstrategiasDescuento event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(const SalesLoading());

      final estrategias = await _repository.getEstrategiasDescuento(
        categoriaId: event.categoriaId,
        tiendaId: event.tiendaId,
        soloActivas: event.soloActivas,
      );

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(estrategias: estrategias));
      } else {
        emit(SalesLoaded(estrategias: estrategias));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar estrategias de descuento: ${e.toString()}',
        errorCode: 'LOAD_ESTRATEGIAS_ERROR',
      ));
    }
  }

  Future<void> _onLoadEstrategiaParaCategoria(
    LoadEstrategiaParaCategoria event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final estrategia = await _repository.getEstrategiaParaCategoria(
        event.categoriaId,
        tiendaId: event.tiendaId,
      );

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(estrategiaActual: estrategia));
      } else {
        emit(SalesLoaded(estrategiaActual: estrategia));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar estrategia para categoría: ${e.toString()}',
        errorCode: 'LOAD_ESTRATEGIA_CATEGORIA_ERROR',
      ));
    }
  }

  Future<void> _onCreateEstrategiaDescuento(
    CreateEstrategiaDescuento event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(const SalesLoading());

      final nuevaEstrategia = await _repository.createEstrategiaDescuento(
        event.estrategiaData,
      );

      emit(const SalesUpdated(
        message: 'Estrategia de descuento creada exitosamente',
      ));

      // Recargar estrategias
      add(const LoadEstrategiasDescuento());

    } catch (e) {
      emit(SalesError(
        message: 'Error al crear estrategia de descuento: ${e.toString()}',
        errorCode: 'CREATE_ESTRATEGIA_ERROR',
      ));
    }
  }

  // ================== PERMISOS ==================

  Future<void> _onLoadPermisoDescuento(
    LoadPermisoDescuento event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final permiso = await _repository.getPermisoDescuento(event.rolUsuario);

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(permisoActual: permiso));
      } else {
        emit(SalesLoaded(permisoActual: permiso));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar permisos de descuento: ${e.toString()}',
        errorCode: 'LOAD_PERMISO_ERROR',
      ));
    }
  }

  Future<void> _onLoadAllPermisosDescuento(
    LoadAllPermisosDescuento event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final permisos = await _repository.getAllPermisosDescuento();

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(permisos: permisos));
      } else {
        emit(SalesLoaded(permisos: permisos));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar todos los permisos: ${e.toString()}',
        errorCode: 'LOAD_ALL_PERMISOS_ERROR',
      ));
    }
  }

  // ================== CARRITO/POS ==================

  Future<void> _onAddArticuloToCarrito(
    AddArticuloToCarrito event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final currentState = state is SalesLoaded ? state as SalesLoaded : const SalesLoaded();
      final carrito = currentState.carrito;

      // Verificar si el artículo ya está en el carrito
      final existingItemIndex = carrito.getItemIndex(event.articulo.id);

      List<CarritoItem> updatedItems = List.from(carrito.items);

      if (existingItemIndex != -1) {
        // Actualizar cantidad del artículo existente
        final existingItem = carrito.items[existingItemIndex];
        final nuevaCantidad = existingItem.cantidad + event.cantidad;

        final updatedItem = _calculateCarritoItem(
          event.articulo,
          nuevaCantidad,
          existingItem.descuentoPorcentaje,
          existingItem.motivoDescuento,
          existingItem.esDescuentoAutomatico,
        );

        updatedItems[existingItemIndex] = updatedItem;
      } else {
        // Agregar nuevo artículo
        final newItem = _calculateCarritoItem(
          event.articulo,
          event.cantidad,
          0.0, // Sin descuento inicial
          null,
          false,
        );

        updatedItems.add(newItem);
      }

      final updatedCarrito = _calculateCarritoTotals(carrito.copyWith(items: updatedItems));
      emit(currentState.copyWith(carrito: updatedCarrito));

      // Calcular descuentos automáticos después de agregar
      add(const CalcularDescuentosAutomaticos());

    } catch (e) {
      emit(SalesError(
        message: 'Error al agregar artículo al carrito: ${e.toString()}',
        errorCode: 'ADD_CARRITO_ERROR',
      ));
    }
  }

  Future<void> _onUpdateCantidadCarrito(
    UpdateCantidadCarrito event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final currentState = state is SalesLoaded ? state as SalesLoaded : const SalesLoaded();
      final carrito = currentState.carrito;

      final itemIndex = carrito.getItemIndex(event.articuloId);
      if (itemIndex == -1) {
        emit(const SalesError(
          message: 'Artículo no encontrado en el carrito',
          errorCode: 'ITEM_NOT_FOUND',
        ));
        return;
      }

      List<CarritoItem> updatedItems = List.from(carrito.items);

      if (event.nuevaCantidad <= 0) {
        // Remover artículo si la cantidad es 0 o negativa
        updatedItems.removeAt(itemIndex);
      } else {
        // Actualizar cantidad
        final existingItem = carrito.items[itemIndex];
        final updatedItem = _calculateCarritoItem(
          existingItem.articulo,
          event.nuevaCantidad,
          existingItem.descuentoPorcentaje,
          existingItem.motivoDescuento,
          existingItem.esDescuentoAutomatico,
        );

        updatedItems[itemIndex] = updatedItem;
      }

      final updatedCarrito = _calculateCarritoTotals(carrito.copyWith(items: updatedItems));
      emit(currentState.copyWith(carrito: updatedCarrito));

      // Recalcular descuentos automáticos
      add(const CalcularDescuentosAutomaticos());

    } catch (e) {
      emit(SalesError(
        message: 'Error al actualizar cantidad: ${e.toString()}',
        errorCode: 'UPDATE_CANTIDAD_ERROR',
      ));
    }
  }

  Future<void> _onRemoveArticuloFromCarrito(
    RemoveArticuloFromCarrito event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final currentState = state is SalesLoaded ? state as SalesLoaded : const SalesLoaded();
      final carrito = currentState.carrito;

      final updatedItems = carrito.items
          .where((item) => item.articulo.id != event.articuloId)
          .toList();

      final updatedCarrito = _calculateCarritoTotals(carrito.copyWith(items: updatedItems));
      emit(currentState.copyWith(carrito: updatedCarrito));

    } catch (e) {
      emit(SalesError(
        message: 'Error al remover artículo del carrito: ${e.toString()}',
        errorCode: 'REMOVE_CARRITO_ERROR',
      ));
    }
  }

  Future<void> _onClearCarrito(
    ClearCarrito event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final currentState = state is SalesLoaded ? state as SalesLoaded : const SalesLoaded();

      emit(currentState.copyWith(carrito: const CarritoState()));

    } catch (e) {
      emit(SalesError(
        message: 'Error al limpiar carrito: ${e.toString()}',
        errorCode: 'CLEAR_CARRITO_ERROR',
      ));
    }
  }

  Future<void> _onApplyDescuentoToArticulo(
    ApplyDescuentoToArticulo event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final currentState = state is SalesLoaded ? state as SalesLoaded : const SalesLoaded();
      final carrito = currentState.carrito;

      final itemIndex = carrito.getItemIndex(event.articuloId);
      if (itemIndex == -1) {
        emit(const SalesError(
          message: 'Artículo no encontrado en el carrito',
          errorCode: 'ITEM_NOT_FOUND',
        ));
        return;
      }

      List<CarritoItem> updatedItems = List.from(carrito.items);
      final existingItem = carrito.items[itemIndex];

      final updatedItem = _calculateCarritoItem(
        existingItem.articulo,
        existingItem.cantidad,
        event.descuentoPorcentaje,
        event.motivoDescuento,
        false, // Es descuento manual
      );

      updatedItems[itemIndex] = updatedItem;

      final updatedCarrito = _calculateCarritoTotals(carrito.copyWith(items: updatedItems));
      emit(currentState.copyWith(carrito: updatedCarrito));

    } catch (e) {
      emit(SalesError(
        message: 'Error al aplicar descuento: ${e.toString()}',
        errorCode: 'APPLY_DESCUENTO_ERROR',
      ));
    }
  }

  Future<void> _onCalcularDescuentosAutomaticos(
    CalcularDescuentosAutomaticos event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final currentState = state is SalesLoaded ? state as SalesLoaded : const SalesLoaded();
      final carrito = currentState.carrito;

      List<CarritoItem> updatedItems = [];

      for (final item in carrito.items) {
        // Solo aplicar descuentos automáticos a artículos sin descuento manual
        if (!item.esDescuentoAutomatico && item.descuentoPorcentaje == 0) {
          // Obtener categoría del producto
          final categoriaId = item.articulo.producto?.categoriaId;

          if (categoriaId != null) {
            try {
              final descuentoAutomatico = await _repository.calcularDescuentoPorCantidad(
                categoriaId,
                item.cantidad,
              );

              if (descuentoAutomatico > 0) {
                final updatedItem = _calculateCarritoItem(
                  item.articulo,
                  item.cantidad,
                  descuentoAutomatico,
                  'Descuento automático por cantidad',
                  true, // Es descuento automático
                );
                updatedItems.add(updatedItem);
              } else {
                updatedItems.add(item);
              }
            } catch (e) {
              // Si falla el cálculo, mantener el artículo sin cambios
              updatedItems.add(item);
            }
          } else {
            updatedItems.add(item);
          }
        } else {
          // Mantener artículos con descuento manual
          updatedItems.add(item);
        }
      }

      final updatedCarrito = _calculateCarritoTotals(carrito.copyWith(items: updatedItems));
      emit(currentState.copyWith(carrito: updatedCarrito));

    } catch (e) {
      emit(SalesError(
        message: 'Error al calcular descuentos automáticos: ${e.toString()}',
        errorCode: 'CALCULATE_AUTO_DESCUENTOS_ERROR',
      ));
    }
  }

  // ================== VENTAS ==================

  Future<void> _onCreateVenta(
    CreateVenta event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(const SalesLoading());

      // Calcular totales de la venta
      final currentState = state is SalesLoaded ? state as SalesLoaded : const SalesLoaded();
      final carrito = currentState.carrito;

      final totales = SalesCalculations.calcularTotalVenta(
        carrito.items.map((item) => DetalleVenta(
          id: '',
          ventaId: '',
          articuloId: item.articulo.id,
          cantidad: item.cantidad,
          precioUnitario: item.precioUnitario,
          descuentoPorcentaje: item.descuentoPorcentaje,
          descuentoMonto: item.descuentoMonto,
          subtotal: item.subtotal,
          createdAt: DateTime.now(),
        )).toList(),
      );

      // Crear venta
      final ventaData = {
        'tienda_id': event.tiendaId,
        'vendedor_id': event.vendedorId,
        'cliente_id': event.clienteId,
        'subtotal': totales['subtotal'],
        'descuento_total': totales['descuento_total'],
        'impuestos': totales['impuestos'],
        'monto_total': totales['monto_total'],
        'estado': 'pendiente',
        'fecha_venta': DateTime.now().toIso8601String(),
      };

      final venta = await _repository.createVenta(ventaData);

      // Crear detalles de venta
      final detallesData = carrito.items
          .map((item) => item.toDetalleVenta(venta.id))
          .toList();

      await _repository.createDetallesVenta(detallesData);

      // Limpiar carrito después de crear la venta
      add(const ClearCarrito());

      emit(SalesCreated(
        venta: venta,
        message: 'Venta creada exitosamente: ${venta.numeroVenta}',
      ));

    } catch (e) {
      emit(SalesError(
        message: 'Error al crear venta: ${e.toString()}',
        errorCode: 'CREATE_VENTA_ERROR',
      ));
    }
  }

  Future<void> _onLoadVenta(
    LoadVenta event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(const SalesLoading());

      final venta = await _repository.getVenta(event.ventaId);

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(ventaActual: venta));
      } else {
        emit(SalesLoaded(ventaActual: venta));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar venta: ${e.toString()}',
        errorCode: 'LOAD_VENTA_ERROR',
      ));
    }
  }

  Future<void> _onLoadVentas(
    LoadVentas event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(const SalesLoading());

      final ventas = await _repository.getVentas(
        tiendaId: event.tiendaId,
        vendedorId: event.vendedorId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        estado: event.estado,
        limit: event.limit,
        offset: event.offset,
      );

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(ventas: ventas));
      } else {
        emit(SalesLoaded(ventas: ventas));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar ventas: ${e.toString()}',
        errorCode: 'LOAD_VENTAS_ERROR',
      ));
    }
  }

  Future<void> _onUpdateEstadoVenta(
    UpdateEstadoVenta event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(const SalesLoading());

      final ventaActualizada = await _repository.updateEstadoVenta(
        event.ventaId,
        event.nuevoEstado,
      );

      emit(SalesUpdated(
        message: 'Estado de venta actualizado exitosamente',
        updatedData: ventaActualizada,
      ));

      // Recargar ventas
      add(const LoadVentas());

    } catch (e) {
      emit(SalesError(
        message: 'Error al actualizar estado de venta: ${e.toString()}',
        errorCode: 'UPDATE_ESTADO_VENTA_ERROR',
      ));
    }
  }

  // ================== APROBACIONES ==================

  Future<void> _onSolicitarAprobacionDescuento(
    SolicitarAprobacionDescuento event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final aprobacionData = {
        'venta_id': event.ventaId,
        'vendedor_id': event.vendedorId,
        'descuento_solicitado': event.descuentoSolicitado,
        'motivo_descuento': event.motivoDescuento,
        'estado': 'pendiente',
        'fecha_solicitud': DateTime.now().toIso8601String(),
      };

      await _repository.createAprobacionDescuento(aprobacionData);

      emit(const SalesUpdated(
        message: 'Solicitud de aprobación enviada exitosamente',
      ));

    } catch (e) {
      emit(SalesError(
        message: 'Error al solicitar aprobación: ${e.toString()}',
        errorCode: 'SOLICITAR_APROBACION_ERROR',
      ));
    }
  }

  Future<void> _onLoadAprobacionesPendientes(
    LoadAprobacionesPendientes event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final aprobaciones = await _repository.getAprobacionesPendientes(
        supervisorId: event.supervisorId,
      );

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(aprobacionesPendientes: aprobaciones));
      } else {
        emit(SalesLoaded(aprobacionesPendientes: aprobaciones));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar aprobaciones pendientes: ${e.toString()}',
        errorCode: 'LOAD_APROBACIONES_ERROR',
      ));
    }
  }

  Future<void> _onResponderAprobacion(
    ResponderAprobacion event,
    Emitter<SalesState> emit,
  ) async {
    try {
      await _repository.responderAprobacion(
        event.aprobacionId,
        event.estado,
        comentarios: event.comentarios,
        supervisorId: event.supervisorId,
      );

      emit(const SalesUpdated(
        message: 'Respuesta de aprobación registrada exitosamente',
      ));

      // Recargar aprobaciones pendientes
      add(LoadAprobacionesPendientes(supervisorId: event.supervisorId));

    } catch (e) {
      emit(SalesError(
        message: 'Error al responder aprobación: ${e.toString()}',
        errorCode: 'RESPONDER_APROBACION_ERROR',
      ));
    }
  }

  // ================== CÁLCULOS ==================

  Future<void> _onCalcularDescuentoPorCantidad(
    CalcularDescuentoPorCantidad event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final descuento = await _repository.calcularDescuentoPorCantidad(
        event.categoriaId,
        event.cantidad,
        tiendaId: event.tiendaId,
      );

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(descuentoCalculado: descuento));
      } else {
        emit(SalesLoaded(descuentoCalculado: descuento));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al calcular descuento: ${e.toString()}',
        errorCode: 'CALCULATE_DESCUENTO_ERROR',
      ));
    }
  }

  Future<void> _onVerificarPermisoDescuento(
    VerificarPermisoDescuento event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final tienePermiso = await _repository.verificarPermisoDescuento(
        event.rolUsuario,
        event.descuentoPorcentaje,
      );

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(permisoVerificado: tienePermiso));
      } else {
        emit(SalesLoaded(permisoVerificado: tienePermiso));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al verificar permiso: ${e.toString()}',
        errorCode: 'VERIFY_PERMISO_ERROR',
      ));
    }
  }

  // ================== REPORTES ==================

  Future<void> _onLoadResumenVentas(
    LoadResumenVentas event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final resumen = await _repository.getResumenVentas(
        tiendaId: event.tiendaId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );

      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        emit(currentState.copyWith(resumenVentas: resumen));
      } else {
        emit(SalesLoaded(resumenVentas: resumen));
      }

    } catch (e) {
      emit(SalesError(
        message: 'Error al cargar resumen de ventas: ${e.toString()}',
        errorCode: 'LOAD_RESUMEN_ERROR',
      ));
    }
  }

  // ================== ESTADO ==================

  Future<void> _onResetSalesState(
    ResetSalesState event,
    Emitter<SalesState> emit,
  ) async {
    emit(const SalesInitial());
  }

  Future<void> _onClearSalesErrors(
    ClearSalesErrors event,
    Emitter<SalesState> emit,
  ) async {
    if (state is SalesError) {
      emit(const SalesLoaded());
    }
  }

  // ================== FUNCIONES AUXILIARES ==================

  /// Calcula un item del carrito con descuentos
  CarritoItem _calculateCarritoItem(
    Articulo articulo,
    int cantidad,
    double descuentoPorcentaje,
    String? motivoDescuento,
    bool esDescuentoAutomatico,
  ) {
    final precioUnitario = articulo.precioSugerido;
    final descuentoMonto = SalesCalculations.calcularMontoDescuento(
      precioUnitario,
      cantidad,
      descuentoPorcentaje,
    );
    final subtotal = SalesCalculations.calcularSubtotalConDescuento(
      precioUnitario,
      cantidad,
      descuentoPorcentaje,
    );

    return CarritoItem(
      articulo: articulo,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      descuentoPorcentaje: descuentoPorcentaje,
      descuentoMonto: descuentoMonto,
      subtotal: subtotal,
      motivoDescuento: motivoDescuento,
      esDescuentoAutomatico: esDescuentoAutomatico,
    );
  }

  /// Calcula los totales del carrito
  CarritoState _calculateCarritoTotals(CarritoState carrito) {
    double subtotal = 0.0;
    double descuentoTotal = 0.0;
    bool tieneDescuentosEspeciales = false;

    for (final item in carrito.items) {
      subtotal += item.precioUnitario * item.cantidad;
      descuentoTotal += item.descuentoMonto;

      if (item.tieneDescuento && !item.esDescuentoAutomatico) {
        tieneDescuentosEspeciales = true;
      }
    }

    final impuestos = SalesCalculations.calcularImpuestos(subtotal - descuentoTotal);
    final montoTotal = subtotal - descuentoTotal + impuestos;

    return carrito.copyWith(
      subtotal: SalesCalculations.redondearMoneda(subtotal),
      descuentoTotal: SalesCalculations.redondearMoneda(descuentoTotal),
      impuestos: SalesCalculations.redondearMoneda(impuestos),
      montoTotal: SalesCalculations.redondearMoneda(montoTotal),
      tieneDescuentosEspeciales: tieneDescuentosEspeciales,
    );
  }
}