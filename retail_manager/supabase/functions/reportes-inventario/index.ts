// Edge Function: Reportes de Inventario en Tiempo Real
// Descripción: Genera reportes consolidados de inventario multi-tienda

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ReporteRequest {
  tipo_reporte: 'stock_bajo' | 'consolidado' | 'movimientos' | 'valor_inventario';
  tienda_id?: string;
  fecha_inicio?: string;
  fecha_fin?: string;
  filtros?: {
    marca_id?: string;
    categoria_id?: string;
    stock_minimo?: number;
  };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
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

    // Verificar permisos del usuario
    const { data: usuario } = await supabaseClient
      .from('usuarios')
      .select('rol_id, tienda_asignada, roles!inner(nombre)')
      .eq('id', user.id)
      .single()

    if (!usuario) {
      return new Response(
        JSON.stringify({ error: 'Usuario no encontrado' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 403 }
      )
    }

    const rolUsuario = usuario.roles.nombre
    const tiendaUsuario = usuario.tienda_asignada

    const {
      tipo_reporte,
      tienda_id,
      fecha_inicio,
      fecha_fin,
      filtros = {}
    }: ReporteRequest = await req.json()

    let datosReporte: any = {}

    switch (tipo_reporte) {
      case 'stock_bajo':
        datosReporte = await generarReporteStockBajo(supabaseClient, {
          tienda_id: rolUsuario === 'SUPER_ADMIN' ? tienda_id : tiendaUsuario,
          filtros
        })
        break

      case 'consolidado':
        datosReporte = await generarReporteConsolidado(supabaseClient, {
          tienda_id: rolUsuario === 'SUPER_ADMIN' ? tienda_id : tiendaUsuario,
          filtros
        })
        break

      case 'movimientos':
        datosReporte = await generarReporteMovimientos(supabaseClient, {
          tienda_id: rolUsuario === 'SUPER_ADMIN' ? tienda_id : tiendaUsuario,
          fecha_inicio,
          fecha_fin,
          filtros
        })
        break

      case 'valor_inventario':
        datosReporte = await generarReporteValorInventario(supabaseClient, {
          tienda_id: rolUsuario === 'SUPER_ADMIN' ? tienda_id : tiendaUsuario,
          filtros
        })
        break

      default:
        return new Response(
          JSON.stringify({ error: 'Tipo de reporte no válido' }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }

    return new Response(
      JSON.stringify({
        tipo_reporte,
        generado_en: new Date().toISOString(),
        usuario: {
          id: user.id,
          rol: rolUsuario,
          tienda: tiendaUsuario
        },
        datos: datosReporte
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )

  } catch (error) {
    console.error('Error en reportes-inventario:', error)
    return new Response(
      JSON.stringify({ error: 'Error interno del servidor', details: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})

async function generarReporteStockBajo(supabaseClient: any, params: any) {
  let query = supabaseClient
    .from('productos_disponibles_tienda')
    .select(`
      producto_master_id,
      producto_nombre,
      marca_nombre,
      categoria_nombre,
      talla_codigo,
      articulo_id,
      sku,
      color_nombre,
      tienda_id,
      stock_actual,
      stock_reservado,
      stock_disponible,
      precio_venta
    `)
    .or('stock_actual.lte.stock_minimo,stock_disponible.lte.5')

  if (params.tienda_id) {
    query = query.eq('tienda_id', params.tienda_id)
  }

  if (params.filtros.marca_id) {
    // Necesitaríamos join adicional para filtrar por marca
  }

  const { data, error } = await query.order('stock_disponible', { ascending: true })

  if (error) throw error

  return {
    productos_stock_bajo: data,
    total_productos: data.length,
    valor_total_comprometido: data.reduce((sum: number, item: any) => 
      sum + (item.stock_actual * item.precio_venta), 0
    ),
    resumen_por_tienda: data.reduce((acc: any, item: any) => {
      if (!acc[item.tienda_id]) {
        acc[item.tienda_id] = { count: 0, valor: 0 }
      }
      acc[item.tienda_id].count++
      acc[item.tienda_id].valor += item.stock_actual * item.precio_venta
      return acc
    }, {})
  }
}

async function generarReporteConsolidado(supabaseClient: any, params: any) {
  // Usar la vista materializada stock_consolidado_productos
  let query = supabaseClient
    .from('stock_consolidado_productos')
    .select('*')

  if (params.filtros.marca_nombre) {
    query = query.eq('marca_nombre', params.filtros.marca_nombre)
  }

  const { data, error } = await query.order('stock_total', { ascending: false })

  if (error) throw error

  return {
    productos: data,
    total_productos: data.length,
    stock_total_sistema: data.reduce((sum: number, item: any) => sum + item.stock_total, 0),
    valor_total_inventario: data.reduce((sum: number, item: any) => 
      sum + (item.stock_total * item.precio_promedio), 0
    ),
    estadisticas: {
      productos_sin_stock: data.filter((p: any) => p.stock_total === 0).length,
      productos_stock_alto: data.filter((p: any) => p.stock_total > 100).length,
      precio_promedio_general: data.reduce((sum: number, item: any) => 
        sum + item.precio_promedio, 0) / data.length
    }
  }
}

async function generarReporteMovimientos(supabaseClient: any, params: any) {
  let query = supabaseClient
    .from('movimientos_stock')
    .select(`
      id,
      tipo_movimiento,
      cantidad,
      precio_unitario,
      fecha_movimiento,
      motivo,
      articulos!inner(
        sku,
        productos_master!inner(nombre, marcas!inner(nombre))
      ),
      tiendas!inner(nombre, codigo)
    `)

  if (params.tienda_id) {
    query = query.eq('tienda_id', params.tienda_id)
  }

  if (params.fecha_inicio) {
    query = query.gte('fecha_movimiento', params.fecha_inicio)
  }

  if (params.fecha_fin) {
    query = query.lte('fecha_movimiento', params.fecha_fin)
  }

  const { data, error } = await query
    .order('fecha_movimiento', { ascending: false })
    .limit(1000) // Limitar para performance

  if (error) throw error

  return {
    movimientos: data,
    total_movimientos: data.length,
    resumen_por_tipo: data.reduce((acc: any, mov: any) => {
      if (!acc[mov.tipo_movimiento]) {
        acc[mov.tipo_movimiento] = { count: 0, cantidad_total: 0, valor_total: 0 }
      }
      acc[mov.tipo_movimiento].count++
      acc[mov.tipo_movimiento].cantidad_total += Math.abs(mov.cantidad)
      acc[mov.tipo_movimiento].valor_total += Math.abs(mov.cantidad * mov.precio_unitario)
      return acc
    }, {}),
    valor_total_movido: data.reduce((sum: number, mov: any) => 
      sum + Math.abs(mov.cantidad * mov.precio_unitario), 0
    )
  }
}

async function generarReporteValorInventario(supabaseClient: any, params: any) {
  let query = supabaseClient
    .from('inventario_tienda')
    .select(`
      stock_actual,
      precio_venta,
      precio_costo,
      articulos!inner(
        sku,
        productos_master!inner(nombre, marcas!inner(nombre), categorias!inner(nombre))
      ),
      tiendas!inner(nombre, codigo)
    `)
    .eq('activo', true)

  if (params.tienda_id) {
    query = query.eq('tienda_id', params.tienda_id)
  }

  const { data, error } = await query

  if (error) throw error

  const valorVenta = data.reduce((sum: number, item: any) => 
    sum + (item.stock_actual * item.precio_venta), 0
  )

  const valorCosto = data.reduce((sum: number, item: any) => 
    sum + (item.stock_actual * item.precio_costo), 0
  )

  return {
    inventario: data,
    resumen: {
      total_articulos: data.length,
      unidades_total: data.reduce((sum: number, item: any) => sum + item.stock_actual, 0),
      valor_venta_total: valorVenta,
      valor_costo_total: valorCosto,
      utilidad_potencial: valorVenta - valorCosto,
      margen_promedio: ((valorVenta - valorCosto) / valorVenta) * 100
    },
    por_marca: data.reduce((acc: any, item: any) => {
      const marca = item.articulos.productos_master.marcas.nombre
      if (!acc[marca]) {
        acc[marca] = { unidades: 0, valor_venta: 0, valor_costo: 0 }
      }
      acc[marca].unidades += item.stock_actual
      acc[marca].valor_venta += item.stock_actual * item.precio_venta
      acc[marca].valor_costo += item.stock_actual * item.precio_costo
      return acc
    }, {})
  }
}