import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_models.dart';

/// Repositorio para el módulo de ventas
/// Maneja estrategias de descuento, permisos, ventas y aprobaciones
class SalesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ================== ESTRATEGIAS DE DESCUENTO ==================

  /// Obtiene todas las estrategias de descuento activas
  Future<List<EstrategiaDescuento>> getEstrategiasDescuento({
    String? categoriaId,
    String? tiendaId,
    bool soloActivas = true,
  }) async {
    try {
      print('🔄 [SALES_REPO] Obteniendo estrategias de descuento...');

      var query = _client
          .from('estrategias_descuento')
          .select('''
            *,
            categorias:categoria_id(id, nombre),
            tiendas:tienda_id(id, nombre)
          ''');

      if (soloActivas) {
        query = query.eq('activa', true);
      }

      if (categoriaId != null) {
        query = query.eq('categoria_id', categoriaId);
      }

      if (tiendaId != null) {
        query = query.eq('tienda_id', tiendaId);
      }

      final response = await query.order('nombre');

      print('✅ [SALES_REPO] Estrategias obtenidas: ${response.length}');

      return (response as List)
          .map((json) => EstrategiaDescuento.fromJson(json))
          .toList();

    } catch (e) {
      print('❌ [SALES_REPO] Error getEstrategiasDescuento: $e');
      throw Exception('Error al obtener estrategias de descuento: $e');
    }
  }

  /// Obtiene una estrategia de descuento específica aplicable a una categoría
  Future<EstrategiaDescuento?> getEstrategiaParaCategoria(
    String categoriaId, {
    String? tiendaId,
  }) async {
    try {
      print('🔄 [SALES_REPO] Buscando estrategia para categoría $categoriaId...');

      var query = _client
          .from('estrategias_descuento')
          .select('*')
          .eq('activa', true);

      // Buscar primero estrategia específica para la categoría
      query = query.eq('categoria_id', categoriaId);

      if (tiendaId != null) {
        query = query.eq('tienda_id', tiendaId);
      }

      var response = await query.maybeSingle();

      // Si no encuentra estrategia específica, buscar estrategia general
      if (response == null) {
        query = _client
            .from('estrategias_descuento')
            .select('*')
            .eq('activa', true)
            .isFilter('categoria_id', null);

        if (tiendaId != null) {
          query = query.eq('tienda_id', tiendaId);
        }

        response = await query.maybeSingle();
      }

      if (response != null) {
        print('✅ [SALES_REPO] Estrategia encontrada: ${response['nombre']}');
        return EstrategiaDescuento.fromJson(response);
      }

      print('⚠️ [SALES_REPO] No se encontró estrategia para categoría $categoriaId');
      return null;

    } catch (e) {
      print('❌ [SALES_REPO] Error getEstrategiaParaCategoria: $e');
      throw Exception('Error al obtener estrategia para categoría: $e');
    }
  }

  /// Crea una nueva estrategia de descuento
  Future<EstrategiaDescuento> createEstrategiaDescuento(
      Map<String, dynamic> estrategiaData) async {
    try {
      print('🔄 [SALES_REPO] Creando estrategia de descuento...');
      print('   Datos: $estrategiaData');

      final response = await _client
          .from('estrategias_descuento')
          .insert(estrategiaData)
          .select()
          .single();

      print('✅ [SALES_REPO] Estrategia creada exitosamente');
      return EstrategiaDescuento.fromJson(response);

    } catch (e) {
      print('❌ [SALES_REPO] Error createEstrategiaDescuento: $e');
      throw Exception('Error al crear estrategia de descuento: $e');
    }
  }

  /// Actualiza una estrategia de descuento existente
  Future<EstrategiaDescuento> updateEstrategiaDescuento(
      String estrategiaId, Map<String, dynamic> estrategiaData) async {
    try {
      estrategiaData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('estrategias_descuento')
          .update(estrategiaData)
          .eq('id', estrategiaId)
          .select()
          .single();

      return EstrategiaDescuento.fromJson(response);

    } catch (e) {
      print('❌ [SALES_REPO] Error updateEstrategiaDescuento: $e');
      throw Exception('Error al actualizar estrategia de descuento: $e');
    }
  }

  // ================== PERMISOS DE DESCUENTO ==================

  /// Obtiene los permisos de descuento para un rol específico
  Future<PermisoDescuento?> getPermisoDescuento(String rolUsuario) async {
    try {
      print('🔄 [SALES_REPO] Obteniendo permisos para rol $rolUsuario...');

      final response = await _client
          .from('permisos_descuento')
          .select('*')
          .eq('rol_usuario', rolUsuario)
          .eq('activo', true)
          .maybeSingle();

      if (response != null) {
        print('✅ [SALES_REPO] Permisos encontrados para rol $rolUsuario');
        return PermisoDescuento.fromJson(response);
      }

      print('⚠️ [SALES_REPO] No se encontraron permisos para rol $rolUsuario');
      return null;

    } catch (e) {
      print('❌ [SALES_REPO] Error getPermisoDescuento: $e');
      throw Exception('Error al obtener permisos de descuento: $e');
    }
  }

  /// Obtiene todos los permisos de descuento activos
  Future<List<PermisoDescuento>> getAllPermisosDescuento() async {
    try {
      final response = await _client
          .from('permisos_descuento')
          .select('*')
          .eq('activo', true)
          .order('descuento_maximo_porcentaje');

      return (response as List)
          .map((json) => PermisoDescuento.fromJson(json))
          .toList();

    } catch (e) {
      print('❌ [SALES_REPO] Error getAllPermisosDescuento: $e');
      throw Exception('Error al obtener todos los permisos de descuento: $e');
    }
  }

  // ================== VENTAS ==================

  /// Crea una nueva venta
  Future<Venta> createVenta(Map<String, dynamic> ventaData) async {
    try {
      print('🔄 [SALES_REPO] Creando nueva venta...');
      print('   Datos: $ventaData');

      final response = await _client
          .from('ventas')
          .insert(ventaData)
          .select('''
            *,
            tiendas:tienda_id(id, nombre, direccion)
          ''')
          .single();

      print('✅ [SALES_REPO] Venta creada exitosamente: ${response['numero_venta']}');
      return Venta.fromJson(response);

    } catch (e) {
      print('❌ [SALES_REPO] Error createVenta: $e');
      throw Exception('Error al crear venta: $e');
    }
  }

  /// Obtiene una venta por ID
  Future<Venta?> getVenta(String ventaId) async {
    try {
      final response = await _client
          .from('ventas')
          .select('''
            *,
            tiendas:tienda_id(id, nombre, direccion),
            detalles_venta(
              *,
              articulos(
                *,
                productos_master(nombre, marca_id, categoria_id),
                colores(nombre, codigo_hex)
              )
            )
          ''')
          .eq('id', ventaId)
          .maybeSingle();

      if (response != null) {
        return Venta.fromJson(response);
      }
      return null;

    } catch (e) {
      print('❌ [SALES_REPO] Error getVenta: $e');
      throw Exception('Error al obtener venta: $e');
    }
  }

  /// Obtiene ventas con filtros
  Future<List<Venta>> getVentas({
    String? tiendaId,
    String? vendedorId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    EstadoVenta? estado,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      print('🔄 [SALES_REPO] Obteniendo ventas con filtros...');

      var query = _client
          .from('ventas')
          .select('''
            *,
            tiendas:tienda_id(id, nombre)
          ''');

      if (tiendaId != null) {
        query = query.eq('tienda_id', tiendaId);
      }

      if (vendedorId != null) {
        query = query.eq('vendedor_id', vendedorId);
      }

      if (fechaInicio != null) {
        query = query.gte('fecha_venta', fechaInicio.toIso8601String());
      }

      if (fechaFin != null) {
        query = query.lte('fecha_venta', fechaFin.toIso8601String());
      }

      if (estado != null) {
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
        query = query.eq('estado', estadoStr);
      }

      final response = await query
          .order('fecha_venta', ascending: false)
          .range(offset, offset + limit - 1);

      print('✅ [SALES_REPO] Ventas obtenidas: ${response.length}');

      return (response as List)
          .map((json) => Venta.fromJson(json))
          .toList();

    } catch (e) {
      print('❌ [SALES_REPO] Error getVentas: $e');
      throw Exception('Error al obtener ventas: $e');
    }
  }

  /// Actualiza el estado de una venta
  Future<Venta> updateEstadoVenta(String ventaId, EstadoVenta estado) async {
    try {
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

      final response = await _client
          .from('ventas')
          .update({
            'estado': estadoStr,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ventaId)
          .select()
          .single();

      return Venta.fromJson(response);

    } catch (e) {
      print('❌ [SALES_REPO] Error updateEstadoVenta: $e');
      throw Exception('Error al actualizar estado de venta: $e');
    }
  }

  // ================== DETALLES DE VENTA ==================

  /// Crea detalles de venta
  Future<List<DetalleVenta>> createDetallesVenta(
      List<Map<String, dynamic>> detallesData) async {
    try {
      print('🔄 [SALES_REPO] Creando detalles de venta...');
      print('   Cantidad de detalles: ${detallesData.length}');

      final response = await _client
          .from('detalles_venta')
          .insert(detallesData)
          .select('''
            *,
            articulos(
              *,
              productos_master(nombre),
              colores(nombre, codigo_hex)
            )
          ''');

      print('✅ [SALES_REPO] Detalles de venta creados exitosamente');

      return (response as List)
          .map((json) => DetalleVenta.fromJson(json))
          .toList();

    } catch (e) {
      print('❌ [SALES_REPO] Error createDetallesVenta: $e');
      throw Exception('Error al crear detalles de venta: $e');
    }
  }

  // ================== APROBACIONES DE DESCUENTO ==================

  /// Crea una solicitud de aprobación de descuento
  Future<AprobacionDescuento> createAprobacionDescuento(
      Map<String, dynamic> aprobacionData) async {
    try {
      print('🔄 [SALES_REPO] Creando solicitud de aprobación...');

      final response = await _client
          .from('aprobaciones_descuento')
          .insert(aprobacionData)
          .select()
          .single();

      print('✅ [SALES_REPO] Solicitud de aprobación creada');
      return AprobacionDescuento.fromJson(response);

    } catch (e) {
      print('❌ [SALES_REPO] Error createAprobacionDescuento: $e');
      throw Exception('Error al crear solicitud de aprobación: $e');
    }
  }

  /// Obtiene aprobaciones pendientes para un supervisor
  Future<List<AprobacionDescuento>> getAprobacionesPendientes({
    String? supervisorId,
  }) async {
    try {
      var query = _client
          .from('aprobaciones_descuento')
          .select('*')
          .eq('estado', 'pendiente');

      if (supervisorId != null) {
        query = query.eq('supervisor_id', supervisorId);
      }

      final response = await query.order('fecha_solicitud');

      return (response as List)
          .map((json) => AprobacionDescuento.fromJson(json))
          .toList();

    } catch (e) {
      print('❌ [SALES_REPO] Error getAprobacionesPendientes: $e');
      throw Exception('Error al obtener aprobaciones pendientes: $e');
    }
  }

  /// Responde a una solicitud de aprobación
  Future<AprobacionDescuento> responderAprobacion(
    String aprobacionId,
    EstadoAprobacion estado, {
    String? comentarios,
    String? supervisorId,
  }) async {
    try {
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

      final updateData = {
        'estado': estadoStr,
        'fecha_respuesta': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (comentarios != null) {
        updateData['comentarios_supervisor'] = comentarios;
      }

      if (supervisorId != null) {
        updateData['supervisor_id'] = supervisorId;
      }

      final response = await _client
          .from('aprobaciones_descuento')
          .update(updateData)
          .eq('id', aprobacionId)
          .select()
          .single();

      return AprobacionDescuento.fromJson(response);

    } catch (e) {
      print('❌ [SALES_REPO] Error responderAprobacion: $e');
      throw Exception('Error al responder aprobación: $e');
    }
  }

  // ================== FUNCIONES DE CÁLCULO ==================

  /// Calcula el descuento aplicable para una cantidad y categoría específica
  Future<double> calcularDescuentoPorCantidad(
    String categoriaId,
    int cantidad, {
    String? tiendaId,
  }) async {
    try {
      print('🔄 [SALES_REPO] Calculando descuento para categoría $categoriaId, cantidad $cantidad');

      // Llamar función de BD que calcula el descuento
      final response = await _client.rpc('calcular_descuento_por_cantidad', params: {
        'p_categoria_id': categoriaId,
        'p_cantidad': cantidad,
        'p_tienda_id': tiendaId,
      });

      final descuento = (response ?? 0.0).toDouble();
      print('✅ [SALES_REPO] Descuento calculado: $descuento%');

      return descuento;

    } catch (e) {
      print('❌ [SALES_REPO] Error calcularDescuentoPorCantidad: $e');
      // En caso de error, devolver 0% de descuento
      return 0.0;
    }
  }

  /// Verifica si un usuario puede aplicar un descuento específico
  Future<bool> verificarPermisoDescuento(
    String rolUsuario,
    double descuentoPorcentaje,
  ) async {
    try {
      print('🔄 [SALES_REPO] Verificando permiso de descuento para rol $rolUsuario: $descuentoPorcentaje%');

      final response = await _client.rpc('verificar_permiso_descuento', params: {
        'p_rol_usuario': rolUsuario,
        'p_descuento_porcentaje': descuentoPorcentaje,
      });

      final puedeAplicar = response ?? false;
      print('✅ [SALES_REPO] Permiso verificado: $puedeAplicar');

      return puedeAplicar;

    } catch (e) {
      print('❌ [SALES_REPO] Error verificarPermisoDescuento: $e');
      // En caso de error, denegar el permiso por seguridad
      return false;
    }
  }

  // ================== REPORTES Y ESTADÍSTICAS ==================

  /// Obtiene resumen de ventas para un período
  Future<Map<String, dynamic>> getResumenVentas({
    String? tiendaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      print('🔄 [SALES_REPO] Obteniendo resumen de ventas...');

      var query = _client
          .from('ventas')
          .select('monto_total, estado, fecha_venta');

      if (tiendaId != null) {
        query = query.eq('tienda_id', tiendaId);
      }

      if (fechaInicio != null) {
        query = query.gte('fecha_venta', fechaInicio.toIso8601String());
      }

      if (fechaFin != null) {
        query = query.lte('fecha_venta', fechaFin.toIso8601String());
      }

      final response = await query;

      // Procesar datos para generar resumen
      double totalVentas = 0;
      int ventasCompletadas = 0;
      int ventasCanceladas = 0;
      int totalTransacciones = response.length;

      for (final venta in response) {
        if (venta['estado'] == 'completada') {
          totalVentas += (venta['monto_total'] ?? 0.0).toDouble();
          ventasCompletadas++;
        } else if (venta['estado'] == 'cancelada') {
          ventasCanceladas++;
        }
      }

      final resumen = {
        'total_ventas': totalVentas,
        'total_transacciones': totalTransacciones,
        'ventas_completadas': ventasCompletadas,
        'ventas_canceladas': ventasCanceladas,
        'ticket_promedio': ventasCompletadas > 0 ? totalVentas / ventasCompletadas : 0.0,
      };

      print('✅ [SALES_REPO] Resumen calculado: $resumen');
      return resumen;

    } catch (e) {
      print('❌ [SALES_REPO] Error getResumenVentas: $e');
      throw Exception('Error al obtener resumen de ventas: $e');
    }
  }
}