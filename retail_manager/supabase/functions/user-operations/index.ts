// Edge Function: Operaciones Masivas de Usuarios
// Descripción: Funciones especializadas para gestión avanzada de usuarios

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface BulkApprovalRequest {
  user_ids: string[];
  notify_users?: boolean;
  approval_reason?: string;
}

interface MetricsRequest {
  time_range?: 'week' | 'month' | 'quarter';
  include_trends?: boolean;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Get current user
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser();

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const url = new URL(req.url);
    const operation = url.pathname.split('/').pop();

    switch (operation) {
      case 'bulk-approve':
        return await handleBulkApproval(req, supabaseClient, user.id);
      case 'bulk-reject':
        return await handleBulkReject(req, supabaseClient, user.id);
      case 'bulk-suspend':
        return await handleBulkSuspend(req, supabaseClient, user.id);
      case 'metrics':
        return await handleMetrics(req, supabaseClient, user.id);
      case 'urgent-notifications':
        return await handleUrgentNotifications(req, supabaseClient, user.id);
      default:
        return new Response(
          JSON.stringify({ error: 'Operation not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }

  } catch (error) {
    console.error('Error in user-operations function:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

async function handleBulkApproval(
  req: Request,
  supabaseClient: any,
  userId: string
): Promise<Response> {
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: corsHeaders }
    );
  }

  const { user_ids, notify_users = true, approval_reason }: BulkApprovalRequest = await req.json();

  if (!user_ids || user_ids.length === 0) {
    return new Response(
      JSON.stringify({ error: 'No user IDs provided' }),
      { status: 400, headers: corsHeaders }
    );
  }

  // Validate permission using database function
  const { data: canModify, error: permissionError } = await supabaseClient
    .rpc('validar_operacion_masiva', {
      usuario_ids: user_ids,
      operacion: 'APROBAR'
    });

  if (permissionError || !canModify) {
    return new Response(
      JSON.stringify({ error: 'Insufficient permissions for bulk operation' }),
      { status: 403, headers: corsHeaders }
    );
  }

  // Perform bulk approval
  const approvalTimestamp = new Date().toISOString();
  const { data: updatedUsers, error: updateError } = await supabaseClient
    .from('usuarios')
    .update({
      estado: 'ACTIVA',
      fecha_aprobacion: approvalTimestamp,
      aprobado_por: userId,
      ...(approval_reason && { metadatos: { approval_reason } })
    })
    .in('id', user_ids)
    .select('id, email, nombre_completo');

  if (updateError) {
    return new Response(
      JSON.stringify({ error: `Bulk approval failed: ${updateError.message}` }),
      { status: 500, headers: corsHeaders }
    );
  }

  // Send notifications if requested
  if (notify_users && updatedUsers?.length > 0) {
    await sendBulkNotifications(supabaseClient, updatedUsers, 'APPROVED', approval_reason);
  }

  // Log the bulk operation
  await logBulkOperation(supabaseClient, userId, 'BULK_APPROVAL', {
    affected_users: user_ids.length,
    reason: approval_reason
  });

  return new Response(
    JSON.stringify({
      success: true,
      message: `${updatedUsers?.length || 0} usuarios aprobados exitosamente`,
      affected_users: updatedUsers?.length || 0
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function handleBulkReject(
  req: Request,
  supabaseClient: any,
  userId: string
): Promise<Response> {
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: corsHeaders }
    );
  }

  const { user_ids, reason }: { user_ids: string[], reason: string } = await req.json();

  if (!user_ids || user_ids.length === 0) {
    return new Response(
      JSON.stringify({ error: 'No user IDs provided' }),
      { status: 400, headers: corsHeaders }
    );
  }

  if (!reason || reason.trim().length < 10) {
    return new Response(
      JSON.stringify({ error: 'Rejection reason must be at least 10 characters' }),
      { status: 400, headers: corsHeaders }
    );
  }

  // Validate permissions
  const { data: canModify } = await supabaseClient
    .rpc('validar_operacion_masiva', {
      usuario_ids: user_ids,
      operacion: 'RECHAZAR'
    });

  if (!canModify) {
    return new Response(
      JSON.stringify({ error: 'Insufficient permissions' }),
      { status: 403, headers: corsHeaders }
    );
  }

  // Perform bulk rejection
  const { data: updatedUsers, error: updateError } = await supabaseClient
    .from('usuarios')
    .update({
      estado: 'RECHAZADA',
      fecha_rechazo: new Date().toISOString(),
      motivo_rechazo: reason
    })
    .in('id', user_ids)
    .select('id, email, nombre_completo');

  if (updateError) {
    return new Response(
      JSON.stringify({ error: `Bulk rejection failed: ${updateError.message}` }),
      { status: 500, headers: corsHeaders }
    );
  }

  // Send notifications
  if (updatedUsers?.length > 0) {
    await sendBulkNotifications(supabaseClient, updatedUsers, 'REJECTED', reason);
  }

  await logBulkOperation(supabaseClient, userId, 'BULK_REJECTION', {
    affected_users: user_ids.length,
    reason
  });

  return new Response(
    JSON.stringify({
      success: true,
      message: `${updatedUsers?.length || 0} usuarios rechazados`,
      affected_users: updatedUsers?.length || 0
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function handleBulkSuspend(
  req: Request,
  supabaseClient: any,
  userId: string
): Promise<Response> {
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: corsHeaders }
    );
  }

  const { user_ids, reason, duration_days }: { 
    user_ids: string[], 
    reason: string,
    duration_days?: number 
  } = await req.json();

  // Validate permissions
  const { data: canModify } = await supabaseClient
    .rpc('validar_operacion_masiva', {
      usuario_ids: user_ids,
      operacion: 'SUSPENDER'
    });

  if (!canModify) {
    return new Response(
      JSON.stringify({ error: 'Insufficient permissions' }),
      { status: 403, headers: corsHeaders }
    );
  }

  const suspensionData: any = {
    estado: 'SUSPENDIDA',
    fecha_suspension: new Date().toISOString(),
    motivo_suspension: reason
  };

  // Add expiration if duration is provided
  if (duration_days && duration_days > 0) {
    const expirationDate = new Date();
    expirationDate.setDate(expirationDate.getDate() + duration_days);
    suspensionData.bloqueado_hasta = expirationDate.toISOString();
  }

  const { data: updatedUsers, error: updateError } = await supabaseClient
    .from('usuarios')
    .update(suspensionData)
    .in('id', user_ids)
    .select('id, email, nombre_completo');

  if (updateError) {
    return new Response(
      JSON.stringify({ error: `Bulk suspension failed: ${updateError.message}` }),
      { status: 500, headers: corsHeaders }
    );
  }

  // Send notifications
  if (updatedUsers?.length > 0) {
    await sendBulkNotifications(supabaseClient, updatedUsers, 'SUSPENDED', reason);
  }

  await logBulkOperation(supabaseClient, userId, 'BULK_SUSPENSION', {
    affected_users: user_ids.length,
    reason,
    duration_days
  });

  return new Response(
    JSON.stringify({
      success: true,
      message: `${updatedUsers?.length || 0} usuarios suspendidos`,
      affected_users: updatedUsers?.length || 0
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function handleMetrics(
  req: Request,
  supabaseClient: any,
  userId: string
): Promise<Response> {
  if (req.method !== 'GET') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: corsHeaders }
    );
  }

  // Check admin permissions
  const { data: isAdmin, error: roleError } = await supabaseClient
    .rpc('es_admin_activo');

  if (roleError || !isAdmin) {
    return new Response(
      JSON.stringify({ error: 'Admin access required' }),
      { status: 403, headers: corsHeaders }
    );
  }

  // Get dashboard metrics
  const { data: metrics, error: metricsError } = await supabaseClient
    .rpc('get_dashboard_metrics');

  if (metricsError) {
    return new Response(
      JSON.stringify({ error: `Failed to fetch metrics: ${metricsError.message}` }),
      { status: 500, headers: corsHeaders }
    );
  }

  // Get weekly trends
  const { data: trends, error: trendsError } = await supabaseClient
    .from('user_weekly_trends')
    .select('*')
    .order('semana', { ascending: false })
    .limit(8);

  if (trendsError) {
    console.warn('Failed to fetch trends:', trendsError);
  }

  return new Response(
    JSON.stringify({
      ...metrics,
      weekly_trends: trends || []
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function handleUrgentNotifications(
  req: Request,
  supabaseClient: any,
  userId: string
): Promise<Response> {
  if (req.method !== 'GET') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: corsHeaders }
    );
  }

  // Check admin permissions
  const { data: isAdmin } = await supabaseClient.rpc('es_admin_activo');
  if (!isAdmin) {
    return new Response(
      JSON.stringify({ error: 'Admin access required' }),
      { status: 403, headers: corsHeaders }
    );
  }

  // Get urgent pending users (>3 days)
  const { data: urgentUsers, error } = await supabaseClient
    .from('usuarios_lista_optimizada')
    .select('id, email, nombre_completo, created_at, prioridad')
    .eq('estado', 'PENDIENTE_APROBACION')
    .in('prioridad', ['URGENTE', 'MUY_URGENTE'])
    .order('created_at', { ascending: true });

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: corsHeaders }
    );
  }

  const notifications = urgentUsers?.map(user => ({
    id: user.id,
    title: 'Usuario Pendiente de Aprobación',
    message: `${user.nombre_completo || user.email} lleva ${
      user.prioridad === 'MUY_URGENTE' ? 'más de 7 días' : 'más de 3 días'
    } esperando aprobación`,
    priority: user.prioridad,
    created_at: user.created_at,
    action_url: `/admin/users/${user.id}`
  })) || [];

  return new Response(
    JSON.stringify({
      notifications,
      count: notifications.length,
      generated_at: new Date().toISOString()
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// Helper functions
async function sendBulkNotifications(
  supabaseClient: any,
  users: any[],
  action: 'APPROVED' | 'REJECTED' | 'SUSPENDED',
  reason?: string
) {
  try {
    // This would integrate with your notification system
    // For now, just log the notification intent
    console.log(`Sending ${action} notifications to ${users.length} users`, {
      action,
      reason,
      users: users.map(u => u.email)
    });

    // You could integrate with email service here
    // await sendEmailNotifications(users, action, reason);
    
  } catch (error) {
    console.error('Failed to send notifications:', error);
  }
}

async function logBulkOperation(
  supabaseClient: any,
  userId: string,
  operation: string,
  details: any
) {
  try {
    await supabaseClient
      .from('auditoria_usuarios')
      .insert({
        usuario_id: userId,
        accion: operation,
        detalles: details,
        realizada_por: userId
      });
  } catch (error) {
    console.error('Failed to log bulk operation:', error);
  }
}