# Patrones de Errores - Sistema Retail Manager

## Errores Conocidos y Soluciones Validadas

> **CRÍTICO**: Esta documentación contiene errores ya resueltos. Los agentes DEBEN consultar estos patrones antes de implementar para evitar repetir errores.

## 1. Errores de Base de Datos

### Error 23505 - Constraint Violations

#### Campo boolean: `activo` vs `activa`
```
ERROR: column "activo" does not exist
ERROR: column marcas.activo does not exist
```

**CAUSA**: Inconsistencia en nomenclatura de campos boolean.

**SOLUCIÓN CONFIRMADA**:
```sql
-- ✅ CORRECTO: Usar siempre 'activa'
SELECT * FROM marcas WHERE activa = true;
SELECT * FROM categorias WHERE activa = true;
SELECT * FROM tallas WHERE activa = true;
SELECT * FROM colores WHERE activa = true;

-- ❌ INCORRECTO: Usar 'activo'
SELECT * FROM marcas WHERE activo = true;  -- FALLA
```

**IMPLEMENTACIÓN EN REPOSITORIES**:
```dart
// ✅ CORRECTO
final response = await _client
    .from('marcas')
    .select('*')
    .eq('activa', true);  // Campo correcto

// ❌ INCORRECTO
final response = await _client
    .from('marcas')
    .select('*')
    .eq('activo', true);  // Campo inexistente
```

#### Error 23505 - Duplicate Key Constraint
```
ERROR: duplicate key value violates unique constraint "unique_talla_codigo"
DETAIL: Key (codigo)=(M) already exists.
```

**CAUSA**: Intentar insertar código duplicado sin validación previa.

**SOLUCIÓN CONFIRMADA**:
```dart
// ✅ Validar duplicado ANTES de insertar
Future<void> createTalla(CreateTallaRequest request) async {
  // 1. Validar duplicado local (case-insensitive)
  final existing = await _client
      .from('tallas')
      .select('id')
      .ilike('codigo', request.codigo)
      .maybeSingle();

  if (existing != null) {
    throw const TallaExistsException('Talla con este código ya existe');
  }

  // 2. Insertar solo si no existe
  final response = await _client
      .from('tallas')
      .insert({
        'codigo': request.codigo.toUpperCase(),
        'valor': request.valor,
        'activa': true,  // Campo correcto
      })
      .select()
      .single();

  return Talla.fromJson(response);
}
```

#### Error 400 - Bad Request en POST
```
POST /rest/v1/tallas returned 400:
{"code":"22P02","details":"invalid input value","hint":null,"message":"invalid input value"}
```

**CAUSA**: Mapping incorrecto entre modelo Dart y esquema BD.

**SOLUCIÓN CONFIRMADA**:
```dart
// ❌ MAPPING INCORRECTO
Map<String, dynamic> toJson() => {
  'codigo': codigo,
  'nombre': valor,      // Campo incorrecto
  'activo': activa,     // Campo incorrecto
};

// ✅ MAPPING CORRECTO
Map<String, dynamic> toJson() => {
  'codigo': codigo,
  'valor': valor,       // Campo correcto según schema
  'activa': activa,     // Campo correcto
};
```

### Error de Tipos de Datos
```
ERROR: invalid input syntax for type boolean: "INDIVIDUAL"
```

**CAUSA**: Enviar tipo enum como string a campo boolean.

**SOLUCIÓN**:
```dart
// ✅ Mapear enum correctamente
Map<String, dynamic> toJson() => {
  'codigo': codigo,
  'valor': valor,
  'tipo_talla': tipoTalla.toString().split('.').last,  // Enum como string
  'activa': activa,  // Boolean como boolean
};
```

## 2. Errores de Frontend (Flutter)

### Dropdown Vacíos - Problema Multi-Dominio
```
Problem: Los dropdowns de marcas, tallas, categorías aparecen vacíos
```

**DIAGNÓSTICO**: Problema abarca UI + datos BD, requiere coordinación flutter-expert + supabase-expert.

**PATRÓN DE SOLUCIÓN COORDINADA**:
```dart
// FLUTTER-EXPERT: Verificar carga de datos en widget
class _CreateProductPageState extends State<CreateProductPage> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();  // ⚠️ Verificar que se ejecute
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      context.read<MarcasBloc>().add(LoadMarcas()),
      context.read<TallasBloc>().add(LoadTallas()),
      context.read<CategoriasBloc>().add(LoadCategorias()),
    ]);
  }
}

// SUPABASE-EXPERT: Verificar queries repository
class MarcasRepository {
  Future<List<Marca>> getMarcas() async {
    final response = await _client
        .from('marcas')
        .select('*')
        .eq('activa', true)  // ⚠️ Campo correcto
        .order('nombre');

    return response.map((json) => Marca.fromJson(json)).toList();
  }
}
```

### Error de Navegación Post-Login
```
GoRouter: Could not find a location in the route tree
```

**CAUSA**: Rutas protegidas sin configuración correcta de AuthGuard.

**SOLUCIÓN CONFIRMADA**:
```dart
// ✅ Configurar rutas con redirect correcto
final _router = GoRouter(
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return '/login';
    }

    // Verificar permisos por ruta
    final rutasProtegidas = {
      '/admin': [RolUsuario.ADMIN],
      '/products': [RolUsuario.ADMIN, RolUsuario.GERENTE, RolUsuario.VENDEDOR],
    };

    final requiredRoles = rutasProtegidas[state.location];
    if (requiredRoles != null && !requiredRoles.contains(authState.usuario.rol)) {
      return '/unauthorized';
    }

    return null; // Permitir navegación
  },
  routes: [...],
);
```

## 3. Errores de Coordinación entre Agentes

### Problema: UX/UI Codificando Directamente
```
❌ INCORRECTO: UX/UI usa Edit/Write tools directamente
✅ CORRECTO: UX/UI coordina con agente especializado
```

**PATRÓN CORRECTO DE COORDINACIÓN**:
```
Usuario: "Simplificar formulario crear producto"

❌ UX/UI incorrecto:
[UX/UI usa Edit tool para modificar create_product_page.dart]

✅ UX/UI correcto:
UX/UI: "Coordino con flutter-expert para simplificar UI del formulario..."
[Delega via Task tool al flutter-expert con especificaciones detalladas]
UX/UI: "Flutter-expert completó la simplificación exitosamente"
```

### Problema: Coordinación Mono-Agente en Problemas Multi-Dominio
```
Usuario: "Los combos no cargan data"

❌ COORDINACIÓN DEFICIENTE:
UX/UI: "Coordino con flutter-expert para revisar dropdowns..."
[Solo flutter-expert, ignora que problema es de datos BD]

✅ COORDINACIÓN CORRECTA:
UX/UI: "Problema multi-dominio: UI + Datos BD. Coordino SIMULTÁNEAMENTE:
- flutter-expert: Revisar _loadInitialData(), estados, UI dropdowns
- supabase-expert: Verificar queries, campos BD, RLS policies"
```

## 4. Errores de Autenticación

### Error de Conexión Supabase Local
```
AuthRetryableFetchException: Failed to fetch, uri=http://127.0.0.1:54321/auth/v1/token
```

**CAUSA**: Supabase local no está corriendo o Docker con problemas.

**SOLUCIÓN PASO A PASO**:
```bash
# 1. Verificar Docker
docker ps

# 2. Parar Supabase limpiamente (NO usar db reset)
supabase stop

# 3. Iniciar Supabase preservando datos
supabase start

# 4. Verificar URLs disponibles
supabase status
```

### Error RLS Policy Recursiva
```
ERROR: infinite recursion detected in policy
```

**CAUSA**: Política RLS que se referencia a sí misma.

**SOLUCIÓN**:
```sql
-- ❌ POLÍTICA RECURSIVA
CREATE POLICY "Users can view users" ON usuarios
FOR SELECT USING (
    EXISTS(SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'ADMIN')
    -- ↑ Esta consulta llama a la misma tabla con la misma política
);

-- ✅ POLÍTICA CORRECTA
CREATE POLICY "Users can view users" ON usuarios
FOR SELECT USING (
    auth.jwt() ->> 'role' = 'authenticated' AND (
        id = auth.uid() OR
        auth.uid() IN (SELECT id FROM usuarios WHERE rol = 'ADMIN')
    )
);
```

## 5. Errores de Performance

### N+1 Queries en Dropdowns
```
Problem: 100+ queries para cargar cada marca/categoría individualmente
```

**SOLUCIÓN**: Usar joins en lugar de múltiples queries.

```dart
// ❌ N+1 QUERIES
Future<List<Producto>> getProductos() async {
  final productos = await _client.from('producto_master').select('*');

  // ❌ Query por cada producto
  for (final producto in productos) {
    producto['marca'] = await _client
        .from('marcas')
        .select('*')
        .eq('id', producto['marca_id'])
        .single();
  }
}

// ✅ SINGLE QUERY WITH JOINS
Future<List<Producto>> getProductos() async {
  final response = await _client
      .from('producto_master')
      .select('''
        *,
        marca:marcas(*),
        categoria:categorias(*),
        material:materiales(*)
      ''')
      .eq('activo', true);  // Campo correcto

  return response.map((json) => Producto.fromJson(json)).toList();
}
```

### Memory Leaks en BLoC Streams
```
Problem: Flutter app consume cada vez más memoria
```

**SOLUCIÓN**: Cancelar suscripciones correctamente.

```dart
class _ProductPageState extends State<ProductPage> {
  StreamSubscription<ProductsState>? _productsSubscription;

  @override
  void initState() {
    super.initState();

    // ✅ Guardar suscripción para cancelar
    _productsSubscription = context.read<ProductsBloc>().stream.listen((state) {
      // Handle state changes
    });
  }

  @override
  void dispose() {
    // ✅ Cancelar suscripción
    _productsSubscription?.cancel();
    super.dispose();
  }
}
```

## 6. Errores de Responsive Design

### Layout Roto en Mobile
```
Problem: Sidebar desktop se muestra en mobile, botones muy pequeños
```

**SOLUCIÓN**: Implementar breakpoints obligatorios según CLAUDE.md.

```dart
// ✅ LAYOUT RESPONSIVO CORRECTO
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Breakpoints obligatorios según directivas
        if (width >= 1200) {
          // Desktop: Sidebar fijo expandido
          return DesktopLayout(child: child);
        } else if (width >= 768) {
          // Tablet: NavigationRail colapsible
          return TabletLayout(child: child);
        } else {
          // Mobile: Drawer oculto + BottomNavigation
          return MobileLayout(child: child);
        }
      },
    );
  }
}
```

## 7. Errores de Migración

### Migración Duplicada
```
ERROR: trigger "trigger_tiendas_updated_at" already exists (SQLSTATE 42710)
```

**CAUSA**: Migración ejecutada múltiples veces o conflicto de nombres.

**SOLUCIÓN**: Usar IF NOT EXISTS en migraciones.

```sql
-- ✅ MIGRACIÓN SEGURA
DO $$
BEGIN
    -- Verificar si trigger ya existe
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'trigger_tiendas_updated_at'
    ) THEN
        CREATE TRIGGER trigger_tiendas_updated_at
            BEFORE UPDATE ON public.tiendas
            FOR EACH ROW
            EXECUTE FUNCTION actualizar_updated_at();
    END IF;
END $$;
```

## 8. Template de Error Handling

### Template para Manejo Consistente de Errores

```dart
class ErrorHandler {
  static String getLocalizedMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Errores BD específicos
    if (errorStr.contains('23505')) {
      if (errorStr.contains('unique_talla_codigo')) {
        return 'Código de talla ya existe';
      } else if (errorStr.contains('unique_marca_nombre')) {
        return 'Nombre de marca ya existe';
      }
      return 'Ya existe un registro con estos datos';
    }

    if (errorStr.contains('23503')) {
      return 'No se puede eliminar: tiene registros relacionados';
    }

    if (errorStr.contains('column') && errorStr.contains('does not exist')) {
      return 'Error interno: Campo de base de datos no encontrado';
    }

    // Errores Supabase
    if (errorStr.contains('failed to fetch')) {
      return 'Error de conexión. Verifique su internet o contacte soporte.';
    }

    if (errorStr.contains('invalid credentials')) {
      return 'Credenciales inválidas';
    }

    if (errorStr.contains('jwt expired')) {
      return 'Sesión expirada. Por favor, inicie sesión nuevamente';
    }

    // Error genérico
    return 'Ha ocurrido un error inesperado. Contacte soporte si persiste.';
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getLocalizedMessage(error)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

## 9. Checklist Pre-Implementación

Antes de implementar cualquier funcionalidad, verificar:

### Database
- [ ] Campo boolean usa `activa` no `activo`
- [ ] Validación de duplicados antes de INSERT
- [ ] Constraint names no conflictivos
- [ ] Usar IF NOT EXISTS en migraciones

### Frontend
- [ ] Mapping correcto modelo ↔ JSON
- [ ] Manejo de errores con ErrorHandler
- [ ] Loading states en UI
- [ ] Responsive design con breakpoints correctos

### Coordinación
- [ ] UX/UI actúa como coordinador, no codifica
- [ ] Problemas multi-dominio involucran múltiples agentes
- [ ] Prompts incluyen contexto de errores conocidos

### Testing
- [ ] Test de casos felices y errores
- [ ] Validar duplicados y constraints
- [ ] Memory leaks en streams

## 10. Comandos de Diagnóstico

```bash
# Verificar estado completo del sistema
flutter doctor -v
supabase status
docker ps

# Logs detallados de errores
flutter run --verbose
supabase logs
```

```sql
-- Verificar integridad de datos
SELECT tablename, schemaname FROM pg_tables WHERE tablename IN ('usuarios', 'marcas', 'tallas', 'categorias');

-- Verificar constraints activos
SELECT conname, contype FROM pg_constraint WHERE conrelid = 'marcas'::regclass;

-- Verificar triggers
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

Este documento debe actualizarse cada vez que se encuentre y resuelva un error nuevo.