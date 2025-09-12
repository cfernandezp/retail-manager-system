import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart' as models;
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
  
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _newMarcaController = TextEditingController();
  final _newCategoriaController = TextEditingController();
  final _newMaterialController = TextEditingController();
  
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
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
    super.dispose();
  }

  void _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      // En una implementación real, cargarías desde el ProductsBloc
      // Por ahora usamos datos mock
      _marcas = [
        models.Marca(id: '1', nombre: 'Arley', createdAt: DateTime.now()),
        models.Marca(id: '2', nombre: 'Bambú', createdAt: DateTime.now()),
        models.Marca(id: '3', nombre: 'Cotton Club', createdAt: DateTime.now()),
      ];
      
      _categorias = [
        models.Categoria(id: '1', nombre: 'Medias Deportivas', createdAt: DateTime.now()),
        models.Categoria(id: '2', nombre: 'Medias Casuales', createdAt: DateTime.now()),
        models.Categoria(id: '3', nombre: 'Medias Formales', createdAt: DateTime.now()),
      ];
      
      _tallas = [
        models.Talla(id: '1', valor: '9-12', tipo: models.TipoTalla.rango, createdAt: DateTime.now()),
        models.Talla(id: '2', valor: '6-8', tipo: models.TipoTalla.rango, createdAt: DateTime.now()),
        models.Talla(id: '3', valor: 'Única', tipo: models.TipoTalla.unica, createdAt: DateTime.now()),
      ];
      
      _materiales = [
        models.Material(id: '1', nombre: 'Algodón', createdAt: DateTime.now()),
        models.Material(id: '2', nombre: 'Nylon', createdAt: DateTime.now()),
        models.Material(id: '3', nombre: 'Poliéster', createdAt: DateTime.now()),
      ];
      
      _tiendas = [
        models.Tienda(id: '1', nombre: 'Tienda Principal', direccion: 'Centro Lima', adminTiendaId: '1', createdAt: DateTime.now()),
        models.Tienda(id: '2', nombre: 'Sucursal Norte', direccion: 'Comas', adminTiendaId: '2', createdAt: DateTime.now()),
        models.Tienda(id: '3', nombre: 'Sucursal Este', direccion: 'Ate', adminTiendaId: '3', createdAt: DateTime.now()),
      ];
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
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
      ),
    );
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
        DropdownButtonFormField<String>(
          value: _selectedTallaId,
          decoration: const InputDecoration(
            hintText: 'Seleccionar talla',
            prefixIcon: Icon(Icons.straighten),
          ),
          items: _tallas.map(
            (talla) => DropdownMenuItem(
              value: talla.id,
              child: Text(talla.displayName),
            ),
          ).toList(),
          onChanged: (value) {
            setState(() => _selectedTallaId = value);
          },
          validator: (value) {
            if (value == null) {
              return 'Seleccione una talla';
            }
            return null;
          },
        ),
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
    return _nombreController.text.isNotEmpty &&
           (_selectedMarcaId != null || _newMarcaController.text.isNotEmpty) &&
           (_selectedCategoriaId != null || _newCategoriaController.text.isNotEmpty) &&
           (_selectedMaterialId != null || _newMaterialController.text.isNotEmpty) &&
           _selectedTallaId != null &&
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
}