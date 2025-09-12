import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

console.log("Función registro-usuario iniciada")

serve(async (req) => {
  // Manejar CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Crear cliente Supabase con permisos de service_role
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { email, password, nombre_completo } = await req.json()

    // Validaciones básicas
    if (!email || !password) {
      return new Response(
        JSON.stringify({ error: 'Email y contraseña son requeridos' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Validar formato de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      return new Response(
        JSON.stringify({ error: 'Formato de email inválido' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Validar fortaleza de contraseña
    if (password.length < 8) {
      return new Response(
        JSON.stringify({ error: 'La contraseña debe tener al menos 8 caracteres' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 1. Crear usuario en auth.users
    const { data: authData, error: authError } = await supabase.auth.admin
      .createUser({
        email,
        password,
        email_confirm: false, // Requiere verificación manual
      })

    if (authError) {
      console.error('Error creando usuario auth:', authError)
      return new Response(
        JSON.stringify({ error: 'Error creando cuenta: ' + authError.message }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 2. Obtener ID del rol OPERARIO
    const { data: rolOperario, error: rolError } = await supabase
      .from('roles')
      .select('id')
      .eq('nombre', 'OPERARIO')
      .single()

    if (rolError || !rolOperario) {
      console.error('Error obteniendo rol OPERARIO:', rolError)
      return new Response(
        JSON.stringify({ error: 'Error del sistema: rol no encontrado' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 3. Crear perfil en tabla usuarios
    const { error: perfilError } = await supabase
      .from('usuarios')
      .insert({
        id: authData.user.id,
        email: email,
        nombre_completo: nombre_completo || null,
        rol_id: rolOperario.id,
        estado: 'PENDIENTE_EMAIL',
        email_verificado: false
      })

    if (perfilError) {
      console.error('Error creando perfil:', perfilError)
      
      // Limpiar usuario auth si falla el perfil
      await supabase.auth.admin.deleteUser(authData.user.id)
      
      return new Response(
        JSON.stringify({ error: 'Error creando perfil de usuario' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 4. Enviar email de verificación
    const { error: emailError } = await supabase.auth.admin
      .generateLink({
        type: 'signup',
        email: email,
      })

    if (emailError) {
      console.warn('Error enviando email de verificación:', emailError)
      // No fallar todo el proceso por el email
    }

    // 5. Notificar a administradores (implementar después)
    // TODO: Crear notificación para admins sobre nuevo usuario pendiente

    console.log(`Usuario registrado exitosamente: ${email}`)

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Usuario registrado exitosamente. Verifique su email y espere la aprobación del administrador.',
        usuario_id: authData.user.id,
        estado: 'PENDIENTE_EMAIL'
      }),
      { 
        status: 201,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error general:', error)
    return new Response(
      JSON.stringify({ error: 'Error interno del servidor' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

/* Para usar esta función:
POST /functions/v1/registro-usuario
{
  "email": "operario@empresa.com",
  "password": "MiPassword123",
  "nombre_completo": "Juan Pérez"
}
*/