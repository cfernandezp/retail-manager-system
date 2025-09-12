-- =====================================================
-- RLS POLICIES - SISTEMA MEDIAS MULTI-TIENDA
-- =====================================================
-- Descripción: Políticas de seguridad por rol (SUPER_ADMIN, ADMIN_TIENDA, VENDEDOR)
-- Versión: 1.0.0
-- Fecha: 2025-09-11

BEGIN;

-- =====================================================
-- 1. HABILITAR RLS EN TODAS LAS TABLAS
-- =====================================================

-- Tablas maestras
ALTER TABLE marcas ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE tallas ENABLE ROW LEVEL SECURITY;
ALTER TABLE colores ENABLE ROW LEVEL SECURITY;

-- Tiendas y usuarios
ALTER TABLE tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE perfiles_usuario ENABLE ROW LEVEL SECURITY;

-- Productos
ALTER TABLE productos_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE articulos ENABLE ROW LEVEL SECURITY;

-- Inventario
ALTER TABLE inventario_tienda ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_stock ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. FUNCIÓN AUXILIAR PARA OBTENER ROL Y TIENDA DEL USUARIO
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_role_and_store()
RETURNS TABLE(user_role rol_usuario, store_id UUID)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.rol::rol_usuario,
        p.tienda_id
    FROM perfiles_usuario p
    WHERE p.id = auth.uid();
    
    -- Si no hay perfil, retornar valores seguros que denieguen acceso
    IF NOT FOUND THEN
        RETURN QUERY SELECT NULL::rol_usuario, NULL::UUID;
    END IF;
END;
$$;

-- =====================================================
-- 3. POLÍTICAS PARA TABLAS MAESTRAS (Solo lectura para VENDEDOR)
-- =====================================================

-- MARCAS - SUPER_ADMIN puede modificar, otros solo leer activas
CREATE POLICY "marcas_super_admin_all" ON marcas
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "marcas_read_active" ON marcas
    FOR SELECT USING (
        activo = true AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('ADMIN_TIENDA', 'VENDEDOR')
        )
    );

-- CATEGORIAS - Misma lógica que marcas
CREATE POLICY "categorias_super_admin_all" ON categorias
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "categorias_read_active" ON categorias
    FOR SELECT USING (
        activo = true AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('ADMIN_TIENDA', 'VENDEDOR')
        )
    );

-- TALLAS - Misma lógica que marcas
CREATE POLICY "tallas_super_admin_all" ON tallas
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "tallas_read_active" ON tallas
    FOR SELECT USING (
        activo = true AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('ADMIN_TIENDA', 'VENDEDOR')
        )
    );

-- COLORES - Misma lógica que marcas
CREATE POLICY "colores_super_admin_all" ON colores
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "colores_read_active" ON colores
    FOR SELECT USING (
        activo = true AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('ADMIN_TIENDA', 'VENDEDOR')
        )
    );

-- =====================================================
-- 4. POLÍTICAS PARA TIENDAS
-- =====================================================

-- TIENDAS - SUPER_ADMIN ve todas, ADMIN_TIENDA/VENDEDOR solo la suya
CREATE POLICY "tiendas_super_admin_all" ON tiendas
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "tiendas_own_store_read" ON tiendas
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('ADMIN_TIENDA', 'VENDEDOR') 
            AND store_id = tiendas.id
        )
    );

-- ADMIN_TIENDA puede actualizar configuración de su tienda
CREATE POLICY "tiendas_admin_update_own" ON tiendas
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'ADMIN_TIENDA' AND store_id = tiendas.id
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'ADMIN_TIENDA' AND store_id = tiendas.id
        )
    );

-- =====================================================
-- 5. POLÍTICAS PARA PERFILES DE USUARIO
-- =====================================================

-- PERFILES_USUARIO - SUPER_ADMIN ve todos, otros solo el suyo y compañeros de tienda
CREATE POLICY "perfiles_super_admin_all" ON perfiles_usuario
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "perfiles_own_profile" ON perfiles_usuario
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "perfiles_same_store" ON perfiles_usuario
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() gs
            WHERE gs.user_role IN ('ADMIN_TIENDA', 'VENDEDOR') 
            AND gs.store_id = perfiles_usuario.tienda_id
        )
    );

-- Solo SUPER_ADMIN puede crear/modificar perfiles
CREATE POLICY "perfiles_super_admin_modify" ON perfiles_usuario
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "perfiles_super_admin_update" ON perfiles_usuario
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

-- Usuarios pueden actualizar su propio perfil (datos básicos)
CREATE POLICY "perfiles_update_own_basic" ON perfiles_usuario
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (
        id = auth.uid() AND
        -- No pueden cambiar rol ni tienda asignada
        rol = (SELECT rol FROM perfiles_usuario WHERE id = auth.uid()) AND
        tienda_id = (SELECT tienda_id FROM perfiles_usuario WHERE id = auth.uid())
    );

-- =====================================================
-- 6. POLÍTICAS PARA PRODUCTOS MASTER
-- =====================================================

-- PRODUCTOS_MASTER - SUPER_ADMIN gestiona catálogo, otros solo leen activos
CREATE POLICY "productos_master_super_admin_all" ON productos_master
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "productos_master_read_active" ON productos_master
    FOR SELECT USING (
        estado = 'ACTIVO' AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('ADMIN_TIENDA', 'VENDEDOR')
        )
    );

-- =====================================================
-- 7. POLÍTICAS PARA ARTICULOS
-- =====================================================

-- ARTICULOS - SUPER_ADMIN gestiona, otros leen activos
CREATE POLICY "articulos_super_admin_all" ON articulos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY "articulos_read_active" ON articulos
    FOR SELECT USING (
        estado = 'ACTIVO' AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role IN ('ADMIN_TIENDA', 'VENDEDOR')
        )
    );

-- =====================================================
-- 8. POLÍTICAS PARA INVENTARIO_TIENDA (Críticas)
-- =====================================================

-- SUPER_ADMIN ve todo el inventario
CREATE POLICY "inventario_super_admin_all" ON inventario_tienda
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

-- ADMIN_TIENDA gestiona inventario de su tienda
CREATE POLICY "inventario_admin_own_store" ON inventario_tienda
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'ADMIN_TIENDA' AND store_id = inventario_tienda.tienda_id
        )
    );

-- VENDEDOR solo lee inventario activo de su tienda
CREATE POLICY "inventario_vendedor_read_own_store" ON inventario_tienda
    FOR SELECT USING (
        activo = true AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'VENDEDOR' AND store_id = inventario_tienda.tienda_id
        )
    );

-- =====================================================
-- 9. POLÍTICAS PARA MOVIMIENTOS_STOCK
-- =====================================================

-- SUPER_ADMIN ve todos los movimientos
CREATE POLICY "movimientos_super_admin_all" ON movimientos_stock
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() WHERE user_role = 'SUPER_ADMIN'
        )
    );

-- ADMIN_TIENDA ve movimientos de su tienda y puede crear nuevos
CREATE POLICY "movimientos_admin_own_store" ON movimientos_stock
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'ADMIN_TIENDA' AND store_id = movimientos_stock.tienda_id
        )
    );

CREATE POLICY "movimientos_admin_create_own_store" ON movimientos_stock
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'ADMIN_TIENDA' AND store_id = movimientos_stock.tienda_id
        )
    );

-- VENDEDOR puede crear movimientos de venta en su tienda
CREATE POLICY "movimientos_vendedor_create_venta" ON movimientos_stock
    FOR INSERT WITH CHECK (
        tipo_movimiento = 'VENTA' AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'VENDEDOR' AND store_id = movimientos_stock.tienda_id
        )
    );

-- VENDEDOR puede ver movimientos recientes de su tienda (últimos 30 días)
CREATE POLICY "movimientos_vendedor_read_recent" ON movimientos_stock
    FOR SELECT USING (
        created_at >= NOW() - INTERVAL '30 days' AND
        EXISTS (
            SELECT 1 FROM get_user_role_and_store() 
            WHERE user_role = 'VENDEDOR' AND store_id = movimientos_stock.tienda_id
        )
    );

-- =====================================================
-- 10. INDICES ADICIONALES PARA RLS PERFORMANCE
-- =====================================================

-- Índice para función get_user_role_and_store()
CREATE INDEX IF NOT EXISTS idx_perfiles_usuario_auth_uid ON perfiles_usuario(id) WHERE id IS NOT NULL;

-- Índices para filtros RLS frecuentes
CREATE INDEX IF NOT EXISTS idx_inventario_tienda_activo_rls ON inventario_tienda(tienda_id, activo) WHERE activo = true;
CREATE INDEX IF NOT EXISTS idx_articulos_estado_activo_rls ON articulos(estado) WHERE estado = 'ACTIVO';
CREATE INDEX IF NOT EXISTS idx_productos_master_estado_activo_rls ON productos_master(estado) WHERE estado = 'ACTIVO';

COMMIT;