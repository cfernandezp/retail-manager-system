# PROMPTS TÉCNICOS - Vista Detalle y Editar Producto

## PROMPT 1: VISTA DETALLE DE PRODUCTO (/products/:id)

### CONTEXTO BD CONFIRMADO:
- **Tabla principal**: `producto_master` con campos:
  - `id` (UUID), `codigo` (TEXT UNIQUE), `nombre` (TEXT), `descripcion` (TEXT)
  - `marca_id` (UUID FK), `categoria_id` (UUID FK), `material_id` (UUID FK)
  - `precio_base` (DECIMAL), `costo_base` (DECIMAL), `imagen_url` (TEXT)
  - `activa` (BOOLEAN) ← **CRÍTICO: usar 'activa', NO 'activo'**

- **Relaciones cargadas**: marcas(activa), categorias(activa), materiales(activo)
- **Variantes**: tabla `articulos` con talla_id, color_id, sku, precio_venta, stock
- **Repository existente**: `ProductsRepository` con métodos CRUD confirmados
- **Model confirmado**: `CatalogoCompleto` en `/data/models/product_models.dart`

### TAREA FLUTTER-EXPERT:
Crear archivo `/presentation/pages/products/product_detail_page.dart` con:

1. **Página detalle responsiva** que recibe productId via GoRouter:
   ```dart
   class ProductDetailPage extends StatefulWidget {
     final String productId;
     const ProductDetailPage({super.key, required this.productId});
   }
   ```

2. **Layout responsive específico**:
   - **Desktop (≥1200px)**: Layout horizontal con imagen grande izquierda + info derecha + panel acciones
   - **Tablet (768-1199px)**: Layout vertical con imagen arriba + info grid 2 columnas
   - **Mobile (<768px)**: ListView vertical con imagen compacta + info apilada

3. **Funcionalidades requeridas**:
   - Cargar producto desde ProductsRepository usando productId
   - Mostrar info completa: nombre, código, descripción, marca, categoría, material
   - Precio base formateado como moneda peruana (S/ XX.XX)
   - Estado activa/inactiva with status badge
   - Grid de variantes (tallas/colores) con stock y precios
   - **Acciones principales**: Editar, Duplicar, Eliminar, Ver Variantes

4. **Navegación y acciones**:
   - AppBar con botón back y título dinámico
   - FAB "Editar" que navega a `/products/:id/edit`
   - Menu acciones: Duplicar producto, Eliminar (con confirmación)
   - **Navegación GoRouter**: usar `context.go('/products/$productId/edit')`

5. **Manejo estados BLoC**:
   - Usar ProductsBloc existente para cargar producto específico
   - Eventos: `LoadProductById(productId)`, `DeleteProduct(productId)`
   - Estados: Loading shimmer, Error con retry, Loaded con data

### CRITERIOS ÉXITO:
- **Funcionalidad**: Página carga correctamente producto por ID desde BD
- **Responsive**: Layouts diferentes según breakpoints Material 3
- **Navegación**: AppBar back funcional + FAB editar lleva a ruta correcta
- **UX**: Loading states, error handling, confirmaciones para acciones destructivas
- **Variantes**: Grid muestra tallas/colores con stock y precios si disponibles

### INFORMACIÓN CRÍTICA:
- **Repository method**: `await repository.getProductById(productId)`
- **Error handling**: Producto no encontrado → mostrar 404 con botón volver
- **Material 3**: Usar Material 3 components (Cards, FAB, AppBar)
- **Breakpoints**: `MediaQuery.of(context).size.width` para responsive
- **Currency format**: `NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ')`

### ERRORES EVITADOS:
- ❌ NO usar campo `activo` → ✅ Usar `activa` para estado boolean
- ❌ NO asumir producto existe → ✅ Manejar 404/null response
- ❌ NO hardcodear layouts → ✅ Responsive breakpoints obligatorios
- ❌ NO usar rutas relativas → ✅ Usar `/products/$productId/edit` absoluto

---

## PROMPT 2: MODAL/PÁGINA EDITAR PRODUCTO (/products/:id/edit)

### CONTEXTO BD CONFIRMADO:
- **Misma estructura**: `producto_master` con campo `activa` (boolean)
- **Constraints confirmados**:
  - `codigo` UNIQUE → validar duplicados antes del UPDATE
  - `precio_base` DECIMAL(10,2) → debe ser > 0 y ≤ 99999.99
  - Referencias FK válidas para marca_id, categoria_id, material_id

- **Repository methods**:
  - `updateProductoMaster(id, data)` disponible
  - `getProductById(id)` para cargar datos actuales
  - Dropdowns: `getMarcas()`, `getCategorias()`, `getMateriales()`

### TAREA FLUTTER-EXPERT:
Crear archivo `/presentation/pages/products/edit_product_page.dart` con:

1. **Componente adaptive**:
   - **Desktop/Tablet**: Modal dialog fullscreen con AppBar
   - **Mobile**: Página completa con AppBar y navegación back
   ```dart
   class EditProductPage extends StatefulWidget {
     final String productId;
     const EditProductPage({super.key, required this.productId});
   }
   ```

2. **Formulario completo** con validaciones:
   - **Campos editables**: nombre, descripcion, marca_id, categoria_id, material_id, precio_base, costo_base, imagen_url
   - **Campos readonly**: codigo (no editable), fechas created/updated
   - **Validaciones locales**:
     - Nombre: requerido, 2-200 caracteres
     - Precio: requerido, > 0, formato decimal válido
     - Dropdowns: selección válida requerida

3. **Estado del formulario**:
   - `GlobalKey<FormState>` para validaciones
   - Controllers para cada campo
   - Estado loading durante actualización
   - **Carga inicial**: Cargar datos actuales del producto en campos

4. **Dropdowns reactivos**:
   - Marcas, Categorías, Materiales cargados desde repository
   - Valor inicial del producto actual pre-seleccionado
   - Loading state mientras cargan opciones
   - Empty state si no hay opciones disponibles

5. **Acciones del formulario**:
   - Botón "Cancelar" → vuelve sin guardar (`context.pop()`)
   - Botón "Guardar" → valida + actualiza + navega back
   - **Validación previa**: duplicados, formato, constraints

### CRITERIOS ÉXITO:
- **Carga inicial**: Formulario pre-poblado con datos actuales del producto
- **Validación**: Campos validados localmente antes de submit
- **Actualización**: PUT exitoso a BD sin errores 400/23505
- **UX**: Estados de loading/error claros, mensajes user-friendly
- **Navegación**: Back funcional, cerrar modal después de guardar exitoso

### INFORMACIÓN CRÍTICA:
- **Pre-población**: `await repository.getProductById(productId)` → poblar controllers
- **Update method**: `await repository.updateProductoMaster(productId, formData)`
- **Responsive Modal**: `showDialog()` desktop vs `Navigator.push()` mobile
- **Form validation**: `_formKey.currentState?.validate()` antes de submit
- **Success navigation**: `context.go('/products/$productId')` tras actualizar

### ERRORES EVITADOS:
- ❌ NO permitir editar código → ✅ Campo readonly para evitar duplicates
- ❌ NO validar precios → ✅ Validación precio > 0 y formato decimal
- ❌ NO manejar error 400 → ✅ Capturar y mostrar mensajes específicos
- ❌ NO pre-cargar datos → ✅ Formulario debe iniciarse con valores actuales
- ❌ NO usar campo `activo` → ✅ Usar `activa` boolean consistente con BD

### IMPLEMENTACIÓN ESPECÍFICA:

```dart
// Estructura requerida para ambas páginas
class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    // Cargar producto específico
    context.read<ProductsBloc>().add(LoadProductById(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(/* configuración */),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) => _buildResponsiveLayout(state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/products/${widget.productId}/edit'),
        child: Icon(Icons.edit),
      ),
    );
  }
}
```

### INTEGRACIÓN CON ROUTER EXISTENTE:
- Rutas ya definidas en `/presentation/routes/app_router.dart`
- Reemplazar implementaciones dummy con páginas reales
- Mantener navegación GoRouter con parámetros productId
- Usar AdaptiveNavigationScaffold para consistencia

### TESTING MANUAL SUGERIDO:
1. Navegar desde ProductsPage → ProductDetailPage via card tap
2. Verificar carga de producto y info completa mostrada
3. Tap FAB editar → navega a EditProductPage
4. Modificar campos → guardar → verificar actualización en BD
5. Probar responsive en diferentes tamaños de ventana