import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_models.dart';

class ProductsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ================== MARCAS ==================
  Future<List<Marca>> getMarcas() async {
    try {
      final response = await _client
          .from('marcas')
          .select('*')
          .eq('activo', true)
          .order('nombre');

      return (response as List)
          .map((json) => Marca.fromJson(json))
          .toList();
    } catch (e) {
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
      final response = await _client
          .from('categorias')
          .select('*')
          .eq('activo', true)
          .order('nombre');

      return (response as List)
          .map((json) => Categoria.fromJson(json))
          .toList();
    } catch (e) {
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

  // ================== MATERIALES (Usar categorías por ahora) ==================
  Future<List<Material>> getMateriales() async {
    try {
      final response = await _client
          .from('categorias')
          .select('*')
          .eq('activo', true)
          .eq('tipo', 'MATERIAL')
          .order('nombre');

      return (response as List)
          .map((json) => Material.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener materiales: $e');
    }
  }

  Future<Material> createMaterial(Map<String, dynamic> materialData) async {
    try {
      materialData['tipo'] = 'MATERIAL';
      final response = await _client
          .from('categorias')
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
      final response = await _client
          .from('tallas')
          .select('*')
          .eq('activo', true)
          .order('orden_display');

      return (response as List)
          .map((json) => Talla.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tallas: $e');
    }
  }

  Future<Talla> createTalla(Map<String, dynamic> tallaData) async {
    try {
      final response = await _client
          .from('tallas')
          .insert(tallaData)
          .select()
          .single();

      return Talla.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear talla: $e');
    }
  }

  // ================== COLORES ==================
  Future<List<ColorData>> getColores() async {
    try {
      final response = await _client
          .from('colores')
          .select('*')
          .eq('activo', true)
          .order('nombre');

      return (response as List)
          .map((json) => ColorData.fromJson(json))
          .toList();
    } catch (e) {
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
      final response = await _client
          .from('tiendas')
          .select('*')
          .eq('activo', true)
          .order('nombre');

      return (response as List)
          .map((json) => Tienda.fromJson(json))
          .toList();
    } catch (e) {
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
      var query = _client
          .from('productos_master')
          .select('''
            *,
            marcas(id, nombre),
            categorias(id, nombre),
            tallas(id, codigo, nombre)
          ''');

      // Aplicar filtros si se proporcionan
      if (filters != null) {
        if (filters.marcaIds.isNotEmpty) {
          query = query.inFilter('marca_id', filters.marcaIds);
        }
        if (filters.categoriaIds.isNotEmpty) {
          query = query.inFilter('categoria_id', filters.categoriaIds);
        }
        if (filters.tallaIds.isNotEmpty) {
          query = query.inFilter('talla_id', filters.tallaIds);
        }
        if (filters.precioMinimo != null) {
          query = query.gte('precio_sugerido', filters.precioMinimo!);
        }
        if (filters.precioMaximo != null) {
          query = query.lte('precio_sugerido', filters.precioMaximo!);
        }
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          query = query.or('nombre.ilike.%${filters.searchQuery}%,descripcion.ilike.%${filters.searchQuery}%');
        }
        if (filters.soloActivos == true) {
          query = query.eq('activo', true);
        }
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductoMaster.fromJson(json))
          .toList();
    } catch (e) {
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
      final response = await _client
          .from('productos_master')
          .select('''
            *,
            marcas(id, nombre),
            categorias(id, nombre),
            tallas(id, codigo, nombre)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ProductoMaster.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener producto por ID: $e');
    }
  }

  // ================== ARTÍCULOS ==================
  Future<List<Articulo>> getArticulosByProductoId(String productoId) async {
    try {
      final response = await _client
          .from('articulos')
          .select('''
            *,
            colores(id, nombre, hex_color),
            productos_master(id, nombre)
          ''')
          .eq('producto_master_id', productoId)
          .eq('activo', true);

      return (response as List)
          .map((json) => Articulo.fromJson(json))
          .toList();
    } catch (e) {
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
      // Simplificar usando productos directos por ahora
      final productos = await getProductos(filters: filters);
      
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

      final paginationParams = pagination ?? const PaginationParams();
      return PaginatedResult<CatalogoCompleto>(
        data: catalogoItems,
        totalCount: catalogoItems.length,
        currentPage: paginationParams.page,
        pageSize: paginationParams.pageSize,
      );
    } catch (e) {
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
          .update({'activo': false})
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
        .eq('activo', true)
        .map((data) => data.map((json) => ProductoMaster.fromJson(json)).toList());
  }

  Stream<List<Map<String, dynamic>>> subscribeToInventoryChanges(String tiendaId) {
    return _client
        .from('inventario_tienda')
        .stream(primaryKey: ['articulo_id', 'tienda_id'])
        .eq('tienda_id', tiendaId);
  }
}