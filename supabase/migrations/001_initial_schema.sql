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

-- COLORES - Campo: activo (boolean) + soporte colores múltiples
CREATE TABLE colores (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre                  VARCHAR(100) NOT NULL UNIQUE,
    codigo_hex              VARCHAR(7),
    codigo_abrev            VARCHAR(5) NOT NULL UNIQUE,
    activo                  BOOLEAN DEFAULT true,
    created_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    hex_color               VARCHAR(7),
    tipo_color              VARCHAR(10) DEFAULT 'UNICO' CHECK (tipo_color IN ('UNICO', 'VARIOS')),
    colores_componentes     JSONB,
    descripcion_completa    TEXT
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

-- =====================================================
-- MÓDULO DE VENTAS - TABLAS NUEVAS
-- =====================================================

-- ESTRATEGIAS DE DESCUENTO - Maneja descuentos por cantidad
CREATE TABLE estrategias_descuento (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,

    -- Criterios de aplicación
    categoria_id UUID REFERENCES categorias(id),
    marca_id UUID REFERENCES marcas(id),
    producto_id UUID REFERENCES productos_master(id), -- Opcional: producto específico

    -- Configuración de descuentos por cantidad
    rangos_cantidad JSONB NOT NULL DEFAULT '[]'::jsonb,
    -- Formato: [{"cantidad_min": 1, "cantidad_max": 2, "descuento_porcentaje": 0},
    --           {"cantidad_min": 3, "cantidad_max": 11, "descuento_porcentaje": 6.67}]

    -- Configuración general
    activa BOOLEAN DEFAULT true,
    fecha_inicio DATE,
    fecha_fin DATE,
    tienda_id UUID REFERENCES tiendas(id), -- Opcional: por tienda específica

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT estrategias_descuento_nombre_unique UNIQUE (nombre),
    CONSTRAINT estrategias_descuento_fecha_check CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

-- PERMISOS DE DESCUENTO - Define límites por rol
CREATE TABLE permisos_descuento (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rol_usuario VARCHAR(50) NOT NULL, -- 'vendedor_junior', 'vendedor_senior', 'supervisor', 'admin'
    categoria_id UUID REFERENCES categorias(id), -- Opcional: permisos por categoría

    -- Límites de descuento
    descuento_maximo_porcentaje DECIMAL(5,2) NOT NULL DEFAULT 0,
    requiere_aprobacion BOOLEAN DEFAULT false,
    puede_aprobar_descuentos BOOLEAN DEFAULT false,

    -- Estado
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT permisos_descuento_porcentaje_check CHECK (descuento_maximo_porcentaje >= 0 AND descuento_maximo_porcentaje <= 100),
    CONSTRAINT permisos_descuento_rol_categoria_unique UNIQUE (rol_usuario, categoria_id)
);

-- VENTAS - Registra las ventas completadas
CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Información básica
    numero_venta VARCHAR(20) NOT NULL UNIQUE,
    tienda_id UUID NOT NULL REFERENCES tiendas(id),
    vendedor_id UUID NOT NULL REFERENCES auth.users(id),
    cliente_id UUID REFERENCES clientes(id), -- Opcional para ventas sin cliente registrado

    -- Totales
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    descuento_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    impuestos DECIMAL(12,2) NOT NULL DEFAULT 0,
    total DECIMAL(12,2) NOT NULL DEFAULT 0,

    -- Estado y fechas
    estado VARCHAR(20) NOT NULL DEFAULT 'borrador', -- 'borrador', 'completada', 'anulada'
    fecha_venta TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_completada TIMESTAMP WITH TIME ZONE,

    -- Información adicional
    metodo_pago VARCHAR(50), -- 'efectivo', 'tarjeta', 'transferencia', 'mixto'
    notas TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT ventas_totales_check CHECK (total >= 0 AND subtotal >= 0),
    CONSTRAINT ventas_estado_check CHECK (estado IN ('borrador', 'completada', 'anulada'))
);

-- DETALLES DE VENTA - Items individuales de cada venta
CREATE TABLE detalles_venta (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venta_id UUID NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
    articulo_id UUID NOT NULL REFERENCES articulos(id),

    -- Cantidades y precios
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario_original DECIMAL(10,2) NOT NULL, -- Precio antes de descuentos
    descuento_porcentaje DECIMAL(5,2) NOT NULL DEFAULT 0,
    precio_unitario_final DECIMAL(10,2) NOT NULL, -- Precio después de descuentos
    subtotal DECIMAL(12,2) NOT NULL, -- cantidad * precio_unitario_final

    -- Información de descuentos aplicados
    estrategia_descuento_id UUID REFERENCES estrategias_descuento(id),
    descuento_aplicado_manual BOOLEAN DEFAULT false,
    motivo_descuento TEXT,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT detalles_venta_precios_check CHECK (precio_unitario_original >= 0 AND precio_unitario_final >= 0),
    CONSTRAINT detalles_venta_descuento_check CHECK (descuento_porcentaje >= 0 AND descuento_porcentaje <= 100)
);

-- APROBACIONES DE DESCUENTO - Sistema de workflow
CREATE TABLE aprobaciones_descuento (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venta_id UUID NOT NULL REFERENCES ventas(id),
    detalle_venta_id UUID REFERENCES detalles_venta(id),

    -- Usuarios involucrados
    vendedor_id UUID NOT NULL REFERENCES auth.users(id),
    supervisor_id UUID REFERENCES auth.users(id),

    -- Información del descuento
    descuento_solicitado DECIMAL(5,2) NOT NULL,
    descuento_aprobado DECIMAL(5,2),
    justificacion TEXT,
    respuesta_supervisor TEXT,

    -- Estado del proceso
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente', -- 'pendiente', 'aprobado', 'rechazado', 'expirado'

    -- Timestamps
    fecha_solicitud TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_respuesta TIMESTAMP WITH TIME ZONE,
    fecha_expiracion TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '1 hour'), -- Expira en 1 hora

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT aprobaciones_descuento_estado_check CHECK (estado IN ('pendiente', 'aprobado', 'rechazado', 'expirado')),
    CONSTRAINT aprobaciones_descuento_porcentaje_check CHECK (descuento_solicitado >= 0 AND descuento_solicitado <= 100)
);

-- ÍNDICES PARA MÓDULO DE VENTAS
CREATE INDEX idx_estrategias_descuento_activa ON estrategias_descuento(activa) WHERE activa = true;
CREATE INDEX idx_estrategias_descuento_categoria ON estrategias_descuento(categoria_id) WHERE categoria_id IS NOT NULL;
CREATE INDEX idx_estrategias_descuento_marca ON estrategias_descuento(marca_id) WHERE marca_id IS NOT NULL;
CREATE INDEX idx_estrategias_descuento_producto ON estrategias_descuento(producto_id) WHERE producto_id IS NOT NULL;
CREATE INDEX idx_estrategias_descuento_tienda ON estrategias_descuento(tienda_id) WHERE tienda_id IS NOT NULL;

CREATE INDEX idx_permisos_descuento_rol ON permisos_descuento(rol_usuario);
CREATE INDEX idx_permisos_descuento_activo ON permisos_descuento(activo) WHERE activo = true;

CREATE INDEX idx_ventas_tienda_fecha ON ventas(tienda_id, fecha_venta);
CREATE INDEX idx_ventas_vendedor_fecha ON ventas(vendedor_id, fecha_venta);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_ventas_numero ON ventas(numero_venta);

CREATE INDEX idx_detalles_venta_venta_id ON detalles_venta(venta_id);
CREATE INDEX idx_detalles_venta_articulo_id ON detalles_venta(articulo_id);
CREATE INDEX idx_detalles_venta_estrategia ON detalles_venta(estrategia_descuento_id) WHERE estrategia_descuento_id IS NOT NULL;

CREATE INDEX idx_aprobaciones_descuento_vendedor ON aprobaciones_descuento(vendedor_id);
CREATE INDEX idx_aprobaciones_descuento_supervisor ON aprobaciones_descuento(supervisor_id) WHERE supervisor_id IS NOT NULL;
CREATE INDEX idx_aprobaciones_descuento_estado ON aprobaciones_descuento(estado);
CREATE INDEX idx_aprobaciones_descuento_pendientes ON aprobaciones_descuento(fecha_solicitud) WHERE estado = 'pendiente';

-- COMENTARIOS PARA MÓDULO DE VENTAS
COMMENT ON TABLE estrategias_descuento IS 'Define estrategias de descuento por cantidad y otros criterios';
COMMENT ON TABLE permisos_descuento IS 'Configuración de permisos de descuento por rol de usuario';
COMMENT ON TABLE ventas IS 'Registro principal de ventas completadas';
COMMENT ON TABLE detalles_venta IS 'Items individuales de cada venta con precios y descuentos aplicados';
COMMENT ON TABLE aprobaciones_descuento IS 'Sistema de workflow para aprobación de descuentos especiales';

-- Fin del esquema inicial limpio