-- =====================================================
-- FUNCIONES Y TRIGGERS - SISTEMA MEDIAS MULTI-TIENDA
-- =====================================================
-- Descripción: Automatización de SKUs, auditoría, stock y cálculos
-- Versión: 1.0.0
-- Fecha: 2025-09-11

BEGIN;

-- =====================================================
-- 1. FUNCIONES DE UTILIDAD
-- =====================================================

-- Función para generar SKU automático
CREATE OR REPLACE FUNCTION generate_sku(
    p_marca_prefijo VARCHAR(3),
    p_categoria_prefijo VARCHAR(3),
    p_talla_codigo VARCHAR(20),
    p_color_prefijo VARCHAR(3)
)
RETURNS VARCHAR(50)
LANGUAGE plpgsql
AS $$
DECLARE
    sku_base VARCHAR(50);
    sku_final VARCHAR(50);
    counter INTEGER := 1;
BEGIN
    -- Formato: MED-POL-ARL-912-AZU
    -- Limpiar y formatear códigos
    p_talla_codigo := REPLACE(p_talla_codigo, '-', '');
    
    -- Construir SKU base
    sku_base := UPPER(p_categoria_prefijo) || '-' || 
                UPPER(p_marca_prefijo) || '-' || 
                UPPER(p_talla_codigo) || '-' || 
                UPPER(p_color_prefijo);
    
    sku_final := sku_base;
    
    -- Verificar unicidad y agregar sufijo si es necesario
    WHILE EXISTS (SELECT 1 FROM articulos WHERE sku = sku_final) LOOP
        counter := counter + 1;
        sku_final := sku_base || '-' || LPAD(counter::TEXT, 2, '0');
    END LOOP;
    
    RETURN sku_final;
END;
$$;

-- Función para generar nombre completo del artículo
CREATE OR REPLACE FUNCTION generate_article_name(
    p_producto_master_nombre VARCHAR(500),
    p_color_nombre VARCHAR(50)
)
RETURNS VARCHAR(600)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN p_producto_master_nombre || ' ' || UPPER(p_color_nombre);
END;
$$;

-- Función para actualizar timestamp updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- =====================================================
-- 2. TRIGGER PARA AUTO-GENERACIÓN DE SKU Y NOMBRE
-- =====================================================

-- Función trigger para auto-generar SKU en artículos
CREATE OR REPLACE FUNCTION trigger_generate_article_data()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_marca_prefijo VARCHAR(3);
    v_categoria_prefijo VARCHAR(3);
    v_talla_codigo VARCHAR(20);
    v_color_prefijo VARCHAR(3);
    v_producto_nombre VARCHAR(500);
    v_color_nombre VARCHAR(50);
BEGIN
    -- Solo generar si SKU o nombre están vacíos
    IF NEW.sku IS NULL OR NEW.sku = '' OR NEW.nombre_completo IS NULL OR NEW.nombre_completo = '' THEN
        
        -- Obtener datos necesarios para generar SKU y nombre
        SELECT 
            m.prefijo_sku,
            c.prefijo_sku,
            t.codigo,
            col.prefijo_sku,
            pm.nombre,
            col.nombre
        INTO 
            v_marca_prefijo,
            v_categoria_prefijo,
            v_talla_codigo,
            v_color_prefijo,
            v_producto_nombre,
            v_color_nombre
        FROM productos_master pm
        JOIN marcas m ON pm.marca_id = m.id
        JOIN categorias c ON pm.categoria_id = c.id
        JOIN tallas t ON pm.talla_id = t.id
        JOIN colores col ON NEW.color_id = col.id
        WHERE pm.id = NEW.producto_master_id;
        
        -- Generar SKU si está vacío
        IF NEW.sku IS NULL OR NEW.sku = '' THEN
            NEW.sku := generate_sku(v_marca_prefijo, v_categoria_prefijo, v_talla_codigo, v_color_prefijo);
        END IF;
        
        -- Generar nombre completo si está vacío
        IF NEW.nombre_completo IS NULL OR NEW.nombre_completo = '' THEN
            NEW.nombre_completo := generate_article_name(v_producto_nombre, v_color_nombre);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Crear trigger para artículos
CREATE TRIGGER trigger_articulos_generate_data
    BEFORE INSERT OR UPDATE ON articulos
    FOR EACH ROW
    EXECUTE FUNCTION trigger_generate_article_data();

-- =====================================================
-- 3. TRIGGERS PARA ACTUALIZACIÓN DE TIMESTAMPS
-- =====================================================

-- Crear triggers updated_at para todas las tablas
CREATE TRIGGER trigger_marcas_updated_at
    BEFORE UPDATE ON marcas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_categorias_updated_at
    BEFORE UPDATE ON categorias
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_tallas_updated_at
    BEFORE UPDATE ON tallas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_colores_updated_at
    BEFORE UPDATE ON colores
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_tiendas_updated_at
    BEFORE UPDATE ON tiendas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_perfiles_usuario_updated_at
    BEFORE UPDATE ON perfiles_usuario
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_productos_master_updated_at
    BEFORE UPDATE ON productos_master
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_articulos_updated_at
    BEFORE UPDATE ON articulos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_inventario_tienda_updated_at
    BEFORE UPDATE ON inventario_tienda
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- 4. TRIGGER PARA GESTIÓN AUTOMÁTICA DE STOCK
-- =====================================================

-- Función para actualizar stock y crear movimiento
CREATE OR REPLACE FUNCTION update_stock_and_create_movement(
    p_articulo_id UUID,
    p_tienda_id UUID,
    p_tipo_movimiento tipo_movimiento,
    p_cantidad INTEGER,
    p_precio_unitario DECIMAL(10,2) DEFAULT NULL,
    p_motivo TEXT DEFAULT NULL,
    p_referencia_externa VARCHAR(100) DEFAULT NULL,
    p_tienda_origen_id UUID DEFAULT NULL,
    p_usuario_id UUID DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_anterior INTEGER;
    v_stock_nuevo INTEGER;
    v_costo_total DECIMAL(10,2);
BEGIN
    -- Obtener stock actual
    SELECT stock_actual 
    INTO v_stock_anterior
    FROM inventario_tienda 
    WHERE articulo_id = p_articulo_id AND tienda_id = p_tienda_id;
    
    -- Si no existe registro de inventario, crearlo con stock 0
    IF v_stock_anterior IS NULL THEN
        INSERT INTO inventario_tienda (articulo_id, tienda_id, stock_actual, precio_venta)
        VALUES (p_articulo_id, p_tienda_id, 0, COALESCE(p_precio_unitario, 0));
        v_stock_anterior := 0;
    END IF;
    
    -- Calcular nuevo stock
    v_stock_nuevo := v_stock_anterior + p_cantidad;
    
    -- Validar que el stock no sea negativo
    IF v_stock_nuevo < 0 THEN
        RAISE EXCEPTION 'Stock insuficiente. Stock actual: %, Cantidad solicitada: %', v_stock_anterior, ABS(p_cantidad);
    END IF;
    
    -- Calcular costo total
    v_costo_total := COALESCE(p_precio_unitario * ABS(p_cantidad), 0);
    
    -- Actualizar stock en inventario
    UPDATE inventario_tienda 
    SET 
        stock_actual = v_stock_nuevo,
        updated_at = NOW(),
        ultima_venta = CASE WHEN p_tipo_movimiento = 'VENTA' THEN NOW() ELSE ultima_venta END
    WHERE articulo_id = p_articulo_id AND tienda_id = p_tienda_id;
    
    -- Crear registro de movimiento
    INSERT INTO movimientos_stock (
        articulo_id,
        tienda_id,
        tipo_movimiento,
        cantidad,
        stock_anterior,
        stock_nuevo,
        precio_unitario,
        costo_total,
        motivo,
        referencia_externa,
        tienda_origen_id,
        usuario_id
    ) VALUES (
        p_articulo_id,
        p_tienda_id,
        p_tipo_movimiento,
        p_cantidad,
        v_stock_anterior,
        v_stock_nuevo,
        p_precio_unitario,
        v_costo_total,
        p_motivo,
        p_referencia_externa,
        p_tienda_origen_id,
        COALESCE(p_usuario_id, auth.uid())
    );
    
    RETURN TRUE;
END;
$$;

-- =====================================================
-- 5. FUNCIONES PARA REPORTES Y CONSULTAS
-- =====================================================

-- Función para obtener stock consolidado por tienda
CREATE OR REPLACE FUNCTION get_stock_consolidado_tienda(p_tienda_id UUID)
RETURNS TABLE(
    articulo_id UUID,
    sku VARCHAR(50),
    nombre_completo VARCHAR(600),
    marca VARCHAR(100),
    categoria VARCHAR(100),
    talla VARCHAR(20),
    color VARCHAR(50),
    stock_actual INTEGER,
    stock_minimo INTEGER,
    precio_venta DECIMAL(10,2),
    valor_inventario DECIMAL(12,2),
    estado_stock TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.sku,
        a.nombre_completo,
        m.nombre as marca,
        c.nombre as categoria,
        t.codigo as talla,
        col.nombre as color,
        COALESCE(it.stock_actual, 0) as stock_actual,
        COALESCE(it.stock_minimo, 0) as stock_minimo,
        COALESCE(it.precio_venta, pm.precio_sugerido) as precio_venta,
        (COALESCE(it.stock_actual, 0) * COALESCE(it.precio_venta, pm.precio_sugerido)) as valor_inventario,
        CASE 
            WHEN COALESCE(it.stock_actual, 0) = 0 THEN 'SIN_STOCK'
            WHEN COALESCE(it.stock_actual, 0) <= COALESCE(it.stock_minimo, 0) THEN 'STOCK_BAJO'
            ELSE 'STOCK_OK'
        END as estado_stock
    FROM articulos a
    JOIN productos_master pm ON a.producto_master_id = pm.id
    JOIN marcas m ON pm.marca_id = m.id
    JOIN categorias c ON pm.categoria_id = c.id
    JOIN tallas t ON pm.talla_id = t.id
    JOIN colores col ON a.color_id = col.id
    LEFT JOIN inventario_tienda it ON a.id = it.articulo_id AND it.tienda_id = p_tienda_id
    WHERE a.estado = 'ACTIVO'
    AND pm.estado = 'ACTIVO'
    ORDER BY m.nombre, pm.nombre, t.orden_display, col.nombre;
END;
$$;

-- Función para obtener movimientos de stock por período
CREATE OR REPLACE FUNCTION get_movimientos_stock_periodo(
    p_tienda_id UUID,
    p_fecha_inicio TIMESTAMP WITH TIME ZONE,
    p_fecha_fin TIMESTAMP WITH TIME ZONE,
    p_tipo_movimiento tipo_movimiento DEFAULT NULL
)
RETURNS TABLE(
    id UUID,
    articulo_sku VARCHAR(50),
    articulo_nombre VARCHAR(600),
    tipo_movimiento tipo_movimiento,
    cantidad INTEGER,
    stock_anterior INTEGER,
    stock_nuevo INTEGER,
    precio_unitario DECIMAL(10,2),
    costo_total DECIMAL(10,2),
    motivo TEXT,
    referencia_externa VARCHAR(100),
    usuario_nombre VARCHAR(200),
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ms.id,
        a.sku,
        a.nombre_completo,
        ms.tipo_movimiento,
        ms.cantidad,
        ms.stock_anterior,
        ms.stock_nuevo,
        ms.precio_unitario,
        ms.costo_total,
        ms.motivo,
        ms.referencia_externa,
        pu.nombre_completo as usuario_nombre,
        ms.created_at
    FROM movimientos_stock ms
    JOIN articulos a ON ms.articulo_id = a.id
    LEFT JOIN perfiles_usuario pu ON ms.usuario_id = pu.id
    WHERE ms.tienda_id = p_tienda_id
    AND ms.created_at >= p_fecha_inicio
    AND ms.created_at <= p_fecha_fin
    AND (p_tipo_movimiento IS NULL OR ms.tipo_movimiento = p_tipo_movimiento)
    ORDER BY ms.created_at DESC;
END;
$$;

-- Función para obtener artículos con stock bajo
CREATE OR REPLACE FUNCTION get_articulos_stock_bajo(p_tienda_id UUID)
RETURNS TABLE(
    articulo_id UUID,
    sku VARCHAR(50),
    nombre_completo VARCHAR(600),
    stock_actual INTEGER,
    stock_minimo INTEGER,
    diferencia INTEGER,
    precio_venta DECIMAL(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.sku,
        a.nombre_completo,
        it.stock_actual,
        it.stock_minimo,
        (it.stock_minimo - it.stock_actual) as diferencia,
        it.precio_venta
    FROM inventario_tienda it
    JOIN articulos a ON it.articulo_id = a.id
    WHERE it.tienda_id = p_tienda_id
    AND it.activo = true
    AND it.stock_actual <= it.stock_minimo
    AND it.stock_minimo > 0
    ORDER BY diferencia DESC, a.nombre_completo;
END;
$$;

-- =====================================================
-- 6. FUNCIÓN PARA TRASPASO ENTRE TIENDAS
-- =====================================================

CREATE OR REPLACE FUNCTION realizar_traspaso_inventario(
    p_articulo_id UUID,
    p_tienda_origen_id UUID,
    p_tienda_destino_id UUID,
    p_cantidad INTEGER,
    p_motivo TEXT DEFAULT 'Traspaso entre tiendas',
    p_usuario_id UUID DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_precio_origen DECIMAL(10,2);
    v_precio_destino DECIMAL(10,2);
BEGIN
    -- Validar que la cantidad sea positiva
    IF p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor a 0';
    END IF;
    
    -- Validar que las tiendas sean diferentes
    IF p_tienda_origen_id = p_tienda_destino_id THEN
        RAISE EXCEPTION 'Las tiendas de origen y destino deben ser diferentes';
    END IF;
    
    -- Obtener precios de ambas tiendas
    SELECT precio_venta INTO v_precio_origen
    FROM inventario_tienda
    WHERE articulo_id = p_articulo_id AND tienda_id = p_tienda_origen_id;
    
    SELECT precio_venta INTO v_precio_destino
    FROM inventario_tienda
    WHERE articulo_id = p_articulo_id AND tienda_id = p_tienda_destino_id;
    
    -- Si no existe precio destino, usar el precio origen
    v_precio_destino := COALESCE(v_precio_destino, v_precio_origen);
    
    -- Crear movimiento de salida en tienda origen
    PERFORM update_stock_and_create_movement(
        p_articulo_id,
        p_tienda_origen_id,
        'TRASPASO'::tipo_movimiento,
        -p_cantidad, -- Negativo para salida
        v_precio_origen,
        p_motivo || ' - SALIDA a ' || (SELECT codigo FROM tiendas WHERE id = p_tienda_destino_id),
        'TRASPASO-' || gen_random_uuid()::text,
        NULL, -- No hay tienda origen para la salida
        p_usuario_id
    );
    
    -- Crear movimiento de entrada en tienda destino
    PERFORM update_stock_and_create_movement(
        p_articulo_id,
        p_tienda_destino_id,
        'TRASPASO'::tipo_movimiento,
        p_cantidad, -- Positivo para entrada
        v_precio_destino,
        p_motivo || ' - ENTRADA desde ' || (SELECT codigo FROM tiendas WHERE id = p_tienda_origen_id),
        'TRASPASO-' || gen_random_uuid()::text,
        p_tienda_origen_id,
        p_usuario_id
    );
    
    RETURN TRUE;
END;
$$;

COMMIT;