# Módulo de Productos - Sistema Retail Manager

## Descripción General
Sistema completo de gestión de catálogo de productos para retail de ropa y medias con soporte multi-variante (talla/color), SKUs únicos y gestión de inventario integrada.

## Arquitectura de Datos

### Modelo Jerárquico de Productos
```
Producto Master (producto_master)
├── Variante 1 (articulos) - Talla S, Color Rojo
├── Variante 2 (articulos) - Talla M, Color Rojo
├── Variante 3 (articulos) - Talla S, Color Azul
└── Variante N (articulos) - Cada combinación única
```

## Esquemas de Base de Datos

### Tablas Principales

#### 1. producto_master
```sql
CREATE TABLE public.producto_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,           -- SKU base del producto
    nombre TEXT NOT NULL,
    descripcion TEXT,
    marca_id UUID REFERENCES public.marcas(id),
    categoria_id UUID REFERENCES public.categorias(id),
    material_id UUID REFERENCES public.materiales(id),
    precio_base DECIMAL(10,2) NOT NULL,
    costo_base DECIMAL(10,2),
    imagen_url TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 2. articulos (Variantes de Producto)
```sql
CREATE TABLE public.articulos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_master_id UUID REFERENCES public.producto_master(id) ON DELETE CASCADE,
    sku TEXT UNIQUE NOT NULL,              -- SKU único por variante
    talla_id UUID REFERENCES public.tallas(id),
    color_id UUID REFERENCES public.colores(id),
    precio_venta DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2),
    peso DECIMAL(5,2),
    codigo_barras TEXT UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constrains para evitar duplicados
    UNIQUE(producto_master_id, talla_id, color_id)
);
```

#### 3. Tablas de Apoyo
```sql
-- Marcas
CREATE TABLE public.marcas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE
);

-- Categorías
CREATE TABLE public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    descripcion TEXT,
    categoria_padre_id UUID REFERENCES public.categorias(id),
    activa BOOLEAN DEFAULT TRUE
);

-- Tallas
CREATE TABLE public.tallas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,           -- S, M, L, XL, 38, 40, etc.
    valor TEXT NOT NULL,                   -- Valor mostrado al usuario
    tipo_talla tipo_talla_enum DEFAULT 'INDIVIDUAL',
    orden INTEGER DEFAULT 0,               -- Para ordenamiento
    activa BOOLEAN DEFAULT TRUE
);

-- Colores
CREATE TABLE public.colores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    hex_color TEXT,                        -- #FF0000 para preview
    activa BOOLEAN DEFAULT TRUE
);

-- Materiales
CREATE TABLE public.materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);
```

## Modelos Dart (Flutter)

### ProductoMaster
```dart
class ProductoMaster {
  final String id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String marcaId;
  final String categoriaId;
  final String? materialId;
  final double precioBase;
  final double? costoBase;
  final String? imagenUrl;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relaciones cargadas
  final Marca? marca;
  final Categoria? categoria;
  final Material? material;
  final List<Articulo> variantes;

  const ProductoMaster({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.marcaId,
    required this.categoriaId,
    this.materialId,
    required this.precioBase,
    this.costoBase,
    this.imagenUrl,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.marca,
    this.categoria,
    this.material,
    this.variantes = const [],
  });

  factory ProductoMaster.fromJson(Map<String, dynamic> json) {
    return ProductoMaster(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      marcaId: json['marca_id'],
      categoriaId: json['categoria_id'],
      materialId: json['material_id'],
      precioBase: double.parse(json['precio_base'].toString()),
      costoBase: json['costo_base'] != null
          ? double.parse(json['costo_base'].toString())
          : null,
      imagenUrl: json['imagen_url'],
      activo: json['activo'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      // Relaciones se cargan por separado
      marca: json['marca'] != null ? Marca.fromJson(json['marca']) : null,
      categoria: json['categoria'] != null ? Categoria.fromJson(json['categoria']) : null,
      material: json['material'] != null ? Material.fromJson(json['material']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigo': codigo,
    'nombre': nombre,
    'descripcion': descripcion,
    'marca_id': marcaId,
    'categoria_id': categoriaId,
    'material_id': materialId,
    'precio_base': precioBase,
    'costo_base': costoBase,
    'imagen_url': imagenUrl,
    'activo': activo,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
```

### Articulo (Variante)
```dart
class Articulo {
  final String id;
  final String productoMasterId;
  final String sku;
  final String tallaId;
  final String colorId;
  final double precioVenta;
  final double? costo;
  final double? peso;
  final String? codigoBarras;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relaciones
  final ProductoMaster? productoMaster;
  final Talla? talla;
  final Color? color;

  // Stock (calculado desde inventario)
  final int? stockActual;
  final int? stockMinimo;
  final int? stockReservado;

  const Articulo({
    required this.id,
    required this.productoMasterId,
    required this.sku,
    required this.tallaId,
    required this.colorId,
    required this.precioVenta,
    this.costo,
    this.peso,
    this.codigoBarras,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.productoMaster,
    this.talla,
    this.color,
    this.stockActual,
    this.stockMinimo,
    this.stockReservado,
  });

  // Propiedades calculadas
  bool get tieneStock => stockActual != null && stockActual! > 0;
  bool get stockBajo => stockMinimo != null &&
      stockActual != null &&
      stockActual! <= stockMinimo!;

  double get margenBruto => costo != null
      ? ((precioVenta - costo!) / precioVenta) * 100
      : 0.0;

  String get descripcionCompleta =>
      '${productoMaster?.nombre ?? ''} - ${talla?.valor ?? ''} - ${color?.nombre ?? ''}';
}
```

## Repositorios (Supabase)

### ProductsRepository
```dart
class ProductsRepository {
  final SupabaseClient _client;

  ProductsRepository(this._client);

  // Obtener productos con filtros y paginación
  Future<List<ProductoMaster>> getProductos({
    int? limit = 20,
    int? offset = 0,
    String? searchQuery,
    String? marcaId,
    String? categoriaId,
    bool? soloActivos = true,
  }) async {
    var query = _client
        .from('producto_master')
        .select('''
          *,
          marca:marcas(*),
          categoria:categorias(*),
          material:materiales(*)
        ''');

    if (soloActivos == true) {
      query = query.eq('activo', true);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('nombre.ilike.%$searchQuery%,codigo.ilike.%$searchQuery%');
    }

    if (marcaId != null) {
      query = query.eq('marca_id', marcaId);
    }

    if (categoriaId != null) {
      query = query.eq('categoria_id', categoriaId);
    }

    query = query
        .order('nombre')
        .range(offset!, offset + limit! - 1);

    final response = await query;

    return response.map((json) => ProductoMaster.fromJson(json)).toList();
  }

  // Obtener variantes de un producto
  Future<List<Articulo>> getVariantesProducto(String productoMasterId) async {
    final response = await _client
        .from('articulos')
        .select('''
          *,
          talla:tallas(*),
          color:colores(*),
          inventario:inventario(stock_actual, stock_minimo, stock_reservado)
        ''')
        .eq('producto_master_id', productoMasterId)
        .eq('activo', true)
        .order('talla_id, color_id');

    return response.map((json) {
      // Agregar stock desde inventario
      final inventario = json['inventario'] as List?;
      int? stockActual;
      int? stockMinimo;
      int? stockReservado;

      if (inventario != null && inventario.isNotEmpty) {
        final inv = inventario.first;
        stockActual = inv['stock_actual'];
        stockMinimo = inv['stock_minimo'];
        stockReservado = inv['stock_reservado'];
      }

      return Articulo.fromJson({
        ...json,
        'stock_actual': stockActual,
        'stock_minimo': stockMinimo,
        'stock_reservado': stockReservado,
      });
    }).toList();
  }

  // Crear producto master
  Future<ProductoMaster> createProductoMaster(CreateProductoRequest request) async {
    final response = await _client
        .from('producto_master')
        .insert({
          'codigo': request.codigo,
          'nombre': request.nombre,
          'descripcion': request.descripcion,
          'marca_id': request.marcaId,
          'categoria_id': request.categoriaId,
          'material_id': request.materialId,
          'precio_base': request.precioBase,
          'costo_base': request.costoBase,
          'imagen_url': request.imagenUrl,
        })
        .select()
        .single();

    return ProductoMaster.fromJson(response);
  }

  // Crear variante (artículo)
  Future<Articulo> createArticulo(CreateArticuloRequest request) async {
    // Generar SKU único si no se proporciona
    final sku = request.sku ?? await _generateSku(
      request.productoMasterId,
      request.tallaId,
      request.colorId,
    );

    final response = await _client
        .from('articulos')
        .insert({
          'producto_master_id': request.productoMasterId,
          'sku': sku,
          'talla_id': request.tallaId,
          'color_id': request.colorId,
          'precio_venta': request.precioVenta,
          'costo': request.costo,
          'peso': request.peso,
          'codigo_barras': request.codigoBarras,
        })
        .select()
        .single();

    return Articulo.fromJson(response);
  }

  // Generar SKU automático
  Future<String> _generateSku(
    String productoMasterId,
    String tallaId,
    String colorId,
  ) async {
    final producto = await _client
        .from('producto_master')
        .select('codigo')
        .eq('id', productoMasterId)
        .single();

    final talla = await _client
        .from('tallas')
        .select('codigo')
        .eq('id', tallaId)
        .single();

    final color = await _client
        .from('colores')
        .select('codigo')
        .eq('id', colorId)
        .single();

    return '${producto['codigo']}-${talla['codigo']}-${color['codigo']}';
  }
}
```

## Componentes Flutter

### ProductCard
```dart
class ProductCard extends StatelessWidget {
  final ProductoMaster producto;
  final VoidCallback? onTap;
  final bool showStock;

  const ProductCard({
    super.key,
    required this.producto,
    this.onTap,
    this.showStock = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: producto.imagenUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          producto.imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 48,
                          ),
                        ),
                      )
                    : const Icon(Icons.inventory_2, size: 48),
              ),
              const SizedBox(height: 8),

              // Información del producto
              Text(
                producto.nombre,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                producto.marca?.nombre ?? 'Sin marca',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'S/ ${producto.precioBase.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              if (showStock) ...[
                const SizedBox(height: 4),
                FutureBuilder<int>(
                  future: _getTotalStock(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();

                    final stock = snapshot.data!;
                    return Text(
                      'Stock: $stock unidades',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: stock > 0 ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getTotalStock() async {
    // Calcular stock total de todas las variantes
    // Implementar usando ProductsRepository
    return 0;
  }
}
```

### ProductVariantGrid
```dart
class ProductVariantGrid extends StatelessWidget {
  final List<Articulo> variantes;
  final Function(Articulo) onVariantSelected;

  const ProductVariantGrid({
    super.key,
    required this.variantes,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Agrupar variantes por talla y color para matriz
    final tallaGroups = <String, List<Articulo>>{};

    for (final variante in variantes) {
      final tallaKey = variante.talla?.valor ?? 'Sin talla';
      tallaGroups.putIfAbsent(tallaKey, () => []).add(variante);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Talla')),
          ...variantes
              .map((v) => v.color?.nombre ?? 'Sin color')
              .toSet()
              .map((color) => DataColumn(
                    label: Text(color),
                  )),
        ],
        rows: tallaGroups.entries.map((entry) {
          final talla = entry.key;
          final variantesTalla = entry.value;

          return DataRow(
            cells: [
              DataCell(Text(talla)),
              ...variantes
                  .map((v) => v.color?.nombre ?? 'Sin color')
                  .toSet()
                  .map((color) {
                final variante = variantesTalla.firstWhereOrNull(
                  (v) => v.color?.nombre == color,
                );

                return DataCell(
                  variante != null
                      ? InkWell(
                          onTap: () => onVariantSelected(variante),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: variante.tieneStock
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'S/ ${variante.precioVenta.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Stock: ${variante.stockActual ?? 0}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: variante.tieneStock
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}
```

## Estados BLoC

### ProductsBloc
```dart
// Estados
abstract class ProductsState {}

class ProductsInitial extends ProductsState {}
class ProductsLoading extends ProductsState {}
class ProductsLoaded extends ProductsState {
  final List<ProductoMaster> productos;
  final bool hasReachedMax;
  final String? searchQuery;
  final Map<String, dynamic> filtros;

  ProductsLoaded({
    required this.productos,
    this.hasReachedMax = false,
    this.searchQuery,
    this.filtros = const {},
  });
}
class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}

// Eventos
abstract class ProductsEvent {}

class LoadProducts extends ProductsEvent {
  final bool refresh;
  LoadProducts({this.refresh = false});
}

class SearchProducts extends ProductsEvent {
  final String query;
  SearchProducts(this.query);
}

class FilterProducts extends ProductsEvent {
  final Map<String, dynamic> filtros;
  FilterProducts(this.filtros);
}

class LoadMoreProducts extends ProductsEvent {}

// BLoC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository _repository;
  final int _pageSize = 20;

  ProductsBloc(this._repository) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProducts>(_onFilterProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      if (event.refresh || state is ProductsInitial) {
        emit(ProductsLoading());
      }

      final productos = await _repository.getProductos(
        limit: _pageSize,
        offset: 0,
      );

      emit(ProductsLoaded(
        productos: productos,
        hasReachedMax: productos.length < _pageSize,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(ProductsLoading());

      final productos = await _repository.getProductos(
        limit: _pageSize,
        offset: 0,
        searchQuery: event.query,
      );

      emit(ProductsLoaded(
        productos: productos,
        hasReachedMax: productos.length < _pageSize,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
```

## Validaciones y Reglas de Negocio

### Validaciones Frontend
```dart
class ProductValidators {
  static String? codigo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Código es requerido';
    }
    if (value.length < 3) {
      return 'Código debe tener al menos 3 caracteres';
    }
    if (!RegExp(r'^[A-Z0-9\-_]+$').hasMatch(value)) {
      return 'Código solo puede contener letras mayúsculas, números, guiones y guiones bajos';
    }
    return null;
  }

  static String? nombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre es requerido';
    }
    if (value.length < 2) {
      return 'Nombre debe tener al menos 2 caracteres';
    }
    if (value.length > 200) {
      return 'Nombre no puede exceder 200 caracteres';
    }
    return null;
  }

  static String? precio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Precio es requerido';
    }
    final precio = double.tryParse(value);
    if (precio == null || precio <= 0) {
      return 'Precio debe ser mayor a 0';
    }
    if (precio > 99999.99) {
      return 'Precio no puede exceder S/ 99,999.99';
    }
    return null;
  }

  static String? sku(String? value) {
    if (value == null || value.isEmpty) {
      return 'SKU es requerido';
    }
    if (value.length < 5) {
      return 'SKU debe tener al menos 5 caracteres';
    }
    if (!RegExp(r'^[A-Z0-9\-]+$').hasMatch(value)) {
      return 'SKU solo puede contener letras mayúsculas, números y guiones';
    }
    return null;
  }
}
```

### Triggers de Base de Datos
```sql
-- Auto-generar código si no se proporciona
CREATE OR REPLACE FUNCTION auto_generate_codigo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.codigo IS NULL OR NEW.codigo = '' THEN
        NEW.codigo := 'PROD-' || EXTRACT(EPOCH FROM NOW())::TEXT;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_codigo
    BEFORE INSERT ON public.producto_master
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_codigo();

-- Validar SKU único en artículos
CREATE OR REPLACE FUNCTION validar_sku_unico()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM public.articulos
        WHERE sku = NEW.sku AND id != NEW.id
    ) THEN
        RAISE EXCEPTION 'SKU % ya existe', NEW.sku;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_sku
    BEFORE INSERT OR UPDATE ON public.articulos
    FOR EACH ROW
    EXECUTE FUNCTION validar_sku_unico();
```

## Manejo de Errores Específicos

### Errores Comunes
```dart
class ProductsExceptions {
  static const String duplicateCode = 'Código de producto ya existe';
  static const String duplicateSku = 'SKU ya existe';
  static const String invalidVariant = 'Combinación talla/color ya existe';
  static const String productNotFound = 'Producto no encontrado';
  static const String inactiveProduct = 'Producto inactivo';

  static String getLocalizedMessage(String error) {
    if (error.contains('duplicate key value violates unique constraint')) {
      if (error.contains('producto_master_codigo')) {
        return duplicateCode;
      } else if (error.contains('articulos_sku')) {
        return duplicateSku;
      } else if (error.contains('articulos_producto_master_id_talla_id_color_id')) {
        return invalidVariant;
      }
    }

    if (error.contains('23505')) {
      return 'Ya existe un registro con estos datos';
    }

    return 'Error en productos: $error';
  }
}
```

## Testing

### Test Cases Críticos
```dart
void main() {
  group('ProductsRepository Tests', () {
    test('crear producto master exitosamente', () async {
      final request = CreateProductoRequest(
        codigo: 'TEST-001',
        nombre: 'Producto Test',
        marcaId: 'marca-id',
        categoriaId: 'categoria-id',
        precioBase: 29.90,
      );

      final producto = await repository.createProductoMaster(request);

      expect(producto.codigo, 'TEST-001');
      expect(producto.nombre, 'Producto Test');
      expect(producto.precioBase, 29.90);
    });

    test('crear variante con SKU auto-generado', () async {
      // Test de creación de variante
    });

    test('validar SKU duplicado retorna error', () async {
      // Test de validación de duplicados
    });
  });
}
```

## Comandos Útiles

### Supabase CLI
```sql
-- Ver productos con más variantes
SELECT
  pm.nombre,
  pm.codigo,
  COUNT(a.id) as total_variantes,
  SUM(COALESCE(i.stock_actual, 0)) as stock_total
FROM producto_master pm
LEFT JOIN articulos a ON pm.id = a.producto_master_id
LEFT JOIN inventario i ON a.id = i.articulo_id
GROUP BY pm.id, pm.nombre, pm.codigo
ORDER BY total_variantes DESC;

-- Productos sin stock
SELECT
  pm.nombre,
  a.sku,
  t.valor as talla,
  c.nombre as color,
  COALESCE(i.stock_actual, 0) as stock
FROM producto_master pm
JOIN articulos a ON pm.id = a.producto_master_id
JOIN tallas t ON a.talla_id = t.id
JOIN colores c ON a.color_id = c.id
LEFT JOIN inventario i ON a.id = i.articulo_id
WHERE COALESCE(i.stock_actual, 0) = 0
ORDER BY pm.nombre, t.orden, c.nombre;
```