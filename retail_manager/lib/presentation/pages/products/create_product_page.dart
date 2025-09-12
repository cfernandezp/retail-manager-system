import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart' as models;
import '../../../data/repositories/products_repository_simple.dart';
import '../../bloc/products/products_bloc.dart';
import '../../widgets/products/color_selector.dart';
import '../../widgets/products/talla_selector.dart';
import '../../widgets/common/corporate_form_field.dart';
import '../../widgets/common/corporate_button.dart';

/// Página para crear un nuevo producto con wizard de 3 pasos
class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late ProductsRepository _productsRepository;
  
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _newMarcaController = TextEditingController();
  final _newCategoriaController = TextEditingController();
  final _newMaterialController = TextEditingController();
  final _newTallaController = TextEditingController();
  
  // Selection state
  String? _selectedMarcaId;
  String? _selectedCategoriaId;
  String? _selectedTallaId;
  String? _selectedMaterialId;
  List<String> _selectedColores = [];
  Map<String, double> _preciosPorColor = {};
  List<String> _selectedTiendas = [];
  Map<String, Map<String, dynamic>> _inventarioPorTienda = {};
  
  // Data
  List<models.Marca> _marcas = [];
  List<models.Categoria> _categorias = [];
  List<models.Talla> _tallas = [];
  List<models.Material> _materiales = [];
  List<models.Tienda> _tiendas = [];
  
  // UI State
  bool _isLoading = false;
  bool _showNewMarcaField = false;
  bool _showNewCategoriaField = false;
  bool _showNewMaterialField = false;
  bool _showNewTallaField = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _productsRepository = ProductsRepository();
    
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _newMarcaController.dispose();
    _newCategoriaController.dispose();
    _newMaterialController.dispose();
    _newTallaController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    // ========================================================================
    // SISTEMA DE LOGGING COMPLETO PARA DEBUGGING REMOTO
    // ========================================================================
    final timestamp = DateTime.now();
    print('');
    print('==================== [DROPDOWN_DEBUG] ====================');
    print('⏰ TIMESTAMP: $timestamp');
    print('🚀 INICIANDO: Carga completa de datos para dropdowns');
    print('📱 CONTEXTO: CreateProductPage._loadInitialData()');
    print('===========================================================');
    
    // Estado inicial de UI
    print('');
    print('=== [UI_STATE] ESTADO INICIAL ===');
    print('🔄 _isLoading: $_isLoading (antes de setState)');
    print('📊 Listas actuales:');
    print('   • _marcas.length: ${_marcas.length}');
    print('   • _categorias.length: ${_categorias.length}'); 
    print('   • _tallas.length: ${_tallas.length}');
    print('   • _materiales.length: ${_materiales.length}');
    print('   • _tiendas.length: ${_tiendas.length}');
    print('=== FIN UI_STATE INICIAL ===\n');
    
    setState(() => _isLoading = true);
    
    print('=== [UI_STATE] DESPUÉS DE setState ===');
    print('🔄 _isLoading: $_isLoading (después de setState)');
    print('✅ setState ejecutado correctamente');
    print('=== FIN UI_STATE DESPUÉS DE setState ===\n');
    
    try {
      // Verificar conexión a repository
      print('=== [CONNECTION_CHECK] VERIFICACIÓN DE CONEXIÓN ===');
      print('📡 ProductsRepository instanciado: ${_productsRepository != null}');
      print('📡 Tipo de repository: ${_productsRepository.runtimeType}');
      print('=== FIN CONNECTION_CHECK ===\n');
      
      // ========================================================================
      // CARGA DE MARCAS
      // ========================================================================
      print('=== [DROPDOWN_DEBUG] ${DateTime.now()} ===');
      print('🔄 INICIANDO carga de MARCAS...');
      print('📍 Método: _productsRepository.getMarcas()');
      
      try {
        final marcas = await _productsRepository.getMarcas();
        print('✅ MARCAS: ${marcas.length} registros cargados exitosamente');
        
        if (marcas.isNotEmpty) {
          print('📋 Primeras 3 marcas:');
          for (int i = 0; i < marcas.length && i < 3; i++) {
            final marca = marcas[i];
            print('   ${i+1}. ID: ${marca.id} | Nombre: "${marca.nombre}"');
          }
          
          if (marcas.length > 3) {
            print('   ... y ${marcas.length - 3} marcas más');
          }
          
          // Validar estructura de datos
          final primeraMarca = marcas.first;
          print('🔍 Estructura primera marca:');
          try {
            print('   JSON: ${primeraMarca.toJson()}');
          } catch (e) {
            print('   ⚠️ Error al serializar marca: $e');
          }
        } else {
          print('⚠️ ALERTA: Lista de marcas está COMPLETAMENTE VACÍA');
          print('🚨 POSIBLES CAUSAS:');
          print('   1. Tabla "marcas" vacía en BD');
          print('   2. Error en query SQL');
          print('   3. Problema de permisos RLS');
          print('   4. Conexión a BD fallida');
        }
        
        _marcas = marcas;
        print('💾 Variable _marcas asignada: ${_marcas.length} registros');
        
      } catch (e, stackTrace) {
        print('❌ ERROR MARCAS: $e');
        print('📜 STACK TRACE MARCAS:');
        print('$stackTrace');
        print('🚨 Error específico al cargar marcas - proceso continuará');
        _marcas = []; // Lista vacía para evitar errores
      }
      
      print('=== FIN MARCAS DEBUG ===\n');
      
      // ========================================================================
      // CARGA DE CATEGORÍAS
      // ========================================================================
      print('=== [DROPDOWN_DEBUG] ${DateTime.now()} ===');
      print('🔄 INICIANDO carga de CATEGORÍAS...');
      print('📍 Método: _productsRepository.getCategorias()');
      
      try {
        final categorias = await _productsRepository.getCategorias();
        print('✅ CATEGORÍAS: ${categorias.length} registros cargados exitosamente');
        
        if (categorias.isNotEmpty) {
          print('📋 Primeras 3 categorías:');
          for (int i = 0; i < categorias.length && i < 3; i++) {
            final categoria = categorias[i];
            print('   ${i+1}. ID: ${categoria.id} | Nombre: "${categoria.nombre}"');
          }
          
          if (categorias.length > 3) {
            print('   ... y ${categorias.length - 3} categorías más');
          }
          
          // Validar estructura de datos
          final primeraCategoria = categorias.first;
          print('🔍 Estructura primera categoría:');
          try {
            print('   JSON: ${primeraCategoria.toJson()}');
          } catch (e) {
            print('   ⚠️ Error al serializar categoría: $e');
          }
        } else {
          print('⚠️ ALERTA: Lista de categorías está COMPLETAMENTE VACÍA');
          print('🚨 POSIBLES CAUSAS:');
          print('   1. Tabla "categorias" vacía en BD');
          print('   2. Error en query SQL');
          print('   3. Problema de permisos RLS');
          print('   4. Conexión a BD fallida');
        }
        
        _categorias = categorias;
        print('💾 Variable _categorias asignada: ${_categorias.length} registros');
        
      } catch (e, stackTrace) {
        print('❌ ERROR CATEGORÍAS: $e');
        print('📜 STACK TRACE CATEGORÍAS:');
        print('$stackTrace');
        print('🚨 Error específico al cargar categorías - proceso continuará');
        _categorias = []; // Lista vacía para evitar errores
      }
      
      print('=== FIN CATEGORÍAS DEBUG ===\n');
      
      // ========================================================================
      // CARGA DE TALLAS
      // ========================================================================
      print('=== [DROPDOWN_DEBUG] ${DateTime.now()} ===');
      print('🔄 INICIANDO carga de TALLAS...');
      print('📍 Método: _productsRepository.getTallas()');
      
      try {
        final tallas = await _productsRepository.getTallas();
        print('✅ TALLAS: ${tallas.length} registros cargados exitosamente');
        
        if (tallas.isNotEmpty) {
          print('📋 Primeras 5 tallas:');
          for (int i = 0; i < tallas.length && i < 5; i++) {
            final talla = tallas[i];
            print('   ${i+1}. ID: ${talla.id} | Valor: "${talla.valor}" | Display: "${talla.displayName}"');
          }
          
          if (tallas.length > 5) {
            print('   ... y ${tallas.length - 5} tallas más');
          }
          
          // Validar estructura de datos
          final primeraTalla = tallas.first;
          print('🔍 Estructura primera talla:');
          try {
            print('   JSON: ${primeraTalla.toJson()}');
          } catch (e) {
            print('   ⚠️ Error al serializar talla: $e');
          }
        } else {
          print('⚠️ ALERTA: Lista de tallas está COMPLETAMENTE VACÍA');
          print('🚨 POSIBLES CAUSAS:');
          print('   1. Tabla "tallas" vacía en BD');
          print('   2. Error en query SQL');
          print('   3. Problema de permisos RLS');
          print('   4. Conexión a BD fallida');
        }
        
        _tallas = tallas;
        print('💾 Variable _tallas asignada: ${_tallas.length} registros');
        
      } catch (e, stackTrace) {
        print('❌ ERROR TALLAS: $e');
        print('📜 STACK TRACE TALLAS:');
        print('$stackTrace');
        print('🚨 Error específico al cargar tallas - proceso continuará');
        _tallas = []; // Lista vacía para evitar errores
      }
      
      print('=== FIN TALLAS DEBUG ===\n');
      
      // ========================================================================
      // CARGA DE MATERIALES
      // ========================================================================
      print('=== [DROPDOWN_DEBUG] ${DateTime.now()} ===');
      print('🔄 INICIANDO carga de MATERIALES...');
      print('📍 Método: _productsRepository.getMateriales()');
      
      try {
        final materiales = await _productsRepository.getMateriales();
        print('✅ MATERIALES: ${materiales.length} registros cargados exitosamente');
        
        if (materiales.isNotEmpty) {
          print('📋 Primeros 3 materiales:');
          for (int i = 0; i < materiales.length && i < 3; i++) {
            final material = materiales[i];
            print('   ${i+1}. ID: ${material.id} | Nombre: "${material.nombre}"');
          }
          
          if (materiales.length > 3) {
            print('   ... y ${materiales.length - 3} materiales más');
          }
          
          // Validar estructura de datos
          final primerMaterial = materiales.first;
          print('🔍 Estructura primer material:');
          try {
            print('   JSON: ${primerMaterial.toJson()}');
          } catch (e) {
            print('   ⚠️ Error al serializar material: $e');
          }
        } else {
          print('⚠️ ALERTA: Lista de materiales está COMPLETAMENTE VACÍA');
          print('🚨 POSIBLES CAUSAS:');
          print('   1. Tabla "materiales" vacía en BD');
          print('   2. Error en query SQL');
          print('   3. Problema de permisos RLS');
          print('   4. Conexión a BD fallida');
        }
        
        _materiales = materiales;
        print('💾 Variable _materiales asignada: ${_materiales.length} registros');
        
      } catch (e, stackTrace) {
        print('❌ ERROR MATERIALES: $e');
        print('📜 STACK TRACE MATERIALES:');
        print('$stackTrace');
        print('🚨 Error específico al cargar materiales - proceso continuará');
        _materiales = []; // Lista vacía para evitar errores
      }
      
      print('=== FIN MATERIALES DEBUG ===\n');
      
      // ========================================================================
      // CARGA DE TIENDAS
      // ========================================================================
      print('=== [DROPDOWN_DEBUG] ${DateTime.now()} ===');
      print('🔄 INICIANDO carga de TIENDAS...');
      print('📍 Método: _productsRepository.getTiendas()');
      
      try {
        final tiendas = await _productsRepository.getTiendas();
        print('✅ TIENDAS: ${tiendas.length} registros cargados exitosamente');
        
        if (tiendas.isNotEmpty) {
          print('📋 Primeras 3 tiendas:');
          for (int i = 0; i < tiendas.length && i < 3; i++) {
            final tienda = tiendas[i];
            print('   ${i+1}. ID: ${tienda.id} | Nombre: "${tienda.nombre}" | Dirección: "${tienda.direccion}"');
          }
          
          if (tiendas.length > 3) {
            print('   ... y ${tiendas.length - 3} tiendas más');
          }
          
          // Validar estructura de datos
          final primeraTienda = tiendas.first;
          print('🔍 Estructura primera tienda:');
          try {
            print('   JSON: ${primeraTienda.toJson()}');
          } catch (e) {
            print('   ⚠️ Error al serializar tienda: $e');
          }
        } else {
          print('⚠️ ALERTA: Lista de tiendas está COMPLETAMENTE VACÍA');
          print('🚨 POSIBLES CAUSAS:');
          print('   1. Tabla "tiendas" vacía en BD');
          print('   2. Error en query SQL');
          print('   3. Problema de permisos RLS');
          print('   4. Conexión a BD fallida');
        }
        
        _tiendas = tiendas;
        print('💾 Variable _tiendas asignada: ${_tiendas.length} registros');
        
      } catch (e, stackTrace) {
        print('❌ ERROR TIENDAS: $e');
        print('📜 STACK TRACE TIENDAS:');
        print('$stackTrace');
        print('🚨 Error específico al cargar tiendas - proceso continuará');
        _tiendas = []; // Lista vacía para evitar errores
      }
      
      print('=== FIN TIENDAS DEBUG ===\n');
      
      // ========================================================================
      // RESUMEN FINAL COMPLETO
      // ========================================================================
      print('');
      print('================== [RESUMEN_FINAL] ==================');
      print('🎯 CARGA DE DATOS COMPLETADA');
      print('⏰ Timestamp final: ${DateTime.now()}');
      print('');
      print('📊 RESULTADOS POR DROPDOWN:');
      print('   📦 MARCAS........: ${_marcas.length} registros ${_marcas.isEmpty ? "❌ VACÍO" : "✅"}');
      print('   📂 CATEGORÍAS....: ${_categorias.length} registros ${_categorias.isEmpty ? "❌ VACÍO" : "✅"}');
      print('   📏 TALLAS........: ${_tallas.length} registros ${_tallas.isEmpty ? "❌ VACÍO" : "✅"}');
      print('   🧵 MATERIALES....: ${_materiales.length} registros ${_materiales.isEmpty ? "❌ VACÍO" : "✅"}');
      print('   🏪 TIENDAS.......: ${_tiendas.length} registros ${_tiendas.isEmpty ? "❌ VACÍO" : "✅"}');
      print('');
      
      // Verificar estado crítico
      final totalRegistros = _marcas.length + _categorias.length + _tallas.length + _materiales.length + _tiendas.length;
      final dropdownsVacios = [_marcas, _categorias, _tallas, _materiales, _tiendas]
          .where((lista) => lista.isEmpty).length;
      
      print('📈 ESTADÍSTICAS GLOBALES:');
      print('   • Total registros cargados: $totalRegistros');
      print('   • Dropdowns con datos: ${5 - dropdownsVacios}/5');
      print('   • Dropdowns vacíos: $dropdownsVacios/5');
      print('');
      
      if (dropdownsVacios == 0) {
        print('🎉 ¡ÉXITO COMPLETO! Todos los dropdowns tienen datos');
        print('✅ La UI debería funcionar correctamente');
      } else {
        print('⚠️ PROBLEMAS DETECTADOS:');
        print('🚨 $dropdownsVacios dropdowns están vacíos');
        print('❌ La UI mostrará la vista de debug');
        
        if (_marcas.isEmpty) print('   • MARCAS: Lista vacía');
        if (_categorias.isEmpty) print('   • CATEGORÍAS: Lista vacía');
        if (_tallas.isEmpty) print('   • TALLAS: Lista vacía');
        if (_materiales.isEmpty) print('   • MATERIALES: Lista vacía');
        if (_tiendas.isEmpty) print('   • TIENDAS: Lista vacía');
      }
      
      print('================== FIN RESUMEN_FINAL ==================');
      print('');
      
    } catch (e, stackTrace) {
      // ========================================================================
      // MANEJO DE ERRORES CRÍTICOS
      // ========================================================================
      print('');
      print('🚨🚨🚨 [ERROR_CRÍTICO] 🚨🚨🚨');
      print('⏰ Timestamp error: ${DateTime.now()}');
      print('❌ ERROR CRÍTICO GLOBAL al cargar datos');
      print('📍 Ubicación: _loadInitialData() - try/catch principal');
      print('');
      print('🔍 DETALLES DEL ERROR:');
      print('Tipo: ${e.runtimeType}');
      print('Mensaje: $e');
      print('');
      print('📜 STACK TRACE COMPLETO:');
      print('$stackTrace');
      print('');
      print('📊 ESTADO DE LISTAS AL MOMENTO DEL ERROR:');
      print('   • _marcas: ${_marcas.length} registros');
      print('   • _categorias: ${_categorias.length} registros');
      print('   • _tallas: ${_tallas.length} registros');
      print('   • _materiales: ${_materiales.length} registros');
      print('   • _tiendas: ${_tiendas.length} registros');
      print('🚨🚨🚨 FIN ERROR_CRÍTICO 🚨🚨🚨');
      print('');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error crítico al cargar datos: $e'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 8), // Más tiempo para errores críticos
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () => _loadInitialData(),
            ),
          ),
        );
      }
    } finally {
      // ========================================================================
      // FINALIZACIÓN Y ACTUALIZACIÓN DE UI
      // ========================================================================
      print('');
      print('=== [UI_STATE] FINALIZACIÓN ===');
      print('🔄 Ejecutando setState final...');
      print('📱 mounted: $mounted');
      
      if (mounted) {
        print('✅ Widget está montado, actualizando _isLoading');
        setState(() => _isLoading = false);
        print('💾 _isLoading actualizado: $_isLoading');
        print('🎨 UI se re-renderizará con nuevos datos');
      } else {
        print('⚠️ Widget NO está montado, saltando setState');
      }
      
      print('=== FIN UI_STATE FINALIZACIÓN ===');
      print('');
      print('==================== FIN DROPDOWN_DEBUG ====================');
      print('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _hasDebugData()
        ? Column(
        children: [
          // Header with progress
          _buildHeader(),
          
          // Progress indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildStep1(), // Información básica
                _buildStep2(), // Colores y variantes
                _buildStep3(), // Inventario por tienda
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      )
      : _buildDebugDataView(), // ⚠️ NUEVO: Vista de debug
    );
  }
  
  /// Widget temporal de debug para mostrar el estado de los datos
  Widget _buildDebugDataView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 DEBUG: PROBLEMA CON DATOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Estado actual de las listas de datos:'),
                const SizedBox(height: 8),
                
                _buildDebugDataItem('📦 Marcas', _marcas.length, _marcas.take(3).map((m) => m.nombre).join(', ')),
                _buildDebugDataItem('📂 Categorías', _categorias.length, _categorias.take(3).map((c) => c.nombre).join(', ')),
                _buildDebugDataItem('📏 Tallas', _tallas.length, _tallas.take(3).map((t) => t.valor).join(', ')),
                _buildDebugDataItem('🧵 Materiales', _materiales.length, _materiales.take(3).map((m) => m.nombre).join(', ')),
                _buildDebugDataItem('🏪 Tiendas', _tiendas.length, _tiendas.take(3).map((t) => t.nombre).join(', ')),
                
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loadInitialData(); // Reintentar carga
                    });
                  },
                  child: const Text('🔄 Reintentar Carga de Datos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDebugDataItem(String label, int count, String sample) {
    final isEmpty = count == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isEmpty ? Colors.red : Colors.green,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count registros',
                  style: TextStyle(
                    color: isEmpty ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isEmpty && sample.isNotEmpty)
                  Text(
                    'Ejemplos: $sample',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (isEmpty)
                  const Text(
                    '❌ LISTA VACÍA - PROBLEMA DETECTADO',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Verifica si hay datos suficientes para mostrar la UI normal
  bool _hasDebugData() {
    // Solo mostrar UI normal si TODAS las listas tienen datos
    return _marcas.isNotEmpty && 
           _categorias.isNotEmpty && 
           _tallas.isNotEmpty && 
           _materiales.isNotEmpty && 
           _tiendas.isNotEmpty;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.add_circle_outline,
            color: AppTheme.primaryTurquoise,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear Nuevo Producto',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepTitle(_currentStep),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(
          _totalSteps,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < _totalSteps - 1 ? 8 : 0,
              ),
              child: LinearProgressIndicator(
                value: index <= _currentStep ? 1.0 : 0.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryTurquoise,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica del Producto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Nombre del producto
            CorporateFormField(
              controller: _nombreController,
              label: 'Nombre del Producto',
              hintText: 'Ej: Media deportiva de algodón',
              prefixIcon: Icons.inventory_2_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El nombre es requerido';
                }
                if (value!.length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),

            // Marca
            _buildMarcaSelector(),
            
            const SizedBox(height: 20),

            // Categoría
            _buildCategoriaSelector(),
            
            const SizedBox(height: 20),

            // Material
            _buildMaterialSelector(),
            
            const SizedBox(height: 20),

            // Talla
            _buildTallaSelector(),
            
            const SizedBox(height: 20),

            // Precio sugerido
            CorporateFormField(
              controller: _precioController,
              label: 'Precio Sugerido (S/)',
              hintText: '0.00',
              prefixIcon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El precio es requerido';
                }
                final precio = double.tryParse(value!);
                if (precio == null || precio <= 0) {
                  return 'Ingrese un precio válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarcaSelector() {
    print('🎨 [MarcaSelector] Construyendo widget con ${_marcas.length} marcas');
    if (_marcas.isEmpty) {
      print('⚠️ [MarcaSelector] ALERTA: Lista de marcas está vacía en build()');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marca',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_showNewMarcaField) ...[
          CorporateFormField(
            controller: _newMarcaController,
            label: 'Nueva Marca',
            hintText: 'Nombre de la marca',
          ),
        ] else ...[
          DropdownButtonFormField<String>(
            value: _selectedMarcaId,
            decoration: const InputDecoration(
              hintText: 'Seleccionar marca',
              prefixIcon: Icon(Icons.branding_watermark),
            ),
            items: [
              ..._marcas.map(
                (marca) => DropdownMenuItem(
                  value: marca.id,
                  child: Text(marca.nombre),
                ),
              ),
              const DropdownMenuItem(
                value: 'nueva',
                child: Text(
                  '+ Crear nueva marca',
                  style: TextStyle(
                    color: AppTheme.primaryTurquoise,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == 'nueva') {
                setState(() => _showNewMarcaField = true);
              } else {
                setState(() => _selectedMarcaId = value);
              }
            },
            validator: (value) {
              if (value == null && !_showNewMarcaField) {
                return 'Seleccione o cree una marca';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCategoriaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_showNewCategoriaField) ...[
          CorporateFormField(
            controller: _newCategoriaController,
            label: 'Nueva Categoría',
            hintText: 'Nombre de la categoría',
          ),
        ] else ...[
          DropdownButtonFormField<String>(
            value: _selectedCategoriaId,
            decoration: const InputDecoration(
              hintText: 'Seleccionar categoría',
              prefixIcon: Icon(Icons.category),
            ),
            items: [
              ..._categorias.map(
                (categoria) => DropdownMenuItem(
                  value: categoria.id,
                  child: Text(categoria.nombre),
                ),
              ),
              const DropdownMenuItem(
                value: 'nueva',
                child: Text(
                  '+ Crear nueva categoría',
                  style: TextStyle(
                    color: AppTheme.primaryTurquoise,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == 'nueva') {
                setState(() => _showNewCategoriaField = true);
              } else {
                setState(() => _selectedCategoriaId = value);
              }
            },
            validator: (value) {
              if (value == null && !_showNewCategoriaField) {
                return 'Seleccione o cree una categoría';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMaterialSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Material',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_showNewMaterialField) ...[
          CorporateFormField(
            controller: _newMaterialController,
            label: 'Nuevo Material',
            hintText: 'Nombre del material',
          ),
        ] else ...[
          DropdownButtonFormField<String>(
            value: _selectedMaterialId,
            decoration: const InputDecoration(
              hintText: 'Seleccionar material',
              prefixIcon: Icon(Icons.texture),
            ),
            items: [
              ..._materiales.map(
                (material) => DropdownMenuItem(
                  value: material.id,
                  child: Text(material.nombre),
                ),
              ),
              const DropdownMenuItem(
                value: 'nuevo',
                child: Text(
                  '+ Crear nuevo material',
                  style: TextStyle(
                    color: AppTheme.primaryTurquoise,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == 'nuevo') {
                setState(() => _showNewMaterialField = true);
              } else {
                setState(() => _selectedMaterialId = value);
              }
            },
            validator: (value) {
              if (value == null && !_showNewMaterialField) {
                return 'Seleccione o cree un material';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTallaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Talla',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_showNewTallaField) ...[
          // Mostrar tallas existentes como referencia
          if (_tallas.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTurquoise.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryTurquoise.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tallas existentes:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _tallas.take(8).map((talla) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTurquoise.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        talla.valor.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
          CorporateFormField(
            controller: _newTallaController,
            label: 'Nueva Talla',
            hintText: _tallas.isEmpty 
              ? 'Ej: 9-12, M, XL, 36, Única' 
              : 'Ingresa una talla que no esté en la lista superior',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'La talla es requerida';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _createNewTalla,
                child: const Text('Crear Talla'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showNewTallaField = false;
                    _newTallaController.clear();
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ] else ...[
          DropdownButtonFormField<String>(
            value: _selectedTallaId,
            decoration: const InputDecoration(
              hintText: 'Seleccionar talla',
              prefixIcon: Icon(Icons.straighten),
            ),
            items: [
              ..._tallas.map(
                (talla) => DropdownMenuItem(
                  value: talla.id,
                  child: Text(talla.displayName),
                ),
              ),
              const DropdownMenuItem(
                value: 'nueva',
                child: Text(
                  '+ Crear nueva talla',
                  style: TextStyle(
                    color: AppTheme.primaryTurquoise,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == 'nueva') {
                setState(() => _showNewTallaField = true);
              } else {
                setState(() => _selectedTallaId = value);
              }
            },
            validator: (value) {
              if (value == null && !_showNewTallaField) {
                return 'Seleccione o cree una talla';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Colores y Variantes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selecciona los colores disponibles para este producto',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Color selector
          ColorSelector(
            selectedColors: _selectedColores,
            onColorsChanged: (colors) {
              setState(() {
                _selectedColores = colors;
                // Inicializar precios por color
                for (final color in colors) {
                  if (!_preciosPorColor.containsKey(color)) {
                    final precioBase = double.tryParse(_precioController.text) ?? 0.0;
                    _preciosPorColor[color] = precioBase;
                  }
                }
                // Remover precios de colores no seleccionados
                _preciosPorColor.removeWhere(
                  (color, _) => !colors.contains(color),
                );
              });
            },
          ),

          if (_selectedColores.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text(
              'Precios por Color (Opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personaliza el precio para cada color o usa el precio base',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de precios por color
            ..._selectedColores.map((color) => 
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    // Color indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getColorFromName(color),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Color name
                    SizedBox(
                      width: 100,
                      child: Text(
                        color,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Price input
                    Expanded(
                      child: TextFormField(
                        initialValue: _preciosPorColor[color]?.toString() ?? '',
                        decoration: InputDecoration(
                          labelText: 'Precio S/',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          final precio = double.tryParse(value);
                          if (precio != null) {
                            _preciosPorColor[color] = precio;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),

            const SizedBox(height: 24),
            
            // Preview de SKUs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vista Previa de SKUs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._selectedColores.map((color) {
                      final sku = _generatePreviewSKU(color);
                      final precio = _preciosPorColor[color] ?? 
                          double.tryParse(_precioController.text) ?? 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getColorFromName(color),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$sku - $color',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              'S/ ${precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primaryTurquoise,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disponibilidad por Tienda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Configura el stock inicial y precios por tienda',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Selector de tiendas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tiendas Disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ..._tiendas.map((tienda) {
                    final isSelected = _selectedTiendas.contains(tienda.id);
                    return CheckboxListTile(
                      title: Text(tienda.nombre),
                      subtitle: Text(tienda.direccion),
                      value: isSelected,
                      activeColor: AppTheme.primaryTurquoise,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedTiendas.add(tienda.id);
                            // Inicializar inventario para esta tienda
                            _inventarioPorTienda[tienda.id] = {
                              'stock_inicial': 0,
                              'precio_local': double.tryParse(_precioController.text) ?? 0.0,
                            };
                          } else {
                            _selectedTiendas.remove(tienda.id);
                            _inventarioPorTienda.remove(tienda.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          if (_selectedTiendas.isNotEmpty) ...[
            const SizedBox(height: 24),
            
            // Configuración por tienda
            ..._selectedTiendas.map((tiendaId) {
              final tienda = _tiendas.firstWhere((t) => t.id == tiendaId);
              final inventario = _inventarioPorTienda[tiendaId] ?? {};
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tienda.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTurquoise,
                        ),
                      ),
                      Text(
                        tienda.direccion,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Stock inicial
                          Expanded(
                            child: TextFormField(
                              initialValue: inventario['stock_inicial']?.toString() ?? '0',
                              decoration: const InputDecoration(
                                labelText: 'Stock Inicial',
                                suffixText: 'unidades',
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final stock = int.tryParse(value) ?? 0;
                                _inventarioPorTienda[tiendaId] = {
                                  ...inventario,
                                  'stock_inicial': stock,
                                };
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Precio local
                          Expanded(
                            child: TextFormField(
                              initialValue: inventario['precio_local']?.toString() ?? 
                                  _precioController.text,
                              decoration: const InputDecoration(
                                labelText: 'Precio Local S/',
                                isDense: true,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (value) {
                                final precio = double.tryParse(value) ?? 0.0;
                                _inventarioPorTienda[tiendaId] = {
                                  ...inventario,
                                  'precio_local': precio,
                                };
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],

          if (_selectedColores.isNotEmpty && _selectedTiendas.isNotEmpty) ...[
            const SizedBox(height: 24),
            
            // Resumen final
            Card(
              color: AppTheme.primaryTurquoise.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de Creación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTurquoise,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text('• ${_selectedColores.length} colores'),
                    Text('• ${_selectedTiendas.length} tiendas'),
                    Text('• ${_selectedColores.length * _selectedTiendas.length} registros de inventario'),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Se crearán ${_selectedColores.length} artículos con sus respectivos SKUs automáticos.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Anterior'),
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 16),

          // Next/Create button
          Expanded(
            child: _currentStep == _totalSteps - 1
                ? CorporateButton(
                    text: 'Crear Producto',
                    onPressed: _canCreateProduct() ? _createProduct : null,
                    isLoading: _isLoading,
                    icon: Icons.check,
                  )
                : ElevatedButton(
                    onPressed: _canProceedToNextStep() ? _nextStep : null,
                    child: const Text('Siguiente'),
                  ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Paso 1: Información Básica';
      case 1:
        return 'Paso 2: Colores y Variantes';
      case 2:
        return 'Paso 3: Inventario por Tienda';
      default:
        return '';
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        return _selectedColores.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  bool _canCreateProduct() {
    // Validar talla: o tiene una seleccionada, o está creando una nueva con campo completo
    final tallaValida = _selectedTallaId != null || 
      (_showNewTallaField && _newTallaController.text.trim().isNotEmpty);
    
    return _nombreController.text.isNotEmpty &&
           (_selectedMarcaId != null || _newMarcaController.text.isNotEmpty) &&
           (_selectedCategoriaId != null || _newCategoriaController.text.isNotEmpty) &&
           (_selectedMaterialId != null || _newMaterialController.text.isNotEmpty) &&
           tallaValida &&
           _precioController.text.isNotEmpty &&
           _selectedColores.isNotEmpty;
  }

  void _nextStep() {
    if (_canProceedToNextStep()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _createProduct() async {
    if (!_canCreateProduct()) return;

    setState(() => _isLoading = true);

    try {
      // Preparar datos del producto
      final productData = {
        'nombre': _nombreController.text.trim(),
        'precio_sugerido': double.parse(_precioController.text),
        'marca_id': _selectedMarcaId,
        'categoria_id': _selectedCategoriaId,
        'talla_id': _selectedTallaId,
      };

      // Si hay nuevas marcas/categorías, crear primero
      if (_newMarcaController.text.isNotEmpty) {
        // Crear nueva marca (implementar en ProductsRepository)
        // productData['marca_id'] = nuevaMarcaId;
      }
      
      if (_newCategoriaController.text.isNotEmpty) {
        // Crear nueva categoría (implementar en ProductsRepository)  
        // productData['categoria_id'] = nuevaCategoriaId;
      }

      // Crear el producto con BLoC
      context.read<ProductsBloc>().add(
        CreateProduct(
          productData: productData,
          colores: _selectedColores,
          inventarioInicial: _inventarioPorTienda.entries
              .map((entry) => {
                    'tienda_id': entry.key,
                    ...entry.value,
                  })
              .toList(),
        ),
      );

      // Navegar de vuelta a la lista
      if (mounted) {
        context.pop();
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear producto: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getColorFromName(String colorName) {
    final colors = {
      'rojo': Colors.red,
      'azul': Colors.blue,
      'verde': Colors.green,
      'amarillo': Colors.yellow,
      'negro': Colors.black,
      'blanco': Colors.white,
      'gris': Colors.grey,
      'rosado': Colors.pink,
      'morado': Colors.purple,
      'naranja': Colors.orange,
      'café': Colors.brown,
      'beige': const Color(0xFFF5F5DC),
    };

    return colors[colorName.toLowerCase()] ?? Colors.grey[400]!;
  }

  String _generatePreviewSKU(String color) {
    final marca = _marcas
        .where((m) => m.id == _selectedMarcaId)
        .firstOrNull?.nombre ?? 'MRC';
    final categoria = _categorias
        .where((c) => c.id == _selectedCategoriaId)
        .firstOrNull?.nombre ?? 'CAT';
    
    // Generar SKU simple: MARCA-CATEGORIA-COLOR-001
    final marcaCode = marca.substring(0, marca.length > 3 ? 3 : marca.length).toUpperCase();
    final categoriaCode = categoria.substring(0, categoria.length > 3 ? 3 : categoria.length).toUpperCase();
    final colorCode = color.substring(0, color.length > 3 ? 3 : color.length).toUpperCase();
    
    return '$marcaCode-$categoriaCode-$colorCode-001';
  }

  /// Crea una nueva talla usando ProductsRepository
  void _createNewTalla() async {
    // Validar campo requerido
    if (_newTallaController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El campo talla es requerido'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final tallaValue = _newTallaController.text.trim().toLowerCase();

    // 1. VALIDACIÓN PREVIA: Verificar si ya existe una talla con ese código
    final tallaExistente = _tallas.where((talla) => 
      talla.valor.toLowerCase() == tallaValue).firstOrNull;
    
    if (tallaExistente != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La talla "${tallaValue.toUpperCase()}" ya existe'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Preparar datos para crear la talla
      // Usar el mismo valor del campo único para todos los campos de BD
      final tallaData = {
        'valor': tallaValue,
        'codigo': tallaValue, // mismo valor
        'nombre': tallaValue, // mismo valor
        'tipo': 'UNICA', // Valor por defecto
        'orden_display': _tallas.length + 1,
        'activa': true,
      };

      // Crear la talla usando el repositorio
      final nuevaTalla = await _productsRepository.createTalla(tallaData);

      // Agregar la nueva talla a la lista local
      setState(() {
        _tallas.add(nuevaTalla);
        _selectedTallaId = nuevaTalla.id; // Seleccionar automáticamente
        _showNewTallaField = false; // Volver al dropdown
      });

      // Limpiar formulario
      _newTallaController.clear();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Talla "${tallaValue.toUpperCase()}" creada exitosamente'),
            backgroundColor: AppTheme.primaryTurquoise,
          ),
        );
      }
      
    } catch (e) {
      // 2. MANEJO MEJORADO DE ERRORES: Detectar error específico de constraint de unicidad
      String mensajeError = 'Error al crear talla: ${e.toString()}';
      
      if (e.toString().contains('duplicate key') && e.toString().contains('tallas_codigo_key')) {
        mensajeError = 'La talla ya existe. Intenta con otro nombre.';
      } else if (e.toString().contains('23505')) {
        // Código PostgreSQL para violación de constraint de unicidad
        mensajeError = 'La talla ya existe. Intenta con otro nombre.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 4), // Más tiempo para leer el mensaje específico
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}