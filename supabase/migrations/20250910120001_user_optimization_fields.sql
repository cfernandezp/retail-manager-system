-- Migración: Campos de Optimización para Gestión de Usuarios
-- Fecha: 2025-09-10
-- Descripción: Agregar campos faltantes y optimizar estructura para retail

-- Agregar campos faltantes a tabla tiendas existente
DO $$
BEGIN
    -- Agregar manager_id si no existe (referencia a usuarios)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'manager_id') THEN
        ALTER TABLE public.tiendas ADD COLUMN manager_id UUID;
    END IF;

    -- Asegurar que existe la columna activa (usar activa en lugar de activo para consistencia)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activa') THEN
        -- Si existe 'activo', renombrarlo a 'activa'
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activo') THEN
            ALTER TABLE public.tiendas RENAME COLUMN activo TO activa;
        ELSE
            -- Si no existe ninguno, crear 'activa'
            ALTER TABLE public.tiendas ADD COLUMN activa BOOLEAN DEFAULT TRUE;
        END IF;
    END IF;
END $$;

-- Agregar campos faltantes a usuarios
DO $$ 
BEGIN
    -- Agregar campos si no existen
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'fecha_suspension') THEN
        ALTER TABLE public.usuarios ADD COLUMN fecha_suspension TIMESTAMPTZ;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'fecha_reactivacion') THEN
        ALTER TABLE public.usuarios ADD COLUMN fecha_reactivacion TIMESTAMPTZ;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'motivo_rechazo') THEN
        ALTER TABLE public.usuarios ADD COLUMN motivo_rechazo TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'motivo_suspension') THEN
        ALTER TABLE public.usuarios ADD COLUMN motivo_suspension TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'tienda_asignada') THEN
        ALTER TABLE public.usuarios ADD COLUMN tienda_asignada UUID REFERENCES public.tiendas(id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'usuarios' AND column_name = 'fecha_rechazo') THEN
        ALTER TABLE public.usuarios ADD COLUMN fecha_rechazo TIMESTAMPTZ;
    END IF;
END $$;

-- Agregar rol VENDEDOR si no existe
INSERT INTO public.roles (nombre, descripcion, permisos) VALUES 
('VENDEDOR', 'Vendedor con permisos de POS y ventas', '{"pos": ["read", "write"], "products": ["read"], "sales": ["create", "read"], "customers": ["read", "create"]}')
ON CONFLICT (nombre) DO NOTHING;

-- Crear índices de optimización
CREATE INDEX IF NOT EXISTS idx_usuarios_tienda ON public.usuarios(tienda_asignada) WHERE tienda_asignada IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_usuarios_fecha_creacion ON public.usuarios(created_at);
CREATE INDEX IF NOT EXISTS idx_usuarios_fecha_aprobacion ON public.usuarios(fecha_aprobacion);
CREATE INDEX IF NOT EXISTS idx_usuarios_nombre_completo ON public.usuarios USING gin(to_tsvector('spanish', nombre_completo));
CREATE INDEX IF NOT EXISTS idx_usuarios_email_gin ON public.usuarios USING gin(to_tsvector('spanish', email));
CREATE INDEX IF NOT EXISTS idx_usuarios_pendientes_urgentes ON public.usuarios(created_at) WHERE estado = 'PENDIENTE_APROBACION';

-- Índices para tiendas
CREATE INDEX IF NOT EXISTS idx_tiendas_codigo ON public.tiendas(codigo);
-- Verificar si las columnas existen antes de crear índices
DO $$
BEGIN
    -- Índice para columna activa (después del rename)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'activa') THEN
        CREATE INDEX IF NOT EXISTS idx_tiendas_activa ON public.tiendas(activa);
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tiendas' AND column_name = 'manager_id') THEN
        CREATE INDEX IF NOT EXISTS idx_tiendas_manager ON public.tiendas(manager_id);
    END IF;
END $$;

-- Trigger para updated_at en tiendas (verificación mejorada)
DO $$
BEGIN
    -- Verificar si el trigger ya existe antes de crearlo
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE t.tgname = 'trigger_tiendas_updated_at'
        AND c.relname = 'tiendas'
        AND n.nspname = 'public'
    ) THEN
        -- Verificar que la función existe antes de crear el trigger
        IF EXISTS (
            SELECT 1 FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = 'actualizar_updated_at'
            AND n.nspname = 'public'
        ) THEN
            CREATE TRIGGER trigger_tiendas_updated_at
                BEFORE UPDATE ON public.tiendas
                FOR EACH ROW
                EXECUTE FUNCTION public.actualizar_updated_at();
        END IF;
    END IF;
END $$;

-- Comentarios
COMMENT ON COLUMN public.usuarios.fecha_suspension IS 'Fecha en que se suspendió al usuario';
COMMENT ON COLUMN public.usuarios.fecha_reactivacion IS 'Fecha en que se reactivó al usuario';
COMMENT ON COLUMN public.usuarios.motivo_rechazo IS 'Motivo por el cual se rechazó al usuario';
COMMENT ON COLUMN public.usuarios.motivo_suspension IS 'Motivo por el cual se suspendió al usuario';
COMMENT ON COLUMN public.usuarios.tienda_asignada IS 'Tienda a la que está asignado el usuario';

COMMENT ON TABLE public.tiendas IS 'Catálogo de tiendas del sistema retail';
COMMENT ON COLUMN public.tiendas.codigo IS 'Código único de la tienda (ej: T001, T002)';
COMMENT ON COLUMN public.tiendas.manager_id IS 'Usuario manager asignado a la tienda';