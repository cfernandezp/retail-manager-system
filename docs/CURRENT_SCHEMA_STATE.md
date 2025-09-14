# ESTADO ACTUAL DEL ESQUEMA DE BASE DE DATOS

> **IMPORTANTE**: Este archivo documenta el estado REAL de las tablas tras aplicar TODAS las migraciones.
>
> **Actualizado**: 2025-09-14
> **Propósito**: Evitar confusión entre schema inicial y modificaciones posteriores

## 📋 TABLAS PRINCIPALES Y CAMPOS CONFIRMADOS

### 🏷️ TABLAS DE CATÁLOGO

#### `marcas`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(100) NOT NULL UNIQUE
descripcion     TEXT
logo_url        TEXT
activo          BOOLEAN DEFAULT true  -- ⚠️ CONFIRMAR: usa 'activo', no 'activa'
prefijo_sku     VARCHAR(3) NOT NULL UNIQUE
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO (desarrollo)
```

#### `categorias`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(100) NOT NULL UNIQUE
descripcion     TEXT
prefijo_sku     VARCHAR(3) NOT NULL UNIQUE
activo          BOOLEAN DEFAULT true  -- ⚠️ CONFIRMAR: usa 'activo', no 'activa'
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO (desarrollo)
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
activo          BOOLEAN DEFAULT true  -- ⚠️ CONFIRMAR: usa 'activo', no 'activa'
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO (desarrollo)
-- Constraint: check_talla_tipo
```

#### `colores`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(50) NOT NULL UNIQUE
codigo_hex      VARCHAR(7)  -- #FF0000
prefijo_sku     VARCHAR(3) NOT NULL UNIQUE
activo          BOOLEAN DEFAULT true  -- ⚠️ CONFIRMAR: usa 'activo', no 'activa'
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: DESHABILITADO (desarrollo)
```

#### `materiales`
```sql
id              UUID PRIMARY KEY DEFAULT uuid_generate_v4()
nombre          VARCHAR(100) NOT NULL UNIQUE
descripcion     TEXT
codigo          VARCHAR(10) NOT NULL UNIQUE
activo          BOOLEAN DEFAULT true  -- ⚠️ CONFIRMAR: usa 'activo', no 'activa'
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: Habilitado
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
manager_id      UUID  -- ⚠️ CAMBIO: era 'admin_tienda_id', ahora 'manager_id'
activa          BOOLEAN DEFAULT true  -- ⚠️ CAMBIO: era 'activo', ahora 'activa'
configuracion   JSONB DEFAULT '{}'
created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- Estado RLS: Habilitado
-- FOREIGN KEY: manager_id REFERENCES usuarios(id)
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
precio_sugerido       DECIMAL(10,2) NOT NULL CHECK (precio_sugerido >= 0)
estado                estado_producto DEFAULT 'ACTIVO'  -- ENUM: 'ACTIVO' | 'INACTIVO' | 'DESCONTINUADO'
imagen_principal_url  TEXT
especificaciones      JSONB DEFAULT '{}'
created_by            UUID REFERENCES auth.users(id)
created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- UNIQUE constraint: (marca_id, categoria_id, talla_id, nombre)
-- Estado RLS: DESHABILITADO (desarrollo)
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
-- Estado RLS: DESHABILITADO (desarrollo)
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
activo            BOOLEAN DEFAULT true  -- ⚠️ CONFIRMAR: usa 'activo', no 'activa'
ultima_venta      TIMESTAMP WITH TIME ZONE
created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()

-- UNIQUE constraint: (articulo_id, tienda_id)
-- Estado RLS: DESHABILITADO (desarrollo)
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

-- Estado RLS: DESHABILITADO (desarrollo)
```

## 🔄 CAMBIOS PRINCIPALES VS SCHEMA INICIAL

### Cambios Confirmados por Migraciones:

1. **Tabla `tiendas`** (migración `20250913000001_unify_tiendas_schema.sql`):
   - `activo` → `activa` ✅
   - `admin_tienda_id` → `manager_id` ✅

2. **Tabla `materiales`** (migración `20250911140001_create_materiales_table.sql`):
   - Tabla nueva añadida ✅

3. **RLS Policies** (migración `20250914235001_force_disable_rls_critical.sql`):
   - `marcas`, `categorias`, `tallas`, `colores`: RLS DESHABILITADO ✅
   - `productos_master`, `articulos`, `inventario_tienda`, `movimientos_stock`: RLS DESHABILITADO ✅

4. **Datos de Prueba** (migración `20250914230001_seed_catalog_data.sql`):
   - Datos populados en marcas, categorias, tallas ✅

## ⚠️ VALIDACIÓN REQUERIDA

**Para desarrolladores y agentes IA:**

**ANTES de escribir queries, VALIDAR estos campos:**

```sql
-- ESTOS CAMPOS SON CORRECTOS:
SELECT * FROM marcas WHERE activo = true;        -- ✅ 'activo'
SELECT * FROM categorias WHERE activo = true;   -- ✅ 'activo'
SELECT * FROM tallas WHERE activo = true;       -- ✅ 'activo'
SELECT * FROM colores WHERE activo = true;      -- ✅ 'activo'
SELECT * FROM materiales WHERE activo = true;   -- ✅ 'activo'

-- ESTE CAMPO ES DIFERENTE:
SELECT * FROM tiendas WHERE activa = true;      -- ✅ 'activa' (cambio por migración)
```

## 🚨 REGLA CRÍTICA

**NO confiar en:**
- Documentación previa desactualizada
- Schema inicial `001_initial_schema.sql` (modificado por migraciones)
- Suposiciones sobre nombres de campos

**SÍ validar con:**
- Este archivo (actualizado regularmente)
- Consulta directa a BD con herramientas pgAdmin/psql
- Verificación en `information_schema.columns`

---

**Última actualización**: 2025-09-14 22:45 UTC
**Responsable**: Análisis post-resolución dropdowns vacíos
**Próxima revisión**: Al aplicar nuevas migraciones que modifiquen esquema