-- =====================================================
-- FUNCIONES Y TRIGGERS LIMPIOS - BASADOS EN ESTADO REAL BD
-- =====================================================
-- Archivo: 003_functions_triggers_clean.sql
-- Propósito: Reemplazo limpio de 003_functions_triggers.sql
-- Basado en: Estado actual funcional de BD
-- Fecha: 2025-09-15
--
-- FUNCIONES INCLUIDAS:
-- - update_updated_at_column(): Trigger automático para updated_at
-- - generate_sku(): Generación automática de SKUs
-- - update_stock(): Actualización de stock con movimientos
-- =====================================================

-- =====================================================
-- FUNCIÓN: ACTUALIZACIÓN AUTOMÁTICA DE updated_at
-- =====================================================

-- Función para actualizar campo updated_at automáticamente
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS PARA updated_at EN TODAS LAS TABLAS
-- =====================================================

-- Trigger para marcas
CREATE TRIGGER trigger_marcas_updated_at
    BEFORE UPDATE ON marcas
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para categorias
CREATE TRIGGER trigger_categorias_updated_at
    BEFORE UPDATE ON categorias
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para tallas
CREATE TRIGGER trigger_tallas_updated_at
    BEFORE UPDATE ON tallas
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para colores
CREATE TRIGGER trigger_colores_updated_at
    BEFORE UPDATE ON colores
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para materiales
CREATE TRIGGER trigger_materiales_updated_at
    BEFORE UPDATE ON materiales
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para roles
CREATE TRIGGER trigger_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para tiendas
CREATE TRIGGER trigger_tiendas_updated_at
    BEFORE UPDATE ON tiendas
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para usuarios
CREATE TRIGGER trigger_usuarios_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para productos_master
CREATE TRIGGER trigger_productos_master_updated_at
    BEFORE UPDATE ON productos_master
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para articulos
CREATE TRIGGER trigger_articulos_updated_at
    BEFORE UPDATE ON articulos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para inventario_tienda
CREATE TRIGGER trigger_inventario_tienda_updated_at
    BEFORE UPDATE ON inventario_tienda
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- =====================================================
-- FUNCIÓN: GENERACIÓN AUTOMÁTICA DE SKUs
-- =====================================================

-- Función para generar SKU automático basado en prefijos
CREATE OR REPLACE FUNCTION generate_sku(
    marca_prefijo VARCHAR(3),
    categoria_prefijo VARCHAR(3),
    color_prefijo VARCHAR(3),
    talla_codigo VARCHAR(20)
)
RETURNS VARCHAR(50) AS $$
DECLARE
    nuevo_sku VARCHAR(50);
    contador INTEGER;
BEGIN
    -- Generar SKU base: MARCA-CATEGORIA-COLOR-TALLA
    nuevo_sku := UPPER(marca_prefijo || '-' || categoria_prefijo || '-' || color_prefijo || '-' || talla_codigo);

    -- Verificar si el SKU ya existe
    SELECT COUNT(*) INTO contador
    FROM articulos
    WHERE sku = nuevo_sku;

    -- Si existe, agregar sufijo numérico
    IF contador > 0 THEN
        contador := 1;
        WHILE EXISTS (SELECT 1 FROM articulos WHERE sku = nuevo_sku || '-' || contador::text) LOOP
            contador := contador + 1;
        END LOOP;
        nuevo_sku := nuevo_sku || '-' || contador::text;
    END IF;

    RETURN nuevo_sku;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: ACTUALIZACIÓN DE STOCK CON MOVIMIENTOS
-- =====================================================

-- Función para actualizar stock y registrar movimiento
CREATE OR REPLACE FUNCTION update_stock(
    p_articulo_id UUID,
    p_tienda_id UUID,
    p_tipo_movimiento tipo_movimiento,
    p_cantidad INTEGER,
    p_motivo TEXT DEFAULT NULL,
    p_precio_unitario DECIMAL DEFAULT NULL,
    p_usuario_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    stock_anterior INTEGER;
    stock_nuevo INTEGER;
    costo_calculado DECIMAL(10,2);
BEGIN
    -- Obtener stock actual
    SELECT stock_actual INTO stock_anterior
    FROM inventario_tienda
    WHERE articulo_id = p_articulo_id AND tienda_id = p_tienda_id;

    -- Si no existe el registro de inventario, crearlo
    IF stock_anterior IS NULL THEN
        INSERT INTO inventario_tienda (articulo_id, tienda_id, stock_actual, precio_venta, precio_costo)
        VALUES (p_articulo_id, p_tienda_id, 0, 0, 0);
        stock_anterior := 0;
    END IF;

    -- Calcular nuevo stock según tipo de movimiento
    CASE p_tipo_movimiento
        WHEN 'ENTRADA', 'DEVOLUCION' THEN
            stock_nuevo := stock_anterior + p_cantidad;
        WHEN 'SALIDA', 'VENTA' THEN
            stock_nuevo := stock_anterior - p_cantidad;
        WHEN 'AJUSTE' THEN
            stock_nuevo := p_cantidad; -- p_cantidad es el nuevo valor absoluto
        ELSE
            stock_nuevo := stock_anterior + p_cantidad; -- Default para TRASPASO
    END CASE;

    -- Validar que el stock no sea negativo
    IF stock_nuevo < 0 THEN
        RAISE EXCEPTION 'Stock insuficiente. Stock actual: %, Cantidad solicitada: %', stock_anterior, p_cantidad;
    END IF;

    -- Calcular costo total
    costo_calculado := COALESCE(p_precio_unitario, 0) * ABS(p_cantidad);

    -- Actualizar stock en inventario_tienda
    UPDATE inventario_tienda
    SET stock_actual = stock_nuevo,
        updated_at = NOW()
    WHERE articulo_id = p_articulo_id AND tienda_id = p_tienda_id;

    -- Registrar movimiento
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
        usuario_id
    ) VALUES (
        p_articulo_id,
        p_tienda_id,
        p_tipo_movimiento,
        p_cantidad,
        stock_anterior,
        stock_nuevo,
        p_precio_unitario,
        costo_calculado,
        p_motivo,
        p_usuario_id
    );

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCIÓN: VALIDACIÓN DE TALLAS SEGÚN TIPO
-- =====================================================

-- Función para validar datos de talla según su tipo (CORREGIDA para schema real)
CREATE OR REPLACE FUNCTION validate_talla_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar campos requeridos
    IF NEW.codigo IS NULL OR NEW.codigo = '' THEN
        RAISE EXCEPTION 'codigo es requerido';
    END IF;

    IF NEW.nombre IS NULL OR NEW.nombre = '' THEN
        RAISE EXCEPTION 'nombre es requerido';
    END IF;

    IF NEW.valor IS NULL OR NEW.valor = '' THEN
        RAISE EXCEPTION 'valor es requerido';
    END IF;

    -- Validar tipo de talla permitidos
    IF NEW.tipo NOT IN ('RANGO', 'INDIVIDUAL', 'LETRA') THEN
        RAISE EXCEPTION 'tipo debe ser RANGO, INDIVIDUAL o LETRA';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validación de tallas
CREATE TRIGGER trigger_validate_talla_data
    BEFORE INSERT OR UPDATE ON tallas
    FOR EACH ROW
    EXECUTE FUNCTION validate_talla_data();

-- =====================================================
-- FUNCIÓN: TRIGGER PARA SKU AUTOMÁTICO EN ARTÍCULOS
-- =====================================================

-- Función para generar SKU automáticamente al insertar artículo
CREATE OR REPLACE FUNCTION generar_sku_articulo()
RETURNS TRIGGER AS $$
DECLARE
    marca_codigo VARCHAR(5);
    categoria_codigo VARCHAR(5);
    talla_codigo VARCHAR(10);
    color_codigo VARCHAR(5);
    nuevo_sku VARCHAR(100);
BEGIN
    -- Solo generar SKU si no se proporciona uno
    IF NEW.sku_auto IS NULL OR NEW.sku_auto = '' THEN
        -- Obtener códigos para construir SKU
        SELECT
            UPPER(LEFT(REGEXP_REPLACE(m.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
            UPPER(LEFT(REGEXP_REPLACE(c.nombre, '[^A-Za-z0-9]', '', 'g'), 3)),
            UPPER(REGEXP_REPLACE(t.codigo, '[^A-Za-z0-9]', '', 'g')),
            col.codigo_abrev
        INTO marca_codigo, categoria_codigo, talla_codigo, color_codigo
        FROM productos_master pm
        JOIN marcas m ON pm.marca_id = m.id
        JOIN categorias c ON pm.categoria_id = c.id
        JOIN tallas t ON pm.talla_id = t.id
        JOIN colores col ON NEW.color_id = col.id
        WHERE pm.id = NEW.producto_master_id;

        -- Construir SKU: MED-POL-ARL-912-AZU
        nuevo_sku := 'MED-' || categoria_codigo || '-' || marca_codigo || '-' || talla_codigo || '-' || color_codigo;

        -- Verificar unicidad y agregar sufijo si es necesario
        WHILE EXISTS (SELECT 1 FROM articulos WHERE sku_auto = nuevo_sku) LOOP
            nuevo_sku := nuevo_sku || '-' || TO_CHAR(FLOOR(RANDOM() * 100), 'FM00');
        END LOOP;

        NEW.sku_auto := nuevo_sku;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para SKU automático
CREATE TRIGGER trigger_generar_sku_articulo
    BEFORE INSERT OR UPDATE ON articulos
    FOR EACH ROW
    EXECUTE FUNCTION generar_sku_articulo();

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION actualizar_updated_at() IS 'Actualiza automáticamente el campo updated_at';
COMMENT ON FUNCTION generate_sku(VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS 'Genera SKU automático basado en prefijos';
COMMENT ON FUNCTION update_stock(UUID, UUID, tipo_movimiento, INTEGER, TEXT, DECIMAL, UUID) IS 'Actualiza stock y registra movimiento';
COMMENT ON FUNCTION validate_talla_data() IS 'Valida consistencia de datos según tipo de talla';
COMMENT ON FUNCTION generar_sku_articulo() IS 'Genera SKU automáticamente para artículos';

-- Fin de funciones y triggers limpios