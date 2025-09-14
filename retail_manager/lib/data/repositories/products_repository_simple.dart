import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_models.dart';

class ProductsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ================== MARCAS ==================
  Future<List<Marca>> getMarcas() async {
    try {
      print('🔄 [REPO] Ejecutando query marcas...');
      print('   Query: SELECT * FROM marcas WHERE activo = true ORDER BY nombre');

      final response = await _client
          .from('marcas')
          .select('*')
          .eq('activo', true) // RLS deshabilitado - campo confirmado
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

  // ================== CATEGORIAS ==================
  Future<List<Categoria>> getCategorias() async {
    try {
      print('🔄 [REPO] Ejecutando query categorias...');
      print('   Query: SELECT * FROM categorias WHERE activa = true ORDER BY nombre');

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

  // ================== MATERIALES ==================
  Future<List<Material>> getMateriales() async {
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
      
      final materiales = (response as List).map((json) => Material.fromJson(json)).toList();
      print('✅ [REPO] Materiales parseados: ${materiales.length}');
      return materiales;
      
    } catch (e, stackTrace) {
      print('❌ [REPO] ERROR getMateriales: $e');
      print('📜 [REPO] Stack trace: $stackTrace');
      print('🔍 [REPO] Tipo error: ${e.runtimeType}');
      throw Exception('Error al obtener materiales: $e');
    }
  }

  Future<Material> createMaterial(Map<String, dynamic> materialData) async {
    try {
      materialData['activo'] = materialData['activa'] ?? materialData['activo'] ?? true;
      final response = await _client
          .from('materiales')
          .insert(materialData)
          .select()
          .single();

      return Material.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear material: $e');
    }
  }

  // ================== TALLAS ==================
  Future<List<Talla>> getTallas() async {
    try {
      print('🔄 [REPO] Ejecutando query tallas...');
      print('   Query: SELECT * FROM tallas WHERE activa = true ORDER BY codigo');

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
        'codigo': tallaData['valor'] ?? tallaData['codigo'],
        // Eliminamos 'nombre' porque NO EXISTE en tabla tallas según esquema BD
        // Usar directamente el tipo recibido (enum tipo_talla: 'RANGO' | 'UNICA')
        'tipo': tallaData['tipo'],
        'activa': tallaData['activa'] ?? tallaData['activo'] ?? true, // BD usa 'activa'
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

  // ================== COLORES ==================
  Future<List<ColorData>> getColores() async {
    try {
      print('🔄 [REPO] Ejecutando query colores...');
      print('   Query: SELECT * FROM colores WHERE activa = true ORDER BY nombre');

      final response = await _client
          .from('colores')
          .select('*')
          .eq('activa', true)
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
          .eq('estado', 'ACTIVO') // Solo productos activos
          .eq('id', id)
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
      print('   Query: SELECT *, colores(id, nombre, hex_color), productos_master(id, nombre) FROM articulos WHERE producto_master_id = $productoId AND estado = ACTIVO');
      
      final response = await _client
          .from('articulos')
          .select('''
            *,
            colores(id, nombre, hex_color),
            productos_master(id, nombre)
          ''')
          .eq('producto_master_id', productoId)
          .eq('estado', 'ACTIVO');

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
      // Simplificar usando productos directos por ahora
      final productos = await getProductos(filters: filters);
      print('✅ [Repository] Productos obtenidos: ${productos.length}');
      
      // Convertir productos a catálogo completo
      final catalogoItems = productos.map((producto) => CatalogoCompleto(
        productoId: producto.id,
        productoNombre: producto.nombre,
        marcaNombre: producto.marca?.nombre ?? 'Sin marca',
        categoriaNombre: producto.categoria?.nombre ?? 'Sin categoría',
        tallaValor: producto.talla?.valor ?? 'Sin talla',
        precioSugerido: producto.precioSugerido,
        totalArticulos: 0, // Simplificado por ahora
        stockTotal: 0,     // Simplificado por ahora
        precioMinimo: producto.precioSugerido,
        precioMaximo: producto.precioSugerido,
        coloresDisponibles: [],
        tiendasConStock: 0,
      )).toList();

      print('✅ [Repository] Catálogo convertido: ${catalogoItems.length} items');

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

  Future<List<Articulo>> createArticulos(String productoId, List<String> colores) async {
    try {
      final articulosData = colores.map((color) => {
        'producto_master_id': productoId,
        'color_id': color,
        'sku_auto': 'SKU-${DateTime.now().millisecondsSinceEpoch}',
        'precio_sugerido': 0.0, // Será actualizado después
        'activo': true,
      }).toList();

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
}