# CLAUDE.md

Este archivo proporciona guía a Claude Code (claude.ai/code) para trabajar con código en este repositorio.

## Descripción del Proyecto

Sistema de gestión retail/inventario especializado en ventas de ropa y medias. Desarrollado con Flutter para multiplataforma (web + móvil) y Supabase como backend-as-a-service.

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

Este repositorio utiliza 5 agentes especializados optimizados para trabajo eficiente:

### Equipo de Desarrollo Principal
- **ux-ui-expert**: Especialista en experiencia de usuario y diseño visual para interfaces retail, wireframes, flujos de usuario, accesibilidad y design systems
- **flutter-expert**: Especialista Flutter/Dart para UI/UX multiplataforma, gestión de estado, navegación, diseño responsivo e integración con Supabase
- **supabase-expert**: Especialista Supabase para esquemas de BD, políticas RLS, Edge Functions, Auth, subscripciones Realtime y diseño de APIs
- **database-expert**: Especialista PostgreSQL para modelado de datos, indexación, restricciones, migraciones, optimización de rendimiento y consultas analíticas
- **technical-documentator**: Especialista en documentación técnica automática, gestión de contexto compartido, alineación de agentes y optimización de tokens para el equipo de desarrollo

## DIRECTIVA CRÍTICA: COORDINACIÓN DE AGENTES

### ⚠️ IMPORTANTE: Rol del Agente UX/UI ⚠️
**El agente UX/UI actúa ÚNICAMENTE como COORDINADOR y NO debe codificar directamente**

**ROL CORRECTO del UX/UI:**
- ✅ **COORDINADOR**: Orquesta y delega tareas a agentes especializados
- ✅ **PLANIFICADOR**: Define flujos, wireframes y especificaciones UX
- ✅ **SUPERVISOR**: Revisa y aprueba implementaciones de otros agentes
- ✅ **GESTOR DE ERRORES**: El usuario reporta TODOS los errores al UX/UI, quien coordina la solución con el agente apropiado
- ❌ **NO CODIFICA**: No debe usar herramientas Edit, Write, MultiEdit directamente

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

### 🧠 ÁRBOL DE DECISIÓN PARA COORDINACIÓN

```
¿El problema involucra DATOS de BD?
├─ SÍ ─── ¿También UI/UX?
│         ├─ SÍ → flutter-expert + supabase-expert
│         └─ NO → supabase-expert solo
└─ NO ─── ¿Solo UI/Navegación?
          ├─ SÍ → flutter-expert solo
          └─ NO → Analizar más dominio específico
```

### 📋 CHECKLIST OBLIGATORIO ANTES DE COORDINAR

**ANTES de delegar, UX/UI DEBE preguntarse:**
- [ ] ¿Este problema involucra mostrar datos de BD? → Agregar supabase-expert
- [ ] ¿Hay validación o persistencia? → Agregar database-expert  
- [ ] ¿Afecta UI/UX/navegación? → Agregar flutter-expert
- [ ] ¿Hay autenticación/permisos? → Agregar supabase-expert
- [ ] ¿Performance de consultas? → Agregar database-expert

**CRÍTICO:** Si se olvida un agente relevante, el problema se resolverá parcialmente y reaparecerán errores relacionados.

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

## MEJORES PRÁCTICAS PARA PROMPTS DE AGENTES

### ⚠️ PROBLEMA: Errores Repetidos por Prompts Deficientes ⚠️

**Errores comunes identificados:**
- Campo BD mismatch (`activo` vs `activa`)
- Constraint violations (unique keys, tipos incorrectos)
- API 400/23505 errors por datos mal formateados
- Mapeo incorrecto entre modelos Flutter y esquema BD

### 📋 TEMPLATE MEJORADO PARA PROMPTS

**ESTRUCTURA OBLIGATORIA para delegar tareas:**

```
CONTEXTO ESPECÍFICO:
- Esquema BD actual: [campos exactos, tipos, constraints]
- Archivos relacionados: [rutas específicas]
- Errores conocidos evitados: [lista de errores ya resueltos]
- Patrones establecidos: [convenciones del proyecto]

TAREA ESPECÍFICA:
- Objetivo medible: [comportamiento exacto esperado]
- Archivos a modificar: [rutas absolutas]
- Validaciones requeridas: [casos específicos a manejar]
- Integración: [cómo se conecta con código existente]

INFORMACIÓN CRÍTICA DE BD:
- Tabla: [nombre]
- Campos: [nombre: tipo, constraints]
- RLS policies: [si aplica]
- Unique constraints: [campos únicos]

CRITERIOS DE ÉXITO:
- Funcionalidad: [comportamiento observable]
- Manejo de errores: [errores específicos a capturar]
- UX: [mensajes al usuario]
- Testing: [cómo verificar que funciona]
```

### 🎯 INFORMACIÓN CONTEXTUAL CRÍTICA

**ESQUEMAS DE BD CONFIRMADOS:**
- `marcas`: campos con `activa` (boolean)
- `categorias`: campos con `activa` (boolean)
- `tallas`: campos con `activa` (boolean), unique constraint en `codigo`
- `colores`: campos con `activa` (boolean)
- `tiendas`: campos con `activa` (boolean)

**CONVENCIONES ESTABLECIDAS:**
- Usar `activa` (no `activo`) para campos boolean de estado
- Validación local antes de llamadas a BD
- Manejo específico de errores 400, 23505
- Mensajes user-friendly vs técnicos
- Case-insensitive comparisons para duplicados

**ERRORES YA RESUELTOS (NO repetir):**
- ✅ Campo `activo` → `activa` en repositories
- ✅ Error 400 en POST tallas por mapping incorrecto
- ✅ Error 23505 por constraint unique sin validación previa
- ✅ Tipos incorrectos: `'UNICA'` → `'INDIVIDUAL'`

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