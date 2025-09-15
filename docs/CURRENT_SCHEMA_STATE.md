# ESTADO ACTUAL DEL ESQUEMA DE BASE DE DATOS

> **IMPORTANTE**: Este archivo documenta el estado REAL de las tablas tras la limpieza de migraciones.
>
> **Actualizado**: 2025-09-15 (Esquema limpio con 7 migraciones)
> **Propósito**: Estado autoritativo tras eliminación de 35+ migraciones problemáticas
> **Método**: Migraciones limpias regeneradas desde estado real de BD
> **Estado**: ✅ LIMPIO - Todas las inconsistencias resueltas

## 📋 TABLAS PRINCIPALES Y CAMPOS CONFIRMADOS

### 🏷️ TABLAS DE CATÁLOGO

#### `marcas`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(100) NOT NULL UNIQUE
descripcion     TEXT
logo_url        TEXT
activo          BOOLEAN DEFAULT true  -- ✅ CONFIRMADO: campo 'activo'
prefijo_sku     VARCHAR(3) NOT NULL UNIQUE
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO (relrowsecurity = false)
-- Datos semilla: 5 marcas activas
```

#### `categorias`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(100) NOT NULL UNIQUE
descripcion     TEXT
prefijo_sku     VARCHAR(3) NOT NULL UNIQUE
activo          BOOLEAN DEFAULT true  -- ✅ CONFIRMADO: campo 'activo'
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO (relrowsecurity = false)
-- Datos semilla: 5 categorías activas
```

#### `tallas`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
codigo          VARCHAR(20) NOT NULL UNIQUE
tipo            tipo_talla NOT NULL  -- ENUM: 'RANGO' | 'UNICA'
talla_min       INTEGER  -- Para rangos
talla_max       INTEGER  -- Para rangos
talla_unica     INTEGER  -- Para tallas únicas
orden_display   INTEGER DEFAULT 0
activo          BOOLEAN DEFAULT true  -- ✅ CONFIRMADO: campo 'activo' (no 'activa')
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO (relrowsecurity = false)
-- Constraint: check_talla_tipo
-- Datos actuales: 16 tallas activas
```

#### `colores`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(50) NOT NULL UNIQUE
codigo_hex      VARCHAR(7)  -- #FF0000
prefijo_sku     VARCHAR(3) NOT NULL UNIQUE
activo          BOOLEAN DEFAULT true  -- ✅ CONFIRMADO: campo 'activo' (no 'activa')
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: HABILITADO (relrowsecurity = true) - ⚠️ DIFERENTE a otras tablas
```

#### `materiales`
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
nombre          VARCHAR(100) NOT NULL UNIQUE
descripcion     TEXT
codigo_abrev    VARCHAR(10)  -- Diferente a 'codigo' en otras tablas
densidad        NUMERIC(5,2)
propiedades     JSONB DEFAULT '{}'
activo          BOOLEAN DEFAULT true  -- ✅ CONFIRMADO: campo 'activo' (no 'activa')
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: HABILITADO (relrowsecurity = true)
-- Índices adicionales: idx_materiales_activo, idx_materiales_codigo_abrev
```

### 🏢 TABLA DE TIENDAS

#### `tiendas`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(200) NOT NULL
codigo          VARCHAR(10) NOT NULL UNIQUE
direccion       TEXT
telefono        VARCHAR(20)
email           VARCHAR(100)
admin_tienda_id UUID REFERENCES perfiles_usuario(id)  -- ✅ CONFIRMADO: AÚN PRESENTE
manager_id      UUID  -- ✅ CONFIRMADO: COEXISTE con admin_tienda_id
activa          BOOLEAN DEFAULT true  -- ✅ CONFIRMADO: campo 'activa' (no 'activo')
configuracion   JSONB DEFAULT '{}'
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO
-- ⚠️ OBSERVACIÓN CRÍTICA: admin_tienda_id Y manager_id coexisten
-- Migración incompleta: esperaba solo manager_id pero ambos están presentes
```

### 📦 TABLAS DE PRODUCTOS

#### `productos_master`
```sql
id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre                VARCHAR(500) NOT NULL
descripcion           TEXT
marca_id              UUID NOT NULL REFERENCES marcas(id)
categoria_id          UUID NOT NULL REFERENCES categorias(id)
talla_id              UUID NOT NULL REFERENCES tallas(id)
material_id           UUID REFERENCES materiales(id)  -- ✅ CONFIRMADO: FK a materiales
precio_sugerido       DECIMAL(10,2) NOT NULL CHECK (precio_sugerido >= 0)
estado                estado_producto DEFAULT 'ACTIVO'  -- ENUM: 'ACTIVO' | 'INACTIVO' | 'DESCONTINUADO'
imagen_principal_url  TEXT
especificaciones      JSONB DEFAULT '{}'
created_by            UUID REFERENCES auth.users(id)
created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- UNIQUE constraint: (marca_id, categoria_id, talla_id, nombre)
-- Estado RLS: DESHABILITADO
```

#### `articulos`
```sql
id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4()
producto_master_id      UUID NOT NULL REFERENCES productos_master(id) ON DELETE CASCADE
color_id                UUID NOT NULL REFERENCES colores(id)
sku                     VARCHAR(50) NOT NULL UNIQUE
nombre_completo         VARCHAR(600) NOT NULL
codigo_barras           VARCHAR(50) UNIQUE
imagen_url              TEXT
estado                  estado_producto DEFAULT 'ACTIVO'
peso_gramos             INTEGER DEFAULT 0
especificaciones_color  JSONB DEFAULT '{}'
created_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- UNIQUE constraint: (producto_master_id, color_id)
-- Estado RLS: DESHABILITADO
```

### 📊 TABLAS DE INVENTARIO

#### `inventario_tienda`
```sql
id                UUID PRIMARY KEY DEFAULT uuid_generate_v4()
articulo_id       UUID NOT NULL REFERENCES articulos(id) ON DELETE CASCADE
tienda_id         UUID NOT NULL REFERENCES tiendas(id) ON DELETE CASCADE
stock_actual      INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0)
stock_minimo      INTEGER DEFAULT 0 CHECK (stock_minimo >= 0)
stock_maximo      INTEGER CHECK (stock_maximo IS NULL OR stock_maximo >= stock_minimo)
precio_venta      DECIMAL(10,2) NOT NULL CHECK (precio_venta >= 0)
precio_costo      DECIMAL(10,2) DEFAULT 0 CHECK (precio_costo >= 0)
ubicacion_fisica  VARCHAR(100)
activo            BOOLEAN DEFAULT true  -- ✅ CONFIRMADO: campo 'activo' (no 'activa')
ultima_venta      TIMESTAMP WITH TIME ZONE
created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- UNIQUE constraint: (articulo_id, tienda_id)
-- Estado RLS: DESHABILITADO
```

#### `movimientos_stock`
```sql
id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4()
articulo_id           UUID NOT NULL REFERENCES articulos(id)
tienda_id             UUID NOT NULL REFERENCES tiendas(id)
tipo_movimiento       tipo_movimiento NOT NULL  -- ENUM: 'ENTRADA' | 'SALIDA' | 'TRASPASO' | 'AJUSTE' | 'VENTA' | 'DEVOLUCION'
cantidad              INTEGER NOT NULL
stock_anterior        INTEGER NOT NULL
stock_nuevo           INTEGER NOT NULL
precio_unitario       DECIMAL(10,2)
costo_total           DECIMAL(10,2)
motivo                TEXT
referencia_externa    VARCHAR(100)
tienda_origen_id      UUID REFERENCES tiendas(id)
usuario_id            UUID REFERENCES auth.users(id)
created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO
```

## 🔄 CAMBIOS PRINCIPALES VS SCHEMA INICIAL

### Cambios Confirmados por Validación BD:

1. **Tabla `tiendas`**:
   - ✅ `activo` → `activa` (migración aplicada)
   - ⚠️ `admin_tienda_id` Y `manager_id` AMBOS PRESENTES (migración incompleta)

2. **Tabla `materiales`**:
   - ✅ Tabla creada y funcional
   - ✅ Campo `codigo_abrev` (no `codigo`)
   - ✅ RLS habilitado

3. **Estado RLS (validado con relrowsecurity)**:
   - ✅ `marcas`: DESHABILITADO (false)
   - ✅ `categorias`: DESHABILITADO (false)
   - ✅ `tallas`: DESHABILITADO (false)
   - ⚠️ `colores`: HABILITADO (true) - inconsistente
   - ✅ `materiales`: HABILITADO (true)

4. **Datos de Prueba**:
   - ✅ marcas: 5 registros activos
   - ✅ categorias: 5 registros activos
   - ✅ tallas: 16 registros activos

## ⚠️ INCONSISTENCIAS DETECTADAS

**CRÍTICO - Migración Incompleta en `tiendas`:**
- La migración `20250913000001_unify_tiendas_schema.sql` debía eliminar `admin_tienda_id`
- **REALIDAD**: Ambos campos coexisten actualmente
- **IMPACTO**: Posible confusión en queries y lógica de negocio

**Estado RLS Inconsistente:**
- `colores` tiene RLS habilitado mientras otras tablas de catálogo no
- Puede causar comportamiento diferente en acceso a datos

## 📋 VALIDACIÓN PARA DESARROLLADORES

**ANTES de escribir queries, USAR estos campos exactos:**

```sql
-- CAMPOS CONFIRMADOS FUNCIONANDO:
SELECT * FROM marcas WHERE activo = true;        -- ✅ 'activo'
SELECT * FROM categorias WHERE activo = true;   -- ✅ 'activo'
SELECT * FROM tallas WHERE activo = true;       -- ✅ 'activo'
SELECT * FROM colores WHERE activo = true;      -- ✅ 'activo'
SELECT * FROM materiales WHERE activo = true;   -- ✅ 'activo'
SELECT * FROM tiendas WHERE activa = true;      -- ✅ 'activa'

-- CAMPOS TIENDAS (AMBOS PRESENTES):
SELECT admin_tienda_id, manager_id FROM tiendas; -- ⚠️ Ambos existen
```

## 🚨 REGLA CRÍTICA DE DESARROLLO

**MÉTODO DE VALIDACIÓN OBLIGATORIO:**
1. **NO** confiar en documentación antigua
2. **SÍ** validar directamente con BD usando:
   ```bash
   docker exec supabase_db_py-01 psql -U postgres -c "\d public.tabla_name"
   ```
3. **VERIFICAR** estado RLS actual antes de implementar políticas

---

**Última actualización**: 2025-09-14 23:30 UTC
**Método validación**: Consulta directa BD local con psql
**Próxima revisión**: Al aplicar nuevas migraciones críticas