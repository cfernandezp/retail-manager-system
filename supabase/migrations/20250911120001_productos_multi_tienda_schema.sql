-- Migración: Schema Completo Productos Multi-Tienda de Medias
-- Fecha: 2025-09-11
-- Descripción: Implementar schema completo para sistema de medias con estructura Producto Master → Artículos por color

-- ==============================================================================
-- 1. TABLAS MAESTRAS DEL CATÁLOGO
-- ==============================================================================

-- Tabla de marcas (Arley, Nike, etc.)
CREATE TABLE IF NOT EXISTS public.marcas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    logo_url TEXT,
    activa BOOLEAN DEFAULT TRUE,
    metadatos JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de categorías/materiales (Polyester, Algodón, etc.)
CREATE TABLE IF NOT EXISTS public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    tipo VARCHAR(50) DEFAULT 'MATERIAL' CHECK (tipo IN ('MATERIAL', 'ESTILO', 'USO')),
    activa BOOLEAN DEFAULT TRUE,
    metadatos JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de tallas (flexibles: rangos como 9-12 o individuales como 3, 12)
CREATE TABLE IF NOT EXISTS public.tallas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(20) NOT NULL UNIQUE, -- Ej: "9-12", "3", "L", "XL"
    nombre VARCHAR(50) NOT NULL, -- Ej: "9-12 años", "Talla 3", "Large"
    tipo VARCHAR(30) DEFAULT 'RANGO' CHECK (tipo IN ('RANGO', 'INDIVIDUAL', 'LETRA')),
    orden_display INTEGER DEFAULT 0, -- Para ordenar en UI
    activa BOOLEAN DEFAULT TRUE,
    metadatos JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de colores
CREATE TABLE IF NOT EXISTS public.colores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    codigo_hex VARCHAR(7), -- Ej: #FF0000 para rojo
    codigo_abrev VARCHAR(5) NOT NULL UNIQUE, -- Ej: AZU, ROJ, NEG para SKU
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 2. PRODUCTOS MASTER (Sin color, base del catálogo)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.productos_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL, -- Ej: "Media fútbol polyester Arley 9-12"
    descripcion TEXT,
    marca_id UUID NOT NULL REFERENCES public.marcas(id),
    categoria_id UUID NOT NULL REFERENCES public.categorias(id),
    talla_id UUID NOT NULL REFERENCES public.tallas(id),
    precio_sugerido DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    codigo_base VARCHAR(50), -- Base para generar SKUs, ej: MED-POL-ARL-912
    imagen_principal_url TEXT,
    imagenes_adicionales JSONB DEFAULT '[]', -- Array de URLs de imágenes
    especificaciones JSONB DEFAULT '{}', -- Material, peso, cuidados, etc.
    activo BOOLEAN DEFAULT TRUE,
    fecha_lanzamiento DATE,
    created_by UUID REFERENCES public.usuarios(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT uk_productos_master_nombre_marca_talla UNIQUE(nombre, marca_id, talla_id)
);

-- ==============================================================================
-- 3. ARTÍCULOS (Producto Master + Color = SKU único)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.articulos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_master_id UUID NOT NULL REFERENCES public.productos_master(id) ON DELETE CASCADE,
    color_id UUID NOT NULL REFERENCES public.colores(id),
    sku VARCHAR(100) NOT NULL UNIQUE, -- Ej: MED-POL-ARL-912-AZU
    codigo_barras VARCHAR(50) UNIQUE,
    imagen_color_url TEXT, -- Imagen específica del color
    precio_sugerido DECIMAL(10,2), -- Puede override precio del master
    activo BOOLEAN DEFAULT TRUE,
    fecha_activacion DATE DEFAULT CURRENT_DATE,
    fecha_descontinuacion DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT uk_articulo_master_color UNIQUE(producto_master_id, color_id)
);

-- ==============================================================================
-- 4. INVENTARIO POR TIENDA
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.inventario_tienda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tienda_id UUID NOT NULL REFERENCES public.tiendas(id),
    articulo_id UUID NOT NULL REFERENCES public.articulos(id),
    stock_actual INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_reservado INTEGER NOT NULL DEFAULT 0 CHECK (stock_reservado >= 0),
    stock_minimo INTEGER DEFAULT 0,
    stock_maximo INTEGER DEFAULT 1000,
    precio_venta DECIMAL(10,2) NOT NULL, -- Precio local de la tienda
    precio_costo DECIMAL(10,2),
    ubicacion_fisica VARCHAR(50), -- Ej: "Estante A-3", "Almacén"
    activo BOOLEAN DEFAULT TRUE,
    fecha_ultima_venta TIMESTAMP WITH TIME ZONE,
    fecha_ultimo_ingreso TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT uk_inventario_tienda_articulo UNIQUE(tienda_id, articulo_id)
);

-- ==============================================================================
-- 5. MOVIMIENTOS DE STOCK (Trazabilidad completa)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.movimientos_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tienda_id UUID NOT NULL REFERENCES public.tiendas(id),
    articulo_id UUID NOT NULL REFERENCES public.articulos(id),
    tipo_movimiento VARCHAR(30) NOT NULL CHECK (tipo_movimiento IN (
        'INGRESO_COMPRA', 'INGRESO_TRASPASO', 'INGRESO_DEVOLUCION', 'INGRESO_AJUSTE',
        'SALIDA_VENTA', 'SALIDA_TRASPASO', 'SALIDA_MERMA', 'SALIDA_AJUSTE',
        'RESERVA', 'LIBERACION_RESERVA'
    )),
    cantidad INTEGER NOT NULL, -- Positivo para ingresos, negativo para salidas
    stock_anterior INTEGER NOT NULL,
    stock_resultante INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2),
    motivo TEXT,
    documento_referencia VARCHAR(100), -- Nro factura, orden traspaso, etc.
    usuario_id UUID REFERENCES public.usuarios(id),
    fecha_movimiento TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadatos JSONB DEFAULT '{}', -- Info adicional específica del tipo
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 6. ÍNDICES DE OPTIMIZACIÓN
-- ==============================================================================

-- Índices para marcas
CREATE INDEX IF NOT EXISTS idx_marcas_activo ON public.marcas(activo);
CREATE INDEX IF NOT EXISTS idx_marcas_nombre ON public.marcas USING gin(to_tsvector('spanish', nombre));

-- Índices para categorías
CREATE INDEX IF NOT EXISTS idx_categorias_activo ON public.categorias(activo);
CREATE INDEX IF NOT EXISTS idx_categorias_nombre ON public.categorias USING gin(to_tsvector('spanish', nombre));

-- Índices para tallas
CREATE INDEX IF NOT EXISTS idx_tallas_activo ON public.tallas(activo);
CREATE INDEX IF NOT EXISTS idx_tallas_tipo ON public.tallas(tipo);
CREATE INDEX IF NOT EXISTS idx_tallas_orden ON public.tallas(orden_display);

-- Índices para colores
CREATE INDEX IF NOT EXISTS idx_colores_activo ON public.colores(activo);

-- Índices para productos master
CREATE INDEX IF NOT EXISTS idx_productos_master_estado ON public.productos_master(estado);
CREATE INDEX IF NOT EXISTS idx_productos_master_marca ON public.productos_master(marca_id);
CREATE INDEX IF NOT EXISTS idx_productos_master_categoria ON public.productos_master(categoria_id);
CREATE INDEX IF NOT EXISTS idx_productos_master_talla ON public.productos_master(talla_id);
CREATE INDEX IF NOT EXISTS idx_productos_master_nombre ON public.productos_master USING gin(to_tsvector('spanish', nombre));
CREATE INDEX IF NOT EXISTS idx_productos_master_precio ON public.productos_master(precio_sugerido);

-- Índices para artículos
CREATE INDEX IF NOT EXISTS idx_articulos_estado ON public.articulos(estado);
CREATE INDEX IF NOT EXISTS idx_articulos_producto_master ON public.articulos(producto_master_id);
CREATE INDEX IF NOT EXISTS idx_articulos_color ON public.articulos(color_id);
CREATE INDEX IF NOT EXISTS idx_articulos_sku ON public.articulos(sku);
CREATE INDEX IF NOT EXISTS idx_articulos_codigo_barras ON public.articulos(codigo_barras) WHERE codigo_barras IS NOT NULL;

-- Índices para inventario (críticos para performance POS)
CREATE INDEX IF NOT EXISTS idx_inventario_tienda ON public.inventario_tienda(tienda_id);
CREATE INDEX IF NOT EXISTS idx_inventario_articulo ON public.inventario_tienda(articulo_id);
CREATE INDEX IF NOT EXISTS idx_inventario_activo ON public.inventario_tienda(activo);
CREATE INDEX IF NOT EXISTS idx_inventario_stock_bajo ON public.inventario_tienda(tienda_id, stock_actual) WHERE stock_actual <= stock_minimo;
CREATE INDEX IF NOT EXISTS idx_inventario_precio ON public.inventario_tienda(precio_venta);

-- Índices para movimientos de stock
CREATE INDEX IF NOT EXISTS idx_movimientos_tienda_fecha ON public.movimientos_stock(tienda_id, created_at);
CREATE INDEX IF NOT EXISTS idx_movimientos_articulo_fecha ON public.movimientos_stock(articulo_id, created_at);
CREATE INDEX IF NOT EXISTS idx_movimientos_tipo ON public.movimientos_stock(tipo_movimiento);
CREATE INDEX IF NOT EXISTS idx_movimientos_usuario ON public.movimientos_stock(usuario_id);

-- ==============================================================================
-- 7. TRIGGERS PARA UPDATED_AT (idempotentes)
-- ==============================================================================

DO $$
BEGIN
    -- Trigger para marcas
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_marcas_updated_at' AND tgrelid = 'public.marcas'::regclass
    ) THEN
        CREATE TRIGGER trigger_marcas_updated_at
            BEFORE UPDATE ON public.marcas
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;

    -- Trigger para categorias
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_categorias_updated_at' AND tgrelid = 'public.categorias'::regclass
    ) THEN
        CREATE TRIGGER trigger_categorias_updated_at
            BEFORE UPDATE ON public.categorias
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;

    -- Trigger para tallas
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_tallas_updated_at' AND tgrelid = 'public.tallas'::regclass
    ) THEN
        CREATE TRIGGER trigger_tallas_updated_at
            BEFORE UPDATE ON public.tallas
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;

    -- Trigger para colores
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_colores_updated_at' AND tgrelid = 'public.colores'::regclass
    ) THEN
        CREATE TRIGGER trigger_colores_updated_at
            BEFORE UPDATE ON public.colores
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;

    -- Trigger para productos_master
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_productos_master_updated_at' AND tgrelid = 'public.productos_master'::regclass
    ) THEN
        CREATE TRIGGER trigger_productos_master_updated_at
            BEFORE UPDATE ON public.productos_master
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;

    -- Trigger para articulos
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_articulos_updated_at' AND tgrelid = 'public.articulos'::regclass
    ) THEN
        CREATE TRIGGER trigger_articulos_updated_at
            BEFORE UPDATE ON public.articulos
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;

    -- Trigger para inventario_tienda
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_inventario_tienda_updated_at' AND tgrelid = 'public.inventario_tienda'::regclass
    ) THEN
        CREATE TRIGGER trigger_inventario_tienda_updated_at
            BEFORE UPDATE ON public.inventario_tienda
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
    END IF;
END $$;

-- ==============================================================================
-- 8. FUNCIÓN PARA GENERACIÓN AUTOMÁTICA DE SKUs
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.generar_sku_articulo()
RETURNS TRIGGER AS $$
DECLARE
    marca_codigo VARCHAR(5);
    categoria_codigo VARCHAR(5);
    talla_codigo VARCHAR(10);
    color_codigo VARCHAR(5);
    nuevo_sku VARCHAR(100);
BEGIN
    -- Si ya tiene SKU, no modificar
    IF NEW.sku IS NOT NULL AND NEW.sku != '' THEN
        RETURN NEW;
    END IF;
    
    -- Obtener códigos para construir SKU
    SELECT 
        UPPER(LEFT(REGEXP_REPLACE(m.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
        UPPER(LEFT(REGEXP_REPLACE(c.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
        UPPER(REGEXP_REPLACE(t.codigo, '[^A-Za-z0-9]', '', 'g')),
        col.codigo_abrev
    INTO marca_codigo, categoria_codigo, talla_codigo, color_codigo
    FROM public.productos_master pm
    JOIN public.marcas m ON pm.marca_id = m.id
    JOIN public.categorias c ON pm.categoria_id = c.id
    JOIN public.tallas t ON pm.talla_id = t.id
    JOIN public.colores col ON NEW.color_id = col.id
    WHERE pm.id = NEW.producto_master_id;
    
    -- Construir SKU: MED-POL-ARL-912-AZU
    nuevo_sku := 'MED-' || categoria_codigo || '-' || marca_codigo || '-' || talla_codigo || '-' || color_codigo;
    
    -- Verificar unicidad y agregar sufijo si es necesario
    WHILE EXISTS (SELECT 1 FROM public.articulos WHERE sku = nuevo_sku) LOOP
        nuevo_sku := nuevo_sku || '-' || TO_CHAR(FLOOR(RANDOM() * 100), 'FM00');
    END LOOP;
    
    NEW.sku := nuevo_sku;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para generación automática de SKU
CREATE TRIGGER trigger_generar_sku_articulo
    BEFORE INSERT OR UPDATE ON public.articulos
    FOR EACH ROW
    EXECUTE FUNCTION public.generar_sku_articulo();

-- ==============================================================================
-- 9. FUNCIÓN PARA ACTUALIZAR STOCK AUTOMÁTICAMENTE
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.actualizar_stock_desde_movimiento()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar stock en inventario_tienda
    UPDATE public.inventario_tienda 
    SET 
        stock_actual = NEW.stock_resultante,
        fecha_ultima_venta = CASE 
            WHEN NEW.tipo_movimiento = 'SALIDA_VENTA' THEN NEW.fecha_movimiento 
            ELSE fecha_ultima_venta 
        END,
        fecha_ultimo_ingreso = CASE 
            WHEN NEW.tipo_movimiento LIKE 'INGRESO_%' THEN NEW.fecha_movimiento 
            ELSE fecha_ultimo_ingreso 
        END,
        updated_at = NOW()
    WHERE tienda_id = NEW.tienda_id AND articulo_id = NEW.articulo_id;
    
    -- Si no existe registro en inventario, crearlo
    IF NOT FOUND THEN
        INSERT INTO public.inventario_tienda (
            tienda_id, articulo_id, stock_actual, precio_venta, precio_costo
        ) VALUES (
            NEW.tienda_id, 
            NEW.articulo_id, 
            NEW.stock_resultante,
            COALESCE(NEW.precio_unitario, 0),
            COALESCE(NEW.precio_unitario * 0.7, 0) -- Estimar 30% margen
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar stock automáticamente
CREATE TRIGGER trigger_actualizar_stock_desde_movimiento
    AFTER INSERT ON public.movimientos_stock
    FOR EACH ROW
    EXECUTE FUNCTION public.actualizar_stock_desde_movimiento();

-- ==============================================================================
-- 10. COMENTARIOS PARA DOCUMENTACIÓN
-- ==============================================================================

COMMENT ON TABLE public.marcas IS 'Catálogo de marcas de productos (Arley, Nike, etc.)';
COMMENT ON TABLE public.categorias IS 'Categorías de productos por material o tipo (Polyester, Algodón)';
COMMENT ON TABLE public.tallas IS 'Catálogo de tallas flexibles (rangos y individuales)';
COMMENT ON TABLE public.colores IS 'Catálogo de colores con códigos para SKU';
COMMENT ON TABLE public.productos_master IS 'Productos base sin color - plantilla para artículos';
COMMENT ON TABLE public.articulos IS 'Artículos vendibles - Producto Master + Color = SKU único';
COMMENT ON TABLE public.inventario_tienda IS 'Stock y precios por artículo por tienda';
COMMENT ON TABLE public.movimientos_stock IS 'Trazabilidad completa de movimientos de inventario';

-- COMMENT ON COLUMN public.productos_master.codigo_base IS 'Base para generar SKUs automáticamente'; -- Campo no existe
COMMENT ON COLUMN public.articulos.sku IS 'Código único del artículo, generado automáticamente';
COMMENT ON COLUMN public.inventario_tienda.stock_reservado IS 'Stock comprometido en ventas pendientes';
COMMENT ON COLUMN public.movimientos_stock.cantidad IS 'Cantidad del movimiento (+ ingresos, - salidas)';

-- ==============================================================================
-- 11. DATOS INICIALES BÁSICOS
-- ==============================================================================

-- Insertar marcas básicas
INSERT INTO public.marcas (nombre, descripcion) VALUES 
('Arley', 'Marca nacional de medias deportivas'),
('Nike', 'Marca internacional deportiva'),
('Adidas', 'Marca internacional deportiva'),
('Puma', 'Marca internacional deportiva'),
('Generic', 'Marca genérica para productos sin marca')
ON CONFLICT (nombre) DO NOTHING;

-- Insertar categorías básicas
INSERT INTO public.categorias (nombre, descripcion, tipo) VALUES 
('Polyester', 'Material sintético deportivo', 'MATERIAL'),
('Algodón', 'Material natural básico', 'MATERIAL'),
('Fútbol', 'Estilo deportivo para fútbol', 'ESTILO'),
('Casual', 'Estilo para uso diario', 'ESTILO'),
('Escolar', 'Para uso escolar', 'USO')
ON CONFLICT (nombre) DO NOTHING;

-- Insertar tallas básicas
INSERT INTO public.tallas (codigo, nombre, tipo, orden_display) VALUES 
('9-12', 'Talla 9-12', 'RANGO', 1),
('6-8', 'Talla 6-8', 'RANGO', 2),
('3-5', 'Talla 3-5', 'RANGO', 3),
('3', 'Talla 3', 'INDIVIDUAL', 4),
('6', 'Talla 6', 'INDIVIDUAL', 5),
('9', 'Talla 9', 'INDIVIDUAL', 6),
('12', 'Talla 12', 'INDIVIDUAL', 7),
('S', 'Small', 'LETRA', 8),
('M', 'Medium', 'LETRA', 9),
('L', 'Large', 'LETRA', 10),
('XL', 'Extra Large', 'LETRA', 11)
ON CONFLICT (codigo) DO NOTHING;

-- Insertar colores básicos
INSERT INTO public.colores (nombre, codigo_hex, codigo_abrev) VALUES 
('Azul', '#0066CC', 'AZU'),
('Rojo', '#CC0000', 'ROJ'),
('Negro', '#000000', 'NEG'),
('Blanco', '#FFFFFF', 'BLA'),
('Verde', '#00CC00', 'VER'),
('Amarillo', '#FFCC00', 'AMA'),
('Gris', '#808080', 'GRI'),
('Rosa', '#FF69B4', 'ROS'),
('Morado', '#8A2BE2', 'MOR'),
('Naranja', '#FF8C00', 'NAR')
ON CONFLICT (nombre) DO NOTHING;