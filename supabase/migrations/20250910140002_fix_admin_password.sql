-- Migración: Corregir contraseña de admin para autenticación
-- Fecha: 2025-09-10
-- Descripción: Actualizar contraseña admin a formato compatible sin caracteres especiales

-- Actualizar contraseña del usuario admin existente
DO $$ 
DECLARE
    admin_user_id UUID;
    encrypted_password TEXT;
BEGIN 
    -- Buscar el usuario admin existente
    SELECT id INTO admin_user_id 
    FROM auth.users 
    WHERE email = 'admin@test.com';
    
    IF admin_user_id IS NOT NULL THEN
        -- Crear hash de la nueva contraseña
        encrypted_password := crypt('admin123', gen_salt('bf'));
        
        -- Actualizar la contraseña en auth.users
        UPDATE auth.users 
        SET encrypted_password = encrypted_password,
            updated_at = NOW()
        WHERE id = admin_user_id;
        
        RAISE NOTICE '✅ Contraseña actualizada para admin@test.com';
        RAISE NOTICE 'Nueva contraseña: admin123 (sin caracteres especiales)';
    ELSE
        RAISE NOTICE '⚠️  Usuario admin@test.com no encontrado';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error actualizando contraseña: %', SQLERRM;
END $$;