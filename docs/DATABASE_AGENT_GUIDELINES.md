# 🛡️ LINEAMIENTOS CRÍTICOS PARA AGENTE DE BASE DE DATOS

## 🎯 PRINCIPIOS FUNDAMENTALES

### ⚠️ REGLA #1: PRESERVACIÓN DE DATOS
**NUNCA eliminar datos existentes sin confirmación explícita del usuario**
- ❌ `DELETE FROM categorias;` sin avisar
- ✅ Proponer migración, explicar impacto, pedir confirmación

### 🔍 REGLA #2: VALIDACIÓN PREVIA OBLIGATORIA
**SIEMPRE consultar estado actual antes de modificar**
```sql
-- CORRECTO: Verificar antes de insertar
SELECT id, nombre FROM categorias ORDER BY created_at;

-- Luego decidir estrategia según datos existentes
```

### 📝 REGLA #3: MIGRACIONES INCREMENTALES
**Evitar conflictos entre múltiples migraciones de datos**
- ✅ Una migración = Un propósito específico
- ❌ Múltiples inserts en diferentes migraciones para la misma tabla

## 🔧 PROTOCOLO DE TRABAJO OBLIGATORIO

### **PASO 1: DIAGNÓSTICO**
```sql
-- Template obligatorio para empezar cualquier trabajo de BD
SELECT 'DIAGNÓSTICO INICIAL' as fase;

-- 1. Verificar datos existentes
SELECT COUNT(*) as total,
       array_agg(nombre) as ejemplos
FROM categorias
LIMIT 5;

-- 2. Verificar migraciones aplicadas
SELECT version
FROM supabase_migrations.schema_migrations
WHERE version LIKE '%categoria%'
ORDER BY version DESC;
```

### **PASO 2: ANÁLISIS DE IMPACTO**
```sql
-- 3. Identificar dependencias
SELECT table_name, constraint_name
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
AND table_name = 'categorias';

-- 4. Verificar datos relacionados
SELECT 'productos_master' as tabla, COUNT(*) as registros_afectados
FROM productos_master
WHERE categoria_id IN (SELECT id FROM categorias);
```

### **PASO 3: ESTRATEGIA ESPECÍFICA**
```yaml
# Decidir estrategia según hallazgos:

CASO A - Tabla vacía:
  accion: "INSERT directo con ON CONFLICT DO NOTHING"
  riesgo: "Bajo"

CASO B - Datos incorrectos:
  accion: "UPDATE campos específicos + INSERT faltantes"
  riesgo: "Medio - Validar dependencias"

CASO C - Datos mezclados:
  accion: "Migración limpia con respaldo + comunicación al usuario"
  riesgo: "Alto - Requiere aprobación"
```

## 🚨 DETECCIÓN DE CONFLICTOS

### **Señales de Alerta - PARAR INMEDIATAMENTE:**
1. **Datos inconsistentes detectados**:
   ```sql
   -- Ejemplo: categorías que parecen materiales
   SELECT nombre FROM categorias
   WHERE nombre IN ('Polyester', 'Algodón', 'Lycra');
   ```

2. **Múltiples migraciones para misma tabla**:
   ```bash
   ls supabase/migrations/ | grep categoria
   # Si hay más de 1 resultado = CONFLICTO POTENCIAL
   ```

3. **Foreign keys huérfanas**:
   ```sql
   SELECT COUNT(*) as registros_huerfanos
   FROM productos_master p
   LEFT JOIN categorias c ON p.categoria_id = c.id
   WHERE c.id IS NULL;
   ```

## 📋 TEMPLATES OBLIGATORIOS

### **Template: Migración de Datos Segura**
```sql
-- =====================================================
-- MIGRACIÓN: [Descripción específica]
-- FECHA: [YYYY-MM-DD HH:MM:SS]
-- IMPACTO: [Bajo/Medio/Alto]
-- VALIDACIÓN PREVIA: [Qué se verificó]
-- =====================================================

-- PASO 1: Verificación de estado actual
DO $$
BEGIN
    RAISE NOTICE '=== ESTADO PREVIO ===';
    RAISE NOTICE 'Registros existentes: %', (SELECT COUNT(*) FROM tabla_objetivo);
    -- Mostrar muestra de datos actuales
END $$;

-- PASO 2: Respaldo de datos críticos (si aplica)
CREATE TEMP TABLE backup_tabla_objetivo AS
SELECT * FROM tabla_objetivo;

-- PASO 3: Operación principal con manejo de errores
BEGIN;
    -- Operación aquí

    -- Verificación inmediata
    IF (SELECT COUNT(*) FROM tabla_objetivo) = 0 THEN
        RAISE EXCEPTION 'ERROR: Tabla quedó vacía - ROLLBACK automático';
    END IF;
COMMIT;

-- PASO 4: Verificación post-migración
DO $$
BEGIN
    RAISE NOTICE '=== ESTADO POST-MIGRACIÓN ===';
    RAISE NOTICE 'Registros finales: %', (SELECT COUNT(*) FROM tabla_objetivo);
    RAISE NOTICE 'Ejemplos: %', (SELECT string_agg(nombre, ', ') FROM tabla_objetivo LIMIT 3);
END $$;
```

### **Template: Query de Investigación**
```sql
-- =====================================================
-- INVESTIGACIÓN: [Propósito específico]
-- TABLA: [nombre_tabla]
-- =====================================================

-- 1. Conteo y estructura
SELECT
    COUNT(*) as total_registros,
    COUNT(DISTINCT campo_clave) as valores_unicos,
    MIN(created_at) as primer_registro,
    MAX(created_at) as ultimo_registro
FROM tabla_objetivo;

-- 2. Muestra de datos con contexto
SELECT
    id,
    campo_importante,
    created_at,
    'Origen: ' || CASE
        WHEN created_at < '2025-09-14' THEN 'Datos originales'
        ELSE 'Datos de migración'
    END as contexto
FROM tabla_objetivo
ORDER BY created_at DESC
LIMIT 10;

-- 3. Detección de anomalías
SELECT
    'ANOMALÍA DETECTADA' as alerta,
    campo,
    COUNT(*) as veces_repetido
FROM tabla_objetivo
GROUP BY campo
HAVING COUNT(*) > 1;
```

## 🔄 FLUJO DE TRABAJO MEJORADO

### **ANTES de cualquier modificación:**
1. **Ejecutar script de diagnóstico completo**
2. **Documentar hallazgos en comentarios**
3. **Proponer estrategia específica al usuario**
4. **Esperar confirmación explícita**

### **DURANTE la modificación:**
1. **Usar transacciones con verificaciones**
2. **Logs detallados de cada paso**
3. **Verificación inmediata de resultados**

### **DESPUÉS de la modificación:**
1. **Verificación de integridad completa**
2. **Actualización de documentación**
3. **Reporte de cambios al usuario**

## 🎯 CASOS ESPECÍFICOS RETAIL MANAGER

### **Categorías de Medias - Estándar Definido:**
```sql
-- CATEGORÍAS CORRECTAS Y DEFINITIVAS:
INSERT INTO categorias (nombre, descripcion, prefijo_sku) VALUES
('Medias de Fútbol', 'Medias deportivas para fútbol', 'MFU'),
('Medias Deportivas', 'Medias para actividades deportivas', 'MDE'),
('Medias Casuales', 'Medias para uso diario', 'MCA'),
('Medias Ejecutivas', 'Medias formales para oficina', 'MEJ'),
('Calcetines Deportivos', 'Calcetines para deportes', 'CDE'),
('Calcetines Casuales', 'Calcetines uso diario', 'CCA'),
('Medias de Compresión', 'Medias terapéuticas', 'MCO'),
('Medias Térmicas', 'Medias para clima frío', 'MTE'),
('Calcetines Tobilleros', 'Calcetines cortos', 'CTO'),
('Ropa Interior', 'Ropa interior general', 'RIN');
```

### **Validación de Coherencia:**
```sql
-- Script para validar coherencia del negocio
SELECT
    CASE
        WHEN nombre LIKE '%Media%' OR nombre LIKE '%Calcetín%' THEN '✅ Coherente'
        WHEN nombre IN ('Polyester', 'Algodón', 'Lycra') THEN '❌ Es material, no categoría'
        ELSE '⚠️ Revisar manualmente'
    END as validacion,
    nombre
FROM categorias;
```

## 🚫 PROHIBICIONES ABSOLUTAS

1. **NUNCA** `DELETE` sin respaldo
2. **NUNCA** múltiples migraciones de datos para misma tabla en mismo día
3. **NUNCA** insertar datos sin `ON CONFLICT` strategy
4. **NUNCA** ignorar foreign key constraints
5. **NUNCA** modificar datos sin documentar el cambio

## ✅ BUENAS PRÁCTICAS OBLIGATORIAS

1. **SIEMPRE** usar `ON CONFLICT DO NOTHING/UPDATE`
2. **SIEMPRE** incluir `created_at` y `updated_at`
3. **SIEMPRE** validar con queries `SELECT` antes de modificar
4. **SIEMPRE** documentar el propósito de la migración
5. **SIEMPRE** incluir estrategia de rollback

---

> **RECORDATORIO**: Estos lineamientos son obligatorios para mantener la integridad de datos y evitar confusiones como la que ocurrió con categorías vs materiales.