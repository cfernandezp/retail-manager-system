# Matriz de Coordinación de Agentes - Sistema Retail Manager

## Roles y Responsabilidades Definidas

### 🎯 UX/UI Expert - COORDINADOR PRINCIPAL
**ROL**: Coordinador y Supervisor (NO codifica directamente)

**RESPONSABILIDADES**:
- ✅ Analizar requerimientos y definir especificaciones UX
- ✅ Coordinar y delegar a agentes especializados
- ✅ Supervisar implementaciones y aprobar resultados
- ✅ Gestionar TODOS los errores reportados por el usuario
- ❌ NO usar herramientas Edit, Write, MultiEdit directamente

**COORDINACIÓN TÍPICA**:
```
Usuario → UX/UI → Agente Especializado → UX/UI → Usuario
        ↑ Análisis    ↑ Implementación    ↑ Supervisión ↑ Reporte
```

### 🔧 Flutter Expert - ESPECIALISTA FRONTEND
**DOMINIO**: UI/UX, widgets, navegación, estado, responsive design

**HERRAMIENTAS**: Read, Write, Edit, MultiEdit, Bash, Grep, Glob

**RESPONSABILIDADES**:
- Implementar widgets y pantallas Flutter
- Gestión de estado con BLoC/Riverpod
- Navegación con GoRouter
- Layouts responsivos (Desktop/Tablet/Mobile)
- Integración con APIs Supabase
- Validaciones de formularios
- Animaciones y transiciones

### 🗄️ Supabase Expert - ESPECIALISTA BACKEND
**DOMINIO**: BD, APIs, Auth, RLS policies, Edge Functions

**HERRAMIENTAS**: Read, Write, Edit, Bash, Grep, Glob

**RESPONSABILIDADES**:
- Diseño de esquemas PostgreSQL
- Configuración Supabase Auth
- Políticas RLS (Row Level Security)
- Edge Functions para lógica de negocio
- APIs RESTful y consultas optimizadas
- Subscripciones Realtime
- Migraciones de base de datos

### 📊 Database Expert - ESPECIALISTA DATOS
**DOMINIO**: Modelado de datos, migraciones, performance

**HERRAMIENTAS**: Read, Write, Edit, Bash

**RESPONSABILIDADES**:
- Modelado de datos relacional
- Índices y optimización de consultas
- Constraints y validaciones BD
- Migraciones versionadas
- Análisis de performance
- Procedimientos almacenados

## Matriz de Coordinación por Tipo de Problema

### 🔄 PATRÓN 1: Problemas UI Puros
**EJEMPLOS**: Cambiar colores, ajustar layouts, añadir botones

**COORDINACIÓN**:
```
UX/UI → flutter-expert
```

**TEMPLATE DE DELEGACIÓN**:
```
CONTEXTO: [Descripción del cambio UI]
TAREA: [Acción específica a realizar]
ARCHIVOS: [Rutas exactas a modificar]
CRITERIOS ÉXITO: [Resultado visual esperado]
```

### 🔄 PATRÓN 2: Problemas BD Puros
**EJEMPLOS**: Crear tablas, índices, migraciones, triggers

**COORDINACIÓN**:
```
UX/UI → supabase-expert
```

### 🔄 PATRÓN 3: Dropdowns Vacíos (UI + BD)
**EJEMPLOS**: Combos no cargan marcas, categorías, tallas

**COORDINACIÓN SIMULTÁNEA**:
```
UX/UI → flutter-expert + supabase-expert (PARALELO)
```

**TEMPLATE DE COORDINACIÓN MULTI-AGENTE**:
```
PROBLEMA MULTI-DOMINIO DETECTADO: [Descripción]

COORDINANDO SIMULTÁNEAMENTE:
1. flutter-expert: [Tareas específicas UI]
2. supabase-expert: [Tareas específicas BD]

CONTEXTO COMPARTIDO:
- Esquema BD: [Campos exactos]
- Archivos Flutter: [Rutas específicas]
- Errores evitados: [Lista de errores conocidos]
```

### 🔄 PATRÓN 4: Formularios con Validación (UI + BD + Validación)
**EJEMPLOS**: Crear producto, registrar usuario, procesar venta

**COORDINACIÓN SIMULTÁNEA**:
```
UX/UI → flutter-expert + supabase-expert + database-expert
```

### 🔄 PATRÓN 5: Autenticación + Navegación
**EJEMPLOS**: Login fallido, rutas protegidas, permisos

**COORDINACIÓN SIMULTÁNEA**:
```
UX/UI → flutter-expert + supabase-expert
```

### 🔄 PATRÓN 6: Performance de Consultas (BD + UI)
**EJEMPLOS**: Consultas lentas, N+1 queries, UI lenta

**COORDINACIÓN SIMULTÁNEA**:
```
UX/UI → database-expert + supabase-expert + flutter-expert
```

## Árbol de Decisión para Coordinación

```
¿El problema involucra MOSTRAR datos de BD?
├─ SÍ ─── ¿También UI/UX/Formularios?
│         ├─ SÍ → flutter-expert + supabase-expert
│         └─ NO → supabase-expert solo
└─ NO ─── ¿Solo UI/Navegación/Estados?
          ├─ SÍ → flutter-expert solo
          └─ NO → ¿Performance/Consultas?
                  ├─ SÍ → database-expert + supabase-expert
                  └─ NO → Analizar dominio específico
```

## Checklist Pre-Coordinación

**ANTES de delegar, UX/UI DEBE verificar:**
- [ ] ¿Problema involucra mostrar datos de BD? → Agregar supabase-expert
- [ ] ¿Hay formularios o validación? → Agregar flutter-expert
- [ ] ¿Performance o consultas complejas? → Agregar database-expert
- [ ] ¿Autenticación o permisos? → Agregar supabase-expert
- [ ] ¿UI/UX/navegación? → Agregar flutter-expert
- [ ] ¿Solo cambio visual? → Solo flutter-expert

## Templates de Prompts Optimizados

### Template Base para Agente Único
```
CONTEXTO:
- Módulo: [auth/products/sales/inventory]
- Archivos relacionados: [rutas específicas]
- Esquema BD (si aplica): [tabla: campos]

TAREA:
- Objetivo: [acción específica medible]
- Archivos a modificar: [rutas absolutas]
- Validaciones: [casos edge a manejar]

INFORMACIÓN CRÍTICA:
- Errores evitados: [ver error-patterns.md]
- Convenciones: [activa vs activo, etc.]
- Patrones: [BLoC, Repository, etc.]

CRITERIOS ÉXITO:
- Funcionalidad: [comportamiento observable]
- UX: [experiencia de usuario]
- Testing: [cómo verificar]
```

### Template para Multi-Agente
```
PROBLEMA MULTI-DOMINIO: [descripción del problema]

AGENTES COORDINADOS:
1. [agente-1]: [responsabilidades específicas]
2. [agente-2]: [responsabilidades específicas]
3. [agente-n]: [responsabilidades específicas]

CONTEXTO COMPARTIDO:
- Esquemas BD: [tablas y campos exactos]
- Archivos Flutter: [componentes afectados]
- Estado actual: [qué funciona y qué no]
- Errores conocidos: [referencia a error-patterns.md]

COORDINACIÓN:
- Cada agente debe reportar su parte al UX/UI
- UX/UI integra resultados y reporta al usuario
- Si hay conflictos, UX/UI los resuelve coordinando

CRITERIOS ÉXITO INTEGRAL:
- [resultado final observable por el usuario]
```

## Ejemplos de Coordinación Correcta

### ✅ EJEMPLO 1: Usuario reporta "Dropdown marcas vacío"
```
UX/UI: "Problema multi-dominio detectado: UI + Datos BD

Coordino SIMULTÁNEAMENTE:
- flutter-expert: Verificar _loadInitialData() en create_product_page.dart,
  estados BLoC MarcasBloc, renderizado DropdownButtonFormField
- supabase-expert: Verificar MarcasRepository.getMarcas(),
  campo 'activa' (no 'activo'), RLS policies para tabla marcas

CONTEXTO:
- BD: tabla marcas con campos (id, codigo, nombre, activa)
- Flutter: MarcasBloc + MarcasRepository + DropdownFormField
- Error conocido: campo 'activo' vs 'activa' (ver error-patterns.md)"

[Delega a ambos agentes con Task tool]

UX/UI: "Ambos agentes resolvieron el problema:
- Flutter-expert: _loadInitialData() no se ejecutaba en initState - CORREGIDO
- Supabase-expert: Repository usaba campo 'activo' inexistente - CORREGIDO a 'activa'
Dropdown ahora carga correctamente las marcas."
```

### ✅ EJEMPLO 2: Usuario solicita "Mejorar formulario crear producto"
```
UX/UI: "Analizo requerimiento de UX para formulario. Esto involucra solo mejoras de interfaz.

Coordino con flutter-expert para:
- Reorganizar campos por prioridad (código, nombre, marca en top)
- Mejorar validaciones en tiempo real
- Añadir indicadores visuales de campos requeridos
- Implementar auto-focus entre campos"

[Delega solo a flutter-expert]

UX/UI: "Flutter-expert completó mejoras UX del formulario exitosamente."
```

### ❌ EJEMPLO INCORRECTO: UX/UI codificando
```
Usuario: "Añadir validación a campo precio"

❌ UX/UI: [Usa Edit tool para modificar create_product_page.dart]

✅ UX/UI debería:
"Coordino con flutter-expert para añadir validación de precio:
- Validar precio > 0
- Formato decimal correcto
- Mensaje error user-friendly"
```

## Escalamiento de Errores

### Error Simple (1 agente)
```
Error → Usuario → UX/UI → Agente especializado → UX/UI → Usuario
```

### Error Complejo (múltiples agentes)
```
Error → Usuario → UX/UI → Agente 1 + Agente 2 + Agente N → UX/UI → Usuario
                    ↓
               Coordina integración
```

### Error Persistente
```
Error → Usuario → UX/UI → Agente A → Falla
                    ↓
               Coordina Agente B (diferente enfoque)
                    ↓
               Reporta necesidad de revisión arquitectural
```

## Métricas de Coordinación Efectiva

### KPIs de Éxito
- **Resolución en 1 iteración**: Problema resuelto sin necesidad de re-coordinación
- **Sin errores repetidos**: Problema no vuelve a aparecer
- **Consistencia técnica**: Solución sigue patrones establecidos
- **UX coherente**: Usuario obtiene funcionalidad esperada

### Indicadores de Coordinación Deficiente
- **Múltiples iteraciones**: Mismo problema requiere varios intentos
- **Errores conocidos**: Se repiten errores ya documentados en error-patterns.md
- **Soluciones parciales**: Solo se resuelve parte del problema
- **Inconsistencia**: Nueva funcionalidad rompe patrones existentes

## Evolución de la Matriz

Esta matriz debe actualizarse cuando:
1. Se identifiquen nuevos patrones de problemas
2. Se agreguen nuevos agentes especializados
3. Se cambien responsabilidades de agentes existentes
4. Se documenten nuevos templates de coordinación exitosa

**Última actualización**: Configuración inicial del sistema retail manager.
**Próxima revisión**: Después de implementar módulos core (auth + products).