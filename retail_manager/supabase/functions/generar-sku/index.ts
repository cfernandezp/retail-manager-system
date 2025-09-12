// Edge Function: Generación Avanzada de SKUs
// Descripción: Genera SKUs únicos con lógica de negocio avanzada

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface GenerarSKURequest {
  producto_master_id: string;
  color_id: string;
  custom_prefix?: string;
}

interface ProductoInfo {
  marca_nombre: string;
  categoria_nombre: string;
  talla_codigo: string;
  color_abrev: string;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user } } = await supabaseClient.auth.getUser()
    
    if (!user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 }
      )
    }

    const { producto_master_id, color_id, custom_prefix }: GenerarSKURequest = await req.json()

    if (!producto_master_id || !color_id) {
      return new Response(
        JSON.stringify({ error: 'producto_master_id y color_id son requeridos' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // Obtener información del producto para generar SKU
    const { data: productoInfo, error: productoError } = await supabaseClient
      .from('productos_master')
      .select(`
        marcas!inner(nombre),
        categorias!inner(nombre),
        tallas!inner(codigo)
      `)
      .eq('id', producto_master_id)
      .single()

    if (productoError || !productoInfo) {
      return new Response(
        JSON.stringify({ error: 'Producto master no encontrado' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 404 }
      )
    }

    // Obtener información del color
    const { data: colorInfo, error: colorError } = await supabaseClient
      .from('colores')
      .select('codigo_abrev')
      .eq('id', color_id)
      .single()

    if (colorError || !colorInfo) {
      return new Response(
        JSON.stringify({ error: 'Color no encontrado' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 404 }
      )
    }

    // Generar códigos para SKU
    const marcaCodigo = productoInfo.marcas.nombre.substring(0, 3).toUpperCase()
    const categoriaCodigo = productoInfo.categorias.nombre.substring(0, 3).toUpperCase()
    const tallaCodigo = productoInfo.tallas.codigo.replace(/[^A-Za-z0-9]/g, '').toUpperCase()
    const colorCodigo = colorInfo.codigo_abrev.toUpperCase()

    // Construir SKU base
    const skuBase = custom_prefix || 'MED'
    let nuevoSKU = `${skuBase}-${categoriaCodigo}-${marcaCodigo}-${tallaCodigo}-${colorCodigo}`

    // Verificar unicidad y agregar sufijo si es necesario
    let contador = 0
    let skuFinal = nuevoSKU

    while (true) {
      const { data: existente } = await supabaseClient
        .from('articulos')
        .select('id')
        .eq('sku', skuFinal)
        .maybeSingle()

      if (!existente) {
        break // SKU está disponible
      }

      contador++
      skuFinal = `${nuevoSKU}-${contador.toString().padStart(2, '0')}`
      
      if (contador > 99) {
        // Fallback con timestamp si hay muchas colisiones
        const timestamp = Date.now().toString().slice(-4)
        skuFinal = `${nuevoSKU}-${timestamp}`
        break
      }
    }

    // Generar código de barras sugerido (EAN-13 simulado)
    const codigoBarras = `78${Date.now().toString().slice(-10)}`

    // Log de la generación
    console.log(`SKU generado: ${skuFinal} para producto ${producto_master_id} color ${color_id}`)

    return new Response(
      JSON.stringify({
        sku: skuFinal,
        codigo_barras_sugerido: codigoBarras,
        componentes: {
          prefijo: skuBase,
          categoria: categoriaCodigo,
          marca: marcaCodigo,
          talla: tallaCodigo,
          color: colorCodigo
        },
        meta: {
          intentos: contador + 1,
          generado_en: new Date().toISOString()
        }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )

  } catch (error) {
    console.error('Error en generar-sku:', error)
    return new Response(
      JSON.stringify({ error: 'Error interno del servidor', details: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})