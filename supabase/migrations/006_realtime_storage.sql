-- =====================================================
-- REALTIME Y STORAGE - SISTEMA MEDIAS MULTI-TIENDA
-- =====================================================
-- Descripción: Configuración de Realtime subscriptions y Storage policies
-- Versión: 1.0.0
-- Fecha: 2025-09-11

BEGIN;

-- =====================================================
-- 1. HABILITAR REALTIME EN TABLAS CRÍTICAS
-- =====================================================

-- Habilitar Realtime para inventario (cambios de stock en tiempo real)
ALTER publication supabase_realtime ADD TABLE inventario_tienda;

-- Habilitar Realtime para movimientos de stock (auditoría en tiempo real)
ALTER publication supabase_realtime ADD TABLE movimientos_stock;

-- Habilitar Realtime para artículos (cambios de catálogo)
ALTER publication supabase_realtime ADD TABLE articulos;

-- Habilitar Realtime para productos master (cambios de catálogo)
ALTER publication supabase_realtime ADD TABLE productos_master;

-- =====================================================
-- 2. STORAGE BUCKETS PARA IMÁGENES
-- =====================================================

-- Crear bucket para imágenes de productos (públicas)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'producto-images',
    'producto-images',
    true,
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- Crear bucket para logos de marcas (públicas)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'marca-logos',
    'marca-logos',
    true,
    2097152, -- 2MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']
) ON CONFLICT (id) DO NOTHING;

-- Crear bucket para documentos privados (facturas, reportes)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'documents',
    'documents',
    false,
    10485760, -- 10MB
    ARRAY['application/pdf', 'text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. STORAGE POLICIES PARA IMÁGENES DE PRODUCTOS
-- =====================================================

-- Política para leer imágenes de productos (público)
CREATE POLICY "Imágenes productos lectura pública"
ON storage.objects FOR SELECT
USING (bucket_id = 'producto-images');

-- Política para subir imágenes de productos (solo SUPER_ADMIN y ADMIN_TIENDA)
CREATE POLICY "Imágenes productos subida admin"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'producto-images' AND
    (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        )
    )
);

-- Política para actualizar imágenes de productos
CREATE POLICY "Imágenes productos actualización admin"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'producto-images' AND
    (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        )
    )
);

-- Política para eliminar imágenes de productos (solo SUPER_ADMIN)
CREATE POLICY "Imágenes productos eliminación super admin"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'producto-images' AND
    (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'SUPER_ADMIN'
        )
    )
);

-- =====================================================
-- 4. STORAGE POLICIES PARA LOGOS DE MARCAS
-- =====================================================

-- Política para leer logos de marcas (público)
CREATE POLICY "Logos marcas lectura pública"
ON storage.objects FOR SELECT
USING (bucket_id = 'marca-logos');

-- Política para gestionar logos (solo SUPER_ADMIN)
CREATE POLICY "Logos marcas gestión super admin"
ON storage.objects FOR ALL
USING (
    bucket_id = 'marca-logos' AND
    (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'SUPER_ADMIN'
        )
    )
);

-- =====================================================
-- 5. STORAGE POLICIES PARA DOCUMENTOS PRIVADOS
-- =====================================================

-- Política para documentos privados (basado en tienda)
CREATE POLICY "Documentos lectura por tienda"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'documents' AND
    (
        -- SUPER_ADMIN puede ver todo
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'SUPER_ADMIN'
        )
        OR
        -- ADMIN_TIENDA y VENDEDOR solo documentos de su tienda
        (
            name LIKE ('%/' || (
                SELECT ti.codigo 
                FROM get_user_role_and_store() gs
                JOIN tiendas ti ON gs.store_id = ti.id
            ) || '/%')
        )
    )
);

-- Política para subir documentos
CREATE POLICY "Documentos subida por rol"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'documents' AND
    (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('SUPER_ADMIN', 'ADMIN_TIENDA')
        )
    )
);

-- =====================================================
-- 6. FUNCIONES PARA NOTIFICACIONES REALTIME
-- =====================================================

-- Función para enviar notificaciones de stock bajo
CREATE OR REPLACE FUNCTION notify_low_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    notification_payload JSON;
BEGIN
    -- Solo notificar si el stock nuevo está por debajo del mínimo
    IF NEW.stock_actual <= NEW.stock_minimo AND NEW.stock_minimo > 0 THEN
        
        -- Construir payload con información del artículo
        SELECT json_build_object(
            'type', 'low_stock_alert',
            'tienda_id', NEW.tienda_id,
            'tienda_codigo', t.codigo,
            'articulo_id', NEW.articulo_id,
            'sku', a.sku,
            'nombre_completo', a.nombre_completo,
            'stock_actual', NEW.stock_actual,
            'stock_minimo', NEW.stock_minimo,
            'timestamp', NOW()
        ) INTO notification_payload
        FROM articulos a
        JOIN tiendas t ON NEW.tienda_id = t.id
        WHERE a.id = NEW.articulo_id;
        
        -- Enviar notificación via pg_notify
        PERFORM pg_notify('low_stock_alert', notification_payload::text);
    END IF;
    
    RETURN NEW;
END;
$$;

-- Trigger para notificaciones de stock bajo
CREATE TRIGGER trigger_notify_low_stock
    AFTER UPDATE OF stock_actual ON inventario_tienda
    FOR EACH ROW
    EXECUTE FUNCTION notify_low_stock();

-- Función para notificar movimientos de stock importantes
CREATE OR REPLACE FUNCTION notify_stock_movement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    notification_payload JSON;
BEGIN
    -- Notificar solo movimientos significativos o de ciertos tipos
    IF NEW.tipo_movimiento IN ('VENTA', 'TRASPASO') OR ABS(NEW.cantidad) >= 10 THEN
        
        SELECT json_build_object(
            'type', 'stock_movement',
            'movimiento_id', NEW.id,
            'tipo_movimiento', NEW.tipo_movimiento,
            'tienda_id', NEW.tienda_id,
            'tienda_codigo', t.codigo,
            'articulo_id', NEW.articulo_id,
            'sku', a.sku,
            'nombre_completo', a.nombre_completo,
            'cantidad', NEW.cantidad,
            'stock_anterior', NEW.stock_anterior,
            'stock_nuevo', NEW.stock_nuevo,
            'motivo', NEW.motivo,
            'timestamp', NEW.created_at
        ) INTO notification_payload
        FROM articulos a
        JOIN tiendas t ON NEW.tienda_id = t.id
        WHERE a.id = NEW.articulo_id;
        
        PERFORM pg_notify('stock_movement', notification_payload::text);
    END IF;
    
    RETURN NEW;
END;
$$;

-- Trigger para notificaciones de movimientos
CREATE TRIGGER trigger_notify_stock_movement
    AFTER INSERT ON movimientos_stock
    FOR EACH ROW
    EXECUTE FUNCTION notify_stock_movement();

-- =====================================================
-- 7. FUNCIÓN PARA LIMPIAR NOTIFICACIONES ANTIGUAS
-- =====================================================

-- Función para limpiar movimientos antiguos (más de 6 meses)
CREATE OR REPLACE FUNCTION cleanup_old_movements()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Eliminar movimientos más antiguos de 6 meses, excepto movimientos críticos
    DELETE FROM movimientos_stock
    WHERE created_at < NOW() - INTERVAL '6 months'
    AND tipo_movimiento NOT IN ('ENTRADA', 'TRASPASO') -- Conservar entradas y traspasos para auditoría
    AND referencia_externa NOT LIKE 'INIT-%'; -- Conservar movimientos iniciales
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RAISE NOTICE 'Eliminados % movimientos antiguos', deleted_count;
    RETURN deleted_count;
END;
$$;

-- =====================================================
-- 8. CHANNEL CONFIGURATION PARA REALTIME
-- =====================================================

-- Crear canales Realtime específicos por tienda
-- Los clientes se suscribirán a: `inventory_changes:tienda_id=uuid`

-- Función para obtener configuración de canales Realtime
CREATE OR REPLACE FUNCTION get_realtime_channels(p_user_id UUID DEFAULT NULL)
RETURNS TABLE(
    channel_name TEXT,
    table_name TEXT,
    filter TEXT,
    description TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_role rol_usuario;
    user_store_id UUID;
BEGIN
    -- Obtener rol y tienda del usuario
    SELECT gs.user_role, gs.store_id INTO user_role, user_store_id
    FROM get_user_role_and_store() gs;
    
    IF user_role IS NULL THEN
        RETURN; -- No hay configuración para usuario sin rol
    END IF;
    
    -- SUPER_ADMIN puede suscribirse a todos los canales
    IF user_role = 'SUPER_ADMIN' THEN
        RETURN QUERY VALUES
            ('inventory_global', 'inventario_tienda', '', 'Cambios globales de inventario'),
            ('movements_global', 'movimientos_stock', '', 'Movimientos globales de stock'),
            ('catalog_changes', 'articulos', '', 'Cambios en catálogo de artículos'),
            ('products_changes', 'productos_master', '', 'Cambios en productos master');
    ELSE
        -- ADMIN_TIENDA y VENDEDOR solo canales de su tienda
        RETURN QUERY VALUES
            ('inventory_store_' || user_store_id::text, 'inventario_tienda', 'tienda_id=eq.' || user_store_id::text, 'Inventario de tienda específica'),
            ('movements_store_' || user_store_id::text, 'movimientos_stock', 'tienda_id=eq.' || user_store_id::text, 'Movimientos de tienda específica'),
            ('catalog_changes', 'articulos', '', 'Cambios en catálogo (lectura)');
    END IF;
END;
$$;

-- =====================================================
-- 9. ÍNDICES ADICIONALES PARA REALTIME PERFORMANCE
-- =====================================================

-- Índices para mejorar performance de subscripciones Realtime
CREATE INDEX IF NOT EXISTS idx_inventario_realtime ON inventario_tienda(tienda_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_movimientos_realtime ON movimientos_stock(tienda_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_articulos_realtime ON articulos(updated_at DESC) WHERE estado = 'ACTIVO';

-- =====================================================
-- 10. COMENTARIOS Y DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION notify_low_stock() IS 'Envía notificaciones en tiempo real cuando el stock está bajo el mínimo';
COMMENT ON FUNCTION notify_stock_movement() IS 'Notifica movimientos de stock importantes via pg_notify';
COMMENT ON FUNCTION cleanup_old_movements() IS 'Limpia movimientos antiguos para mantener performance';
COMMENT ON FUNCTION get_realtime_channels(UUID) IS 'Retorna canales Realtime permitidos según rol de usuario';

COMMIT;