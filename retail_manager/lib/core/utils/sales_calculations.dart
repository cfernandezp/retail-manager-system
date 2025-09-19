import '../../data/models/product_models.dart';

/// Utilidades para cálculos de ventas y descuentos
/// Proporciona funciones para calcular precios, descuentos y totales
class SalesCalculations {

  // ================== CÁLCULOS DE DESCUENTO ==================

  /// Calcula el descuento aplicable basado en una estrategia y cantidad
  static double calcularDescuentoPorEstrategia(
    EstrategiaDescuento estrategia,
    int cantidad,
  ) {
    for (final rango in estrategia.rangosDescuento) {
      if (cantidad >= rango.cantidadMin && cantidad <= rango.cantidadMax) {
        return rango.descuentoPorcentaje;
      }
    }
    return 0.0;
  }

  /// Calcula el monto del descuento basado en precio y porcentaje
  static double calcularMontoDescuento(
    double precioUnitario,
    int cantidad,
    double descuentoPorcentaje,
  ) {
    final subtotal = precioUnitario * cantidad;
    return subtotal * (descuentoPorcentaje / 100);
  }

  /// Calcula el subtotal después del descuento
  static double calcularSubtotalConDescuento(
    double precioUnitario,
    int cantidad,
    double descuentoPorcentaje,
  ) {
    final subtotal = precioUnitario * cantidad;
    final descuento = calcularMontoDescuento(precioUnitario, cantidad, descuentoPorcentaje);
    return subtotal - descuento;
  }

  // ================== CÁLCULOS DE VENTA ==================

  /// Calcula el total de una venta con múltiples detalles
  static Map<String, double> calcularTotalVenta(List<DetalleVenta> detalles) {
    double subtotal = 0.0;
    double descuentoTotal = 0.0;

    for (final detalle in detalles) {
      subtotal += detalle.precioUnitario * detalle.cantidad;
      descuentoTotal += detalle.descuentoMonto;
    }

    final impuestos = calcularImpuestos(subtotal - descuentoTotal);
    final montoTotal = subtotal - descuentoTotal + impuestos;

    return {
      'subtotal': subtotal,
      'descuento_total': descuentoTotal,
      'impuestos': impuestos,
      'monto_total': montoTotal,
    };
  }

  /// Calcula los impuestos (IGV 18% en Perú)
  static double calcularImpuestos(double baseImponible, {double porcentajeIGV = 18.0}) {
    return baseImponible * (porcentajeIGV / 100);
  }

  /// Calcula el precio con IGV incluido
  static double calcularPrecioConIGV(double precioSinIGV, {double porcentajeIGV = 18.0}) {
    return precioSinIGV * (1 + porcentajeIGV / 100);
  }

  /// Calcula el precio sin IGV desde un precio con IGV
  static double calcularPrecioSinIGV(double precioConIGV, {double porcentajeIGV = 18.0}) {
    return precioConIGV / (1 + porcentajeIGV / 100);
  }

  // ================== VALIDACIONES DE DESCUENTO ==================

  /// Valida si un descuento puede ser aplicado según los permisos
  static bool validarDescuentoPermitido(
    double descuentoPorcentaje,
    PermisoDescuento permiso,
  ) {
    return descuentoPorcentaje <= permiso.descuentoMaximoPorcentaje;
  }

  /// Determina si un descuento requiere aprobación
  static bool requiereAprobacion(
    double descuentoPorcentaje,
    PermisoDescuento permiso,
  ) {
    if (!validarDescuentoPermitido(descuentoPorcentaje, permiso)) {
      return true; // Siempre requiere aprobación si excede el límite
    }
    return permiso.requiereAprobacion;
  }

  // ================== FORMATEO DE VALORES ==================

  /// Formatea un valor monetario en soles peruanos
  static String formatearMoneda(double valor) {
    return 'S/ ${valor.toStringAsFixed(2)}';
  }

  /// Formatea un porcentaje
  static String formatearPorcentaje(double porcentaje) {
    return '${porcentaje.toStringAsFixed(1)}%';
  }

  /// Redondea un valor monetario a dos decimales
  static double redondearMoneda(double valor) {
    return double.parse(valor.toStringAsFixed(2));
  }

  // ================== CÁLCULOS ESPECÍFICOS PARA RETAIL ==================

  /// Calcula el precio por media docena (6 unidades)
  static double calcularPrecioMediaDocena(
    double precioUnitario,
    EstrategiaDescuento? estrategia,
  ) {
    if (estrategia == null) return precioUnitario * 6;

    final descuento = calcularDescuentoPorEstrategia(estrategia, 6);
    return calcularSubtotalConDescuento(precioUnitario, 6, descuento);
  }

  /// Calcula el precio por docena (12 unidades)
  static double calcularPrecioDocena(
    double precioUnitario,
    EstrategiaDescuento? estrategia,
  ) {
    if (estrategia == null) return precioUnitario * 12;

    final descuento = calcularDescuentoPorEstrategia(estrategia, 12);
    return calcularSubtotalConDescuento(precioUnitario, 12, descuento);
  }

  /// Calcula el ahorro comparado con precio individual
  static double calcularAhorro(
    double precioIndividual,
    double precioConDescuento,
    int cantidad,
  ) {
    final precioSinDescuento = precioIndividual * cantidad;
    return precioSinDescuento - precioConDescuento;
  }

  /// Calcula el porcentaje de ahorro
  static double calcularPorcentajeAhorro(
    double precioIndividual,
    double precioConDescuento,
    int cantidad,
  ) {
    final precioSinDescuento = precioIndividual * cantidad;
    if (precioSinDescuento == 0) return 0.0;

    final ahorro = calcularAhorro(precioIndividual, precioConDescuento, cantidad);
    return (ahorro / precioSinDescuento) * 100;
  }

  // ================== CÁLCULOS DE MARGEN ==================

  /// Calcula el margen de ganancia
  static double calcularMargen(double precioCosto, double precioVenta) {
    if (precioVenta == 0) return 0.0;
    return ((precioVenta - precioCosto) / precioVenta) * 100;
  }

  /// Calcula el markup (sobreprecio)
  static double calcularMarkup(double precioCosto, double precioVenta) {
    if (precioCosto == 0) return 0.0;
    return ((precioVenta - precioCosto) / precioCosto) * 100;
  }

  /// Calcula el precio mínimo de venta para mantener un margen específico
  static double calcularPrecioMinimoVenta(
    double precioCosto,
    double margenMinimoPorcentaje,
  ) {
    return precioCosto / (1 - margenMinimoPorcentaje / 100);
  }

  // ================== FUNCIONES DE UTILIDAD ==================

  /// Convierte un estado de venta a string legible
  static String estadoVentaToString(EstadoVenta estado) {
    switch (estado) {
      case EstadoVenta.pendiente:
        return 'Pendiente';
      case EstadoVenta.completada:
        return 'Completada';
      case EstadoVenta.cancelada:
        return 'Cancelada';
      case EstadoVenta.devuelta:
        return 'Devuelta';
    }
  }

  /// Convierte un estado de aprobación a string legible
  static String estadoAprobacionToString(EstadoAprobacion estado) {
    switch (estado) {
      case EstadoAprobacion.pendiente:
        return 'Pendiente';
      case EstadoAprobacion.aprobada:
        return 'Aprobada';
      case EstadoAprobacion.rechazada:
        return 'Rechazada';
    }
  }

  /// Obtiene el color para mostrar un estado de venta
  static String getColorEstadoVenta(EstadoVenta estado) {
    switch (estado) {
      case EstadoVenta.pendiente:
        return '#FFA500'; // Naranja
      case EstadoVenta.completada:
        return '#4CAF50'; // Verde
      case EstadoVenta.cancelada:
        return '#F44336'; // Rojo
      case EstadoVenta.devuelta:
        return '#9E9E9E'; // Gris
    }
  }

  /// Obtiene el color para mostrar un estado de aprobación
  static String getColorEstadoAprobacion(EstadoAprobacion estado) {
    switch (estado) {
      case EstadoAprobacion.pendiente:
        return '#FFA500'; // Naranja
      case EstadoAprobacion.aprobada:
        return '#4CAF50'; // Verde
      case EstadoAprobacion.rechazada:
        return '#F44336'; // Rojo
    }
  }

  // ================== VALIDACIONES ADICIONALES ==================

  /// Valida que los datos de venta sean consistentes
  static Map<String, dynamic> validarDatosVenta(
    List<DetalleVenta> detalles,
    double subtotalEsperado,
    double descuentoEsperado,
    double totalEsperado,
  ) {
    final calculado = calcularTotalVenta(detalles);

    final errors = <String>[];

    if ((calculado['subtotal']! - subtotalEsperado).abs() > 0.01) {
      errors.add('Subtotal no coincide');
    }

    if ((calculado['descuento_total']! - descuentoEsperado).abs() > 0.01) {
      errors.add('Descuento total no coincide');
    }

    if ((calculado['monto_total']! - totalEsperado).abs() > 0.01) {
      errors.add('Total no coincide');
    }

    return {
      'es_valido': errors.isEmpty,
      'errores': errors,
      'calculado': calculado,
    };
  }

  /// Calcula métricas de rendimiento para un vendedor
  static Map<String, dynamic> calcularMetricasVendedor(
    List<Venta> ventas,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) {
    final ventasCompletadas = ventas
        .where((v) => v.estado == EstadoVenta.completada)
        .toList();

    final totalVentas = ventasCompletadas
        .fold<double>(0.0, (sum, v) => sum + v.montoTotal);

    final promedioTicket = ventasCompletadas.isNotEmpty
        ? totalVentas / ventasCompletadas.length
        : 0.0;

    final diasPeriodo = fechaFin.difference(fechaInicio).inDays + 1;
    final ventasPorDia = ventasCompletadas.length / diasPeriodo;

    return {
      'total_ventas': totalVentas,
      'cantidad_ventas': ventasCompletadas.length,
      'promedio_ticket': promedioTicket,
      'ventas_por_dia': ventasPorDia,
      'total_descuentos': ventasCompletadas
          .fold<double>(0.0, (sum, v) => sum + v.descuentoTotal),
    };
  }
}

/// Extensiones para facilitar cálculos en los modelos
extension EstrategiaDescuentoCalculations on EstrategiaDescuento {

  /// Obtiene el descuento para una cantidad específica
  double getDescuentoParaCantidad(int cantidad) {
    return SalesCalculations.calcularDescuentoPorEstrategia(this, cantidad);
  }

  /// Verifica si la estrategia aplica para una cantidad
  bool aplicaParaCantidad(int cantidad) {
    return getDescuentoParaCantidad(cantidad) > 0;
  }

  /// Obtiene todos los rangos de cantidad disponibles
  List<int> getRangosCantidad() {
    return rangosDescuento.map((r) => r.cantidadMin).toList()..sort();
  }
}

extension PermisoDescuentoValidations on PermisoDescuento {

  /// Verifica si puede aplicar un descuento específico
  bool puedeAplicarDescuento(double porcentaje) {
    return SalesCalculations.validarDescuentoPermitido(porcentaje, this);
  }

  /// Determina si un descuento necesita aprobación
  bool necesitaAprobacion(double porcentaje) {
    return SalesCalculations.requiereAprobacion(porcentaje, this);
  }
}

extension VentaCalculations on Venta {

  /// Obtiene el estado formateado
  String get estadoFormateado => SalesCalculations.estadoVentaToString(estado);

  /// Obtiene el color del estado
  String get colorEstado => SalesCalculations.getColorEstadoVenta(estado);

  /// Obtiene el total formateado
  String get totalFormateado => SalesCalculations.formatearMoneda(montoTotal);

  /// Calcula el ahorro total de la venta
  double get ahorroTotal => subtotal - (montoTotal - impuestos);

  /// Calcula el porcentaje de descuento promedio
  double get porcentajeDescuentoPromedio {
    if (subtotal == 0) return 0.0;
    return (descuentoTotal / subtotal) * 100;
  }
}