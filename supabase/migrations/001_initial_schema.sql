-- =====================================================
-- MIGRACIÓN INICIAL - SISTEMA MEDIAS MULTI-TIENDA
-- =====================================================
-- Descripción: Schema completo para productos multi-tienda con inventario independiente
-- Versión: 1.0.0
-- Fecha: 2025-09-11

BEGIN;

-- =====================================================
-- 1. EXTENSIONES Y CONFIGURACIONES
-- =====================================================

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 2. ENUMS Y TIPOS PERSONALIZADOS
-- =====================================================

-- Tipo de talla (rango o única)
CREATE TYPE tipo_talla AS ENUM ('RANGO', 'UNICA');

-- Estado del producto
CREATE TYPE estado_producto AS ENUM ('ACTIVO', 'INACTIVO', 'DESCONTINUADO');

-- Tipo de movimiento de stock
CREATE TYPE tipo_movimiento AS ENUM ('ENTRADA', 'SALIDA', 'TRASPASO', 'AJUSTE', 'VENTA', 'DEVOLUCION');

-- Roles del sistema
CREATE TYPE rol_usuario AS ENUM ('SUPER_ADMIN', 'ADMIN_TIENDA', 'VENDEDOR');

-- =====================================================
-- 3. TABLAS MAESTRAS
-- =====================================================

-- Tabla de marcas
CREATE TABLE marcas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    logo_url TEXT,
    activo BOOLEAN DEFAULT true,
    prefijo_sku VARCHAR(3) NOT NULL UNIQUE, -- Para generación SKU: ARL, NIK, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de categorías/materiales
CREATE TABLE categorias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    prefijo_sku VARCHAR(3) NOT NULL UNIQUE, -- Para generación SKU: POL, ALG, etc.
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de tallas flexibles
CREATE TABLE tallas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(20) NOT NULL UNIQUE, -- 9-12, 6-8, 3, 12, etc.
    tipo tipo_talla NOT NULL,
    talla_min INTEGER, -- Para rangos: valor mínimo
    talla_max INTEGER, -- Para rangos: valor máximo  
    talla_unica INTEGER, -- Para tallas únicas
    orden_display INTEGER DEFAULT 0, -- Para ordenamiento en UI
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: debe tener rango O talla única, no ambos
    CONSTRAINT check_talla_tipo CHECK (
        (tipo = 'RANGO' AND talla_min IS NOT NULL AND talla_max IS NOT NULL AND talla_unica IS NULL) OR
        (tipo = 'UNICA' AND talla_unica IS NOT NULL AND talla_min IS NULL AND talla_max IS NULL)
    ),
    CONSTRAINT check_rango_valido CHECK (
        tipo != 'RANGO' OR talla_min <= talla_max
    )
);

-- Tabla de colores
CREATE TABLE colores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    codigo_hex VARCHAR(7), -- #FF0000
    prefijo_sku VARCHAR(3) NOT NULL UNIQUE, -- AZU, ROJ, NEG, etc.
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. TABLAS DE TIENDAS Y USUARIOS
-- =====================================================

-- Tabla de tiendas
CREATE TABLE tiendas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(200) NOT NULL,
    codigo VARCHAR(10) NOT NULL UNIQUE, -- GAM, MES, etc.
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    admin_tienda_id UUID, -- Usuario responsable de la tienda
    activo BOOLEAN DEFAULT true,
    configuracion JSONB DEFAULT '{}', -- Configuraciones específicas de tienda
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Perfiles de usuario extendidos (complementa auth.users de Supabase)
CREATE TABLE perfiles_usuario (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nombre_completo VARCHAR(200) NOT NULL,
    rol rol_usuario NOT NULL,
    tienda_id UUID REFERENCES tiendas(id), -- NULL para SUPER_ADMIN
    activo BOOLEAN DEFAULT true,
    configuracion JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: ADMIN_TIENDA y VENDEDOR deben tener tienda asignada
    CONSTRAINT check_rol_tienda CHECK (
        (rol = 'SUPER_ADMIN') OR 
        (rol IN ('ADMIN_TIENDA', 'VENDEDOR') AND tienda_id IS NOT NULL)
    )
);

-- =====================================================
-- 5. TABLAS DE PRODUCTOS
-- =====================================================

-- Tabla de productos master (producto base sin color)
CREATE TABLE productos_master (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(500) NOT NULL, -- "Media fútbol polyester Arley 9-12"
    descripcion TEXT,
    marca_id UUID NOT NULL REFERENCES marcas(id),
    categoria_id UUID NOT NULL REFERENCES categorias(id),
    talla_id UUID NOT NULL REFERENCES tallas(id),
    precio_sugerido DECIMAL(10,2) NOT NULL CHECK (precio_sugerido >= 0),
    estado estado_producto DEFAULT 'ACTIVO',
    imagen_principal_url TEXT,
    especificaciones JSONB DEFAULT '{}', -- Propiedades adicionales
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Índice único para evitar duplicados
    UNIQUE(marca_id, categoria_id, talla_id, nombre)
);

-- Tabla de artículos (variantes por color del producto master)
CREATE TABLE articulos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_master_id UUID NOT NULL REFERENCES productos_master(id) ON DELETE CASCADE,
    color_id UUID NOT NULL REFERENCES colores(id),
    sku VARCHAR(50) NOT NULL UNIQUE, -- MED-POL-ARL-912-AZU (generado automáticamente)
    nombre_completo VARCHAR(600) NOT NULL, -- Nombre con color incluido
    codigo_barras VARCHAR(50) UNIQUE, -- EAN13 o similar
    imagen_url TEXT,
    estado estado_producto DEFAULT 'ACTIVO',
    peso_gramos INTEGER DEFAULT 0,
    especificaciones_color JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Un producto master no puede tener el mismo color duplicado
    UNIQUE(producto_master_id, color_id)
);

-- =====================================================
-- 6. INVENTARIO MULTI-TIENDA
-- =====================================================

-- Tabla de inventario por tienda (stock y precio local)
CREATE TABLE inventario_tienda (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    articulo_id UUID NOT NULL REFERENCES articulos(id) ON DELETE CASCADE,
    tienda_id UUID NOT NULL REFERENCES tiendas(id) ON DELETE CASCADE,
    stock_actual INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo INTEGER DEFAULT 0 CHECK (stock_minimo >= 0),
    stock_maximo INTEGER DEFAULT NULL CHECK (stock_maximo IS NULL OR stock_maximo >= stock_minimo),
    precio_venta DECIMAL(10,2) NOT NULL CHECK (precio_venta >= 0),
    precio_costo DECIMAL(10,2) DEFAULT 0 CHECK (precio_costo >= 0),
    ubicacion_fisica VARCHAR(100), -- Estante, pasillo, etc.
    activo BOOLEAN DEFAULT true,
    ultima_venta TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Un artículo solo puede existir una vez por tienda
    UNIQUE(articulo_id, tienda_id)
);

-- Tabla de movimientos de stock (auditoría completa)
CREATE TABLE movimientos_stock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    articulo_id UUID NOT NULL REFERENCES articulos(id),
    tienda_id UUID NOT NULL REFERENCES tiendas(id),
    tipo_movimiento tipo_movimiento NOT NULL,
    cantidad INTEGER NOT NULL, -- Positivo para entradas, negativo para salidas
    stock_anterior INTEGER NOT NULL,
    stock_nuevo INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2),
    costo_total DECIMAL(10,2),
    motivo TEXT,
    referencia_externa VARCHAR(100), -- ID de venta, compra, traspaso, etc.
    tienda_origen_id UUID REFERENCES tiendas(id), -- Para traspasos
    usuario_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Validaciones de negocio
    CONSTRAINT check_cantidad_tipo CHECK (
        (tipo_movimiento IN ('ENTRADA', 'DEVOLUCION', 'AJUSTE') AND cantidad >= 0) OR
        (tipo_movimiento IN ('SALIDA', 'VENTA') AND cantidad <= 0) OR
        (tipo_movimiento = 'TRASPASO')
    ),
    CONSTRAINT check_traspaso_origen CHECK (
        tipo_movimiento != 'TRASPASO' OR tienda_origen_id IS NOT NULL
    )
);

-- =====================================================
-- 7. ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para búsquedas frecuentes en POS
CREATE INDEX idx_articulos_sku ON articulos(sku);
CREATE INDEX idx_articulos_codigo_barras ON articulos(codigo_barras) WHERE codigo_barras IS NOT NULL;
CREATE INDEX idx_articulos_producto_master ON articulos(producto_master_id);
CREATE INDEX idx_articulos_estado ON articulos(estado) WHERE estado = 'ACTIVO';

-- Índices para inventario
CREATE INDEX idx_inventario_tienda_articulo ON inventario_tienda(tienda_id, articulo_id);
CREATE INDEX idx_inventario_stock_bajo ON inventario_tienda(tienda_id) WHERE stock_actual <= stock_minimo;
CREATE INDEX idx_inventario_activo ON inventario_tienda(tienda_id) WHERE activo = true;

-- Índices para movimientos de stock
CREATE INDEX idx_movimientos_articulo_tienda ON movimientos_stock(articulo_id, tienda_id);
CREATE INDEX idx_movimientos_fecha ON movimientos_stock(created_at DESC);
CREATE INDEX idx_movimientos_referencia ON movimientos_stock(referencia_externa) WHERE referencia_externa IS NOT NULL;
CREATE INDEX idx_movimientos_tipo ON movimientos_stock(tipo_movimiento);

-- Índices para productos master
CREATE INDEX idx_productos_master_marca ON productos_master(marca_id);
CREATE INDEX idx_productos_master_categoria ON productos_master(categoria_id);
CREATE INDEX idx_productos_master_talla ON productos_master(talla_id);
CREATE INDEX idx_productos_master_estado ON productos_master(estado) WHERE estado = 'ACTIVO';
CREATE INDEX idx_productos_master_nombre_busqueda ON productos_master USING gin(to_tsvector('spanish', nombre));

-- Índices para perfiles
CREATE INDEX idx_perfiles_usuario_rol ON perfiles_usuario(rol);
CREATE INDEX idx_perfiles_usuario_tienda ON perfiles_usuario(tienda_id) WHERE tienda_id IS NOT NULL;

-- =====================================================
-- 8. ACTUALIZACIÓN DE FOREIGN KEYS
-- =====================================================

-- Actualizar referencia de admin_tienda_id en tiendas
ALTER TABLE tiendas ADD CONSTRAINT fk_tiendas_admin_tienda 
    FOREIGN KEY (admin_tienda_id) REFERENCES perfiles_usuario(id);

COMMIT;