-- Migración: Campos de Optimización para Gestión de Usuarios
-- Fecha: 2025-09-10
-- Descripción: Agregar campos faltantes y optimizar estructura para retail

-- Crear tabla de tiendas (si no existe)
CREATE TABLE IF NOT EXISTS public.tiendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(255),
    manager_id UUID REFERENCES public.usuarios(id),
    activa BOOLEAN DEFAULT TRUE,
    configuracion JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
CREATE INDEX IF NOT EXISTS idx_tiendas_activa ON public.tiendas(activa);
CREATE INDEX IF NOT EXISTS idx_tiendas_manager ON public.tiendas(manager_id);

-- Trigger para updated_at en tiendas
CREATE TRIGGER trigger_tiendas_updated_at
    BEFORE UPDATE ON public.tiendas
    FOR EACH ROW
    EXECUTE FUNCTION public.actualizar_updated_at();

-- Comentarios
COMMENT ON COLUMN public.usuarios.fecha_suspension IS 'Fecha en que se suspendió al usuario';
COMMENT ON COLUMN public.usuarios.fecha_reactivacion IS 'Fecha en que se reactivó al usuario';
COMMENT ON COLUMN public.usuarios.motivo_rechazo IS 'Motivo por el cual se rechazó al usuario';
COMMENT ON COLUMN public.usuarios.motivo_suspension IS 'Motivo por el cual se suspendió al usuario';
COMMENT ON COLUMN public.usuarios.tienda_asignada IS 'Tienda a la que está asignado el usuario';

COMMENT ON TABLE public.tiendas IS 'Catálogo de tiendas del sistema retail';
COMMENT ON COLUMN public.tiendas.codigo IS 'Código único de la tienda (ej: T001, T002)';
COMMENT ON COLUMN public.tiendas.manager_id IS 'Usuario manager asignado a la tienda';