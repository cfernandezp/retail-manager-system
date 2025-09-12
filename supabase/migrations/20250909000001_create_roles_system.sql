-- Migración: Sistema de Roles y Usuarios
-- Fecha: 2025-09-09
-- Descripción: Crear tablas para sistema de autenticación con roles

-- Crear tabla de roles
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    permisos JSONB DEFAULT '{}',
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar roles del MVP
INSERT INTO public.roles (nombre, descripcion, permisos) VALUES 
('SUPER_ADMIN', 'Administrador del sistema completo', '{"all": true, "users": ["create", "read", "update", "delete"], "settings": ["read", "write"]}'),
('ADMIN', 'Administrador de tienda y usuarios', '{"users": ["read", "approve", "suspend"], "reports": ["read", "export"], "pos": ["read", "write"], "inventory": ["read", "write"]}'),
('OPERARIO', 'Operario con permisos básicos', '{"pos": ["read", "write"], "products": ["read"], "sales": ["create", "read"]}')
ON CONFLICT (nombre) DO NOTHING;

-- Crear tabla de perfiles de usuario (complementa auth.users)
CREATE TABLE IF NOT EXISTS public.usuarios (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    nombre_completo VARCHAR(255),
    rol_id UUID REFERENCES public.roles(id) NOT NULL,
    estado VARCHAR(50) DEFAULT 'PENDIENTE_EMAIL' CHECK (estado IN ('PENDIENTE_EMAIL', 'PENDIENTE_APROBACION', 'ACTIVA', 'SUSPENDIDA', 'RECHAZADA')),
    email_verificado BOOLEAN DEFAULT FALSE,
    aprobado_por UUID REFERENCES public.usuarios(id),
    fecha_aprobacion TIMESTAMP WITH TIME ZONE,
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    intentos_fallidos INTEGER DEFAULT 0,
    bloqueado_hasta TIMESTAMP WITH TIME ZONE,
    metadatos JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de auditoría para cambios críticos
CREATE TABLE IF NOT EXISTS public.auditoria_usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE,
    accion VARCHAR(100) NOT NULL,
    realizada_por UUID REFERENCES public.usuarios(id),
    detalles JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para optimización
CREATE INDEX IF NOT EXISTS idx_usuarios_estado ON public.usuarios(estado);
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON public.usuarios(rol_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON public.usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_ultimo_acceso ON public.usuarios(ultimo_acceso);
CREATE INDEX IF NOT EXISTS idx_auditoria_usuario_fecha ON public.auditoria_usuarios(usuario_id, created_at);

-- Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear triggers para updated_at
CREATE TRIGGER trigger_usuarios_updated_at
    BEFORE UPDATE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION public.actualizar_updated_at();

CREATE TRIGGER trigger_roles_updated_at
    BEFORE UPDATE ON public.roles
    FOR EACH ROW
    EXECUTE FUNCTION public.actualizar_updated_at();

-- Crear función para registrar auditoría automáticamente
CREATE OR REPLACE FUNCTION public.registrar_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo auditar cambios importantes
    IF TG_OP = 'UPDATE' AND (OLD.estado != NEW.estado OR OLD.rol_id != NEW.rol_id) THEN
        INSERT INTO public.auditoria_usuarios (usuario_id, accion, detalles)
        VALUES (
            NEW.id,
            'CAMBIO_' || TG_OP,
            jsonb_build_object(
                'estado_anterior', OLD.estado,
                'estado_nuevo', NEW.estado,
                'rol_anterior', OLD.rol_id,
                'rol_nuevo', NEW.rol_id
            )
        );
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO public.auditoria_usuarios (usuario_id, accion, detalles)
        VALUES (
            NEW.id,
            'USUARIO_CREADO',
            jsonb_build_object(
                'rol', NEW.rol_id,
                'estado', NEW.estado
            )
        );
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Crear trigger de auditoría
CREATE TRIGGER trigger_auditoria_usuarios
    AFTER INSERT OR UPDATE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION public.registrar_auditoria();

-- Comentarios para documentación
COMMENT ON TABLE public.roles IS 'Roles del sistema con permisos granulares';
COMMENT ON TABLE public.usuarios IS 'Perfiles de usuario complementarios a auth.users';
COMMENT ON TABLE public.auditoria_usuarios IS 'Log de auditoría para cambios críticos de usuarios';

COMMENT ON COLUMN public.usuarios.estado IS 'Estado del usuario: PENDIENTE_EMAIL, PENDIENTE_APROBACION, ACTIVA, SUSPENDIDA, RECHAZADA';
COMMENT ON COLUMN public.usuarios.rol_id IS 'Referencia al rol asignado al usuario';
COMMENT ON COLUMN public.usuarios.aprobado_por IS 'Usuario admin que aprobó esta cuenta';