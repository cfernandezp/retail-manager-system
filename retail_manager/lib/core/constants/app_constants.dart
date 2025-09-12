class AppConstants {
  // App Info
  static const String appName = 'Retail Manager';
  static const String appVersion = '1.0.0';
  
  // Supabase Configuration (Local)
  static const String supabaseUrl = 'http://127.0.0.1:54321';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
  
  // Database Tables
  static const String usuariosTable = 'usuarios';
  static const String tiendasTable = 'tiendas';
  static const String productosTable = 'productos';
  static const String inventarioTable = 'inventario';
  static const String ventasTable = 'ventas';
  static const String clientesTable = 'clientes';
  
  // Storage Buckets
  static const String productImagesBucket = 'product-images';
  
  // Local Storage Keys
  static const String userSessionKey = 'user_session';
  static const String selectedStoreKey = 'selected_store';
  static const String themeKey = 'theme_mode';
  
  // Validation Constants
  static const int dniLength = 8;
  static const int rucLength = 11;
  static const int phoneLength = 9;
  
  // Currency
  static const String currency = 'S/';
  static const String locale = 'es_PE';
  
  // API Endpoints
  static const String procesarVentaFunction = 'procesar-venta';
  static const String actualizarStockFunction = 'actualizar-stock';
  static const String generarReporteFunction = 'generar-reporte';
}