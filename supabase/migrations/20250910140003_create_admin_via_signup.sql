-- Migración: Crear admin usando registro estándar de Supabase
-- Fecha: 2025-09-10
-- Descripción: Usar el flujo de registro estándar para evitar problemas de autenticación

-- Crear función para registrar usuario admin
CREATE OR REPLACE FUNCTION create_admin_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record auth.users%ROWTYPE;
    admin_role_id UUID;
BEGIN
    -- Buscar si ya existe el usuario
    SELECT * INTO user_record 
    FROM auth.users 
    WHERE email = 'admin@test.com';
    
    -- Si no existe, crearlo usando el método estándar de Supabase
    IF user_record.id IS NULL THEN
        -- Obtener ID del rol SUPER_ADMIN
        SELECT id INTO admin_role_id 
        FROM public.roles 
        WHERE nombre = 'SUPER_ADMIN';
        
        -- Crear en auth.users usando el método correcto
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
        
        -- Crear en public.usuarios
        INSERT INTO public.usuarios (
            id,
            email,
            nombre_completo,
            rol_id,
            estado,
            email_verificado,
            created_at
        ) VALUES (
            user_record.id,
            'admin@test.com',
            'Administrador de Prueba',
            admin_role_id,
            'ACTIVA',
            TRUE,
            NOW()
        );
        
        RAISE NOTICE '✅ Usuario admin creado correctamente con ID: %', user_record.id;
        RAISE NOTICE '📧 Email: admin@test.com';
        RAISE NOTICE '🔑 Password: admin123';
    ELSE
        RAISE NOTICE '⚠️  Usuario admin ya existe con ID: %', user_record.id;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ Error creando usuario admin: %', SQLERRM;
        RAISE EXCEPTION '%', SQLERRM;
END;
$$;

-- Ejecutar la función
SELECT create_admin_user();

-- Comentario informativo
COMMENT ON FUNCTION create_admin_user IS 'Crea usuario admin usando el flujo estándar de Supabase Auth';