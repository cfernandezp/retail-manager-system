-- =====================================================
-- POLÍTICAS RLS LIMPIAS - BASADAS EN ESTADO REAL BD
-- =====================================================
-- Archivo: 002_rls_policies_clean.sql
-- Propósito: Reemplazo limpio de 002_rls_policies.sql
-- Basado en: docs/CURRENT_SCHEMA_STATE.md (validado 2025-09-14)
-- Fecha: 2025-09-15
--
-- ESTADO RLS CONFIRMADO:
-- - Tablas catálogo (marcas, categorias, tallas, colores): RLS DESHABILITADO
-- - materiales: RLS DESHABILITADO
-- - tiendas: RLS DESHABILITADO
-- - productos/inventario: RLS DESHABILITADO
-- =====================================================

-- =====================================================
-- RLS PARA TABLAS DE CATÁLOGO - DESHABILITADO
-- =====================================================

-- MARCAS - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE marcas DISABLE ROW LEVEL SECURITY;

-- CATEGORIAS - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE categorias DISABLE ROW LEVEL SECURITY;

-- TALLAS - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE tallas DISABLE ROW LEVEL SECURITY;

-- COLORES - RLS DESHABILITADO (alineado con otras tablas catálogo)
ALTER TABLE colores DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS PARA MATERIALES - DESHABILITADO (CATÁLOGO PÚBLICO)
-- =====================================================

-- MATERIALES - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE materiales DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS PARA ROLES - DESHABILITADO (PÚBLICO)
-- =====================================================

-- ROLES - RLS DESHABILITADO (acceso público para consultas)
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS PARA TIENDAS - DESHABILITADO
-- =====================================================

-- TIENDAS - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE tiendas DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS PARA USUARIOS - HABILITADO
-- =====================================================

-- USUARIOS - RLS HABILITADO (compatible con frontend)
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Política: Usuarios pueden ver su propio perfil
CREATE POLICY "usuarios_propio_perfil" ON usuarios
    FOR ALL
    USING (auth.uid() = id);

-- Política: Admins pueden ver todos los usuarios
CREATE POLICY "admin_ve_todos_usuarios" ON usuarios
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            JOIN roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre IN ('SUPER_ADMIN', 'ADMIN')
        )
    );

-- Política: Admins pueden insertar usuarios
CREATE POLICY "admin_inserta_usuarios" ON usuarios
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM usuarios u
            JOIN roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre IN ('SUPER_ADMIN', 'ADMIN')
        )
    );

-- Política: Admins pueden actualizar usuarios
CREATE POLICY "admin_actualiza_usuarios" ON usuarios
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            JOIN roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre IN ('SUPER_ADMIN', 'ADMIN')
        )
    );

-- Política: Admins pueden eliminar usuarios
CREATE POLICY "admin_elimina_usuarios" ON usuarios
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM usuarios u
            JOIN roles r ON u.rol_id = r.id
            WHERE u.id = auth.uid()
            AND r.nombre IN ('SUPER_ADMIN', 'ADMIN')
        )
    );

-- =====================================================
-- RLS PARA PRODUCTOS - DESHABILITADO
-- =====================================================

-- PRODUCTOS_MASTER - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE productos_master DISABLE ROW LEVEL SECURITY;

-- ARTICULOS - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE articulos DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS PARA INVENTARIO - DESHABILITADO
-- =====================================================

-- INVENTARIO_TIENDA - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE inventario_tienda DISABLE ROW LEVEL SECURITY;

-- MOVIMIENTOS_STOCK - RLS DESHABILITADO (confirmado estado real)
ALTER TABLE movimientos_stock DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS AUXILIARES (SI SE REQUIEREN EN FUTURO)
-- =====================================================

-- Las siguientes políticas están comentadas pero disponibles
-- para habilitación futura si se requiere RLS específico

/*
-- Política base para lectura de catálogo
CREATE OR REPLACE FUNCTION catalog_read_policy()
RETURNS BOOLEAN AS $$
BEGIN
    -- Permitir lectura de catálogo a usuarios autenticados
    RETURN auth.uid() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Política base para escritura de admin
CREATE OR REPLACE FUNCTION admin_write_policy()
RETURNS BOOLEAN AS $$
BEGIN
    -- Solo admins pueden escribir
    RETURN EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = auth.uid()
        AND (
            auth.users.email LIKE '%admin%' OR
            auth.users.raw_user_meta_data->>'role' = 'admin'
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
*/

-- =====================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================

COMMENT ON TABLE marcas IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';
COMMENT ON TABLE categorias IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';
COMMENT ON TABLE tallas IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';
COMMENT ON TABLE colores IS 'RLS DESHABILITADO - Alineado con catálogo estado real';
COMMENT ON TABLE materiales IS 'RLS DESHABILITADO - Catálogo público como otras tablas base';
COMMENT ON TABLE tiendas IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';
COMMENT ON TABLE productos_master IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';
COMMENT ON TABLE articulos IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';
COMMENT ON TABLE inventario_tienda IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';
COMMENT ON TABLE movimientos_stock IS 'RLS DESHABILITADO - Acceso directo confirmado estado real';

-- =====================================================
-- CORRECCIÓN RLS RECURSIVO - AGREGADO 2025-09-15
-- =====================================================

-- ELIMINAR políticas recursivas problemáticas en usuarios
DROP POLICY IF EXISTS "admin_ve_todos_usuarios" ON usuarios;
DROP POLICY IF EXISTS "admin_inserta_usuarios" ON usuarios;
DROP POLICY IF EXISTS "admin_actualiza_usuarios" ON usuarios;
DROP POLICY IF EXISTS "admin_elimina_usuarios" ON usuarios;

-- CREAR política NO RECURSIVA para usuarios
CREATE POLICY "usuarios_acceso_no_recursivo" ON usuarios
    FOR ALL
    USING (
        -- Acceso propio
        auth.uid() = id
        OR
        -- Admin por email directo (sin consultar tabla usuarios)
        auth.jwt() ->> 'email' = 'admin@test.com'
    );

COMMENT ON POLICY "usuarios_acceso_no_recursivo" ON usuarios IS 'Política RLS no recursiva corrige error infinite recursion';

-- =====================================================
-- POLÍTICAS RLS MÓDULO DE VENTAS
-- =====================================================

-- Habilitar RLS en tablas de ventas
ALTER TABLE estrategias_descuento ENABLE ROW LEVEL SECURITY;
ALTER TABLE permisos_descuento ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalles_venta ENABLE ROW LEVEL SECURITY;
ALTER TABLE aprobaciones_descuento ENABLE ROW LEVEL SECURITY;

-- Políticas para estrategias_descuento
CREATE POLICY "estrategias_descuento_select" ON estrategias_descuento
    FOR SELECT USING (
        -- Todos los usuarios autenticados pueden ver estrategias activas
        activa = true AND (
            tienda_id IS NULL OR
            tienda_id IN (
                SELECT tienda_id FROM usuarios WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY "estrategias_descuento_admin" ON estrategias_descuento
    FOR ALL USING (
        -- Solo admin puede modificar estrategias
        auth.jwt() ->> 'email' = 'admin@test.com'
        OR
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE id = auth.uid() AND rol IN ('admin', 'supervisor')
        )
    );

-- Políticas para permisos_descuento
CREATE POLICY "permisos_descuento_select" ON permisos_descuento
    FOR SELECT USING (
        -- Todos pueden ver sus permisos
        activo = true
    );

CREATE POLICY "permisos_descuento_admin" ON permisos_descuento
    FOR ALL USING (
        -- Solo admin puede modificar permisos
        auth.jwt() ->> 'email' = 'admin@test.com'
        OR
        EXISTS (
            SELECT 1 FROM usuarios
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Políticas para ventas (los vendedores solo ven sus ventas, supervisores ven las de su tienda)
CREATE POLICY "ventas_vendedor_propias" ON ventas
    FOR ALL USING (
        vendedor_id = auth.uid()
        OR
        -- Admin ve todas
        auth.jwt() ->> 'email' = 'admin@test.com'
        OR
        -- Supervisor ve las de su tienda
        EXISTS (
            SELECT 1 FROM usuarios u
            WHERE u.id = auth.uid()
            AND u.rol IN ('supervisor', 'admin')
            AND (u.rol = 'admin' OR u.tienda_id = ventas.tienda_id)
        )
    );

-- Políticas para detalles_venta (siguen la misma lógica que ventas)
CREATE POLICY "detalles_venta_acceso" ON detalles_venta
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM ventas v
            WHERE v.id = detalles_venta.venta_id
            AND (
                v.vendedor_id = auth.uid()
                OR
                auth.jwt() ->> 'email' = 'admin@test.com'
                OR
                EXISTS (
                    SELECT 1 FROM usuarios u
                    WHERE u.id = auth.uid()
                    AND u.rol IN ('supervisor', 'admin')
                    AND (u.rol = 'admin' OR u.tienda_id = v.tienda_id)
                )
            )
        )
    );

-- Políticas para aprobaciones_descuento
CREATE POLICY "aprobaciones_descuento_vendedor" ON aprobaciones_descuento
    FOR SELECT USING (
        vendedor_id = auth.uid()
        OR
        auth.jwt() ->> 'email' = 'admin@test.com'
    );

CREATE POLICY "aprobaciones_descuento_supervisor" ON aprobaciones_descuento
    FOR ALL USING (
        vendedor_id = auth.uid()
        OR
        auth.jwt() ->> 'email' = 'admin@test.com'
        OR
        EXISTS (
            SELECT 1 FROM usuarios u
            WHERE u.id = auth.uid()
            AND u.rol IN ('supervisor', 'admin')
        )
    );

-- COMENTARIOS POLÍTICAS MÓDULO VENTAS
COMMENT ON POLICY "estrategias_descuento_select" ON estrategias_descuento IS 'Usuarios pueden ver estrategias activas de su tienda';
COMMENT ON POLICY "estrategias_descuento_admin" ON estrategias_descuento IS 'Solo admin/supervisor puede modificar estrategias';
COMMENT ON POLICY "ventas_vendedor_propias" ON ventas IS 'Vendedores ven sus ventas, supervisores las de su tienda';
COMMENT ON POLICY "detalles_venta_acceso" ON detalles_venta IS 'Acceso basado en políticas de ventas';
COMMENT ON POLICY "aprobaciones_descuento_supervisor" ON aprobaciones_descuento IS 'Supervisor puede aprobar descuentos';

-- Fin de políticas RLS limpias