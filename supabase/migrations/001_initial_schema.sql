-- =====================================================
-- ESQUEMA INICIAL LIMPIO - BASADO EN ESTADO REAL BD
-- =====================================================
-- Archivo: 001_initial_schema_clean.sql
-- Propósito: Reemplazo limpio de 001_initial_schema.sql
-- Basado en: docs/CURRENT_SCHEMA_STATE.md (validado 2025-09-14)
-- Fecha: 2025-09-15
-- =====================================================

-- EXTENSIONES REQUERIDAS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- TIPOS ENUM
-- =====================================================

-- Tipo de talla
CREATE TYPE tipo_talla AS ENUM ('RANGO', 'UNICA');

-- Estado de producto
CREATE TYPE estado_producto AS ENUM ('ACTIVO', 'INACTIVO', 'DESCONTINUADO');

-- Tipo de movimiento de stock
CREATE TYPE tipo_movimiento AS ENUM ('ENTRADA', 'SALIDA', 'TRASPASO', 'AJUSTE', 'VENTA', 'DEVOLUCION');

-- Roles de usuario (extendido para compatibilidad)
CREATE TYPE rol_usuario_extended AS ENUM ('SUPER_ADMIN', 'ADMIN', 'MANAGER', 'VENDEDOR', 'OPERARIO', 'CLIENTE');

-- Estado de usuario
CREATE TYPE estado_usuario AS ENUM ('PENDIENTE_EMAIL', 'PENDIENTE_APROBACION', 'ACTIVA', 'SUSPENDIDA', 'RECHAZADA');

-- =====================================================
-- TABLAS DE CATÁLOGO - ESTADO CONFIRMADO
-- =====================================================

-- MARCAS - Campo: activo (boolean)
CREATE TABLE marcas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     TEXT,
    logo_url        TEXT,
    activo          BOOLEAN DEFAULT true,
    prefijo_sku     VARCHAR(3) NOT NULL UNIQUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CATEGORIAS - Campo: activo (boolean)
CREATE TABLE categorias (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     TEXT,
    prefijo_sku     VARCHAR(3) NOT NULL UNIQUE,
    activo          BOOLEAN DEFAULT true,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TALLAS - Campo: activo (boolean)
CREATE TABLE tallas (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo          VARCHAR(20) NOT NULL UNIQUE,
    nombre          VARCHAR(50) NOT NULL,
    tipo            VARCHAR(30) DEFAULT 'RANGO' CHECK (tipo IN ('RANGO', 'INDIVIDUAL', 'LETRA')),
    orden_display   INTEGER DEFAULT 0,
    activo          BOOLEAN DEFAULT true,
    metadatos       JSONB DEFAULT '{}',
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valor           VARCHAR(50) NOT NULL
);

-- COLORES - Campo: activo (boolean)
CREATE TABLE colores (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre          VARCHAR(50) NOT NULL UNIQUE,
    codigo_hex      VARCHAR(7),
    codigo_abrev    VARCHAR(5) NOT NULL UNIQUE,
    activo          BOOLEAN DEFAULT true,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    hex_color       VARCHAR(7)
);

-- MATERIALES - Campo: activo (boolean)
CREATE TABLE materiales (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     TEXT,
    codigo_abrev    VARCHAR(10),
    densidad        NUMERIC(5,2),
    propiedades     JSONB DEFAULT '{}',
    activo          BOOLEAN DEFAULT true,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA DE ROLES (REQUERIDA POR USUARIOS)
-- =====================================================

-- ROLES - Sistema de permisos
CREATE TABLE roles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre          VARCHAR(50) NOT NULL UNIQUE,
    descripcion     TEXT,
    permisos        JSONB DEFAULT '{}',
    activo          BOOLEAN DEFAULT true,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA TIENDAS - ESQUEMA UNIFICADO
-- =====================================================

-- TIENDAS - Campo: activa (boolean), solo manager_id
CREATE TABLE tiendas (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre          VARCHAR(200) NOT NULL,
    codigo          VARCHAR(10) NOT NULL UNIQUE,
    direccion       TEXT,
    telefono        VARCHAR(20),
    email           VARCHAR(100),
    manager_id      UUID,
    activa          BOOLEAN DEFAULT true,
    configuracion   JSONB DEFAULT '{}',
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA USUARIOS - COMPATIBILIDAD FRONTEND
-- =====================================================

-- USUARIOS - Tabla que espera el frontend Flutter
CREATE TABLE usuarios (
    id                  UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email               VARCHAR(255) NOT NULL UNIQUE,
    nombre_completo     VARCHAR(255) NOT NULL,
    telefono            VARCHAR(20),
    direccion           TEXT,
    rol_id              UUID REFERENCES roles(id) NOT NULL,
    estado              estado_usuario DEFAULT 'PENDIENTE_APROBACION',
    email_verificado    BOOLEAN DEFAULT false,
    tienda_asignada     UUID REFERENCES tiendas(id),
    aprobado_por        UUID REFERENCES usuarios(id),
    fecha_aprobacion    TIMESTAMP WITH TIME ZONE,
    fecha_suspension    TIMESTAMP WITH TIME ZONE,
    fecha_reactivacion  TIMESTAMP WITH TIME ZONE,
    fecha_rechazo       TIMESTAMP WITH TIME ZONE,
    motivo_rechazo      TEXT,
    motivo_suspension   TEXT,
    ultimo_acceso       TIMESTAMP WITH TIME ZONE,
    intentos_fallidos   INTEGER DEFAULT 0,
    bloqueado_hasta     TIMESTAMP WITH TIME ZONE,
    metadatos           JSONB DEFAULT '{}',
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLAS DE PRODUCTOS
-- =====================================================

-- PRODUCTOS MASTER
CREATE TABLE productos_master (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre                VARCHAR(255) NOT NULL,
    descripcion           TEXT,
    marca_id              UUID NOT NULL REFERENCES marcas(id),
    categoria_id          UUID NOT NULL REFERENCES categorias(id),
    talla_id              UUID NOT NULL REFERENCES tallas(id),
    precio_sugerido       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    codigo_base           VARCHAR(50),
    imagen_principal_url  TEXT,
    imagenes_adicionales  JSONB DEFAULT '[]',
    especificaciones      JSONB DEFAULT '{}',
    estado                estado_producto DEFAULT 'ACTIVO',
    fecha_lanzamiento     DATE,
    created_by            UUID REFERENCES usuarios(id),
    created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    material_id           UUID REFERENCES materiales(id),

    CONSTRAINT uk_productos_master_nombre_marca_talla UNIQUE (nombre, marca_id, talla_id)
);

-- ARTICULOS (PRODUCTO + COLOR)
CREATE TABLE articulos (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_master_id      UUID NOT NULL REFERENCES productos_master(id) ON DELETE CASCADE,
    color_id                UUID NOT NULL REFERENCES colores(id),
    sku_auto                VARCHAR(100) NOT NULL UNIQUE,
    codigo_barras           VARCHAR(50) UNIQUE,
    imagen_color_url        TEXT,
    precio_sugerido         DECIMAL(10,2),
    activo                  BOOLEAN DEFAULT true,
    fecha_activacion        DATE DEFAULT CURRENT_DATE,
    fecha_descontinuacion   DATE,
    created_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT uk_articulo_master_color UNIQUE (producto_master_id, color_id)
);

-- =====================================================
-- TABLAS DE INVENTARIO
-- =====================================================

-- INVENTARIO POR TIENDA - Campo: activo (boolean)
CREATE TABLE inventario_tienda (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    articulo_id       UUID NOT NULL REFERENCES articulos(id) ON DELETE CASCADE,
    tienda_id         UUID NOT NULL REFERENCES tiendas(id) ON DELETE CASCADE,
    stock_actual      INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo      INTEGER DEFAULT 0 CHECK (stock_minimo >= 0),
    stock_maximo      INTEGER CHECK (stock_maximo IS NULL OR stock_maximo >= stock_minimo),
    precio_venta      DECIMAL(10,2) NOT NULL CHECK (precio_venta >= 0),
    precio_costo      DECIMAL(10,2) DEFAULT 0 CHECK (precio_costo >= 0),
    ubicacion_fisica  VARCHAR(100),
    activo            BOOLEAN DEFAULT true,
    ultima_venta      TIMESTAMP WITH TIME ZONE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT uk_inventario_articulo_tienda UNIQUE (articulo_id, tienda_id)
);

-- MOVIMIENTOS DE STOCK
CREATE TABLE movimientos_stock (
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    articulo_id           UUID NOT NULL REFERENCES articulos(id),
    tienda_id             UUID NOT NULL REFERENCES tiendas(id),
    tipo_movimiento       tipo_movimiento NOT NULL,
    cantidad              INTEGER NOT NULL,
    stock_anterior        INTEGER NOT NULL,
    stock_nuevo           INTEGER NOT NULL,
    precio_unitario       DECIMAL(10,2),
    costo_total           DECIMAL(10,2),
    motivo                TEXT,
    referencia_externa    VARCHAR(100),
    tienda_origen_id      UUID REFERENCES tiendas(id),
    usuario_id            UUID REFERENCES auth.users(id),
    created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES BÁSICOS
-- =====================================================

-- Índices para campos activo/activa
CREATE INDEX idx_marcas_activo ON marcas(activo) WHERE activo = true;
CREATE INDEX idx_categorias_activo ON categorias(activo) WHERE activo = true;
CREATE INDEX idx_tallas_activo ON tallas(activo) WHERE activo = true;
CREATE INDEX idx_colores_activo ON colores(activo) WHERE activo = true;
CREATE INDEX idx_materiales_activo ON materiales(activo) WHERE activo = true;
CREATE INDEX idx_roles_activo ON roles(activo) WHERE activo = true;
CREATE INDEX idx_tiendas_activa ON tiendas(activa) WHERE activa = true;
CREATE INDEX idx_inventario_activo ON inventario_tienda(activo) WHERE activo = true;

-- Índices para usuarios
CREATE INDEX idx_usuarios_estado ON usuarios(estado);
CREATE INDEX idx_usuarios_rol ON usuarios(rol_id);
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_tienda ON usuarios(tienda_asignada) WHERE tienda_asignada IS NOT NULL;
CREATE INDEX idx_usuarios_fecha_creacion ON usuarios(created_at);
CREATE INDEX idx_usuarios_pendientes_urgentes ON usuarios(created_at) WHERE estado = 'PENDIENTE_APROBACION';

-- Índices para búsquedas frecuentes
CREATE INDEX idx_articulos_sku_auto ON articulos(sku_auto);
CREATE INDEX idx_articulos_codigo_barras ON articulos(codigo_barras) WHERE codigo_barras IS NOT NULL;
CREATE INDEX idx_articulos_producto_master ON articulos(producto_master_id);
CREATE INDEX idx_articulos_color ON articulos(color_id);
CREATE INDEX idx_productos_master_estado ON productos_master(estado);
CREATE INDEX idx_productos_master_marca ON productos_master(marca_id);
CREATE INDEX idx_productos_master_categoria ON productos_master(categoria_id);
CREATE INDEX idx_productos_master_talla ON productos_master(talla_id);
CREATE INDEX idx_productos_master_material ON productos_master(material_id);
CREATE INDEX idx_tallas_orden ON tallas(orden_display);
CREATE INDEX idx_tallas_tipo ON tallas(tipo);
CREATE INDEX idx_inventario_stock_bajo ON inventario_tienda(stock_actual, stock_minimo) WHERE stock_actual <= stock_minimo;

-- =====================================================
-- COMENTARIOS DOCUMENTANDO ESTADO REAL
-- =====================================================

COMMENT ON TABLE marcas IS 'Marcas - Campo activo (boolean) confirmado BD real';
COMMENT ON TABLE categorias IS 'Categorías - Campo activo (boolean) confirmado BD real';
COMMENT ON TABLE tallas IS 'Tallas - Campo activo (boolean) confirmado BD real';
COMMENT ON TABLE colores IS 'Colores - Campo activo (boolean) confirmado BD real';
COMMENT ON TABLE materiales IS 'Materiales - Campo activo (boolean) confirmado BD real';
COMMENT ON TABLE roles IS 'Roles de usuario - Sistema de permisos';
COMMENT ON TABLE tiendas IS 'Tiendas - Campo activa (boolean), solo manager_id confirmado BD real';
COMMENT ON TABLE usuarios IS 'Usuarios - Tabla compatible con frontend Flutter';
COMMENT ON TABLE inventario_tienda IS 'Inventario - Campo activo (boolean) confirmado BD real';

-- Fin del esquema inicial limpio