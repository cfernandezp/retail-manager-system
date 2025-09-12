import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface InventoryOperation {
  operation: 'stock_update' | 'transfer' | 'bulk_update' | 'price_update' | 'low_stock_alert'
  articulo_id?: string
  tienda_id?: string
  tienda_origen_id?: string
  tienda_destino_id?: string
  cantidad?: number
  nuevo_precio?: number
  motivo?: string
  referencia_externa?: string
  articulos?: Array<{
    articulo_id: string
    cantidad: number
    precio?: number
  }>
}

interface InventoryResponse {
  success: boolean
  message: string
  data?: any
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

    // Get user from JWT token
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Autorización requerida')
    }

    const jwt = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(jwt)
    
    if (authError || !user) {
      throw new Error('Token de autorización inválido')
    }

    const operationData = await req.json() as InventoryOperation
    let result: InventoryResponse

    switch (operationData.operation) {
      case 'stock_update':
        result = await handleStockUpdate(supabaseClient, operationData, user.id)
        break
      case 'transfer':
        result = await handleTransfer(supabaseClient, operationData, user.id)
        break
      case 'bulk_update':
        result = await handleBulkUpdate(supabaseClient, operationData, user.id)
        break
      case 'price_update':
        result = await handlePriceUpdate(supabaseClient, operationData, user.id)
        break
      case 'low_stock_alert':
        result = await handleLowStockAlert(supabaseClient, operationData)
        break
      default:
        throw new Error(`Operación no soportada: ${operationData.operation}`)
    }

    return new Response(
      JSON.stringify(result),
      { 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json' 
        } 
      }
    )

  } catch (error) {
    console.error('Error in inventory-operations function:', error)
    
    const errorResponse: InventoryResponse = {
      success: false,
      message: 'Error procesando operación de inventario',
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

async function handleStockUpdate(
  supabaseClient: any,
  operation: InventoryOperation,
  userId: string
): Promise<InventoryResponse> {
  const { articulo_id, tienda_id, cantidad, motivo, referencia_externa } = operation

  if (!articulo_id || !tienda_id || cantidad === undefined) {
    throw new Error('articulo_id, tienda_id y cantidad son requeridos')
  }

  // Usar la función de base de datos para actualizar stock
  const { data, error } = await supabaseClient.rpc('update_stock_and_create_movement', {
    p_articulo_id: articulo_id,
    p_tienda_id: tienda_id,
    p_tipo_movimiento: cantidad > 0 ? 'ENTRADA' : 'SALIDA',
    p_cantidad: cantidad,
    p_motivo: motivo || 'Actualización manual',
    p_referencia_externa: referencia_externa,
    p_usuario_id: userId
  })

  if (error) {
    throw new Error(`Error actualizando stock: ${error.message}`)
  }

  // Obtener stock actualizado
  const { data: stockActual } = await supabaseClient
    .from('inventario_tienda')
    .select('stock_actual, stock_minimo')
    .eq('articulo_id', articulo_id)
    .eq('tienda_id', tienda_id)
    .single()

  return {
    success: true,
    message: 'Stock actualizado exitosamente',
    data: {
      stock_anterior: stockActual?.stock_actual - cantidad,
      stock_nuevo: stockActual?.stock_actual,
      requiere_restock: stockActual?.stock_actual <= stockActual?.stock_minimo
    }
  }
}

async function handleTransfer(
  supabaseClient: any,
  operation: InventoryOperation,
  userId: string
): Promise<InventoryResponse> {
  const { articulo_id, tienda_origen_id, tienda_destino_id, cantidad, motivo } = operation

  if (!articulo_id || !tienda_origen_id || !tienda_destino_id || !cantidad) {
    throw new Error('articulo_id, tienda_origen_id, tienda_destino_id y cantidad son requeridos')
  }

  if (cantidad <= 0) {
    throw new Error('La cantidad debe ser mayor a 0')
  }

  // Usar la función de base de datos para realizar traspaso
  const { data, error } = await supabaseClient.rpc('realizar_traspaso_inventario', {
    p_articulo_id: articulo_id,
    p_tienda_origen_id: tienda_origen_id,
    p_tienda_destino_id: tienda_destino_id,
    p_cantidad: cantidad,
    p_motivo: motivo || 'Traspaso entre tiendas',
    p_usuario_id: userId
  })

  if (error) {
    throw new Error(`Error realizando traspaso: ${error.message}`)
  }

  // Obtener stocks actualizados de ambas tiendas
  const { data: stocksActualizados } = await supabaseClient
    .from('inventario_tienda')
    .select(`
      tienda_id,
      stock_actual,
      tiendas!inner(nombre, codigo)
    `)
    .eq('articulo_id', articulo_id)
    .in('tienda_id', [tienda_origen_id, tienda_destino_id])

  return {
    success: true,
    message: 'Traspaso realizado exitosamente',
    data: {
      traspaso_completado: true,
      stocks_actualizados: stocksActualizados
    }
  }
}

async function handleBulkUpdate(
  supabaseClient: any,
  operation: InventoryOperation,
  userId: string
): Promise<InventoryResponse> {
  const { tienda_id, articulos, motivo } = operation

  if (!tienda_id || !articulos || articulos.length === 0) {
    throw new Error('tienda_id y articulos son requeridos')
  }

  const resultados = []
  const errores = []

  for (const item of articulos) {
    try {
      const { data, error } = await supabaseClient.rpc('update_stock_and_create_movement', {
        p_articulo_id: item.articulo_id,
        p_tienda_id: tienda_id,
        p_tipo_movimiento: item.cantidad > 0 ? 'ENTRADA' : 'SALIDA',
        p_cantidad: item.cantidad,
        p_precio_unitario: item.precio,
        p_motivo: motivo || 'Actualización masiva',
        p_referencia_externa: `BULK-${Date.now()}`,
        p_usuario_id: userId
      })

      if (error) {
        errores.push({ articulo_id: item.articulo_id, error: error.message })
      } else {
        resultados.push({ articulo_id: item.articulo_id, actualizado: true })
      }
    } catch (error) {
      errores.push({ articulo_id: item.articulo_id, error: error.message })
    }
  }

  return {
    success: errores.length === 0,
    message: errores.length === 0 
      ? 'Actualización masiva completada exitosamente'
      : `Actualización completada con ${errores.length} errores`,
    data: {
      actualizados: resultados.length,
      errores: errores.length,
      detalles_errores: errores
    }
  }
}

async function handlePriceUpdate(
  supabaseClient: any,
  operation: InventoryOperation,
  userId: string
): Promise<InventoryResponse> {
  const { articulo_id, tienda_id, nuevo_precio, motivo } = operation

  if (!articulo_id || !tienda_id || nuevo_precio === undefined) {
    throw new Error('articulo_id, tienda_id y nuevo_precio son requeridos')
  }

  if (nuevo_precio < 0) {
    throw new Error('El precio no puede ser negativo')
  }

  // Obtener precio anterior
  const { data: inventarioAnterior } = await supabaseClient
    .from('inventario_tienda')
    .select('precio_venta')
    .eq('articulo_id', articulo_id)
    .eq('tienda_id', tienda_id)
    .single()

  if (!inventarioAnterior) {
    throw new Error('Registro de inventario no encontrado')
  }

  // Actualizar precio
  const { error } = await supabaseClient
    .from('inventario_tienda')
    .update({ 
      precio_venta: nuevo_precio,
      updated_at: new Date().toISOString()
    })
    .eq('articulo_id', articulo_id)
    .eq('tienda_id', tienda_id)

  if (error) {
    throw new Error(`Error actualizando precio: ${error.message}`)
  }

  // Crear log de cambio de precio (usando tabla de movimientos con tipo AJUSTE)
  await supabaseClient
    .from('movimientos_stock')
    .insert({
      articulo_id,
      tienda_id,
      tipo_movimiento: 'AJUSTE',
      cantidad: 0,
      stock_anterior: 0,
      stock_nuevo: 0,
      precio_unitario: nuevo_precio,
      motivo: `Cambio precio: $${inventarioAnterior.precio_venta} → $${nuevo_precio}. ${motivo || ''}`,
      referencia_externa: `PRICE-${Date.now()}`,
      usuario_id: userId
    })

  return {
    success: true,
    message: 'Precio actualizado exitosamente',
    data: {
      precio_anterior: inventarioAnterior.precio_venta,
      precio_nuevo: nuevo_precio,
      cambio_porcentual: ((nuevo_precio - inventarioAnterior.precio_venta) / inventarioAnterior.precio_venta * 100).toFixed(2)
    }
  }
}

async function handleLowStockAlert(
  supabaseClient: any,
  operation: InventoryOperation
): Promise<InventoryResponse> {
  const { tienda_id } = operation

  if (!tienda_id) {
    throw new Error('tienda_id es requerido')
  }

  // Obtener artículos con stock bajo usando la función existente
  const { data: articulosStockBajo, error } = await supabaseClient.rpc('get_articulos_stock_bajo', {
    p_tienda_id: tienda_id
  })

  if (error) {
    throw new Error(`Error obteniendo artículos con stock bajo: ${error.message}`)
  }

  // Calcular estadísticas
  const totalArticulos = articulosStockBajo.length
  const valorTotalFaltante = articulosStockBajo.reduce(
    (sum: number, item: any) => sum + (item.diferencia * item.precio_venta), 
    0
  )

  return {
    success: true,
    message: `Se encontraron ${totalArticulos} artículos con stock bajo`,
    data: {
      total_articulos_stock_bajo: totalArticulos,
      valor_total_faltante: valorTotalFaltante,
      articulos: articulosStockBajo,
      recomendacion: totalArticulos > 0 
        ? 'Se recomienda realizar pedido de restock urgente'
        : 'Niveles de stock óptimos'
    }
  }
}