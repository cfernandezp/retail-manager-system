-- Migración: Verificar y restaurar usuario admin
-- Fecha: 2025-09-12
-- Descripción: Verificar estado de tablas usuarios y roles, restaurar datos si es necesario

BEGIN;

-- =====================================================
-- 1. VERIFICAR Y CREAR TABLAS SI NO EXISTEN
-- =====================================================

-- Verificar si existe tabla roles
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'roles') THEN
        RAISE NOTICE '❌ Tabla roles no existe. Creándola...';
        
        -- Crear tabla roles
        CREATE TABLE public.roles (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            nombre VARCHAR(50) NOT NULL UNIQUE,
            descripcion TEXT,
            permisos JSONB DEFAULT '{}',
            activo BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Insertar roles básicos
        INSERT INTO public.roles (nombre, descripcion, permisos) VALUES 
        ('SUPER_ADMIN', 'Administrador del sistema completo', '{"all": true, "users": ["create", "read", "update", "delete"], "settings": ["read", "write"]}'),
        ('ADMIN', 'Administrador de tienda y usuarios', '{"users": ["read", "approve", "suspend"], "reports": ["read", "export"], "pos": ["read", "write"], "inventory": ["read", "write"]}'),
        ('OPERARIO', 'Operario con permisos básicos', '{"pos": ["read", "write"], "products": ["read"], "sales": ["create", "read"]}')
        ON CONFLICT (nombre) DO NOTHING;
        
        RAISE NOTICE '✅ Tabla roles creada con datos iniciales';
    ELSE
        RAISE NOTICE '✅ Tabla roles existe';
    END IF;
END
$$;

-- Verificar si existe tabla usuarios
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'usuarios') THEN
        RAISE NOTICE '❌ Tabla usuarios no existe. Creándola...';
        
        -- Crear función para actualizar updated_at si no existe
        CREATE OR REPLACE FUNCTION public.actualizar_updated_at()
        RETURNS TRIGGER AS $func$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $func$ LANGUAGE plpgsql;
        
        -- Crear tabla usuarios
        CREATE TABLE public.usuarios (
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
        
        -- Crear índices
        CREATE INDEX IF NOT EXISTS idx_usuarios_estado ON public.usuarios(estado);
        CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON public.usuarios(rol_id);
        CREATE INDEX IF NOT EXISTS idx_usuarios_email ON public.usuarios(email);
        
        -- Crear trigger
        CREATE TRIGGER trigger_usuarios_updated_at
            BEFORE UPDATE ON public.usuarios
            FOR EACH ROW
            EXECUTE FUNCTION public.actualizar_updated_at();
        
        RAISE NOTICE '✅ Tabla usuarios creada con estructura completa';
    ELSE
        RAISE NOTICE '✅ Tabla usuarios existe';
    END IF;
END
$$;

-- =====================================================
-- 2. VERIFICAR Y RESTAURAR USUARIO ADMIN
-- =====================================================

DO $$
DECLARE
    user_record auth.users%ROWTYPE;
    usuario_record public.usuarios%ROWTYPE;
    admin_role_id UUID;
    roles_count INTEGER;
    usuarios_count INTEGER;
BEGIN
    -- Contar roles
    SELECT COUNT(*) INTO roles_count FROM public.roles;
    RAISE NOTICE 'Roles en sistema: %', roles_count;
    
    -- Contar usuarios
    SELECT COUNT(*) INTO usuarios_count FROM public.usuarios;
    RAISE NOTICE 'Usuarios en sistema: %', usuarios_count;
    
    -- Obtener rol SUPER_ADMIN
    SELECT id INTO admin_role_id FROM public.roles WHERE nombre = 'SUPER_ADMIN';
    
    IF admin_role_id IS NULL THEN
        RAISE NOTICE '❌ Rol SUPER_ADMIN no encontrado';
        RETURN;
    END IF;
    
    -- Verificar si existe usuario admin en auth.users
    SELECT * INTO user_record FROM auth.users WHERE email = 'admin@test.com';
    
    IF user_record.id IS NULL THEN
        RAISE NOTICE '❌ Usuario admin no existe en auth.users. Creándolo...';
        
        -- Crear usuario en auth.users
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            recovery_sent_at,
            last_sign_in_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            confirmation_token,
            email_change,
            email_change_token_new,
            recovery_token
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            gen_random_uuid(),
            'authenticated',
            'authenticated',
            'admin@test.com',
            crypt('admin123', gen_salt('bf')),
            NOW(),
            NULL,
            NULL,
            '{"provider": "email", "providers": ["email"]}',
            '{}',
            NOW(),
            NOW(),
            '',
            '',
            '',
            ''
        ) RETURNING * INTO user_record;
        
        RAISE NOTICE '✅ Usuario admin creado en auth.users con ID: %', user_record.id;
    ELSE
        RAISE NOTICE '✅ Usuario admin existe en auth.users con ID: %', user_record.id;
    END IF;
    
    -- Verificar si existe usuario admin en public.usuarios
    SELECT * INTO usuario_record FROM public.usuarios WHERE id = user_record.id;
    
    IF usuario_record.id IS NULL THEN
        RAISE NOTICE '❌ Usuario admin no existe en public.usuarios. Creándolo...';
        
        -- Crear usuario en public.usuarios
        INSERT INTO public.usuarios (
            id,
            email,
            nombre_completo,
            rol_id,
            estado,
            email_verificado,
            created_at,
            updated_at
        ) VALUES (
            user_record.id,
            'admin@test.com',
            'Admin Sistema',
            admin_role_id,
            'ACTIVA',
            TRUE,
            NOW(),
            NOW()
        );
        
        RAISE NOTICE '✅ Usuario admin creado en public.usuarios';
    ELSE
        RAISE NOTICE '✅ Usuario admin existe en public.usuarios';
        
        -- Actualizar datos si es necesario
        UPDATE public.usuarios SET
            email = 'admin@test.com',
            nombre_completo = 'Admin Sistema',
            rol_id = admin_role_id,
            estado = 'ACTIVA',
            email_verificado = TRUE,
            updated_at = NOW()
        WHERE id = user_record.id;
        
        RAISE NOTICE '✅ Datos de usuario admin actualizados';
    END IF;
    
    RAISE NOTICE '=== RESUMEN RESTAURACIÓN ===';
    RAISE NOTICE 'Email: admin@test.com';
    RAISE NOTICE 'Password: admin123';
    RAISE NOTICE 'Estado: ACTIVA';
    RAISE NOTICE 'Rol: SUPER_ADMIN';
    RAISE NOTICE '==========================';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ Error en restauración: %', SQLERRM;
        RAISE;
END
$$;

-- =====================================================
-- 3. VERIFICACIÓN FINAL
-- =====================================================

-- Mostrar estado final de las tablas
DO $$
DECLARE
    roles_count INTEGER;
    usuarios_count INTEGER;
    admin_exists BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO roles_count FROM public.roles;
    SELECT COUNT(*) INTO usuarios_count FROM public.usuarios;
    
    SELECT EXISTS(
        SELECT 1 FROM public.usuarios u
        JOIN public.roles r ON u.rol_id = r.id
        WHERE u.email = 'admin@test.com' AND r.nombre = 'SUPER_ADMIN' AND u.estado = 'ACTIVA'
    ) INTO admin_exists;
    
    RAISE NOTICE '=== VERIFICACIÓN FINAL ===';
    RAISE NOTICE 'Roles totales: %', roles_count;
    RAISE NOTICE 'Usuarios totales: %', usuarios_count;
    RAISE NOTICE 'Admin operativo: %', CASE WHEN admin_exists THEN 'SÍ' ELSE 'NO' END;
    RAISE NOTICE '========================';
END
$$;

COMMIT;