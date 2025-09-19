# CLAUDE.md

Este archivo proporciona guía a Claude Code (claude.ai/code) para trabajar con código en este repositorio.

## Descripción del Proyecto

Sistema de gestión retail/inventario especializado en ventas de ropa y medias. Desarrollado con Flutter para multiplataforma (web + móvil) y Supabase como backend-as-a-service.

## ⚠️ ESPECIFICACIONES DE VERSIONES CRÍTICAS ⚠️

### **TODOS LOS AGENTES IA DEBEN USAR ESTAS VERSIONES EXACTAS:**

#### **Entorno Base**
- **Flutter**: `3.35.1` (stable channel)
- **Dart**: `3.9.0`
- **SDK**: `^3.9.0`

#### **Dependencias Principales**
- **supabase_flutter**: `^2.8.0` → ⚠️ **CRÍTICO**: Usar `.isFilter()` NO `.is_()`
- **flutter_bloc**: `^8.1.6`
- **go_router**: `^14.6.1`
- **equatable**: `^2.0.5`

#### **ERRORES CRÍTICOS A EVITAR:**
```dart
// ❌ INCORRECTO (versión antigua Supabase)
.is_('campo', valor)

// ✅ CORRECTO (Supabase v2.8.0)
.isFilter('campo', valor)

// ❌ INCORRECTO (Spread operator mal usado)
if (condition) ...[
  widget,
  // Sin cierre

// ✅ CORRECTO (Dart 3.9.0)
if (condition) ...[
  widget,
], // Cierre explícito
```

**📋 Documentación completa**: `docs/VERSION_SPECIFICATIONS.md`

## Arquitectura y Stack Tecnológico

### Stack Principal
- **Frontend**: Flutter + Dart (una sola base de código para web y móvil)
- **Backend**: Supabase (PostgreSQL + Edge Functions + Auth + Realtime + Storage)
- **Base de Datos**: PostgreSQL (administrada por Supabase)
- **Autenticación**: Supabase Auth con seguridad a nivel de fila (RLS)
- **Tiempo Real**: Supabase Realtime para actualizaciones de inventario en vivo

### Modelo de Dominio
El sistema está organizado en estos dominios principales:
- **Ventas** - Operaciones POS, transacciones, devoluciones
- **Inventario** - Gestión de stock, variantes de productos (talla/color)
- **Catálogo** - Información de productos, gestión SKU
- **Clientes** - Gestión de clientes, programas de lealtad
- **Facturación** - Generación de facturas, cumplimiento tributario
- **Tiendas** - Operaciones multi-tienda, gestión de ubicaciones

## Agentes Especializados

### Agentes Claude Code Disponibles
- **general-purpose**: Investigación, análisis de problemas complejos, diagnóstico técnico y preparación de especificaciones para agentes especializados
- **flutter-supabase-architect**: Arquitecturas Flutter+Supabase completas, diseño de sistemas end-to-end, implementación de funcionalidades multi-dominio
- **statusline-setup**: Configuración de status line Claude Code
- **output-style-setup**: Configuración de estilos de output Claude Code

### Metodología de Trabajo con Agentes
1. **general-purpose** → Análisis inicial del problema y especificaciones técnicas
2. **UX/UI Coordinator** → Coordinación de implementación respetando guidelines de diseño
3. **flutter-supabase-architect** → Implementación completa Flutter+Supabase
4. **UX/UI Coordinator** → Supervisión final y validación de UX

## ⚠️ DIRECTIVA CRÍTICA: FASE DE ANÁLISIS flutter-supabase-architect ⚠️

### **REGLA OBLIGATORIA: NO CÓDIGO EN FASE DE ANÁLISIS**

**Cuando se usa flutter-supabase-architect para análisis conceptual:**

✅ **SÍ PROPORCIONAR:**
- Análisis arquitectónico conceptual
- Comparación de enfoques y alternativas
- Ventajas/desventajas técnicas y de negocio
- Recomendaciones fundamentadas
- Consideraciones de escalabilidad y performance
- Impacto en UX/UI y operaciones
- Estrategias de migración e implementación

❌ **NO PROPORCIONAR:**
- Código Flutter/Dart
- Scripts SQL o migraciones específicas
- Implementaciones detalladas
- Ejemplos de código
- Snippets o fragmentos

### **FLUJO DE TRABAJO OBLIGATORIO:**

1. **FASE 1 - ANÁLISIS** → flutter-supabase-architect proporciona solo análisis conceptual
2. **FASE 2 - DISCUSIÓN** → Refinamiento de propuesta con usuario
3. **FASE 3 - APROBACIÓN** → Usuario aprueba enfoque seleccionado
4. **FASE 4 - DESARROLLO** → Coordinación con agentes para implementación con código

**Esta directiva garantiza que no se genere código prematuro que podría no ser utilizado.**

## GUIDELINES UX/UI - DISEÑO ESTABLECIDO

### 🎨 **Sistema de Colores Corporativo**
```dart
// Paleta principal - Turquesa moderno retail
primaryTurquoise: Color(0xFF4ECDC4)    // Color principal
primaryLight: Color(0xFF7DEDE8)        // Variante clara
primaryDark: Color(0xFF26A69A)         // Variante oscura
successColor: Color(0xFF4CAF50)        // Verde éxito
errorColor: Color(0xFFF44336)          // Rojo error
warningColor: Color(0xFFFF9800)        // Naranja advertencia
```

### 📱 **Responsive Breakpoints Obligatorios**
```dart
// Breakpoints específicos del proyecto
mobileBreakpoint: 768px     // Mobile: < 768px
tabletBreakpoint: 1200px    // Tablet: 768px - 1200px
desktopBreakpoint: 1200px   // Desktop: ≥ 1200px
```

### 🧩 **Componentes Estandarizados**
```dart
// Botones corporativos
CorporateButton(
  height: 52px,                    // Altura estándar
  borderRadius: 12px,              // Radio consistente
  backgroundColor: primaryTurquoise // Color principal
)

// Campos de formulario
CorporateFormField(
  borderRadius: 12px,              // Radio consistente
  animation: Duration(200ms),      // Micro-interacciones
  focusedBorder: primaryTurquoise  // Color foco
)

// Cards del sistema
Card(
  elevation: 2,                    // Sombra sutil
  borderRadius: 12px,              // Radio consistente
  color: cardWhite                 // Fondo blanco limpio
)
```

### 🚀 **Navegación Adaptativa**
```dart
// Desktop (≥1200px): Sidebar fijo expandido con toggle
// Tablet (768-1199px): NavigationRail colapsible Material 3
// Mobile (<768px): Drawer oculto + BottomNavigation
```

### ⚠️ **COORDINACIÓN UX/UI**
**Todos los agentes DEBEN respetar estos guidelines automáticamente:**
- ✅ **COORDINADOR**: Supervisa cumplimiento de diseño establecido
- ✅ **PLANIFICADOR**: Define flujos respetando patrones existentes
- ✅ **SUPERVISOR**: Valida que implementaciones mantengan consistencia
- ✅ **GUARDIAN DEL DISEÑO**: Preserva identidad visual turquesa moderna

**METODOLOGÍA OBLIGATORIA:**
1. **UX/UI** analiza requerimiento y define especificaciones
2. **UX/UI** delega implementación al agente especializado apropiado:
   - **flutter-expert**: Para cambios en UI/UX, widgets, navegación
   - **supabase-expert**: Para cambios en BD, APIs, autenticación
   - **database-expert**: Para modelado de datos, migraciones
   - **technical-documentator**: Para documentar funcionalidades y decisiones técnicas (activación automática en paralelo)
3. **UX/UI** supervisa resultado y coordina ajustes si es necesario

**GESTIÓN DE ERRORES:**
- **Usuario** reporta TODOS los errores directamente al **UX/UI**
- **UX/UI** diagnostica el error y determina el agente apropiado para solucionarlo
- **UX/UI** delega la corrección del error al agente especializado
- **UX/UI** verifica la solución y reporta el resultado al usuario

**EJEMPLO CORRECTO - Funcionalidad:**
```
Usuario solicita: "Simplificar formulario de crear talla"
UX/UI: "Coordino con flutter-expert para simplificar UI..."
[Delega via Task tool al flutter-expert]
UX/UI: "Flutter-expert completó la simplificación exitosamente"
```

**EJEMPLO CORRECTO - Error:**
```
Usuario reporta: "Error al cargar productos: column marcas.activo does not exist"
UX/UI: "Diagnostico el error como problema de BD, coordino con supabase-expert..."
[Delega corrección del error al supabase-expert]
UX/UI: "Error corregido: campo 'activo' cambiado a 'activa' en repository"
```

**EJEMPLO INCORRECTO:**
```
Usuario solicita: "Simplificar formulario de crear talla"  
UX/UI: [Usa Edit tool directamente para modificar código]
```

Esta directiva asegura separación de responsabilidades y gestión eficiente del equipo de agentes IA.

## 🎯 COORDINACIÓN MULTI-AGENTE AVANZADA

### ⚠️ CRÍTICO: Orquestación para Problemas Multi-Dominio ⚠️

**REGLA FUNDAMENTAL:** Cuando un problema abarca MÚLTIPLES dominios técnicos, el UX/UI DEBE coordinar con TODOS los agentes relevantes simultáneamente.

### 🔄 MATRIZ DE COORDINACIÓN OBLIGATORIA

**Problema: UI Elements que muestran datos de BD**
- ✅ **CORRECTO**: Coordinar `flutter-expert` + `supabase-expert` juntos
- ❌ **INCORRECTO**: Solo coordinar `flutter-expert` ignorando origen de datos

**Problema: Formularios con validación y persistencia**
- ✅ **CORRECTO**: Coordinar `flutter-expert` + `supabase-expert` + `database-expert`
- ❌ **INCORRECTO**: Solo coordinar uno sin considerar el flujo completo

**Problema: Autenticación y navegación**
- ✅ **CORRECTO**: Coordinar `flutter-expert` + `supabase-expert`
- ❌ **INCORRECTO**: Solo resolver en frontend sin verificar políticas RLS

**Problema: Performance de consultas en UI**
- ✅ **CORRECTO**: Coordinar `database-expert` + `supabase-expert` + `flutter-expert`
- ❌ **INCORRECTO**: Solo optimizar consulta sin considerar impacto en UI

### 🎪 PATRONES DE COORDINACIÓN ESPECÍFICOS

#### **PATRÓN 1: Dropdowns Vacíos (UI + BD)**
```
DIAGNOSIS UX/UI: "Dropdown vacío = problema UI + datos"
COORDINACIÓN SIMULTÁNEA:
1. flutter-expert: Verificar lógica de carga en widgets
2. supabase-expert: Verificar queries, campos BD, RLS policies

EJEMPLO CORRECTO:
"Coordino flutter-expert para revisar _loadInitialData() Y 
supabase-expert para verificar repository queries simultáneamente"
```

#### **PATRÓN 2: Formularios con Errores 400/23505**
```
DIAGNOSIS UX/UI: "Error BD = validación + formato + constraint"
COORDINACIÓN SIMULTÁNEA:
1. flutter-expert: Validación local, UX de errores, campos requeridos
2. supabase-expert: Mapping BD, constraints, tipos de datos
3. database-expert: Schema validation, unique keys

EJEMPLO CORRECTO:
"Coordino los 3 agentes para resolver error 23505: flutter-expert 
para validación previa, supabase-expert para mapping correcto, 
database-expert para constraints únicos"
```

#### **PATRÓN 3: Autenticación + Navegación**
```
DIAGNOSIS UX/UI: "Login fallido = auth + routing + permisos"
COORDINACIÓN SIMULTÁNEA:
1. flutter-expert: GoRouter, navegación condicional, UI states
2. supabase-expert: Auth policies, RLS, tokens, sessions

EJEMPLO CORRECTO:
"Coordino flutter-expert para routing post-login Y supabase-expert 
para verificar policies RLS que bloquean acceso"
```

### 📋 **PATRONES DE IMPLEMENTACIÓN OBLIGATORIOS**

#### 🔄 **Micro-interacciones Estándar**
```dart
// Hover effects en cards
AnimatedContainer(
  duration: Duration(milliseconds: 200),      // Duración estándar
  transform: isHovered ? Matrix4.scale(1.02) : Matrix4.identity(),
  child: Card(elevation: isHovered ? 8 : 2)   // Elevación dinámica
)

// Estados de loading
CircularProgressIndicator(
  color: AppTheme.primaryTurquoise,           // Color consistente
  strokeWidth: 2,                             // Grosor estándar
)

// Mensajes de feedback
SnackBar(
  backgroundColor: AppTheme.successColor,     // Verde para éxito
  behavior: SnackBarBehavior.floating,        // Comportamiento estándar
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
)
```

#### 🎛️ **Formularios Estándar**
```dart
// Estructura obligatoria de formularios
Form(
  key: _formKey,
  child: Column(
    children: [
      CorporateFormField(),                     // Campos estandarizados
      SizedBox(height: 16),                     // Espaciado consistente
      CorporateButton(),                        // Botones corporativos
    ]
  )
)

// Validación estándar
validator: (value) {
  if (value?.isEmpty ?? true) return 'Campo requerido';
  return null;
}
```

#### 📱 **Navegación Responsive**
```dart
// Decisión automática por breakpoint
if (width >= AppTheme.desktopBreakpoint) {
  return DesktopLayout(sidebar: fixed);       // Sidebar fijo desktop
} else if (width >= AppTheme.mobileBreakpoint) {
  return TabletLayout(rail: collapsible);     // Rail tablet
} else {
  return MobileLayout(drawer: hidden);        // Drawer + bottom nav
}
```

### ✅ **CHECKLIST IMPLEMENTACIÓN OBLIGATORIO**

**ANTES de implementar, VERIFICAR:**
- [ ] ¿Respeta paleta de colores? → Usar solo AppTheme.primaryTurquoise
- [ ] ¿Usa componentes estándar? → CorporateButton, CorporateFormField
- [ ] ¿Breakpoints correctos? → Desktop ≥1200px, Tablet 768-1199px, Mobile <768px
- [ ] ¿Micro-interacciones? → Hover, loading, animaciones 200ms
- [ ] ¿Mensajes consistentes? → SnackBar con colores de estado
- [ ] ¿Navegación adaptativa? → Sidebar/Rail/Drawer según plataforma

**CRÍTICO:** Mantener consistencia visual turquesa moderna en todas las implementaciones.

### ✅ EJEMPLOS DE COORDINACIÓN MEJORADA

**ANTES (Coordinación deficiente):**
```
Usuario: "Los combos no cargan data de marcas, tallas, categoría, material"
UX/UI: "Coordino con flutter-expert para revisar los dropdowns..."
[Solo involucra flutter-expert, ignora que el problema es de datos BD]
```

**DESPUÉS (Coordinación correcta):**
```
Usuario: "Los combos no cargan data de marcas, tallas, categoría, material"  
UX/UI: "Problema multi-dominio detectado: UI + Datos BD
Coordino SIMULTÁNEAMENTE:
- flutter-expert: Revisar _loadInitialData(), manejo de estados, UI dropdowns
- supabase-expert: Verificar queries repository, campos BD, RLS policies
Ambos agentes trabajarán el problema desde sus especialidades"
```

**RESULTADO:** Problema resuelto completamente en una iteración vs múltiples intentos parciales.

## EJEMPLOS DE IMPLEMENTACIÓN CORRECTA

### 🎨 **Card Producto - Patrón Establecido**
```dart
// Implementación que respeta guidelines
Card(
  elevation: 2,                               // Elevación estándar
  shadowColor: AppTheme.primaryTurquoise.withOpacity(0.3),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),   // Radio consistente
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.all(16),             // Padding estándar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,        // Color texto principal
            ),
          ),
          SizedBox(height: 8),                   // Espaciado consistente
          Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.textSecondary,      // Color texto secundario
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### 📋 **Modal/Dialog - Patrón Establecido**
```dart
// Estructura estándar para modals
Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),   // Radio consistente
  ),
  child: Container(
    constraints: BoxConstraints(maxWidth: 500), // Ancho máximo
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con color corporativo
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryTurquoise.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.edit, color: AppTheme.primaryTurquoise),
              SizedBox(width: 12),
              Text(
                'Título Modal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTurquoise,
                ),
              ),
            ],
          ),
        ),
        // Contenido
        Padding(
          padding: EdgeInsets.all(24),
          child: Form(/* Formulario estándar */),
        ),
        // Footer con botones
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: Text('Cancelar'),
              ),
              SizedBox(width: 12),
              CorporateButton(
                text: 'Guardar',
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

### 📱 **Lista/Grid Responsive - Patrón Establecido**
```dart
// Grid adaptativo según breakpoint
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;
    int crossAxisCount;

    if (width >= AppTheme.desktopBreakpoint) {
      crossAxisCount = 3;                       // Desktop: 3 columnas
    } else if (width >= AppTheme.mobileBreakpoint) {
      crossAxisCount = 2;                       // Tablet: 2 columnas
    } else {
      crossAxisCount = 1;                       // Mobile: 1 columna
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,                    // Espaciado consistente
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,                  // Proporción estándar
      ),
      itemBuilder: (context, index) => ProductMasterCard(),
    );
  },
)
```

## METODOLOGÍA DE TRABAJO CON AGENTES

### 🤖 **TEMPLATE PARA COORDINAR AGENTES**

```markdown
TAREA: [Descripción específica]

GUIDELINES UX OBLIGATORIOS:
✅ Paleta: Solo AppTheme.primaryTurquoise y variantes
✅ Componentes: CorporateButton, CorporateFormField, Cards estándar
✅ Responsive: Desktop ≥1200px, Tablet 768-1199px, Mobile <768px
✅ Micro-interacciones: Hover 200ms, loading consistente
✅ Navegación: Sidebar fijo desktop, Rail tablet, Drawer+Bottom mobile

IMPLEMENTAR:
1. [Cambio específico 1 con ejemplo de código]
2. [Cambio específico 2 respetando patrones]
3. [Validación UX requerida]

ARCHIVOS:
- [ruta absoluta archivo 1]
- [ruta absoluta archivo 2]

CRITERIOS ÉXITO:
- Diseño mantiene identidad turquesa moderna
- Componentes reutilizan widgets corporativos
- Responsive funciona en todos los breakpoints
- Micro-interacciones fluidas y consistentes
```

### 🛡️ **VALIDACIONES Y MEJORES PRÁCTICAS**

**ESQUEMAS BD CONFIRMADOS:**
```sql
marcas: activo (boolean)           -- Campo activo confirmado
categorias: activo (boolean)       -- Campo activo confirmado
tallas: activo (boolean)           -- Campo activo confirmado
colores: activo (boolean)          -- Campo activo confirmado
tiendas: activa (boolean)          -- Campo activa (excepción)
productos_master: estado (enum)    -- Estados: ACTIVO/INACTIVO/DESCONTINUADO
```

**VALIDACIONES OBLIGATORIAS:**
```dart
// Validación nombres duplicados antes save
final isDuplicate = await repository.checkExists(
  nombre: nombre.trim().toLowerCase(),
  excludeId: currentId,
);
if (isDuplicate) {
  showError('Ya existe un registro con ese nombre');
  return;
}

// Manejo errores BD estándar
catch (e) {
  String message = 'Error inesperado';
  if (e.toString().contains('23505')) {
    message = 'Ya existe un registro con esos datos';
  } else if (e.toString().contains('23503')) {
    message = 'No se puede eliminar: tiene registros relacionados';
  }
  showError(message);
}
```

**MENSAJES UX CONSISTENTES:**
```dart
// Éxito: Verde con icono
SnackBar(
  content: Row([
    Icon(Icons.check_circle, color: Colors.white),
    SizedBox(width: 8),
    Text('Operación completada exitosamente'),
  ]),
  backgroundColor: AppTheme.successColor,
)

// Error: Rojo con icono
SnackBar(
  content: Row([
    Icon(Icons.error, color: Colors.white),
    SizedBox(width: 8),
    Text(errorMessage),
  ]),
  backgroundColor: AppTheme.errorColor,
)
```

### 🔧 PROMPTS MEJORADOS - EJEMPLOS

**❌ PROMPT DEFICIENTE:**
"Implementa crear talla en el formulario"

**✅ PROMPT MEJORADO:**
```
CONTEXTO: Formulario create_product_page.dart necesita funcionalidad crear talla
BD: tabla `tallas` con campos codigo:text(unique), valor:text, activa:boolean
Errores evitados: constraint único, mapping valor→codigo, tipo INDIVIDUAL

TAREA: Método _createNewTalla() que:
- Valide duplicados localmente antes de BD
- Use ProductsRepository.createTalla() corregido  
- Maneje error 23505 con mensaje claro
- Actualice UI local tras éxito

CRITERIOS ÉXITO:
- No errores 400/23505
- Mensaje claro si talla duplicada
- Nueva talla aparece en dropdown inmediatamente
```

## ⚠️ CRÍTICO: Rol del Agente Technical-Documentator ⚠️

### 📋 RESPONSABILIDADES CORE

**El agente technical-documentator actúa como GESTOR DE CONOCIMIENTO del proyecto**

**ROL OBLIGATORIO:**
- ✅ **DOCUMENTADOR AUTOMÁTICO**: Captura y sintetiza implementaciones mientras otros agentes desarrollan
- ✅ **CONTEXT KEEPER**: Mantiene contexto técnico compartido y actualizado para alineación de agentes
- ✅ **KNOWLEDGE SYNC**: Sincroniza conocimiento entre sesiones, evitando re-trabajo y pérdida de contexto
- ✅ **ARCHITECTURE TRACKER**: Documenta patrones, decisiones técnicas y convenciones establecidas
- ✅ **TOKEN OPTIMIZER**: Reduce tokens en prompts futuros mediante documentación contextual eficiente

### 🔄 ACTIVACIÓN AUTOMÁTICA OBLIGATORIA

**El technical-documentator se ejecuta EN PARALELO (no secuencial) cuando:**
- Cualquier agente implementa funcionalidad nueva significativa
- Se crean o modifican componentes, APIs, esquemas de BD
- Se establecen patrones, convenciones o decisiones arquitectónicas
- Se resuelven errores que requieren documentación para evitar repetición

**FLUJO DE ACTIVACIÓN:**
```
UX/UI coordina: [flutter-expert + supabase-expert + technical-documentator]
│
├─ flutter-expert: Implementa UI/lógica
├─ supabase-expert: Implementa backend/BD
└─ technical-documentator: Documenta AMBAS implementaciones simultáneamente
```

### 📁 ESTRUCTURA DE DOCUMENTACIÓN TÉCNICA

**Archivos gestionados automáticamente:**
- `/docs/ARCHITECTURE.md` - Decisiones arquitectónicas y patrones establecidos
- `/docs/API_REFERENCE.md` - Endpoints, queries y funciones documentadas
- `/docs/DATABASE_SCHEMA.md` - Esquema BD con relaciones, constraints y RLS
- `/docs/COMPONENT_LIBRARY.md` - Widgets Flutter reutilizables con ejemplos
- `/docs/DEPLOYMENT_GUIDE.md` - Configuración ambiente Supabase/Flutter
- `/docs/DEVELOPMENT_LOG.md` - Changelog técnico de implementaciones

### 🎯 CRITERIOS DE DOCUMENTACIÓN

**QUÉ documentar (obligatorio):**
- ✅ Nuevos componentes/widgets Flutter con props y uso
- ✅ APIs/endpoints Supabase con parámetros y responses
- ✅ Esquemas BD: tablas, campos, constraints, relaciones
- ✅ Patrones de arquitectura establecidos (BLoC, Repository, etc.)
- ✅ Convenciones de naming y estructura de archivos
- ✅ Errores resueltos y soluciones para evitar repetición
- ✅ Configuraciones críticas de ambiente

**QUÉ NO documentar:**
- ❌ Implementación detallada línea por línea
- ❌ Comentarios obvios o redundantes
- ❌ Documentación duplicada que ya existe

### 📊 TEMPLATE DE DOCUMENTACIÓN OPTIMIZADO

**Para componentes Flutter:**
```markdown
## ComponentName
**Ubicación**: `lib/presentation/widgets/component_name.dart`
**Propósito**: [1-2 líneas específicas]
**Props**: param1(type), param2(type)
**Uso**: `ComponentName(prop1: value)`
**Dependencias**: [BLoC/providers necesarios]
```

**Para APIs Supabase:**
```markdown
## endpoint_name
**Método**: POST/GET
**URL**: `/api/v1/endpoint`
**Parámetros**: {param1: type, param2: type}
**Response**: {field1: type, field2: type}
**RLS**: [política aplicada si existe]
**Errores comunes**: [400/23505 etc. si aplica]
```

**Para esquemas BD:**
```markdown
## tabla_name
**Campos**: campo1(tipo, constraint), campo2(tipo, constraint)
**Relaciones**: FK hacia tabla_x, referenciada por tabla_y
**Índices**: [campos indexados]
**RLS**: [políticas activas]
```

## Comandos de Coordinación entre Agentes

### Comandos Principales

#### `/setup-proyecto`
Inicializa proyecto Flutter + Supabase completo:
1. flutter-expert: Crea estructura de proyecto Flutter con arquitectura limpia
2. supabase-expert: Configura proyecto Supabase, Auth y estructura inicial
3. database-expert: Define esquemas básicos (usuarios, tiendas, roles)
4. ux-ui-expert: Establece design system y componentes base

#### `/crear-pantalla [nombre] [descripción]`
Flujo completo para nueva funcionalidad:
1. ux-ui-expert: Diseña wireframes, flujos de usuario y especificaciones UX
2. database-expert: Define esquemas de datos y consultas necesarias
3. supabase-expert: Configura backend, APIs, RLS y funciones necesarias
4. flutter-expert: Implementa la pantalla con widgets y lógica de estado

#### `/crear-modulo [módulo] [funcionalidades]`
Desarrolla módulo completo del sistema:
1. ux-ui-expert: Mapea experiencia completa del módulo
2. database-expert: Diseña modelo de datos completo
3. supabase-expert: Implementa toda la lógica de backend
4. flutter-expert: Crea todas las pantallas y navegación del módulo

### Comandos Específicos de Retail

#### `/pos-setup`
Configura sistema punto de venta:
1. ux-ui-expert: Diseña interfaz POS optimizada para ventas rápidas
2. database-expert: Esquema productos, inventario, ventas y reportes
3. supabase-expert: Edge Functions para procesar ventas y actualizar stock
4. flutter-expert: Pantallas POS con escáner y gestión de carrito

#### `/inventario-completo [tipo]`
Sistema completo de inventario:
- `/inventario-completo setup` → Módulo completo de gestión de stock
- `/inventario-completo alertas` → Sistema de notificaciones stock bajo  
- `/inventario-completo reportes` → Dashboards y métricas de inventario

#### `/cliente-sistema`
Gestión integral de clientes:
1. ux-ui-expert: Flujos de registro, consulta y gestión de clientes
2. database-expert: Esquema clientes con validaciones DNI/RUC Perú
3. supabase-expert: APIs y validaciones para datos de clientes
4. flutter-expert: Pantallas de gestión de clientes con búsqueda

#### `/facturacion-peru`
Sistema de facturación para Perú:
1. ux-ui-expert: Interfaz para generación de comprobantes
2. database-expert: Esquema para facturas, boletas y notas de crédito
3. supabase-expert: Generación de PDFs y cumplimiento tributario
4. flutter-expert: Pantallas de facturación con preview e impresión

### Comandos de Optimización

#### `/optimizar [área]`
Mejoras de rendimiento específicas:
- `/optimizar consultas` → database-expert optimiza queries lentas
- `/optimizar ui` → flutter-expert mejora rendimiento de widgets
- `/optimizar backend` → supabase-expert optimiza Edge Functions
- `/optimizar ux` → ux-ui-expert mejora flujos de usuario

#### `/testing-completo`
Suite completa de pruebas:
1. ux-ui-expert: Define casos de prueba de experiencia de usuario
2. database-expert: Tests de integridad y rendimiento de datos
3. supabase-expert: Tests de APIs y funciones backend
4. flutter-expert: Tests unitarios, widgets e integración
5. technical-documentator: Documenta casos de prueba y cobertura

### Comandos de Documentación

#### `/documentar-auto`
Activación automática del agente technical-documentator:
**Uso**: Ejecutado automáticamente en paralelo cuando otros agentes implementan funcionalidad
**Propósito**: Documentar implementaciones en tiempo real

#### `/sync-knowledge`
Sincronización de contexto técnico:
1. technical-documentator: Actualiza documentación existente
2. Genera resumen de cambios para alineación de agentes
3. Optimiza prompts futuros con contexto actualizado

#### `/review-architecture`
Revisión de decisiones arquitectónicas:
1. technical-documentator: Analiza patrones implementados
2. Identifica inconsistencias o mejoras potenciales
3. Actualiza ARCHITECTURE.md con decisiones validadas

## DIRECTIVAS CRÍTICAS DE DESARROLLO

### ⚠️ PRESERVACIÓN DE DATOS EN DESARROLLO ⚠️
**NUNCA usar `supabase db reset` para reiniciar Supabase en desarrollo**
- ✅ **CORRECTO**: `supabase stop && supabase start` (preserva datos)
- ❌ **INCORRECTO**: `supabase db reset` (borra todos los datos)
- ✅ **Para aplicar nuevas migraciones**: `supabase db push` 
- ✅ **Para problemas de conectividad**: reiniciar contenedores, no reset

**El comando `flutter run -d chrome --no-pub` NO debe borrar datos**
- Si se pierden datos, verificar: políticas RLS recursivas, conflictos de migración
- Usuario admin de prueba: `admin@test.com / admin123`
- Solución: Corregir migraciones problemáticas antes de reset

### 🌐 EXPERIENCIA MULTIPLATAFORMA OBLIGATORIA
**Todos los agentes DEBEN considerar responsive design:**
- **Web (≥1200px)**: Sidebar fijo expandido por defecto con toggle
- **Tablet (768-1199px)**: NavigationRail colapsible estilo Material 3  
- **Mobile (<768px)**: Drawer oculto + BottomNavigation únicamente

**Breakpoints obligatorios:**
```dart
if (width >= 1200) → DesktopLayout()   // Sidebar fijo
else if (width >= 768) → TabletLayout() // NavigationRail
else → MobileLayout()                   // Drawer + BottomNav
```

## Estándares de Desarrollo

### Desarrollo Flutter
- Arquitectura limpia con patrón BLoC/Riverpod para gestión de estado
- Material Design 3 con layouts adaptativos (móvil/tablet/web)
- GoRouter para navegación con rutas protegidas
- Integración Supabase con soporte offline usando Hive para caché
- Internacionalización para español (Perú) con formato de moneda S/
- Widgets reutilizables y componentes modulares

### Diseño de Base de Datos
- PostgreSQL con índices apropiados, llaves foráneas y restricciones
- Políticas RLS (Row Level Security) para escenarios multi-tenant
- Evitar consultas N+1, implementar paginación consistente
- Migraciones versionadas con capacidades de rollback
- Optimización de consultas para reportes en tiempo real

### Backend Supabase
- Edge Functions para lógica de negocio compleja
- Políticas RLS granulares por tabla y operación
- Subscripciones en tiempo real optimizadas
- Autenticación con roles (admin, vendedor, cliente)
- APIs RESTful y consultas GraphQL según necesidad

### Estrategia de Pruebas
- Tests unitarios para lógica de negocio y servicios
- Tests de widgets para componentes Flutter
- Tests de integración para flujos críticos de usuario
- Tests de rendimiento para operaciones de inventario

## Contexto del Negocio

Este sistema está diseñado específicamente para:
- **Negocios retail de ropa y medias** en Perú
- **Productos multi-variante** (combinaciones talla/color con SKUs únicos)
- **Operaciones multi-tienda** con inventario centralizado
- **Sistemas POS** con escaneo de códigos de barras e impresión de tickets
- **Gestión de stock** con reservas y confirmaciones
- **Reportes de ventas** con métricas y analíticas en tiempo real
- **Gestión de clientes** con validación DNI/RUC para Perú

## Flujo de Trabajo

1. Usar el agente especializado apropiado para cada dominio
2. Planificar funcionalidades antes de implementar
3. Crear migraciones de BD antes de cambios de backend
4. Implementar UI responsiva con componentes reutilizables
5. Aplicar pruebas integrales en todos los niveles
6. Mantener documentación viva de APIs y decisiones técnicas

## Consideraciones Regionales

- **Localización**: Idioma español, contexto cultural peruano
- **Cumplimiento**: Regulaciones tributarias, requisitos de facturación
- **Métodos de Pago**: Integración con sistemas de pago locales
- **Moneda**: Formateo y cálculos en Soles Peruanos (S/)
- **Validación**: Formatos DNI, RUC y números telefónicos de Perú

## Directivas Críticas de Desarrollo

### ⚠️ IMPORTANTE: Preservación de Datos en Desarrollo Local
**NUNCA usar `supabase db reset` durante el desarrollo activo**

Para reiniciar Supabase sin perder datos SIEMPRE usar:
```bash
supabase stop
supabase start
```

Para aplicar nuevas migraciones:
```bash
supabase db push --include-all
```

**Comandos PROHIBIDOS que borran datos:**
- ❌ `supabase db reset` → Borra toda la base de datos
- ❌ `supabase db restart` → Puede perder datos

**Esta directiva debe respetarse en TODAS las conversaciones futuras para preservar el trabajo de desarrollo y testing.**

### 📱 CRÍTICO: Experiencia Multiplataforma Adaptativa
**TODA funcionalidad debe diseñarse específicamente para cada contexto de uso**

La aplicación será usada en 3 contextos diferentes que requieren experiencias de navegación y UX específicas:

#### **WEB DESKTOP (>1200px)**
- **Usuarios**: Administrativos con mouse/teclado
- **Navegación**: Sidebar izquierdo FIJO expandido por defecto con botón de colapso
- **Layout**: Multi-panel (sidebar + content + panel info)
- **Interacciones**: Click, hover, keyboard shortcuts, context menus, drag & drop
- **Grids**: 3+ columnas, información detallada
- **Ejemplo**: `[Sidebar Fijo] | [Grid 3-col] | [Panel Info]`

#### **TABLET (768-1200px)**
- **Usuarios**: Gerentes y supervisores, uso híbrido táctil/mouse
- **Navegación**: NavigationRail colapsible (Material 3) con iconos + labels expandibles
- **Layout**: Grid layout optimizado para touch
- **Interacciones**: Touch + hover hybrid, swipe gestures, long press, pinch to zoom
- **Grids**: 2 columnas balanceadas
- **Ejemplo**: `[Rail] | [Grid 2-col Responsive]`

#### **MOBILE (<768px)**
- **Usuarios**: Personal de tienda, 100% táctil, en movimiento
- **Navegación**: NO sidebar visible por defecto, Drawer con hamburger menu ÚNICAMENTE
- **Layout**: Lista vertical + Bottom navigation bar
- **Interacciones**: Pure touch, swipe actions, pull-to-refresh, thumb-friendly targets (44px min)
- **Grids**: Lista single column optimizada para pulgar
- **Ejemplo**: `[≡ Drawer] | [Lista Vertical] | [Bottom Nav]`

#### **Breakpoints Específicos:**
```dart
// OBLIGATORIO usar estos breakpoints en TODA implementación
if (width >= 1200) → DesktopLayout()  // Sidebar fijo
else if (width >= 768) → TabletLayout()   // NavigationRail
else → MobileLayout()                     // Drawer + BottomNav
```

#### **Reglas de Implementación:**
1. **Navegación diferenciada**: Web sidebar fijo ≠ Mobile drawer oculto
2. **Touch targets**: Mobile mínimo 44px, Desktop puede ser menor
3. **Información mostrada**: Desktop más info ≠ Mobile solo esencial
4. **Interacciones**: Desktop mouse/teclado ≠ Mobile pure touch
5. **Performance**: Mobile priorizar velocidad ≠ Desktop más funcionalidad

**ESTA DIRECTIVA ES OBLIGATORIA para todos los agentes (UX/UI, Flutter, Backend) en TODAS las implementaciones futuras.**

## Optimización de Tokens para Agentes IA

### Principios de Comunicación Eficiente
- **Respuestas directas**: Sin preámbulos innecesarios
- **Terminología consistente**: Vocabulario técnico unificado
- **Contexto compartido**: Los agentes conocen el dominio del proyecto
- **Tareas específicas**: Cada agente tiene responsabilidades claras
- **Comunicación en español**: Idioma nativo para mejor comprensión
- **Documentación viva**: El technical-documentator mantiene contexto técnico actualizado

### 📝 PROMPTS OPTIMIZADOS PARA TECHNICAL-DOCUMENTATOR

#### Para Documentar Componentes Flutter
```
TAREA: Documentar [ComponentName] en COMPONENT_LIBRARY.md

CONTEXTO ESPECÍFICO:
- Ubicación: [ruta exacta del archivo]
- Propósito: [funcionalidad específica del componente]
- Props/Parámetros: [tipos y descripciones]
- Dependencias: [BLoCs, providers necesarios]

FORMATO REQUERIDO:
## ComponentName
**Ubicación**: `path/to/component.dart`
**Propósito**: [1-2 líneas específicas]
**Props**: param1(type), param2(type)
**Uso**: `ComponentName(prop1: value)`
**Dependencias**: [BLoC/providers necesarios]

CRITERIOS DOCUMENTACIÓN:
- Enfocarse en USO práctico, no implementación detallada
- Incluir ejemplo de uso real
- Documentar props obligatorios vs opcionales
```

#### Para Documentar APIs/Repositories
```
TAREA: Documentar [RepositoryName.methodName] en API_REFERENCE.md

INFORMACIÓN TÉCNICA REQUERIDA:
- Query SQL ejecutada (si aplica)
- Parámetros de entrada con tipos
- Response type/structure
- Errores comunes (400, 23505, etc.)
- RLS policies aplicadas

FORMATO OBLIGATORIO:
##### methodName()
**Query**: `SELECT ... WHERE ...`
**Response**: `Type<Model>`
**Uso**: [Contexto de uso específico]
**Errores comunes**: [lista de errores y causas]

NO DOCUMENTAR: Implementación línea por línea
SÍ DOCUMENTAR: Comportamiento, parámetros, uso práctico
```

#### Para Documentar Esquemas BD
```
TAREA: Documentar tabla [tabla_name] en DATABASE_SCHEMA.md

INFORMACIÓN CRÍTICA:
- Campos con tipos exactos y constraints
- Relaciones FK entrantes y salientes
- Índices configurados
- RLS policies activas
- Errores comunes conocidos (23505, etc.)

ESTRUCTURA OBLIGATORIA:
### tabla_name
**Propósito**: [funcionalidad de la tabla]
```sql
tabla_name (
  campo1: tipo constraint,
  campo2: tipo constraint
)
```
**Relaciones**: FK hacia X, referenciada por Y
**RLS**: [políticas activas]
**Errores comunes**: [23505 en campo_unique, etc.]

ENFOQUE: Información práctica para desarrollo, no documentación exhaustiva
```

#### Activación Automática en Coordinación
```
FLUJO COORDINACIÓN CON DOCUMENTACIÓN:
1. UX/UI recibe requerimiento del usuario
2. UX/UI coordina agentes técnicos: flutter-expert + supabase-expert + technical-documentator (PARALELO)
3. Agentes técnicos implementan funcionalidad
4. Technical-documentator documenta implementación SIMULTÁNEAMENTE
5. UX/UI reporta completado + documentación actualizada

PROMPT AUTOMÁTICO PARA TECHNICAL-DOCUMENTATOR:
"DOCUMENTAR implementación realizada por [agente]:

IMPLEMENTACIÓN REALIZADA:
- [Resumen de lo implementado por flutter-expert/supabase-expert]
- [Archivos modificados/creados]
- [Decisiones técnicas tomadas]

DOCUMENTAR EN:
- /docs/COMPONENT_LIBRARY.md (si hay componentes Flutter)
- /docs/API_REFERENCE.md (si hay métodos/repositories)
- /docs/DATABASE_SCHEMA.md (si hay cambios BD)
- /docs/DEVELOPMENT_LOG.md (changelog técnico)

ENFOQUE: Actualizar documentación existente, no crear nueva desde cero"
```