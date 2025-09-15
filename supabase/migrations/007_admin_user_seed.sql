-- =====================================================
-- USUARIO ADMIN DE DESARROLLO
-- =====================================================
-- Archivo: 007_admin_user_seed.sql
-- Propósito: Crear usuario admin@test.com para desarrollo
-- Fecha: 2025-09-15
--
-- CREDENCIALES:
-- Email: admin@test.com
-- Password: admin123
-- =====================================================

-- Crear usuario admin basado en método que funcionaba antes
DO $$
DECLARE
    user_record auth.users%ROWTYPE;
    admin_email VARCHAR := 'admin@test.com';
BEGIN
    -- Verificar si existe usuario admin en auth.users
    SELECT * INTO user_record FROM auth.users WHERE email = admin_email;

    IF user_record.id IS NULL THEN
        RAISE NOTICE 'Creando usuario admin en auth.users...';

        -- Crear usuario en auth.users (método que funcionaba antes)
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
            admin_email,
            crypt('admin123', gen_salt('bf')),
            NOW(),
            NULL,
            NULL,
            '{"provider": "email", "providers": ["email"]}',
            '{"nombre_completo": "Administrador Sistema"}',
            NOW(),
            NOW(),
            '',
            '',
            '',
            ''
        ) RETURNING * INTO user_record;

        RAISE NOTICE 'Usuario admin creado en auth.users con ID: %', user_record.id;

        -- Crear usuario en tabla usuarios (compatible con frontend)
        INSERT INTO usuarios (
            id,
            email,
            nombre_completo,
            rol_id,
            estado,
            email_verificado
        ) VALUES (
            user_record.id,
            admin_email,
            'Administrador Sistema',
            (SELECT id FROM roles WHERE nombre = 'ADMIN'),
            'ACTIVA',
            true
        ) ON CONFLICT (id) DO UPDATE SET
            rol_id = (SELECT id FROM roles WHERE nombre = 'ADMIN'),
            estado = 'ACTIVA',
            email_verificado = true;

        RAISE NOTICE '=== USUARIO ADMIN CREADO ===';
        RAISE NOTICE 'Email: admin@test.com';
        RAISE NOTICE 'Password: admin123';
        RAISE NOTICE 'ID: %', user_record.id;
        RAISE NOTICE '==========================';
    ELSE
        RAISE NOTICE 'Usuario admin ya existe: %', admin_email;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error creando usuario admin: %', SQLERRM;
        RAISE;
END $$;

-- Fin de creación de usuario admin