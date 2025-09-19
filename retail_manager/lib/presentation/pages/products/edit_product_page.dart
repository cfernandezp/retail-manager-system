import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart' as models;
import '../../../data/repositories/products_repository_simple.dart';
import '../../bloc/products/products_bloc.dart';
import '../../widgets/common/loading_indicator.dart';

/// Página/Modal para Editar Producto adaptativo según breakpoint
class EditProductPage extends StatefulWidget {
  final String productId;

  const EditProductPage({
    super.key,
    required this.productId,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late ProductsBloc _productsBloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers para formulario
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioBaseController = TextEditingController();
  final TextEditingController _precioCostoController = TextEditingController();

  // Valores de dropdowns
  String? _selectedMarcaId;
  String? _selectedCategoriaId;
  String? _selectedMaterialId;
  String? _selectedTallaId;  // AGREGADO: Selector talla
  bool _isActive = true;

  // Datos para poblar dropdowns
  List<models.Marca> _marcas = [];
  List<models.Categoria> _categorias = [];
  List<models.MaterialModel> _materiales = [];
  List<models.Talla> _tallas = [];  // AGREGADO: Lista tallas

  // Producto actual para pre-poblar
  models.ProductoMaster? _currentProduct;
  bool _isLoading = true;

  // Gestión de artículos
  List<models.Articulo> _articulos = [];
  bool _showArticulosSection = false;

  final currencyFormatter = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _productsBloc = BlocProvider.of<ProductsBloc>(context);
    _loadInitialData();
  }

  void _loadInitialData() {
    print('🔄 [EditProduct] Cargando datos directamente para producto: ${widget.productId}');
    _loadDataDirectly();
  }

  Future<void> _loadDataDirectly() async {
    try {
      final repository = ProductsRepository();
      final data = await repository.loadEditProductData(widget.productId);

      if (mounted) {
        setState(() {
          _currentProduct = data['product'] as models.ProductoMaster;
          _marcas = data['marcas'] as List<models.Marca>;
          _categorias = data['categorias'] as List<models.Categoria>;
          _tallas = data['tallas'] as List<models.Talla>;
          _materiales = data['materiales'] as List<models.MaterialModel>;
          _isLoading = false;
        });

        _populateForm(_currentProduct!);
      }
    } catch (e) {
      print('❌ [EditProduct] Error cargando datos: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar producto: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _populateForm(models.ProductoMaster product) {
    print('🔄 [EditProduct] Poblando formulario con producto: ${product.nombre}');
    print('   ID: ${product.id}');
    print('   MarcaId: ${product.marcaId}');
    print('   CategoriaId: ${product.categoriaId}');
    print('   MaterialId: ${product.materialId}');
    print('   Activo: ${product.activo}');

    setState(() {
      _currentProduct = product;
      _codigoController.text = 'AUTO-${product.id.substring(0,8)}';  // CORREGIDO: SKU legible
      _nombreController.text = product.nombre;
      _precioBaseController.text = product.precioSugerido.toString();
      _precioCostoController.text = "";
      _selectedMarcaId = product.marcaId;
      _selectedCategoriaId = product.categoriaId;
      _selectedMaterialId = product.materialId;
      _selectedTallaId = product.tallaId;  // AGREGADO: Talla
      _isActive = product.activo;
      _isLoading = false;
    });

    print('✅ [EditProduct] Formulario poblado, _isLoading: $_isLoading');
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validar duplicados usando método del repository
      final repository = ProductsRepository();
      final isDuplicate = await repository.checkProductNameExists(
        nombre: _nombreController.text.trim(),
        marcaId: _selectedMarcaId!,
        tallaId: _selectedTallaId!,
        materialId: _selectedMaterialId,
        excludeId: widget.productId,
      );

      if (isDuplicate) {
        // Mensaje error con guidelines UX
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Ya existe un producto con ese nombre, marca y talla'),
              ]),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final updateData = {
        'nombre': _nombreController.text.trim(),
        'marca_id': _selectedMarcaId,
        'categoria_id': _selectedCategoriaId,
        'talla_id': _selectedTallaId,  // AGREGADO: Talla
        'material_id': _selectedMaterialId,
        'precio_sugerido': double.parse(_precioBaseController.text),
        'estado': _isActive ? 'ACTIVO' : 'INACTIVO',
      };

      // Actualizar directamente usando repository sin interferir con BLoC principal
      await repository.updateProductoMaster(widget.productId, updateData);

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Detener loading antes de cerrar
        setState(() => _isLoading = false);

        // Cerrar modal retornando el producto actualizado
        Navigator.of(context).pop(_currentProduct);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al validar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _handleCancel() {
    // No llamar RefreshProducts aquí - mantener datos existentes
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    if (_isLoading) {
      return _buildLoadingView(isDesktop);
    }

    return isDesktop
        ? _buildDesktopModalWithAnimation()
        : _buildMobilePageWithAnimation();
  }

  Widget _buildLoadingView(bool isDesktop) {
    final content = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(),
          SizedBox(height: 16),
          Text('Cargando datos del producto...'),
        ],
      ),
    );

    return isDesktop
        ? Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 600,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: content,
            ),
          )
        : Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            appBar: AppBar(
              title: const Text('Editar Producto'),
              backgroundColor: AppTheme.backgroundLight,
              elevation: 0,
            ),
            body: content,
          );
  }


  Widget _buildMobilePage() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          _currentProduct != null
            ? 'Editar: ${_currentProduct!.nombre}'
            : 'Editar Producto',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: _handleCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildForm(),
      ),
      floatingActionButton: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          final isUpdating = state is ProductsLoading;

          return FloatingActionButton.extended(
            onPressed: isUpdating ? null : _handleSave,
            backgroundColor: AppTheme.primaryTurquoise,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar'),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Espaciado inicial para mejor visibilidad
          const SizedBox(height: 8),

          // Nombre
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Producto *',
              hintText: 'Ingrese el nombre del producto',
              prefixIcon: Icon(Icons.inventory),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              if (value.trim().length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              if (value.trim().length > 200) {
                return 'El nombre no puede exceder 200 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Marca
          DropdownButtonFormField<String>(
            initialValue: _selectedMarcaId,
            decoration: const InputDecoration(
              labelText: 'Marca *',
              hintText: 'Seleccione una marca',
              prefixIcon: Icon(Icons.branding_watermark),
            ),
            items: _marcas.map((marca) {
              return DropdownMenuItem<String>(
                value: marca.id,
                child: Text(marca.nombre),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMarcaId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Debe seleccionar una marca';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Categoría
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoriaId,
            decoration: const InputDecoration(
              labelText: 'Categoría *',
              hintText: 'Seleccione una categoría',
              prefixIcon: Icon(Icons.category),
            ),
            items: _categorias.map((categoria) {
              return DropdownMenuItem<String>(
                value: categoria.id,
                child: Text(categoria.nombre),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoriaId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Debe seleccionar una categoría';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Material
          DropdownButtonFormField<String>(
            initialValue: _selectedMaterialId,
            decoration: const InputDecoration(
              labelText: 'Material *',
              hintText: 'Seleccione un material',
              prefixIcon: Icon(Icons.texture),
            ),
            items: _materiales.map((material) {
              return DropdownMenuItem<String>(
                value: material.id,
                child: Text(material.nombre),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMaterialId = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Debe seleccionar un material';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Talla selector - AGREGADO
          DropdownButtonFormField<String>(
            initialValue: _selectedTallaId,
            decoration: const InputDecoration(
              labelText: 'Talla *',
              hintText: 'Seleccione una talla',
              prefixIcon: Icon(Icons.straighten),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppTheme.primaryTurquoise, width: 2),
              ),
            ),
            items: _tallas.where((talla) => talla.activo).map((talla) =>
              DropdownMenuItem(
                value: talla.id,
                child: Text(talla.valor),
              )
            ).toList(),
            onChanged: (value) => setState(() => _selectedTallaId = value),
            validator: (value) => value == null ? 'Talla es requerida' : null,
          ),
          const SizedBox(height: 16),

          // Precio Base
          TextFormField(
            controller: _precioBaseController,
            decoration: const InputDecoration(
              labelText: 'Precio Base *',
              hintText: '0.00',
              prefixIcon: Icon(Icons.attach_money),
              suffixText: 'S/',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El precio base es requerido';
              }
              final precio = double.tryParse(value);
              if (precio == null) {
                return 'Ingrese un precio válido';
              }
              if (precio <= 0) {
                return 'El precio debe ser mayor a 0';
              }
              if (precio > 99999.99) {
                return 'El precio no puede exceder S/ 99,999.99';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Precio Costo (opcional)
          TextFormField(
            controller: _precioCostoController,
            decoration: const InputDecoration(
              labelText: 'Precio Costo',
              hintText: '0.00 (opcional)',
              prefixIcon: Icon(Icons.price_change),
              suffixText: 'S/',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final precio = double.tryParse(value);
                if (precio == null) {
                  return 'Ingrese un precio válido';
                }
                if (precio <= 0) {
                  return 'El precio debe ser mayor a 0';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Código del Producto (readonly) - Reposicionado para mejor UX
          TextFormField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: 'Código del Producto',
              hintText: 'Código único generado automáticamente',
              prefixIcon: Icon(Icons.qr_code),
              suffixIcon: Icon(Icons.lock_outline, size: 16),
              helperText: 'Campo de solo lectura',
            ),
            readOnly: true,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Estado activo
          SwitchListTile(
            title: const Text('Producto Activo'),
            subtitle: Text(_isActive ? 'Disponible para ventas' : 'No disponible'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            secondary: Icon(
              _isActive ? Icons.check_circle : Icons.remove_circle,
              color: _isActive ? AppTheme.successColor : Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // Sección de artículos expandible
          _buildArticulosSection(),
        ],
      ),
    );
  }

  Widget _buildArticulosSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Artículos / Variantes'),
            subtitle: Text('${_articulos.length} artículos encontrados'),
            trailing: IconButton(
              icon: Icon(_showArticulosSection ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _showArticulosSection = !_showArticulosSection;
                });
                if (_showArticulosSection && _articulos.isEmpty) {
                  // Cargar artículos si no están cargados
                  _productsBloc.add(LoadProductDetails(widget.productId));
                }
              },
            ),
          ),
          if (_showArticulosSection) ...[
            const Divider(height: 1),
            if (_articulos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay artículos creados para este producto',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._articulos.map((articulo) => _buildArticuloTile(articulo)),
          ],
        ],
      ),
    );
  }

  Widget _buildArticuloTile(models.Articulo articulo) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryTurquoise.withOpacity(0.1),
        child: Text(
          articulo.color?.nombre.substring(0, 2).toUpperCase() ?? 'AR',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTurquoise,
          ),
        ),
      ),
      title: Text(articulo.skuAuto.isNotEmpty ? articulo.skuAuto : 'SKU no disponible'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color: ${articulo.color?.nombre ?? "N/A"}'),
          Text('Precio: S/ ${articulo.precioSugerido.toStringAsFixed(2)}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () {
              // TODO: Implementar edición de artículo específico
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función en desarrollo: Editar artículo'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory, size: 18),
            onPressed: () {
              // TODO: Implementar gestión de inventario específico
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función en desarrollo: Gestionar inventario'),
                ),
              );
            },
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  /// Modal desktop simplificado como el color modal
  Widget _buildDesktopModalWithAnimation() {
    return Dialog(
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header turquesa
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryTurquoise.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primaryTurquoise,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Editar Producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTurquoise,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _handleCancel,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildForm(),
              ),
            ),

            // Footer gris con botones
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleCancel,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<ProductsBloc, ProductsState>(
                    builder: (context, state) {
                      final isUpdating = state is ProductsLoading;

                      return ElevatedButton(
                        onPressed: isUpdating ? null : _handleSave,
                        child: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Actualizar'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Página mobile con animación suave
  Widget _buildMobilePageWithAnimation() {
    return TweenAnimationBuilder<Offset>(
      duration: const Duration(milliseconds: 350),
      tween: Tween(begin: const Offset(0, 0.1), end: Offset.zero),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return FractionalTranslation(
          translation: value,
          child: _buildMobilePage(),
        );
      },
    );
  }




  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _precioBaseController.dispose();
    _precioCostoController.dispose();
    super.dispose();
  }
}