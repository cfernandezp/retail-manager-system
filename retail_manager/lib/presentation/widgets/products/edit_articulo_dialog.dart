import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';
import 'package:intl/intl.dart';

/// Diálogo de formulario para editar artículos (variantes de producto)
class EditArticuloDialog extends StatefulWidget {
  final Articulo articulo;
  final List<ColorData> availableColors;
  final List<ColorData>? coloresUnicos; // AGREGADO: Para resolución de colores múltiples

  const EditArticuloDialog({
    super.key,
    required this.articulo,
    required this.availableColors,
    this.coloresUnicos, // AGREGADO: Parámetro opcional
  });

  @override
  State<EditArticuloDialog> createState() => _EditArticuloDialogState();
}

class _EditArticuloDialogState extends State<EditArticuloDialog> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  final ProductsRepository _repository = ProductsRepository();
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  bool _isLoading = false;
  bool _activo = true;
  String? _selectedColorId;
  String _colorFilter = 'todos'; // 'todos', 'unicos', 'multiples'
  List<ColorData> _coloresUnicos = []; // AGREGADO: Lista de colores únicos

  @override
  void initState() {
    super.initState();

    // Cargar datos existentes del artículo
    _selectedColorId = widget.articulo.colorId;
    _precioController.text = widget.articulo.precioSugerido.toStringAsFixed(2);
    _activo = widget.articulo.activo;

    // AGREGADO: Inicializar colores únicos si se proporcionan
    _coloresUnicos = widget.coloresUnicos ?? [];

    // AGREGADO: Cargar colores únicos si no se proporcionaron
    if (_coloresUnicos.isEmpty) {
      _loadColoresUnicos();
    }
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _updateArticulo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final precioSugerido = double.parse(_precioController.text.trim());

      // Validaciones locales mejoradas
      if (precioSugerido < 0) {
        _showErrorMessage('El precio no puede ser negativo');
        return;
      }

      if (precioSugerido > 999999.99) {
        _showErrorMessage('El precio es demasiado alto (máximo S/ 999,999.99)');
        return;
      }

      if (_selectedColorId == null || _selectedColorId!.isEmpty) {
        _showErrorMessage('Debe seleccionar un color');
        return;
      }

      // Verificar que el color seleccionado esté en la lista de colores disponibles
      final selectedColorExists = widget.availableColors.any((c) => c.id == _selectedColorId);
      if (!selectedColorExists) {
        _showErrorMessage('El color seleccionado no es válido');
        return;
      }

      // Validar duplicados solo si el color cambió
      if (_selectedColorId != widget.articulo.colorId) {
        final isDuplicate = await _repository.checkArticuloColorDuplicate(
          productoId: widget.articulo.productoId,
          colorId: _selectedColorId!,
          excludeArticuloId: widget.articulo.id,
        );
        if (isDuplicate) {
          _showErrorMessage('Ya existe un artículo con este color para este producto');
          return;
        }
      }

      final articuloData = {
        'color_id': _selectedColorId,
        'precio_sugerido': precioSugerido,
        'activo': _activo,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final updatedArticulo = await _repository.updateArticulo(widget.articulo.id, articuloData);

      if (mounted) {
        Navigator.of(context).pop(updatedArticulo);
      }

    } catch (e) {
      String errorMessage = 'Error al actualizar artículo';

      // Manejo específico de errores comunes
      if (e.toString().contains('23505')) {
        errorMessage = 'Ya existe un artículo con este color. Verifique los datos.';
      } else if (e.toString().contains('constraint')) {
        errorMessage = 'Error de validación en la base de datos. Verifique los datos.';
      } else if (e.toString().contains('connection')) {
        errorMessage = 'Error de conexión. Verifique su conexión a internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado. Intente nuevamente.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'No tiene permisos para realizar esta acción.';
      } else {
        // Solo mostrar el error técnico en modo debug
        errorMessage = 'Error al actualizar artículo: ${e.toString().substring(0, 100)}';
      }

      print('❌ [EditArticuloDialog] Error: $e');
      _showErrorMessage(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  // AGREGADO: Método para cargar colores únicos
  Future<void> _loadColoresUnicos() async {
    try {
      final coloresUnicos = await _repository.getColoresUnicos();
      if (mounted) {
        setState(() {
          _coloresUnicos = coloresUnicos;
        });
      }
    } catch (e) {
      print('❌ Error cargando colores únicos: $e');
    }
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey[400]!;
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('0xFF$hex'));
    } catch (e) {
      return Colors.grey[400]!;
    }
  }

  List<ColorData> _getFilteredColors() {
    switch (_colorFilter) {
      case 'unicos':
        return widget.availableColors.where((color) => color.tipoColor == 'UNICO').toList();
      case 'multiples':
        return widget.availableColors.where((color) => color.tipoColor == 'VARIOS').toList();
      default:
        return widget.availableColors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 900,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editar Artículo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTurquoise,
                          ),
                        ),
                        Text(
                          'SKU: ${widget.articulo.skuAuto}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del producto padre
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Producto Base',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.articulo.producto?.nombre ?? 'Producto sin nombre',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Selector de color mejorado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Color *',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          // Filtros de color
                          Row(
                            children: [
                              Text(
                                'Filtrar:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'todos',
                                    label: Text('Todos'),
                                    icon: Icon(Icons.palette, size: 16),
                                  ),
                                  ButtonSegment(
                                    value: 'unicos',
                                    label: Text('Únicos'),
                                    icon: Icon(Icons.circle, size: 16),
                                  ),
                                  ButtonSegment(
                                    value: 'multiples',
                                    label: Text('Múltiples'),
                                    icon: Icon(Icons.color_lens, size: 16),
                                  ),
                                ],
                                selected: {_colorFilter},
                                onSelectionChanged: (Set<String> selected) {
                                  setState(() {
                                    _colorFilter = selected.first;
                                  });
                                },
                                style: SegmentedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Color actual seleccionado
                      if (_selectedColorId != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTurquoise.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryTurquoise.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getColorFromHex(_getSelectedColorHex()),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.grey[400]!, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Color Seleccionado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _getSelectedColorName(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.successColor,
                                size: 24,
                              ),
                            ],
                          ),
                        ),

                      // Grid de colores disponibles mejorado
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.palette_outlined,
                                  color: AppTheme.textSecondaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Colores Disponibles (${_getFilteredColors().length})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Grid horizontal extendido con nombres
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final filteredColors = _getFilteredColors();
                                final itemWidth = 140.0;
                                final crossAxisCount = (constraints.maxWidth / itemWidth).floor().clamp(1, 6);

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 2.5,
                                  ),
                                  itemCount: filteredColors.length,
                                  itemBuilder: (context, index) {
                                    final color = filteredColors[index];
                                    final isSelected = _selectedColorId == color.id;

                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedColorId = color.id),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.primaryTurquoise
                                                : Colors.grey[300]!,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: AppTheme.primaryTurquoise.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            else
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.grey[400]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(5),
                                                child: Stack(
                                                  children: [
                                                    // MODIFICADO: Usar visualización correcta para colores múltiples
                                                    color.esColorUnico
                                                        ? Container(
                                                            color: _getColorFromHex(color.hexColor),
                                                          )
                                                        : _buildMultiColorPreview(color),
                                                    // Icono de selección
                                                    if (isSelected)
                                                      Container(
                                                        color: Colors.black.withOpacity(0.3),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    color.nombre,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                      color: isSelected ? AppTheme.primaryTurquoise : AppTheme.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (color.tipoColor == 'VARIOS')
                                                    Text(
                                                      'Múltiple',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.orange[600],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                            if (_getFilteredColors().isEmpty)
                              Container(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'No hay colores en esta categoría',
                                      style: TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Campo precio sugerido
                      TextFormField(
                        controller: _precioController,
                        decoration: InputDecoration(
                          labelText: 'Precio Sugerido *',
                          hintText: '0.00',
                          prefixText: 'S/ ',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showPriceInfo(),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El precio es requerido';
                          }
                          final precio = double.tryParse(value.trim());
                          if (precio == null) {
                            return 'Ingrese un precio válido';
                          }
                          if (precio < 0) {
                            return 'El precio no puede ser negativo';
                          }
                          if (precio > 999999.99) {
                            return 'El precio es demasiado alto';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Switch estado activo
                      Row(
                        children: [
                          Switch(
                            value: _activo,
                            onChanged: (value) => setState(() => _activo = value),
                            activeColor: AppTheme.successColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _activo ? 'Artículo activo' : 'Artículo inactivo',
                            style: TextStyle(
                              fontSize: 16,
                              color: _activo
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Información adicional
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Los cambios se aplicarán inmediatamente y se reflejarán en el catálogo.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer con botones
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
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateArticulo,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Actualizar Artículo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedColorName() {
    if (_selectedColorId == null) return 'Ninguno';
    final color = widget.availableColors.firstWhere(
      (c) => c.id == _selectedColorId,
      orElse: () => ColorData(
        id: '',
        nombre: 'Color desconocido',
        hexColor: '#808080',
        tipoColor: 'UNICO',
        createdAt: DateTime.now(),
      ),
    );
    return color.nombre;
  }

  String? _getSelectedColorHex() {
    if (_selectedColorId == null) return null;
    final color = widget.availableColors.firstWhere(
      (c) => c.id == _selectedColorId,
      orElse: () => ColorData(
        id: '',
        nombre: 'Color desconocido',
        hexColor: '#808080',
        tipoColor: 'UNICO',
        createdAt: DateTime.now(),
      ),
    );
    return color.hexColor;
  }

  void _showPriceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Precio'),
        content: const Text(
          'Este es el precio sugerido para el artículo. '
          'Puede ser diferente del precio de venta final en cada tienda.\n\n'
          'El precio debe ser mayor a 0 y se almacena en soles peruanos (S/).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// AGREGADO: Construye el preview para colores múltiples mostrando barras de colores componentes
  Widget _buildMultiColorPreview(ColorData color) {
    if (color.coloresComponentes == null ||
        color.coloresComponentes!.isEmpty ||
        _coloresUnicos.isEmpty) {
      // Fallback: mostrar color base si no hay componentes o colores únicos
      return Container(
        color: _getColorFromHex(color.hexColor),
      );
    }

    // Obtener los colores componentes reales
    final coloresComponentesReales = <ColorData>[];
    for (final componenteId in color.coloresComponentes!) {
      final colorComponente = _coloresUnicos
          .where((c) => c.id == componenteId)
          .firstOrNull;
      if (colorComponente != null) {
        coloresComponentesReales.add(colorComponente);
      }
    }

    if (coloresComponentesReales.isEmpty) {
      // Fallback si no se encuentran los componentes
      return Container(
        color: _getColorFromHex(color.hexColor),
      );
    }

    // Construir barra de colores dividida
    return Row(
      children: coloresComponentesReales.map((colorComponente) {
        return Expanded(
          child: Container(
            color: _getColorFromHex(colorComponente.hexColor),
          ),
        );
      }).toList(),
    );
  }
}