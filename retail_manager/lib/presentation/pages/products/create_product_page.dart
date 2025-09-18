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
import '../../widgets/products/color_selector_enhanced.dart';
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
  List<models.MaterialModel> _materiales = [];
  List<models.ColorData> _colores = [];
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
      // CARGA DE COLORES
      // ========================================================================
      print('=== [DROPDOWN_DEBUG] ${DateTime.now()} ===');
      print('🔄 INICIANDO carga de COLORES...');
      print('📍 Método: _productsRepository.getColores()');

      try {
        final colores = await _productsRepository.getColores();
        print('✅ COLORES: ${colores.length} registros cargados exitosamente');

        if (colores.isNotEmpty) {
          print('📋 Primeros 5 colores:');
          for (int i = 0; i < colores.length && i < 5; i++) {
            final color = colores[i];
            print('   ${i+1}. ID: ${color.id} | Nombre: "${color.nombre}" | Hex: "${color.hexColor}"');
          }

          if (colores.length > 5) {
            print('   ... y ${colores.length - 5} colores más');
          }

          // Validar estructura de datos
          final primerColor = colores.first;
          print('🔍 Estructura primer color:');
          try {
            print('   JSON: ${primerColor.toJson()}');
          } catch (e) {
            print('   ⚠️ Error al serializar color: $e');
          }
        } else {
          print('⚠️ ALERTA: Lista de colores está COMPLETAMENTE VACÍA');
          print('🚨 POSIBLES CAUSAS:');
          print('   1. Tabla "colores" vacía en BD');
          print('   2. Error en query SQL');
          print('   3. Problema de permisos RLS');
          print('   4. Conexión a BD fallida');
        }

        _colores = colores;
        print('💾 Variable _colores asignada: ${_colores.length} registros');

      } catch (e, stackTrace) {
        print('❌ ERROR COLORES: $e');
        print('📜 STACK TRACE COLORES:');
        print('$stackTrace');
        print('🚨 Error específico al cargar colores - proceso continuará');
        _colores = []; // Lista vacía para evitar errores
      }

      print('=== FIN COLORES DEBUG ===\n');

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
      print('   🎨 COLORES.......: ${_colores.length} registros ${_colores.isEmpty ? "❌ VACÍO" : "✅"}');
      print('   🏪 TIENDAS.......: ${_tiendas.length} registros ${_tiendas.isEmpty ? "❌ VACÍO" : "✅"}');
      print('');

      // Verificar estado crítico
      final totalRegistros = _marcas.length + _categorias.length + _tallas.length + _materiales.length + _colores.length + _tiendas.length;
      final dropdownsVacios = [_marcas, _categorias, _tallas, _materiales, _colores, _tiendas]
          .where((lista) => lista.isEmpty).length;

      print('📈 ESTADÍSTICAS GLOBALES:');
      print('   • Total registros cargados: $totalRegistros');
      print('   • Dropdowns con datos: ${6 - dropdownsVacios}/6');
      print('   • Dropdowns vacíos: $dropdownsVacios/6');
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
        if (_colores.isEmpty) print('   • COLORES: Lista vacía');
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
    return BlocListener<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state is ProductCreated) {
          // Mostrar mensaje de éxito detallado
          final articulosCreados = _selectedColores.length;
          final tiendasConfiguradas = _selectedTiendas.length;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ ${state.product.nombre} creado exitosamente',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('• $articulosCreados artículos generados (uno por color)'),
                  if (tiendasConfiguradas > 0)
                    Text('• Configurado en $tiendasConfiguradas tiendas'),
                  Text('• ID Producto: ${state.product.id}'),
                ],
              ),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Ver Lista',
                textColor: Colors.white,
                onPressed: () {
                  // Opcional: navegar directamente a la lista
                },
              ),
            ),
          );

          // Navegar de vuelta a la lista de productos
          if (mounted) {
            context.pop();
          }
        } else if (state is ProductsError) {
          // Mostrar mensaje de error detallado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '❌ Error al crear producto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(state.message),
                ],
              ),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 6),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () {
                  // El usuario puede volver a intentar crear el producto
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _hasMinimalData()
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
      ),
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
  
  /// Verifica si hay datos mínimos para mostrar la UI normal
  /// CAMBIO: Permitir UI normal incluso con listas vacías, ya que se puede crear inline
  bool _hasMinimalData() {
    // Solo verificar que no haya errores críticos de conexión
    // Las listas vacías se manejan gracefully con opciones de creación inline
    return true; // Siempre mostrar UI normal, manejar listas vacías gracefully
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
          // Mostrar marcas existentes como referencia
          if (_marcas.isNotEmpty) ...[
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
                    'Marcas existentes:',
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
                    children: _marcas.take(8).map((marca) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTurquoise.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        marca.nombre,
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
            controller: _newMarcaController,
            label: 'Nueva Marca',
            hintText: _marcas.isEmpty
              ? 'Ej: Nike, Adidas, Puma, Reebok'
              : 'Ingresa una marca que no esté en la lista superior',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'El nombre de la marca es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _createNewMarca,
                child: const Text('Crear Marca'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showNewMarcaField = false;
                    _newMarcaController.clear();
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
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
          // Mostrar categorías existentes como referencia
          if (_categorias.isNotEmpty) ...[
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
                    'Categorías existentes:',
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
                    children: _categorias.take(8).map((categoria) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTurquoise.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoria.nombre,
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
            controller: _newCategoriaController,
            label: 'Nueva Categoría',
            hintText: _categorias.isEmpty
              ? 'Ej: Medias, Deportivas, Casuales, Formales'
              : 'Ingresa una categoría que no esté en la lista superior',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'El nombre de la categoría es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _createNewCategoria,
                child: const Text('Crear Categoría'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showNewCategoriaField = false;
                    _newCategoriaController.clear();
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
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
          // Mostrar materiales existentes como referencia
          if (_materiales.isNotEmpty) ...[
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
                    'Materiales existentes:',
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
                    children: _materiales.take(8).map((material) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTurquoise.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        material.nombre,
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
            controller: _newMaterialController,
            label: 'Nuevo Material',
            hintText: _materiales.isEmpty
              ? 'Ej: Algodón, Poliéster, Lycra, Nylon'
              : 'Ingresa un material que no esté en la lista superior',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'El nombre del material es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _createNewMaterial,
                child: const Text('Crear Material'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showNewMaterialField = false;
                    _newMaterialController.clear();
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
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

          // Color selector - Colores de BD + opción crear nuevos
          ColorSelectorEnhanced(
            availableColors: _colores,
            selectedColors: _selectedColores,
            onColorsChanged: (colorNames) {
              setState(() {
                _selectedColores = colorNames;
                // Inicializar precios por color
                for (final color in colorNames) {
                  if (!_preciosPorColor.containsKey(color)) {
                    final precioBase = double.tryParse(_precioController.text) ?? 0.0;
                    _preciosPorColor[color] = precioBase;
                  }
                }
                // Remover precios de colores no seleccionados
                _preciosPorColor.removeWhere(
                  (color, _) => !colorNames.contains(color),
                );
              });
            },
            onColorCreated: (newColor) {
              // Recargar colores cuando se crea uno nuevo
              setState(() {
                _colores.add(newColor);
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

    // Validar material: o tiene uno seleccionado, o está creando uno nuevo con campo completo
    final materialValido = _selectedMaterialId != null ||
      (_showNewMaterialField && _newMaterialController.text.trim().isNotEmpty);

    return _nombreController.text.isNotEmpty &&
           (_selectedMarcaId != null || _newMarcaController.text.isNotEmpty) &&
           (_selectedCategoriaId != null || _newCategoriaController.text.isNotEmpty) &&
           materialValido &&
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
      print('');
      print('🚀 [CREAR_PRODUCTO] ==================== INICIO ====================');
      print('📋 Resumen de datos a crear:');
      print('   • Nombre: ${_nombreController.text.trim()}');
      print('   • Colores seleccionados: $_selectedColores (${_selectedColores.length} colores)');
      print('   • Tiendas seleccionadas: $_selectedTiendas (${_selectedTiendas.length} tiendas)');
      print('   • Precio base: ${_precioController.text}');
      print('');

      // 1. CREAR ELEMENTOS NUEVOS PRIMERO SI ES NECESARIO
      String marcaIdFinal = _selectedMarcaId ?? '';
      String categoriaIdFinal = _selectedCategoriaId ?? '';
      String tallaIdFinal = _selectedTallaId ?? '';
      String? materialIdFinal = _selectedMaterialId;

      print('🔧 [FASE_1] Preparando elementos de catálogo...');

      // Crear nueva marca si es necesaria
      if (_showNewMarcaField && _newMarcaController.text.isNotEmpty) {
        final nuevaMarca = await _productsRepository.createMarca({
          'nombre': _newMarcaController.text.trim(),
          'descripcion': 'Marca creada desde formulario de producto',
          'prefijo_sku': _newMarcaController.text.substring(0, _newMarcaController.text.length > 3 ? 3 : _newMarcaController.text.length).toUpperCase(),
          'activo': true,
        });
        marcaIdFinal = nuevaMarca.id;
      }

      // Crear nueva categoría si es necesaria
      if (_showNewCategoriaField && _newCategoriaController.text.isNotEmpty) {
        final nuevaCategoria = await _productsRepository.createCategoria({
          'nombre': _newCategoriaController.text.trim(),
          'descripcion': 'Categoría creada desde formulario de producto',
          'prefijo_sku': _newCategoriaController.text.substring(0, _newCategoriaController.text.length > 3 ? 3 : _newCategoriaController.text.length).toUpperCase(),
          'activo': true,
        });
        categoriaIdFinal = nuevaCategoria.id;
      }

      // Crear nueva talla si es necesaria
      if (_showNewTallaField && _newTallaController.text.isNotEmpty) {
        final nuevaTalla = await _productsRepository.createTalla({
          'valor': _newTallaController.text.trim(),
          'codigo': _newTallaController.text.trim(),
          'nombre': _newTallaController.text.trim(),
          'tipo': 'INDIVIDUAL',
          'orden_display': _tallas.length + 1,
          'activo': true,
        });
        tallaIdFinal = nuevaTalla.id;
      }

      // Crear nuevo material si es necesario
      if (_showNewMaterialField && _newMaterialController.text.isNotEmpty) {
        final nuevoMaterial = await _productsRepository.createMaterial({
          'nombre': _newMaterialController.text.trim(),
          'descripcion': 'Material creado desde formulario de producto',
          'codigo_abrev': _newMaterialController.text.substring(0, _newMaterialController.text.length > 3 ? 3 : _newMaterialController.text.length).toUpperCase(),
          'activo': true,
        });
        materialIdFinal = nuevoMaterial.id;
      }

      // 2. PREPARAR DATOS DEL PRODUCTO CON TODOS LOS IDs FINALES
      final productData = {
        'nombre': _nombreController.text.trim(),
        'precio_sugerido': double.parse(_precioController.text),
        'marca_id': marcaIdFinal,
        'categoria_id': categoriaIdFinal,
        'talla_id': tallaIdFinal,
        'material_id': materialIdFinal, // AGREGADO: material_id
      };

      // Remover material_id si es null para evitar errores de BD
      if (materialIdFinal == null) {
        productData.remove('material_id');
      }

      // 3. CONVERTIR NOMBRES DE COLORES A IDs
      print('🎨 [FASE_4] Convirtiendo nombres de colores a IDs...');
      final coloresIds = <String>[];
      for (final nombreColor in _selectedColores) {
        // Buscar el color por nombre (case-insensitive)
        final colorEncontrado = _colores.where((color) =>
          color.nombre.toLowerCase() == nombreColor.toLowerCase()).firstOrNull;

        if (colorEncontrado != null) {
          coloresIds.add(colorEncontrado.id);
          print('   ✅ "$nombreColor" → ID: ${colorEncontrado.id}');
        } else {
          // Este caso no debería ocurrir ya que ColorSelectorEnhanced
          // solo permite seleccionar colores existentes o crea nuevos automáticamente
          print('   ⚠️ Color "$nombreColor" no encontrado en la lista actual');
          throw Exception('Color "$nombreColor" no encontrado. Esto es un error del sistema.');
        }
      }

      print('🎨 [FASE_4] Conversión colores completada:');
      print('   Nombres originales: $_selectedColores');
      print('   IDs convertidos: $coloresIds');
      print('');

      print('🏗️ [FASE_5] Creando producto en BD...');
      print('📦 Datos del producto:');
      productData.forEach((key, value) => print('   $key: $value'));
      print('');
      print('🎨 Colores a asociar: $coloresIds');
      print('🏪 Inventario inicial para ${_inventarioPorTienda.length} tiendas');
      print('');

      // Crear el producto con BLoC
      context.read<ProductsBloc>().add(
        CreateProduct(
          productData: productData,
          colores: coloresIds, // CORREGIDO: usar IDs en lugar de nombres
          inventarioInicial: _inventarioPorTienda.entries
              .map((entry) => {
                    'tienda_id': entry.key,
                    ...entry.value,
                  })
              .toList(),
        ),
      );

      print('✅ [CREAR_PRODUCTO] Evento CreateProduct enviado al BLoC');
      print('⏳ Esperando resultado...');
      print('==================== FIN LOGGING LOCAL ====================');
      print('');

      // La navegación se maneja en el BlocListener después del éxito
      
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

  String _getHexFromColorName(String colorName) {
    final colorsHex = {
      'rojo': '#FF0000',
      'azul': '#0000FF',
      'verde': '#008000',
      'amarillo': '#FFFF00',
      'negro': '#000000',
      'blanco': '#FFFFFF',
      'gris': '#808080',
      'rosado': '#FFC0CB',
      'morado': '#800080',
      'naranja': '#FFA500',
      'café': '#A52A2A',
      'beige': '#F5F5DC',
      'azul marino': '#000080',
      'turquesa': '#40E0D0',
      'dorado': '#FFD700',
      'plateado': '#C0C0C0',
      'vino': '#722F37',
      'crema': '#FFFDD0',
    };

    return colorsHex[colorName.toLowerCase()] ?? '#808080'; // Default gris
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

  /// Crea una nueva categoría usando ProductsRepository
  void _createNewCategoria() async {
    // Validar campo requerido
    if (_newCategoriaController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El campo categoría es requerido'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final categoriaValue = _newCategoriaController.text.trim();

    // 1. VALIDACIÓN PREVIA: Verificar si ya existe una categoría con ese nombre
    final categoriaExistente = _categorias.where((categoria) =>
      categoria.nombre.toLowerCase() == categoriaValue.toLowerCase()).firstOrNull;

    if (categoriaExistente != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La categoría "$categoriaValue" ya existe'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Preparar datos para crear la categoría
      final categoriaData = {
        'nombre': categoriaValue,
        'descripcion': 'Categoría creada desde formulario de producto',
        'prefijo_sku': categoriaValue.substring(0, categoriaValue.length > 3 ? 3 : categoriaValue.length).toUpperCase(),
        'activo': true,
      };

      // Crear la categoría usando el repositorio
      final nuevaCategoria = await _productsRepository.createCategoria(categoriaData);

      // Agregar la nueva categoría a la lista local
      setState(() {
        _categorias.add(nuevaCategoria);
        _selectedCategoriaId = nuevaCategoria.id; // Seleccionar automáticamente
        _showNewCategoriaField = false; // Volver al dropdown
      });

      // Limpiar formulario
      _newCategoriaController.clear();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoría "$categoriaValue" creada exitosamente'),
            backgroundColor: AppTheme.primaryTurquoise,
          ),
        );
      }

    } catch (e) {
      // 2. MANEJO MEJORADO DE ERRORES: Detectar error específico de constraint de unicidad
      String mensajeError = 'Error al crear categoría: ${e.toString()}';

      if (e.toString().contains('duplicate key') && e.toString().contains('categorias_nombre_key')) {
        mensajeError = 'La categoría ya existe. Intenta con otro nombre.';
      } else if (e.toString().contains('23505')) {
        // Código PostgreSQL para violación de constraint de unicidad
        mensajeError = 'La categoría ya existe. Intenta con otro nombre.';
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

  /// Crea una nueva marca usando ProductsRepository
  void _createNewMarca() async {
    // Validar campo requerido
    if (_newMarcaController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El campo marca es requerido'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final marcaValue = _newMarcaController.text.trim();

    // 1. VALIDACIÓN PREVIA: Verificar si ya existe una marca con ese nombre
    final marcaExistente = _marcas.where((marca) =>
      marca.nombre.toLowerCase() == marcaValue.toLowerCase()).firstOrNull;

    if (marcaExistente != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La marca "$marcaValue" ya existe'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Preparar datos para crear la marca
      final marcaData = {
        'nombre': marcaValue,
        'descripcion': 'Marca creada desde formulario de producto',
        'prefijo_sku': marcaValue.substring(0, marcaValue.length > 3 ? 3 : marcaValue.length).toUpperCase(),
        'activo': true,
      };

      // Crear la marca usando el repositorio
      final nuevaMarca = await _productsRepository.createMarca(marcaData);

      // Agregar la nueva marca a la lista local
      setState(() {
        _marcas.add(nuevaMarca);
        _selectedMarcaId = nuevaMarca.id; // Seleccionar automáticamente
        _showNewMarcaField = false; // Volver al dropdown
      });

      // Limpiar formulario
      _newMarcaController.clear();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marca "$marcaValue" creada exitosamente'),
            backgroundColor: AppTheme.primaryTurquoise,
          ),
        );
      }

    } catch (e) {
      // 2. MANEJO MEJORADO DE ERRORES: Detectar error específico de constraint de unicidad
      String mensajeError = 'Error al crear marca: ${e.toString()}';

      if (e.toString().contains('duplicate key') && e.toString().contains('marcas_nombre_key')) {
        mensajeError = 'La marca ya existe. Intenta con otro nombre.';
      } else if (e.toString().contains('23505')) {
        // Código PostgreSQL para violación de constraint de unicidad
        mensajeError = 'La marca ya existe. Intenta con otro nombre.';
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
        'tipo': 'INDIVIDUAL', // Corregido: usar valor válido según schema
        'orden_display': _tallas.length + 1,
        'activo': true, // Corregido: usar 'activo' no 'activa'
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

  /// Crea un nuevo material usando ProductsRepository
  void _createNewMaterial() async {
    // Validar campo requerido
    if (_newMaterialController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El campo material es requerido'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final materialValue = _newMaterialController.text.trim();

    // 1. VALIDACIÓN PREVIA: Verificar si ya existe un material con ese nombre
    final materialExistente = _materiales.where((material) =>
      material.nombre.toLowerCase() == materialValue.toLowerCase()).firstOrNull;

    if (materialExistente != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El material "$materialValue" ya existe'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Preparar datos para crear el material
      final materialData = {
        'nombre': materialValue,
        'descripcion': 'Material creado desde formulario de producto',
        'codigo_abrev': materialValue.substring(0, materialValue.length > 3 ? 3 : materialValue.length).toUpperCase(),
        'activo': true,
      };

      // Crear el material usando el repositorio
      final nuevoMaterial = await _productsRepository.createMaterial(materialData);

      // Agregar el nuevo material a la lista local
      setState(() {
        _materiales.add(nuevoMaterial);
        _selectedMaterialId = nuevoMaterial.id; // Seleccionar automáticamente
        _showNewMaterialField = false; // Volver al dropdown
      });

      // Limpiar formulario
      _newMaterialController.clear();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Material "$materialValue" creado exitosamente'),
            backgroundColor: AppTheme.primaryTurquoise,
          ),
        );
      }

    } catch (e) {
      // 2. MANEJO MEJORADO DE ERRORES: Detectar error específico de constraint de unicidad
      String mensajeError = 'Error al crear material: ${e.toString()}';

      if (e.toString().contains('duplicate key') && e.toString().contains('materiales_nombre_key')) {
        mensajeError = 'El material ya existe. Intenta con otro nombre.';
      } else if (e.toString().contains('23505')) {
        // Código PostgreSQL para violación de constraint de unicidad
        mensajeError = 'El material ya existe. Intenta con otro nombre.';
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