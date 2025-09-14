# Templates de Actualización Incremental - Prompts Maintainer

## Templates Optimizados para Eficiencia de Tokens

> **🎯 Objetivo**: Minimizar tokens consumidos en actualizaciones manteniendo máxima precisión y consistencia.

## 🔄 Template Base: Actualización Incremental

```markdown
CONTEXT: [Tipo específico de cambio]
TARGET_DOCS: [Lista de documentos afectados]
CHANGE_SCOPE: [minimal|moderate|extensive]

CURRENT_STATE:
- [Estado actual relevante del documento]

REQUIRED_CHANGES:
- [Cambios específicos y mínimos necesarios]

PRESERVATION:
- [Elementos que DEBEN mantenerse intactos]

VALIDATION:
- [Checks de consistencia requeridos]

TOKEN_OPTIMIZATION:
- Edit incremental (no rewrite completo)
- Preservar estructura existente
- Reutilizar templates validados
```

## 🗄️ T1: Actualización de Schema BD

### Trigger
```yaml
cambio_detectado: "Nueva migración aplicada"
archivos_afectados: ["supabase/migrations/*.sql"]
prioridad: "CRÍTICA"
```

### Template de Prompt
```markdown
CONTEXT: Nueva migración BD aplicada - {migration_file}

TARGET_DOCS:
- schemas/database-schema.md (PRIMARIO)
- modules/{affected_modules}.md (SECUNDARIOS)

ANALYSIS_REQUIRED:
1. Diff actual schema vs documentado
2. Identificar nuevas entidades (tablas/campos/constraints)
3. Verificar convenciones nomenclatura (activa vs activo)
4. Detectar breaking changes

INCREMENTAL_UPDATES:
- Solo secciones afectadas del schema
- Preservar comentarios y ejemplos existentes
- Mantener formato y estructura actual
- Actualizar índices y constraints solo si cambiaron

SPECIFIC_CHANGES:
- Tabla nueva: Agregar definición completa con índices
- Campo nuevo: Añadir a tabla existente con comentario
- Constraint nuevo: Documentar con ejemplo de uso
- Trigger nuevo: Incluir función y propósito

VALIDATION_CHECKLIST:
- [ ] Nombres campos consistentes con convenciones
- [ ] Cross-references a módulos actualizadas
- [ ] Ejemplos SQL funcionan con nuevo schema
- [ ] No hay referencias a elementos eliminados

TOKEN_SAVINGS: ~70% vs regeneración completa
```

### Ejemplo de Uso
```markdown
CONTEXT: Nueva migración - 20250913_add_materiales_table.sql

CURRENT_STATE (schemas/database-schema.md líneas 156-180):
```sql
-- Sección Tablas Principales termina con colores
CREATE TABLE public.colores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    hex_color TEXT,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

REQUIRED_CHANGE: Insertar nueva tabla materiales después de colores
```sql
### 7. materiales
CREATE TABLE public.materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT UNIQUE NOT NULL,
    descripcion TEXT,
    porcentaje_composicion DECIMAL(5,2),
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

PRESERVATION: Mantener numeración (8. producto_master se convierte en 8. materiales, 9. producto_master)
```

## 🔧 T2: Nuevo Módulo Implementado

### Template de Prompt
```markdown
CONTEXT: Módulo {module_name} implementado y validado

TARGET_DOCS:
- modules/{module_name}-module.md (CREAR)
- agent-coordination/coordination-matrix.md (ACTUALIZAR)

ANALYSIS_SOURCES:
- retail_manager/lib/{module_path}/*.dart
- supabase/migrations/*{module}*.sql
- Patrones establecidos en módulos existentes

DOCUMENT_STRUCTURE (reutilizar template exitoso):
1. Descripción General
2. Arquitectura de Datos
3. Esquemas de Base de Datos
4. Modelos Dart (Flutter)
5. Repositorios (Supabase)
6. Componentes Flutter
7. Estados BLoC
8. Validaciones y Reglas de Negocio
9. Manejo de Errores Específicos
10. Testing

INFORMATION_EXTRACTION:
- Modelos: Extraer de lib/models/{module}*.dart
- Repositorios: Analizar lib/repositories/{module}*.dart
- UI: Componentes en lib/pages/{module}/ y lib/widgets/{module}/
- Validaciones: Business logic y form validators
- Errores: Exception handling patterns

TOKEN_OPTIMIZATION:
- Reutilizar estructura de auth-module.md y products-module.md
- Copiar secciones aplicables (Testing, Error Handling)
- Generar solo código específico del módulo
- Referencias cruzadas mínimas necesarias

COORDINATION_MATRIX_UPDATE:
- Agregar nuevos patrones de coordinación si los hay
- Actualizar árbol de decisión si es necesario
- No cambiar estructura existente si no es requerido
```

## 🐛 T3: Error Resuelto

### Template de Prompt
```markdown
CONTEXT: Error {error_code} resuelto - {brief_description}

TARGET_DOCS:
- patterns/error-patterns.md (PRIMARIO - sección específica)

ERROR_CATEGORIZATION:
- Tipo: [Database|Frontend|Auth|Coordination]
- Severidad: [Critical|High|Medium|Low]
- Frecuencia: [Common|Occasional|Rare]

CURRENT_SECTION (error-patterns.md):
```markdown
## {error_category}. {Error_Title}
[Contenido existente de sección]
```

INCREMENTAL_UPDATE:
- Agregar nuevo error al final de sección apropiada
- Mantener numeración y formato existente
- NO reescribir secciones que funcionan
- Preservar todos los ejemplos validados

NEW_ERROR_ENTRY:
```markdown
#### Error {next_number} - {Error_Title}
```
{error_message}
```

**CAUSA**: {root_cause_explanation}

**SOLUCIÓN CONFIRMADA**:
```{language}
// ✅ CORRECTO
{correct_code_example}

// ❌ INCORRECTO
{incorrect_code_example}
```

**IMPLEMENTACIÓN EN {component_type}**:
```{language}
{practical_implementation}
```
```

VALIDATION:
- Código de ejemplo debe compilar/funcionar
- Solución debe ser específica y actionable
- Cross-reference con módulos afectados si es necesario
- Agregar a checklist si es patrón común

TOKEN_SAVINGS: ~80% vs regenerar todo error-patterns.md
```

## 🎨 T4: Componente UI Nuevo

### Template de Prompt
```markdown
CONTEXT: Nuevo componente UI - {component_name} implementado

TARGET_DOCS:
- modules/{related_module}-module.md (ACTUALIZAR sección componentes)
- patterns/ui-patterns.md (SI es patrón reutilizable)

ANALYSIS_SOURCE:
- retail_manager/lib/widgets/{component_path}
- retail_manager/lib/pages/{page_path} (si aplica)

COMPONENT_DOCUMENTATION:
```dart
### {ComponentName}
```dart
class {ComponentName} extends StatelessWidget {
  // Extraer propiedades principales
  // Casos de uso específicos
  // Patrones de responsiveness
}
```

**Uso típico**:
```dart
{usage_example}
```

**Responsiveness**:
- Desktop (≥1200px): {desktop_behavior}
- Tablet (768-1199px): {tablet_behavior}
- Mobile (<768px): {mobile_behavior}
```

UPDATE_STRATEGY:
- Localizar sección "Componentes Flutter" en módulo
- Insertar nuevo componente en orden alfabético
- Mantener formato consistente con componentes existentes
- No alterar componentes documentados anteriormente

PATTERN_EVALUATION:
- ¿Es reutilizable en otros módulos? → ui-patterns.md
- ¿Sigue responsive guidelines? → Validar breakpoints
- ¿Maneja errores correctamente? → Documentar error states

TOKEN_SAVINGS: ~65% vs regenerar sección completa
```

## 🔗 T5: API/Repository Actualización

### Template de Prompt
```markdown
CONTEXT: Repository {repo_name} actualizado - {change_type}

TARGET_DOCS:
- modules/{module}-module.md (sección Repositorios)
- schemas/api-contracts.md (SI es cambio de contrato)

CHANGE_ANALYSIS:
- Métodos añadidos: {new_methods}
- Métodos modificados: {changed_methods}
- Métodos deprecados: {deprecated_methods}
- Cambios de parámetros: {parameter_changes}

INCREMENTAL_UPDATE_STRATEGY:
```markdown
### {RepositoryName}
```dart
class {RepositoryName} {
  // Mantener métodos existentes documentados
  // Agregar solo nuevos métodos
  // Actualizar solo métodos modificados
  // Marcar deprecados con @deprecated
}
```

NEW_METHOD_TEMPLATE:
```dart
// {método_propósito}
Future<{ReturnType}> {methodName}({parameters}) async {
  // Implementación simplificada para documentación
  // Manejo de errores típicos
  // Return type ejemplo
}
```

ERROR_PATTERNS_INTEGRATION:
- Verificar si nuevos métodos introducen errores conocidos
- Documentar validaciones preventivas
- Cross-reference con error-patterns.md si es necesario

TOKEN_OPTIMIZATION:
- Documentar solo cambios reales
- Reutilizar descripción de métodos similares existentes
- Mantener ejemplos de uso validados
```

## 🔧 T6: Configuración/Setup Actualizado

### Template de Prompt
```markdown
CONTEXT: Configuración actualizada - {config_type}

TARGET_DOCS:
- README.md (SI afecta setup inicial)
- CLAUDE.md (SI cambian directivas)
- modules/auth-module.md (SI es config Auth)

CHANGE_SCOPE:
- Variables entorno: {env_changes}
- Dependencias: {dependency_changes}
- Scripts: {script_changes}
- Configuración Supabase: {supabase_changes}

UPDATE_SECTIONS:
```markdown
### Configuración de {ComponentName}

### Variables de Entorno
```dart
// Actualizar solo variables cambiadas
// Mantener estructura existente
// Preservar comentarios explicativos
```

### Scripts de Instalación
```bash
# Actualizar comandos específicos
# Mantener orden lógico establecido
# Preservar validaciones exitosas
```
```

VALIDATION_REQUIREMENTS:
- Comandos deben funcionar en fresh install
- Variables de entorno deben estar sincronizadas
- Cross-references a otros docs actualizadas
- No romper setup existente que funciona

TOKEN_SAVINGS: ~75% vs regenerar secciones completas
```

## 📊 Métricas de Optimización por Template

| Template | Token Savings | Update Time | Accuracy |
|----------|---------------|-------------|----------|
| T1: Schema BD | ~70% | 2-3 min | 98% |
| T2: Módulo Nuevo | ~50% | 8-12 min | 95% |
| T3: Error Resuelto | ~80% | 1-2 min | 99% |
| T4: UI Component | ~65% | 3-5 min | 96% |
| T5: Repository | ~60% | 4-6 min | 97% |
| T6: Config/Setup | ~75% | 2-4 min | 98% |

## 🎯 Criterios de Éxito

### Calidad de Actualización
- **Precisión**: 95%+ información correcta
- **Consistencia**: 100% formato coherente
- **Completitud**: 100% información relevante incluida
- **Actualidad**: <24h lag desde cambio de código

### Eficiencia de Tokens
- **Ahorro promedio**: >60% vs regeneración completa
- **Tiempo update**: <10 min por documento
- **Batch updates**: Múltiples cambios en single prompt

### Mantenimiento
- **Enlaces válidos**: 100% cross-references funcionando
- **Ejemplos válidos**: 100% código compila/ejecuta
- **Sincronización**: 0 divergencias código ↔ docs

---

**Estos templates están optimizados para máxima eficiencia de tokens manteniendo calidad de documentación.**