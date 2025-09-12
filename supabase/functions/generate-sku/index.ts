import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SKURequest {
  marca_prefijo?: string
  categoria_prefijo?: string
  talla_codigo?: string
  color_prefijo?: string
  producto_master_id?: string
  color_id?: string
  custom_suffix?: string
}

interface SKUResponse {
  sku: string
  nombre_completo: string
  is_unique: boolean
  error?: string
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
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { marca_prefijo, categoria_prefijo, talla_codigo, color_prefijo, producto_master_id, color_id, custom_suffix } = await req.json() as SKURequest

    let sku: string
    let nombreCompleto: string

    // Si recibimos IDs, obtenemos los datos de la base de datos
    if (producto_master_id && color_id) {
      const { data: productoData, error: productoError } = await supabaseClient
        .from('productos_master')
        .select(`
          *,
          marcas!inner(nombre, prefijo_sku),
          categorias!inner(nombre, prefijo_sku),
          tallas!inner(codigo, tipo, talla_min, talla_max, talla_unica)
        `)
        .eq('id', producto_master_id)
        .single()

      if (productoError || !productoData) {
        throw new Error(`Error obteniendo producto: ${productoError?.message}`)
      }

      const { data: colorData, error: colorError } = await supabaseClient
        .from('colores')
        .select('nombre, prefijo_sku')
        .eq('id', color_id)
        .single()

      if (colorError || !colorData) {
        throw new Error(`Error obteniendo color: ${colorError?.message}`)
      }

      // Generar SKU con datos de la BD
      sku = await generateSKU(
        supabaseClient,
        productoData.marcas.prefijo_sku,
        productoData.categorias.prefijo_sku,
        productoData.tallas.codigo,
        colorData.prefijo_sku,
        custom_suffix
      )

      // Generar nombre completo
      nombreCompleto = `${productoData.nombre} ${colorData.nombre.toUpperCase()}`

    } else if (marca_prefijo && categoria_prefijo && talla_codigo && color_prefijo) {
      // Generar SKU con parámetros directos
      sku = await generateSKU(
        supabaseClient,
        marca_prefijo,
        categoria_prefijo,
        talla_codigo,
        color_prefijo,
        custom_suffix
      )

      nombreCompleto = ''
    } else {
      throw new Error('Debe proporcionar producto_master_id y color_id, o todos los prefijos requeridos')
    }

    // Verificar unicidad
    const { data: existingArticle } = await supabaseClient
      .from('articulos')
      .select('id')
      .eq('sku', sku)
      .single()

    const response: SKUResponse = {
      sku,
      nombre_completo: nombreCompleto,
      is_unique: !existingArticle
    }

    return new Response(
      JSON.stringify(response),
      { 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )

  } catch (error) {
    console.error('Error in generate-sku function:', error)
    
    const errorResponse: SKUResponse = {
      sku: '',
      nombre_completo: '',
      is_unique: false,
      error: error.message
    }

    return new Response(
      JSON.stringify(errorResponse),
      { 
        status: 400,
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )
  }
})

async function generateSKU(
  supabaseClient: any,
  marcaPrefijo: string,
  categoriaPrefijo: string,
  tallaCodigo: string,
  colorPrefijo: string,
  customSuffix?: string
): Promise<string> {
  // Limpiar y formatear códigos
  const talla = tallaCodigo.replace(/-/g, '')
  
  // Construir SKU base: CAT-MAR-TALLA-COL
  const skuBase = `${categoriaPrefijo.toUpperCase()}-${marcaPrefijo.toUpperCase()}-${talla}-${colorPrefijo.toUpperCase()}`
  
  let skuFinal = skuBase
  
  // Agregar sufijo personalizado si se proporciona
  if (customSuffix) {
    skuFinal += `-${customSuffix.toUpperCase()}`
  }
  
  // Verificar unicidad y agregar contador si es necesario
  let counter = 1
  while (true) {
    const { data: existing } = await supabaseClient
      .from('articulos')
      .select('id')
      .eq('sku', skuFinal)
      .single()

    if (!existing) {
      break // SKU único encontrado
    }

    // Incrementar contador y probar nuevamente
    counter++
    const suffix = customSuffix ? `${customSuffix}-${counter.toString().padStart(2, '0')}` : counter.toString().padStart(2, '0')
    skuFinal = `${skuBase}-${suffix.toUpperCase()}`
  }
  
  return skuFinal
}