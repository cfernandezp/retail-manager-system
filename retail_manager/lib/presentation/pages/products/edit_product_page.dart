import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart' as models;
import '../../bloc/products/products_bloc.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_message.dart';

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
  bool _isActive = true;

  // Datos para poblar dropdowns
  List<models.Marca> _marcas = [];
  List<models.Categoria> _categorias = [];
  List<models.Material> _materiales = [];

  // Producto actual para pre-poblar
  models.ProductoMaster? _currentProduct;
  bool _isLoading = true;

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
    // Cargar datos del producto actual
    _productsBloc.add(LoadProductDetails(widget.productId));
    // Cargar datos para dropdowns
    _productsBloc.add(const LoadInitialProductData());
  }

  void _populateForm(models.ProductoMaster product) {
    setState(() {
      _currentProduct = product;
      _codigoController.text = product.id;
      _nombreController.text = product.nombre;
      _precioBaseController.text = product.precioSugerido.toString();
      _precioCostoController.text = "";
      _selectedMarcaId = product.marcaId;
      _selectedCategoriaId = product.categoriaId;
      _selectedMaterialId = product.materialId;
      _isActive = product.activo;
      _isLoading = false;
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updateData = {
      'nombre': _nombreController.text.trim(),
      'marca_id': _selectedMarcaId,
      'categoria_id': _selectedCategoriaId,
      'material_id': _selectedMaterialId,
      'precio_sugerido': double.parse(_precioBaseController.text),
      'activo': _isActive,
    };

    _productsBloc.add(UpdateProductoMaster(widget.productId, updateData));
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;

    return BlocConsumer<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state is ProductDetailsLoaded) {
          _populateForm(state.product);
        } else if (state is InitialProductDataLoaded) {
          setState(() {
            _marcas = state.marcas;
            _categorias = state.categorias;
            _materiales = state.materiales;
          });
        } else if (state is ProductUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto actualizado exitosamente'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is ProductsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (_isLoading) {
          return _buildLoadingView(isDesktop);
        }

        return isDesktop
            ? _buildDesktopModal()
            : _buildMobilePage();
      },
    );
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
            child: SizedBox(
              width: 600,
              height: 400,
              child: content,
            ),
          )
        : Scaffold(
            appBar: AppBar(title: const Text('Editar Producto')),
            body: content,
          );
  }

  Widget _buildDesktopModal() {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar Producto',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _handleCancel,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: SingleChildScrollView(
                child: _buildForm(),
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
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
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        leading: IconButton(
          icon: const Icon(Icons.close),
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
          // Código (readonly)
          TextFormField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: 'Código del Producto',
              hintText: 'Código único del producto',
              prefixIcon: Icon(Icons.qr_code),
            ),
            readOnly: true,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 16),

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
        ],
      ),
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