# Prompts Directory - Sistema Retail Manager

> **📋 Documentación de Especificaciones para Agentes IA**
>
> Este directorio contiene toda la documentación estructurada para que los agentes IA especializados comprendan el contexto, responsabilidades y patrones del proyecto.

## 🎯 Objetivo

Proporcionar **contexto unificado y consistente** para todos los agentes IA que trabajen en el sistema retail manager, evitando:

- ❌ Errores repetidos (campo `activo` vs `activa`)
- ❌ Implementaciones inconsistentes
- ❌ Coordinación deficiente entre agentes
- ❌ Pérdida de contexto entre sesiones

## 📁 Estructura del Directorio

```
prompts/
├── README.md                           # Este archivo
├── modules/                            # Especificaciones de módulos
│   ├── auth-module.md                  # ✅ Sistema autenticación completo
│   ├── products-module.md              # ✅ Gestión productos multi-variante
│   ├── inventory-module.md             # 🔄 [Pendiente]
│   ├── sales-module.md                 # 🔄 [Pendiente]
│   └── reports-module.md               # 🔄 [Pendiente]
├── schemas/                            # Esquemas de datos validados
│   ├── database-schema.md              # ✅ Esquemas PostgreSQL confirmados
│   ├── api-contracts.md                # 🔄 [Pendiente]
│   └── ui-components.md                # 🔄 [Pendiente]
├── patterns/                           # Patrones y errores conocidos
│   ├── error-patterns.md               # ✅ Errores resueltos + soluciones
│   ├── ui-patterns.md                  # 🔄 [Pendiente]
│   └── data-patterns.md                # 🔄 [Pendiente]
└── agent-coordination/                 # Coordinación entre agentes
    ├── coordination-matrix.md          # ✅ Matriz de responsabilidades
    ├── flutter-expert.md               # 🔄 [Pendiente]
    ├── supabase-expert.md              # 🔄 [Pendiente]
    └── database-expert.md              # 🔄 [Pendiente]
```

## 🔥 Documentos Críticos (LEER PRIMERO)

### 1. [coordination-matrix.md](agent-coordination/coordination-matrix.md)
**OBLIGATORIO para UX/UI Expert**
- Roles y responsabilidades de cada agente
- Patrones de coordinación por tipo de problema
- Templates de prompts optimizados
- Árbol de decisión para delegación

### 2. [error-patterns.md](patterns/error-patterns.md)
**OBLIGATORIO para todos los agentes**
- Errores ya resueltos que NO deben repetirse
- Campo `activa` vs `activo` (BD)
- Errores 400/23505 y sus causas
- Templates de manejo de errores

### 3. [database-schema.md](schemas/database-schema.md)
**OBLIGATORIO para supabase-expert y database-expert**
- Esquemas PostgreSQL validados en desarrollo
- Convenciones de nomenclatura
- Constraints y triggers confirmados
- Comandos de mantenimiento

## 🎭 Agentes y sus Documentos

### 🎯 UX/UI Expert (COORDINADOR)
**Documentos principales**:
- [`coordination-matrix.md`](agent-coordination/coordination-matrix.md) - **CRÍTICO**
- [`error-patterns.md`](patterns/error-patterns.md) - Para gestión de errores
- Todos los módulos para entender funcionalidades

**Responsabilidades**:
- Coordinar y delegar (NO codificar directamente)
- Gestionar errores reportados por usuario
- Supervisar implementaciones de agentes especializados

### 🔧 Flutter Expert
**Documentos principales**:
- [`auth-module.md`](modules/auth-module.md) - Autenticación y navegación
- [`products-module.md`](modules/products-module.md) - UI de productos
- [`error-patterns.md`](patterns/error-patterns.md) - Errores de frontend
- [`database-schema.md`](schemas/database-schema.md) - Para mapping correcto

**Responsabilidades**:
- Implementar UI/UX con Flutter
- BLoC/Riverpod para gestión de estado
- Layouts responsivos (Desktop/Tablet/Mobile)
- Validaciones de formularios

### 🗄️ Supabase Expert
**Documentos principales**:
- [`database-schema.md`](schemas/database-schema.md) - **CRÍTICO**
- [`auth-module.md`](modules/auth-module.md) - RLS policies
- [`products-module.md`](modules/products-module.md) - APIs de productos
- [`error-patterns.md`](patterns/error-patterns.md) - Errores BD

**Responsabilidades**:
- APIs y consultas Supabase
- RLS policies y Auth
- Migraciones de BD
- Edge Functions

### 📊 Database Expert
**Documentos principales**:
- [`database-schema.md`](schemas/database-schema.md) - **CRÍTICO**
- [`error-patterns.md`](patterns/error-patterns.md) - Errores SQL
- Todos los módulos para entender relaciones de datos

**Responsabilidades**:
- Modelado de datos relacional
- Optimización de consultas
- Índices y constraints
- Procedimientos almacenados

## 🚀 Cómo Usar Esta Documentación

### Para Nuevos Agentes
1. **Leer OBLIGATORIO**: `coordination-matrix.md` + `error-patterns.md`
2. **Estudiar dominio**: Módulos relacionados con tu especialidad
3. **Validar esquemas**: `database-schema.md` para contexto de datos
4. **Seguir patrones**: No repetir errores ya resueltos

### Para Coordinación Multi-Agente
1. **UX/UI analiza** el problema usando `coordination-matrix.md`
2. **Identifica agentes** necesarios según árbol de decisión
3. **Genera prompts** usando templates optimizados
4. **Delega con contexto** específico de cada agente

### Para Resolución de Errores
1. **Consultar primero** `error-patterns.md`
2. **Verificar si ya fue resuelto** antes
3. **Aplicar solución validada** si existe
4. **Documentar nuevo error** si es primera vez

## ⚡ Templates de Prompt Rápidos

### Template Agente Único
```markdown
CONTEXTO: [Módulo específico]
TAREA: [Acción medible]
ARCHIVOS: [Rutas específicas]
ERRORES EVITADOS: [Ver error-patterns.md]
CRITERIOS ÉXITO: [Resultado observable]
```

### Template Multi-Agente
```markdown
PROBLEMA MULTI-DOMINIO: [Descripción]
AGENTES COORDINADOS:
- agente-1: [responsabilidades específicas]
- agente-2: [responsabilidades específicas]
CONTEXTO COMPARTIDO: [Esquemas, archivos, estado]
CRITERIOS ÉXITO INTEGRAL: [Resultado final]
```

## 📈 Beneficios Documentados

### Consistencia Técnica
- **Campo boolean**: Siempre `activa` (no `activo`)
- **Validaciones**: Duplicados antes de INSERT
- **Mapping**: Modelo ↔ JSON correcto
- **Responsive**: Breakpoints estandarizados

### Eficiencia de Desarrollo
- **Errores conocidos**: Soluciones pre-documentadas
- **Coordinación**: Prompts optimizados para cada caso
- **Onboarding**: Nuevos agentes entienden contexto rápidamente
- **Trazabilidad**: Decisiones técnicas documentadas

### Calidad del Código
- **Patrones establecidos**: BLoC, Repository, etc.
- **Error handling**: Consistente en todo el sistema
- **Testing**: Casos de prueba estandarizados
- **Performance**: Optimizaciones documentadas

## 🔄 Mantenimiento

### Actualizar Documentación Cuando:
- ✅ Se resuelva un error nuevo → `error-patterns.md`
- ✅ Se agregue un módulo → `modules/`
- ✅ Se cambie un esquema → `database-schema.md`
- ✅ Se identifique nuevo patrón → `patterns/`
- ✅ Se modifiquen responsabilidades → `coordination-matrix.md`

### Responsable del Mantenimiento
- **UX/UI Expert**: Coordina actualizaciones
- **Agente que resuelve**: Documenta la solución
- **Usuario**: Puede solicitar mejoras a la documentación

## 🎯 Estado Actual

### ✅ Completado (v1.0)
- Estructura base de directorios
- Módulos core: auth + products
- Esquemas BD validados
- Patrones de errores conocidos
- Matriz de coordinación

### 🔄 En Desarrollo
- Módulos restantes: inventory, sales, reports
- Patrones UI específicos
- Contratos API detallados
- Guías específicas por agente

### 📋 Próximos Pasos
1. Probar coordinación con casos reales
2. Refinar templates basado en resultados
3. Expandir documentación de módulos
4. Crear guías de troubleshooting avanzado

---

> **💡 Consejo**: Este directorio es una **herramienta viva**. Manténlo actualizado para maximizar la eficiencia de los agentes IA y la calidad del código generado.

**Última actualización**: 2025-09-13
**Versión**: 1.0.0
**Maintainer**: UX/UI Coordination Team