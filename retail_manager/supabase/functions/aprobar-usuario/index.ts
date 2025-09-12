import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

console.log("Función aprobar-usuario iniciada")

serve(async (req) => {
  // Manejar CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Crear cliente Supabase
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { usuario_id, accion, nuevo_rol } = await req.json()

    // Obtener token del header
    const authorization = req.headers.get('Authorization')
    if (!authorization) {
      return new Response(
        JSON.stringify({ error: 'Token de autorización requerido' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Verificar que quien hace la petición es admin
    const token = authorization.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Token inválido' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Verificar que el usuario actual es admin
    const { data: adminData, error: adminError } = await supabase
      .from('usuarios')
      .select(`
        id,
        roles!inner(nombre)
      `)
      .eq('id', user.id)
      .eq('estado', 'ACTIVA')
      .single()

    if (adminError || !adminData || !['ADMIN', 'SUPER_ADMIN'].includes(adminData.roles.nombre)) {
      return new Response(
        JSON.stringify({ error: 'No tiene permisos para realizar esta acción' }),
        { 
          status: 403, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Procesar según la acción
    let resultado: any = {}

    switch (accion) {
      case 'APROBAR':
        // Aprobar usuario y activar cuenta
        const { error: aprobarError } = await supabase
          .from('usuarios')
          .update({
            estado: 'ACTIVA',
            aprobado_por: user.id,
            fecha_aprobacion: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('id', usuario_id)
          .eq('estado', 'PENDIENTE_APROBACION') // Solo se pueden aprobar cuentas pendientes

        if (aprobarError) {
          console.error('Error aprobando usuario:', aprobarError)
          return new Response(
            JSON.stringify({ error: 'Error aprobando usuario' }),
            { 
              status: 500, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }

        resultado = { mensaje: 'Usuario aprobado exitosamente' }
        break

      case 'RECHAZAR':
        // Rechazar usuario
        const { error: rechazarError } = await supabase
          .from('usuarios')
          .update({
            estado: 'RECHAZADA',
            aprobado_por: user.id,
            fecha_aprobacion: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('id', usuario_id)

        if (rechazarError) {
          console.error('Error rechazando usuario:', rechazarError)
          return new Response(
            JSON.stringify({ error: 'Error rechazando usuario' }),
            { 
              status: 500, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }

        resultado = { mensaje: 'Usuario rechazado' }
        break

      case 'SUSPENDER':
        // Suspender usuario activo
        const { error: suspenderError } = await supabase
          .from('usuarios')
          .update({
            estado: 'SUSPENDIDA',
            updated_at: new Date().toISOString()
          })
          .eq('id', usuario_id)
          .eq('estado', 'ACTIVA')

        if (suspenderError) {
          console.error('Error suspendiendo usuario:', suspenderError)
          return new Response(
            JSON.stringify({ error: 'Error suspendiendo usuario' }),
            { 
              status: 500, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }

        resultado = { mensaje: 'Usuario suspendido' }
        break

      case 'REACTIVAR':
        // Reactivar usuario suspendido
        const { error: reactivarError } = await supabase
          .from('usuarios')
          .update({
            estado: 'ACTIVA',
            updated_at: new Date().toISOString()
          })
          .eq('id', usuario_id)
          .eq('estado', 'SUSPENDIDA')

        if (reactivarError) {
          console.error('Error reactivando usuario:', reactivarError)
          return new Response(
            JSON.stringify({ error: 'Error reactivando usuario' }),
            { 
              status: 500, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }

        resultado = { mensaje: 'Usuario reactivado' }
        break

      case 'CAMBIAR_ROL':
        // Cambiar rol de usuario (solo SUPER_ADMIN)
        if (adminData.roles.nombre !== 'SUPER_ADMIN') {
          return new Response(
            JSON.stringify({ error: 'Solo SUPER_ADMIN puede cambiar roles' }),
            { 
              status: 403, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }

        // Verificar que el nuevo rol existe
        const { data: rolData, error: rolError } = await supabase
          .from('roles')
          .select('id')
          .eq('nombre', nuevo_rol)
          .single()

        if (rolError || !rolData) {
          return new Response(
            JSON.stringify({ error: 'Rol no válido' }),
            { 
              status: 400, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }

        const { error: cambiarRolError } = await supabase
          .from('usuarios')
          .update({
            rol_id: rolData.id,
            updated_at: new Date().toISOString()
          })
          .eq('id', usuario_id)

        if (cambiarRolError) {
          console.error('Error cambiando rol:', cambiarRolError)
          return new Response(
            JSON.stringify({ error: 'Error cambiando rol' }),
            { 
              status: 500, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }

        resultado = { mensaje: `Rol cambiado a ${nuevo_rol}` }
        break

      default:
        return new Response(
          JSON.stringify({ error: 'Acción no válida' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
    }

    console.log(`Acción ${accion} ejecutada por ${user.email} en usuario ${usuario_id}`)

    return new Response(
      JSON.stringify({ 
        success: true, 
        ...resultado,
        accion_realizada: accion,
        realizada_por: user.email
      }),
      { 
        status: 200,
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
POST /functions/v1/aprobar-usuario
Authorization: Bearer <token_admin>
{
  "usuario_id": "uuid-del-usuario",
  "accion": "APROBAR" | "RECHAZAR" | "SUSPENDER" | "REACTIVAR" | "CAMBIAR_ROL",
  "nuevo_rol": "ADMIN" // solo para CAMBIAR_ROL
}
*/