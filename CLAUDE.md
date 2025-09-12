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

Este repositorio utiliza 3 agentes especializados optimizados para trabajo eficiente:

### Equipo de Desarrollo Principal
- **ux-ui-expert**: Especialista en experiencia de usuario y diseño visual para interfaces retail, wireframes, flujos de usuario, accesibilidad y design systems
- **flutter-expert**: Especialista Flutter/Dart para UI/UX multiplataforma, gestión de estado, navegación, diseño responsivo e integración con Supabase
- **supabase-expert**: Especialista Supabase para esquemas de BD, políticas RLS, Edge Functions, Auth, subscripciones Realtime y diseño de APIs
- **database-expert**: Especialista PostgreSQL para modelado de datos, indexación, restricciones, migraciones, optimización de rendimiento y consultas analíticas

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