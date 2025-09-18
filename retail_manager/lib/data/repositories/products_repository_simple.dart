import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_models.dart';

class ProductsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ================== MARCAS ==================
  Future<List<Marca>> getMarcas() async {
    try {
      print('🔄 [REPO] Ejecutando query marcas...');
      print('   Query: SELECT * FROM marcas ORDER BY nombre');

      final response = await _client
          .from('marcas')
          .select('*')
          .order('nombre');

      print('✅ [REPO] Respuesta raw marcas: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');

      final marcas = (response as List).map((json) => Marca.fromJson(json)).toList();
      print('✅ [REPO] Marcas parseadas: ${marcas.length}');
      return marcas;

    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getMarcas: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener marcas: $e');
    }
  }

  Future<Marca> createMarca(Map<String, dynamic> marcaData) async {
    try {
      final response = await _client
          .from('marcas')
          .insert(marcaData)
          .select()
          .single();

      return Marca.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear marca: $e');
    }
  }

  Future<Marca> updateMarca(String marcaId, Map<String, dynamic> marcaData) async {
    try {
      marcaData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('marcas')
          .update(marcaData)
          .eq('id', marcaId)
          .select()
          .single();

      return Marca.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar marca: $e');
    }
  }

  Future<void> deleteMarca(String marcaId) async {
    try {
      await _client
          .from('marcas')
          .delete()
          .eq('id', marcaId);
    } catch (e) {
      throw Exception('Error al eliminar marca: $e');
    }
  }

  // ================== CATEGORIAS ==================
  Future<List<Categoria>> getCategorias() async {
    try {
      print('🔄 [REPO] Ejecutando query categorias...');
      print('   Query: SELECT * FROM categorias WHERE activo = true ORDER BY nombre');

      final response = await _client
          .from('categorias')
          .select('*')
          .eq('activo', true) // RLS deshabilitado - campo confirmado
          .order('nombre');
      
      print('✅ [REPO] Respuesta raw categorias: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');
      
      final categorias = (response as List).map((json) => Categoria.fromJson(json)).toList();
      print('✅ [REPO] Categorias parseadas: ${categorias.length}');
      return categorias;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getCategorias: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<Categoria> createCategoria(Map<String, dynamic> categoriaData) async {
    try {
      final response = await _client
          .from('categorias')
          .insert(categoriaData)
          .select()
          .single();

      return Categoria.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear categoría: $e');
    }
  }

  Future<Categoria> updateCategoria(String categoriaId, Map<String, dynamic> categoriaData) async {
    try {
      categoriaData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('categorias')
          .update(categoriaData)
          .eq('id', categoriaId)
          .select()
          .single();

      return Categoria.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  Future<void> deleteCategoria(String categoriaId) async {
    try {
      await _client
          .from('categorias')
          .delete()
          .eq('id', categoriaId);
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }

  // ================== MATERIALES ==================
  Future<List<MaterialModel>> getMateriales() async {
    try {
      print('🔄 [REPO] Ejecutando query materiales...');
      print('   Query: SELECT * FROM materiales WHERE activo = true ORDER BY nombre');
      
      final response = await _client
          .from('materiales')
          .select('*')
          .eq('activo', true)
          .order('nombre');
      
      print('✅ [REPO] Respuesta raw materiales: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');
      
      final materiales = (response as List).map((json) => MaterialModel.fromJson(json)).toList();
      print('✅ [REPO] Materiales parseados: ${materiales.length}');
      return materiales;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getMateriales: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener materiales: $e');
    }
  }

  Future<MaterialModel> createMaterial(Map<String, dynamic> materialData) async {
    try {
      materialData['activo'] = materialData['activo'] ?? true;
      final response = await _client
          .from('materiales')
          .insert(materialData)
          .select()
          .single();

      return MaterialModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear material: $e');
    }
  }

  Future<MaterialModel> updateMaterial(String materialId, Map<String, dynamic> materialData) async {
    try {
      materialData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('materiales')
          .update(materialData)
          .eq('id', materialId)
          .select()
          .single();

      return MaterialModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar material: $e');
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      await _client
          .from('materiales')
          .delete()
          .eq('id', materialId);
    } catch (e) {
      throw Exception('Error al eliminar material: $e');
    }
  }

  // ================== TALLAS ==================
  Future<List<Talla>> getTallas() async {
    try {
      print('🔄 [REPO] Ejecutando query tallas...');
      print('   Query: SELECT * FROM tallas WHERE activo = true ORDER BY codigo');

      final response = await _client
          .from('tallas')
          .select('*')
          .eq('activo', true) // RLS deshabilitado - campo confirmado
          .order('codigo');
      
      print('✅ [REPO] Respuesta raw tallas: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');
      
      final tallas = (response as List).map((json) => Talla.fromJson(json)).toList();
      print('✅ [REPO] Tallas parseadas: ${tallas.length}');
      return tallas;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getTallas: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener tallas: $e');
    }
  }

  Future<Talla> createTalla(Map<String, dynamic> tallaData) async {
    try {
      // Corregir mapping de campos para que coincida con el esquema de BD actual
      final correctedData = <String, dynamic>{
        'codigo': tallaData['codigo'] ?? tallaData['valor'],
        'nombre': tallaData['nombre'] ?? tallaData['valor'], // CORREGIDO: tabla SÍ tiene campo nombre
        'valor': tallaData['valor'],
        'tipo': tallaData['tipo'],
        'orden_display': tallaData['orden_display'] ?? 0,
        'activo': tallaData['activo'] ?? true, // BD usa 'activo'
      };

      print('🔄 [Repository] Creando talla con datos: $correctedData');

      final response = await _client
          .from('tallas')
          .insert(correctedData)
          .select()
          .single();

      print('✅ [Repository] Talla creada exitosamente: $response');
      return Talla.fromJson(response);
    } catch (e) {
      print('❌ [Repository] Error al crear talla: $e');
      throw Exception('Error al crear talla: $e');
    }
  }

  Future<Talla> updateTalla(String tallaId, Map<String, dynamic> tallaData) async {
    try {
      tallaData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('tallas')
          .update(tallaData)
          .eq('id', tallaId)
          .select()
          .single();

      return Talla.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar talla: $e');
    }
  }

  Future<void> deleteTalla(String tallaId) async {
    try {
      await _client
          .from('tallas')
          .delete()
          .eq('id', tallaId);
    } catch (e) {
      throw Exception('Error al eliminar talla: $e');
    }
  }

  // ================== COLORES ==================
  Future<List<ColorData>> getColores() async {
    try {
      print('🔄 [REPO] Ejecutando query colores...');
      print('   Query: SELECT * FROM colores ORDER BY nombre');

      final response = await _client
          .from('colores')
          .select('*')
          .order('nombre');

      print('✅ [REPO] Respuesta raw colores: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');

      final colores = (response as List).map((json) => ColorData.fromJson(json)).toList();
      print('✅ [REPO] Colores parseados: ${colores.length}');
      return colores;

    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getColores: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener colores: $e');
    }
  }

  Future<ColorData> createColor(Map<String, dynamic> colorData) async {
    try {
      final response = await _client
          .from('colores')
          .insert(colorData)
          .select()
          .single();

      return ColorData.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear color: $e');
    }
  }

  Future<ColorData> updateColor(String colorId, Map<String, dynamic> colorData) async {
    try {
      // Agregar timestamp de actualización
      colorData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('colores')
          .update(colorData)
          .eq('id', colorId)
          .select()
          .single();

      return ColorData.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar color: $e');
    }
  }

  Future<void> deleteColor(String colorId) async {
    try {
      await _client
          .from('colores')
          .delete()
          .eq('id', colorId);
    } catch (e) {
      throw Exception('Error al eliminar color: $e');
    }
  }

  // ================== TIENDAS ==================
  Future<List<Tienda>> getTiendas() async {
    try {
      print('🔄 [REPO] Ejecutando query tiendas...');
      print('   Query: SELECT * FROM tiendas WHERE activa = true ORDER BY nombre');

      final response = await _client
          .from('tiendas')
          .select('*')
          .eq('activa', true) // CORREGIDO: BD real usa 'activa'
          .order('nombre');
      
      print('✅ [REPO] Respuesta raw tiendas: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');
      
      final tiendas = (response as List).map((json) => Tienda.fromJson(json)).toList();
      print('✅ [REPO] Tiendas parseadas: ${tiendas.length}');
      return tiendas;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getTiendas: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener tiendas: $e');
    }
  }

  Future<Tienda> createTienda(Map<String, dynamic> tiendaData) async {
    try {
      final response = await _client
          .from('tiendas')
          .insert(tiendaData)
          .select()
          .single();

      return Tienda.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear tienda: $e');
    }
  }

  // ================== PRODUCTOS MASTER ==================
  Future<List<ProductoMaster>> getProductos({ProductFilters? filters}) async {
    try {
      print('🔄 [REPO] Ejecutando query productos_master con joins...');
      print('   Base Query: SELECT *, marcas(id, nombre), categorias(id, nombre), tallas(id, codigo) FROM productos_master WHERE estado = ACTIVO');
      
      var query = _client
          .from('productos_master')
          .select('*, marcas(id, nombre), categorias(id, nombre), tallas(id, codigo)')
          .eq('estado', 'ACTIVO'); // Solo productos activos

      // Aplicar filtros si se proporcionan
      if (filters != null) {
        print('🔄 [REPO] Aplicando filtros: $filters');
        if (filters.marcaIds.isNotEmpty) {
          query = query.inFilter('marca_id', filters.marcaIds);
          print('   Filtro marca_ids: ${filters.marcaIds}');
        }
        if (filters.categoriaIds.isNotEmpty) {
          query = query.inFilter('categoria_id', filters.categoriaIds);
          print('   Filtro categoria_ids: ${filters.categoriaIds}');
        }
        if (filters.tallaIds.isNotEmpty) {
          query = query.inFilter('talla_id', filters.tallaIds);
          print('   Filtro talla_ids: ${filters.tallaIds}');
        }
        if (filters.precioMinimo != null) {
          query = query.gte('precio_sugerido', filters.precioMinimo!);
          print('   Filtro precio_minimo: ${filters.precioMinimo}');
        }
        if (filters.precioMaximo != null) {
          query = query.lte('precio_sugerido', filters.precioMaximo!);
          print('   Filtro precio_maximo: ${filters.precioMaximo}');
        }
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          query = query.or('nombre.ilike.%${filters.searchQuery}%,descripcion.ilike.%${filters.searchQuery}%');
          print('   Filtro busqueda: "${filters.searchQuery}"');
        }
        if (filters.soloActivos == true) {
          query = query.eq('estado', 'ACTIVO');
          print('   Filtro solo_activos: true');
        }
      } else {
        print('🔄 [REPO] Sin filtros aplicados');
      }

      final response = await query.order('created_at', ascending: false);
      
      print('✅ [REPO] Respuesta raw productos_master: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');
      
      final productos = (response as List).map((json) => ProductoMaster.fromJson(json)).toList();
      print('✅ [REPO] Productos parseados: ${productos.length}');
      return productos;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getProductos: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener productos: $e');
    }
  }

  Future<ProductoMaster> createProductoMaster(Map<String, dynamic> productoData) async {
    try {
      final response = await _client
          .from('productos_master')
          .insert(productoData)
          .select()
          .single();

      return ProductoMaster.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  Future<ProductoMaster?> getProductoMasterById(String id) async {
    try {
      print('🔄 [REPO] Ejecutando query producto por ID: $id');
      print('   Query: SELECT *, marcas(id, nombre), categorias(id, nombre), tallas(id, codigo) FROM productos_master WHERE id = $id');
      
      final response = await _client
          .from('productos_master')
          .select('*, marcas(id, nombre), categorias(id, nombre), tallas(id, codigo)')
          .eq('id', id) // CORREGIDO: No filtrar por estado en edición
          .maybeSingle();

      print('✅ [REPO] Respuesta raw producto por ID: $response');
      print('   Tipo: ${response.runtimeType}');
      
      if (response == null) {
        print('⚠️ [REPO] No se encontró producto con ID: $id');
        return null;
      }
      
      final producto = ProductoMaster.fromJson(response);
      print('✅ [REPO] Producto parseado: ${producto.nombre}');
      return producto;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getProductoMasterById($id): $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener producto por ID: $e');
    }
  }

  // ================== ARTÍCULOS ==================
  Future<List<Articulo>> getArticulosByProductoId(String productoId) async {
    try {
      print('🔄 [REPO] Ejecutando query artículos por producto ID: $productoId');
      print('   Query: SELECT *, colores(id, nombre, hex_color), productos_master(id, nombre) FROM articulos WHERE producto_master_id = $productoId AND activo = true');

      final response = await _client
          .from('articulos')
          .select('''
            *,
            colores(id, nombre, hex_color),
            productos_master(id, nombre)
          ''')
          .eq('producto_master_id', productoId)
          .eq('activo', true);

      print('✅ [REPO] Respuesta raw artículos: $response');
      print('   Tipo: ${response.runtimeType}, Longitud: ${response.length}');
      
      final articulos = (response as List).map((json) => Articulo.fromJson(json)).toList();
      print('✅ [REPO] Artículos parseados: ${articulos.length}');
      return articulos;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getArticulosByProductoId($productoId): $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener artículos: $e');
    }
  }

  // ================== INVENTARIO ==================
  Future<void> updateInventarioTienda(String articuloId, String tiendaId, Map<String, dynamic> inventarioData) async {
    try {
      await _client
          .from('inventario_tienda')
          .upsert({
            'articulo_id': articuloId,
            'tienda_id': tiendaId,
            ...inventarioData,
          });
    } catch (e) {
      throw Exception('Error al actualizar inventario: $e');
    }
  }

  // ================== CATÁLOGO COMPLETO ==================
  Future<PaginatedResult<CatalogoCompleto>> getCatalogoCompleto({
    ProductFilters? filters,
    PaginationParams? pagination,
  }) async {
    try {
      print('🔄 [Repository] Obteniendo catálogo completo...');

      // Obtener productos básicos
      final productos = await getProductos(filters: filters);
      print('✅ [Repository] Productos obtenidos: ${productos.length}');

      // Convertir productos a catálogo completo con datos agregados reales
      final catalogoItems = <CatalogoCompleto>[];

      for (final producto in productos) {
        // Obtener artículos del producto
        final articulos = await getArticulosByProductoId(producto.id);

        // Calcular datos agregados
        int stockTotal = 0;
        double precioMinimo = producto.precioSugerido;
        double precioMaximo = producto.precioSugerido;
        Set<String> coloresDisponibles = {};
        Set<String> tiendasConStock = {};

        for (final articulo in articulos) {
          // Obtener inventario del artículo
          final inventarios = await _getInventarioByArticuloId(articulo.id);

          for (final inventario in inventarios) {
            final stockActual = (inventario['stock_actual'] ?? 0) as int;
            stockTotal += stockActual;

            if (stockActual > 0) {
              tiendasConStock.add(inventario['tienda_id']);
            }

            final precioVenta = (inventario['precio_venta'] ?? 0.0).toDouble();
            if (precioVenta > 0) {
              if (precioVenta < precioMinimo) precioMinimo = precioVenta;
              if (precioVenta > precioMaximo) precioMaximo = precioVenta;
            }
          }

          // Obtener nombre del color
          try {
            if (articulo.colorId?.isNotEmpty == true) {
              final colorInfo = await _client
                  .from('colores')
                  .select('nombre')
                  .eq('id', articulo.colorId!)
                  .single();
              coloresDisponibles.add(colorInfo['nombre'] ?? 'Sin color');
            } else {
              coloresDisponibles.add('Sin color');
            }
          } catch (e) {
            coloresDisponibles.add('Sin color');
          }
        }

        catalogoItems.add(CatalogoCompleto(
          productoId: producto.id,
          productoNombre: producto.nombre,
          marcaNombre: producto.marca?.nombre ?? 'Sin marca',
          categoriaNombre: producto.categoria?.nombre ?? 'Sin categoría',
          tallaValor: producto.talla?.valor ?? 'Sin talla',
          precioSugerido: producto.precioSugerido,
          totalArticulos: articulos.length,
          stockTotal: stockTotal,
          precioMinimo: precioMinimo,
          precioMaximo: precioMaximo,
          coloresDisponibles: coloresDisponibles.toList(),
          tiendasConStock: tiendasConStock.length,
        ));
      }

      print('✅ [Repository] Catálogo convertido: ${catalogoItems.length} items con datos agregados');

      final paginationParams = pagination ?? const PaginationParams();
      return PaginatedResult<CatalogoCompleto>(
        data: catalogoItems,
        totalCount: catalogoItems.length,
        currentPage: paginationParams.page,
        pageSize: paginationParams.pageSize,
      );
    } catch (e) {
      print('❌ [Repository] Error al obtener catálogo: $e');
      throw Exception('Error al obtener catálogo: $e');
    }
  }

  /// Método auxiliar para obtener inventario por artículo ID
  Future<List<Map<String, dynamic>>> _getInventarioByArticuloId(String articuloId) async {
    try {
      final response = await _client
          .from('inventario_tienda')
          .select('stock_actual, precio_venta, tienda_id')
          .eq('articulo_id', articuloId)
          .eq('activo', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('⚠️ [Repository] Error al obtener inventario para artículo $articuloId: $e');
      return [];
    }
  }

  Future<List<Articulo>> createArticulos(String productoId, List<String> colores) async {
    try {
      final articulosData = <Map<String, dynamic>>[];

      for (final colorId in colores) {
        // Obtener información del color para generar SKU único
        final colorInfo = await _client
            .from('colores')
            .select('codigo_abrev')
            .eq('id', colorId)
            .single();

        final codigoColor = colorInfo['codigo_abrev'] ?? colorId.substring(0, 3).toUpperCase();

        // SKU único usando: timestamp + código del color
        final uniqueSku = 'SKU-${DateTime.now().millisecondsSinceEpoch}-$codigoColor';

        articulosData.add({
          'producto_master_id': productoId,
          'color_id': colorId,
          'sku_auto': uniqueSku,
          'precio_sugerido': 0.0, // Será actualizado después
          'activo': true,
        });
      }

      final response = await _client
          .from('articulos')
          .insert(articulosData)
          .select();

      return (response as List)
          .map((json) => Articulo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al crear artículos: $e');
    }
  }

  Future<ProductoMaster> updateProductoMaster(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('productos_master')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return ProductoMaster.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProductoMaster(String id) async {
    try {
      await _client
          .from('productos_master')
          .update({'estado': 'INACTIVO'})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // ================== SUBSCRIPCIONES REALTIME ==================
  Stream<List<ProductoMaster>> subscribeToProductsChanges() {
    return _client
        .from('productos_master')
        .stream(primaryKey: ['id'])
        .eq('estado', 'ACTIVO')
        .map((data) => data.map((json) => ProductoMaster.fromJson(json)).toList());
  }

  Stream<List<Map<String, dynamic>>> subscribeToInventoryChanges(String tiendaId) {
    return _client
        .from('inventario_tienda')
        .stream(primaryKey: ['articulo_id', 'tienda_id'])
        .eq('tienda_id', tiendaId);
  }

  // ================== GESTIÓN DE PRECIOS POR ARTÍCULO ==================

  /// Actualiza precios de costo y venta para un artículo específico en una tienda
  Future<bool> updatePreciosArticulo({
    required String articuloId,
    required String tiendaId,
    required double precioVenta,
    required double precioCosto,
  }) async {
    try {
      print('🔄 [REPO] Actualizando precios - Artículo: $articuloId, Tienda: $tiendaId');
      print('🔄 [REPO] Precio Venta: S/ $precioVenta, Precio Costo: S/ $precioCosto');

      // Validaciones locales
      if (precioVenta < 0) {
        throw Exception('El precio de venta no puede ser negativo');
      }
      if (precioCosto < 0) {
        throw Exception('El precio de costo no puede ser negativo');
      }
      if (precioVenta < precioCosto) {
        throw Exception('El precio de venta debe ser mayor o igual al precio de costo');
      }

      // Verificar si existe el registro de inventario
      final existingInventory = await _client
          .from('inventario_tienda')
          .select('id')
          .eq('articulo_id', articuloId)
          .eq('tienda_id', tiendaId)
          .maybeSingle();

      if (existingInventory == null) {
        // Crear nuevo registro de inventario con precios
        print('🔄 [REPO] Creando nuevo registro de inventario...');
        await _client.from('inventario_tienda').insert({
          'articulo_id': articuloId,
          'tienda_id': tiendaId,
          'stock_actual': 0,
          'precio_venta': precioVenta,
          'precio_costo': precioCosto,
          'activo': true,
        });
        print('✅ [REPO] Nuevo registro de inventario creado con precios');
      } else {
        // Actualizar precios en registro existente
        print('🔄 [REPO] Actualizando precios en registro existente...');
        await _client
            .from('inventario_tienda')
            .update({
              'precio_venta': precioVenta,
              'precio_costo': precioCosto,
            })
            .eq('articulo_id', articuloId)
            .eq('tienda_id', tiendaId);
        print('✅ [REPO] Precios actualizados exitosamente');
      }

      return true;
    } catch (e) {
      print('❌ [REPO] Error al actualizar precios: $e');
      throw Exception('Error al actualizar precios del artículo: $e');
    }
  }

  /// Obtiene los precios actuales de un artículo en una tienda específica
  Future<Map<String, double>?> getPreciosArticulo({
    required String articuloId,
    required String tiendaId,
  }) async {
    try {
      final response = await _client
          .from('inventario_tienda')
          .select('precio_venta, precio_costo')
          .eq('articulo_id', articuloId)
          .eq('tienda_id', tiendaId)
          .maybeSingle();

      if (response != null) {
        return {
          'precio_venta': response['precio_venta']?.toDouble() ?? 0.0,
          'precio_costo': response['precio_costo']?.toDouble() ?? 0.0,
        };
      }
      return null;
    } catch (e) {
      print('❌ [REPO] Error al obtener precios: $e');
      return null;
    }
  }
}