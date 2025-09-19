import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';

/// Diálogo de formulario para crear o editar colores
class ColorFormDialog extends StatefulWidget {
  final String title;
  final ColorData? color; // null para crear, ColorData para editar
  final List<ColorData> existingColors;

  const ColorFormDialog({
    super.key,
    required this.title,
    this.color,
    required this.existingColors,
  });

  @override
  State<ColorFormDialog> createState() => _ColorFormDialogState();
}

class _ColorFormDialogState extends State<ColorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _hexController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController(); // NUEVO
  final ProductsRepository _repository = ProductsRepository();

  bool _isLoading = false;
  bool _activa = true;
  Color _selectedColor = Colors.grey[400]!;

  // Estados para colores múltiples
  String _tipoColor = 'UNICO'; // NUEVO: 'UNICO' | 'VARIOS'
  List<String> _coloresSeleccionados = []; // NUEVO: IDs para tipo VARIOS
  List<ColorData> _coloresUnicos = []; // NUEVO: Colores disponibles para combinación

  // Colores predefinidos para selección rápida - Gama ampliada para retail de ropa
  final List<Color> _predefinedColors = [
    // Rojos y Rosas
    const Color(0xFFFF0000), // Rojo puro
    const Color(0xFFDC143C), // Crimson
    const Color(0xFFB22222), // Rojo ladrillo
    const Color(0xFF8B0000), // Rojo oscuro
    const Color(0xFFFF6B6B), // Rojo coral
    const Color(0xFFFF1744), // Rojo intenso
    const Color(0xFFFFB3BA), // Rosa claro
    const Color(0xFFFF69B4), // Rosa fuerte
    const Color(0xFFFFC0CB), // Rosa pastel
    const Color(0xFFE91E63), // Rosa magenta
    const Color(0xFFC2185B), // Rosa oscuro

    // Púrpuras y Violetas
    const Color(0xFF800080), // Púrpura
    const Color(0xFF9932CC), // Orquídea oscura
    const Color(0xFFBA55D3), // Orquídea media
    const Color(0xFFDDA0DD), // Púrpura claro
    const Color(0xFF8A2BE2), // Violeta azul
    const Color(0xFF6A0DAD), // Violeta oscuro
    const Color(0xFF9C27B0), // Púrpura material
    const Color(0xFFE1BEE7), // Púrpura muy claro

    // Azules
    const Color(0xFF0000FF), // Azul puro
    const Color(0xFF1E90FF), // Azul cielo profundo
    const Color(0xFF4169E1), // Azul real
    const Color(0xFF0066CC), // Azul corporativo
    const Color(0xFF87CEEB), // Azul cielo
    const Color(0xFFADD8E6), // Azul claro
    const Color(0xFF191970), // Azul medianoche
    const Color(0xFF000080), // Azul marino
    const Color(0xFF4682B4), // Azul acero
    const Color(0xFF2196F3), // Azul material
    const Color(0xFF03A9F4), // Azul claro material
    const Color(0xFFB3E5FC), // Azul muy claro

    // Cianes y Turquesas
    const Color(0xFF00FFFF), // Cian
    const Color(0xFF00CED1), // Turquesa oscuro
    const Color(0xFF48D1CC), // Turquesa medio
    const Color(0xFF40E0D0), // Turquesa
    const Color(0xFFAFEEEE), // Turquesa pálido
    const Color(0xFF00BCD4), // Cian material
    const Color(0xFF26C6DA), // Cian claro material

    // Verdes
    const Color(0xFF008000), // Verde
    const Color(0xFF32CD32), // Verde lima
    const Color(0xFF00FF00), // Verde lima brillante
    const Color(0xFF90EE90), // Verde claro
    const Color(0xFF228B22), // Verde bosque
    const Color(0xFF006400), // Verde oscuro
    const Color(0xFF98FB98), // Verde pálido
    const Color(0xFF00FF7F), // Verde primavera
    const Color(0xFF4CAF50), // Verde material
    const Color(0xFF8BC34A), // Verde claro material
    const Color(0xFFCDDC39), // Verde lima material
    const Color(0xFFDCEDC8), // Verde muy claro

    // Amarillos y Dorados
    const Color(0xFFFFFF00), // Amarillo puro
    const Color(0xFFFFD700), // Dorado
    const Color(0xFFFFA500), // Naranja
    const Color(0xFFFFE135), // Amarillo banana
    const Color(0xFFFFF8DC), // Amarillo crema
    const Color(0xFFFFEB3B), // Amarillo material
    const Color(0xFFFFC107), // Ámbar material
    const Color(0xFFFFF59D), // Amarillo muy claro

    // Naranjas
    const Color(0xFFFF8C00), // Naranja oscuro
    const Color(0xFFFF7F50), // Coral
    const Color(0xFFFF6347), // Tomate
    const Color(0xFFFF4500), // Naranja rojo
    const Color(0xFFFF9800), // Naranja material
    const Color(0xFFFFB74D), // Naranja claro material

    // Marrones y Tierras
    const Color(0xFFA52A2A), // Marrón
    const Color(0xFF8B4513), // Marrón silla de montar
    const Color(0xFFD2691E), // Chocolate
    const Color(0xFFCD853F), // Marrón arena
    const Color(0xFFF4A460), // Marrón arenoso claro
    const Color(0xFFDEB887), // Marrón claro
    const Color(0xFF795548), // Marrón material
    const Color(0xFFA1887F), // Marrón claro material
    const Color(0xFFD7CCC8), // Marrón muy claro

    // Grises
    const Color(0xFF000000), // Negro
    const Color(0xFF808080), // Gris
    const Color(0xFFA9A9A9), // Gris oscuro
    const Color(0xFFD3D3D3), // Gris claro
    const Color(0xFFDCDCDC), // Gris gainsboro
    const Color(0xFFF5F5F5), // Gris humo
    const Color(0xFF607D8B), // Gris azul material
    const Color(0xFF90A4AE), // Gris azul claro material
    const Color(0xFFECEFF1), // Gris azul muy claro

    // Blancos y Cremas
    const Color(0xFFFFFFFF), // Blanco puro
    const Color(0xFFFFFAF0), // Blanco floral
    const Color(0xFFF5F5DC), // Beige
    const Color(0xFFFFE4E1), // Rosa brumoso
    const Color(0xFFFAF0E6), // Lino
    const Color(0xFFFDF5E6), // Crema antiguo

    // Colores especiales para retail
    const Color(0xFF8E24AA), // Violeta retail
    const Color(0xFF5E35B1), // Púrpura profundo retail
    const Color(0xFF3949AB), // Índigo retail
    const Color(0xFF1E88E5), // Azul retail
    const Color(0xFF039BE5), // Azul claro retail
    const Color(0xFF00ACC1), // Cian retail
    const Color(0xFF00897B), // Verde azulado retail
    const Color(0xFF43A047), // Verde retail
    const Color(0xFF7CB342), // Verde claro retail
    const Color(0xFFC0CA33), // Lima retail
    const Color(0xFFFFB300), // Ámbar retail
    const Color(0xFFFF8F00), // Naranja retail
    const Color(0xFFFF5722), // Naranja profundo retail
    const Color(0xFF6D4C41), // Marrón retail
    const Color(0xFF546E7A), // Gris azul retail
  ];

  @override
  void initState() {
    super.initState();
    _loadColoresUnicos(); // NUEVO: Cargar colores base
    _initializeForm();

    // Listeners para sincronizar color hex con color visual
    _hexController.addListener(_onHexChanged);
  }

  /// NUEVO: Cargar colores únicos para selección múltiple
  Future<void> _loadColoresUnicos() async {
    try {
      final colores = await _repository.getColoresUnicos();
      setState(() {
        _coloresUnicos = colores;
      });
    } catch (e) {
      print('Error cargando colores únicos: $e');
    }
  }

  /// NUEVO: Inicializar formulario según modo
  void _initializeForm() {
    if (widget.color != null) {
      // Modo edición - cargar datos existentes
      final color = widget.color!;
      _nombreController.text = color.nombre;
      final hex = color.hexColor ?? '#808080';
      _hexController.text = hex.startsWith('#') ? hex.substring(1) : hex;
      _codigoController.text = color.codigoAbrev ?? '';
      _tipoColor = color.tipoColor;
      _activa = color.activo;
      _selectedColor = _getColorFromHex(color.hexColor);

      // Datos específicos para colores múltiples
      if (color.esColorMultiple) {
        _coloresSeleccionados = List.from(color.coloresComponentes ?? []);
        _descripcionController.text = color.descripcionCompleta ?? '';
      }
    } else {
      // Modo creación - valores por defecto
      _hexController.text = '808080';
      _selectedColor = Colors.grey[400]!;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _hexController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose(); // NUEVO
    super.dispose();
  }

  void _onHexChanged() {
    final hex = _hexController.text;
    final hexWithHash = hex.startsWith('#') ? hex : '#$hex';
    if (hex.isNotEmpty && _isValidHex(hexWithHash)) {
      setState(() {
        _selectedColor = _getColorFromHex(hexWithHash);
      });
    }
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
      _hexController.text = color.value.toRadixString(16).substring(2).toUpperCase();
    });
  }

  bool _isValidHex(String hex) {
    final hexPattern = RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$');
    return hexPattern.hasMatch(hex);
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey[400]!;
    }

    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      } else if (hex.length == 3) {
        // Expandir formato corto #RGB a #RRGGBB
        hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey[400]!;
    }
  }

  /// NUEVO: Toggle selección de color para tipo múltiple
  void _toggleColorSelection(String colorId, bool selected) {
    setState(() {
      if (selected && _coloresSeleccionados.length < 3) {
        _coloresSeleccionados.add(colorId);
      } else {
        _coloresSeleccionados.remove(colorId);
      }

      // Auto-generar nombre para colores múltiples
      if (_tipoColor == 'VARIOS' && _coloresSeleccionados.length >= 2) {
        _autoGenerateMultiColorName();
      }
    });
  }

  /// NUEVO: Auto-generar nombre para colores múltiples
  void _autoGenerateMultiColorName() {
    final nombres = _coloresSeleccionados
        .map((id) => _coloresUnicos.firstWhere((c) => c.id == id).nombre)
        .join('+');
    _nombreController.text = nombres;
  }

  /// NUEVO: Validar datos específicos para colores múltiples
  String? _validateMultiColor() {
    if (_tipoColor == 'VARIOS') {
      if (_coloresSeleccionados.length < 2) {
        return 'Selecciona al menos 2 colores';
      }
      if (_coloresSeleccionados.length > 3) {
        return 'Máximo 3 colores permitidos';
      }
      if (_descripcionController.text.trim().isEmpty) {
        return 'Descripción requerida para colores múltiples';
      }
    }
    return null;
  }

  Future<String> _generateUniqueCode(String nombre) async {
    // Usar el mismo algoritmo que en ColorSelectorEnhanced
    final baseName = nombre.toLowerCase().replaceAll(' ', '');

    // Estrategia 1: Primeras 3 letras
    String code = baseName.substring(0, baseName.length > 3 ? 3 : baseName.length).toUpperCase();

    final existingCodes = widget.existingColors.map((c) => c.codigoAbrev?.toUpperCase()).toSet();

    if (!existingCodes.contains(code)) {
      return code;
    }

    // Estrategia 2: Primera letra + dos primeras consonantes
    if (baseName.length > 2) {
      final consonants = baseName.split('').where((c) => !'aeiou'.contains(c)).toList();
      if (consonants.length >= 2) {
        code = '${baseName[0]}${consonants[0]}${consonants[1]}'.toUpperCase();
        if (!existingCodes.contains(code)) {
          return code;
        }
      }
    }

    // Estrategia 3: Agregar número
    for (int i = 1; i <= 99; i++) {
      final numberedCode = '${code.substring(0, 2)}$i';
      if (!existingCodes.contains(numberedCode)) {
        return numberedCode;
      }
    }

    // Fallback: timestamp
    return 'C${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  Future<void> _saveColor() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar datos específicos para colores múltiples
    final validationError = _validateMultiColor();
    if (validationError != null) {
      _showErrorMessage(validationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nombre = _nombreController.text.trim();
      final hexValue = _hexController.text.trim();
      final hexColor = hexValue.startsWith('#') ? hexValue : '#$hexValue';

      // Validar duplicados por nombre (solo para modo creación)
      if (widget.color == null) {
        final isDuplicatedName = widget.existingColors.any(
          (c) => c.nombre.toLowerCase() == nombre.toLowerCase(),
        );

        if (isDuplicatedName) {
          _showErrorMessage('Ya existe un color con ese nombre');
          return;
        }
      }

      // Generar código abreviado si está vacío
      String codigoAbrev = _codigoController.text.trim();
      if (codigoAbrev.isEmpty) {
        codigoAbrev = await _generateUniqueCode(nombre);
      } else {
        // Validar que el código no esté duplicado (excluir actual en edición)
        final isDuplicatedCode = widget.existingColors.any(
          (c) => c.codigoAbrev?.toUpperCase() == codigoAbrev.toUpperCase() &&
                 c.id != widget.color?.id,
        );

        if (isDuplicatedCode) {
          _showErrorMessage('Ya existe un color con ese código abreviado');
          return;
        }
      }

      final colorData = {
        'nombre': nombre,
        'codigo_hex': hexColor,
        'codigo_abrev': codigoAbrev.toUpperCase(),
        'tipo_color': _tipoColor, // NUEVO
        'activo': _activa,
      };

      // Campos específicos para colores múltiples
      if (_tipoColor == 'VARIOS') {
        colorData['colores_componentes'] = _coloresSeleccionados;
        colorData['descripcion_completa'] = _descripcionController.text.trim();
      }

      ColorData result;
      if (widget.color != null) {
        // Actualizar color existente
        result = await _repository.updateColor(widget.color!.id, colorData);
      } else {
        // Crear nuevo color
        result = await _repository.createColor(colorData);
      }

      Navigator.of(context).pop(result);
    } catch (e) {
      String errorMessage = 'Error al guardar color: ${e.toString()}';

      if (e.toString().contains('23505')) {
        errorMessage = 'Ya existe un color con esos datos. Verifica el nombre o código.';
      }

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 500,
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
                    Icons.palette_outlined,
                    color: AppTheme.primaryTurquoise,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTurquoise,
                    ),
                  ),
                  const Spacer(),
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
                    children: [
                      // Preview del color
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: _tipoColor == 'UNICO'
                            ? Container(
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'PREVIEW',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : _coloresSeleccionados.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Selecciona colores',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: _coloresSeleccionados.map((colorId) {
                                      final color = _coloresUnicos.firstWhere(
                                        (c) => c.id == colorId,
                                        orElse: () => ColorData(
                                          id: '',
                                          nombre: 'Error',
                                          hexColor: '#808080',
                                          tipoColor: 'UNICO',
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                      return Expanded(
                                        child: Container(
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: _getColorFromHex(color.hexColor),
                                            borderRadius: _coloresSeleccionados.indexOf(colorId) == 0
                                                ? const BorderRadius.only(
                                                    topLeft: Radius.circular(7),
                                                    bottomLeft: Radius.circular(7),
                                                  )
                                                : _coloresSeleccionados.indexOf(colorId) == _coloresSeleccionados.length - 1
                                                    ? const BorderRadius.only(
                                                        topRight: Radius.circular(7),
                                                        bottomRight: Radius.circular(7),
                                                      )
                                                    : BorderRadius.zero,
                                          ),
                                          child: Center(
                                            child: Text(
                                              color.nombre.substring(0, 3).toUpperCase(),
                                              style: TextStyle(
                                                color: _getColorFromHex(color.hexColor).computeLuminance() > 0.5
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                      ),

                      const SizedBox(height: 24),

                      // Campo nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Color *',
                          hintText: 'Ej: Azul Marino, Verde Oliva...',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          if (value.trim().length < 2) {
                            return 'El nombre debe tener al menos 2 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Campo código hex (requerido solo para color único)
                      if (_tipoColor == 'UNICO')
                        TextFormField(
                          controller: _hexController,
                          decoration: const InputDecoration(
                            labelText: 'Código Hex *',
                            hintText: '#FF0000',
                            prefixText: '#',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (_tipoColor == 'UNICO' && (value == null || value.trim().isEmpty)) {
                              return 'El código hex es requerido';
                            }
                            if (value != null && value.trim().isNotEmpty) {
                              final hexWithHash = value.startsWith('#') ? value : '#$value';
                              if (!_isValidHex(hexWithHash)) {
                                return 'Formato hex inválido (ej: FF0000)';
                              }
                            }
                            return null;
                          },
                        ),
                      if (_tipoColor == 'VARIOS')
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'El color hex se generará automáticamente basado en el primer color seleccionado',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Campo código abreviado
                      TextFormField(
                        controller: _codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Código Abreviado',
                          hintText: 'AZU (opcional, se genera automáticamente)',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // NUEVO: Selector de tipo de color
                      const Text(
                        'Tipo de Color',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'UNICO',
                            groupValue: _tipoColor,
                            onChanged: (value) => setState(() {
                              _tipoColor = value!;
                              if (_tipoColor == 'UNICO') {
                                _coloresSeleccionados.clear();
                                _descripcionController.clear();
                              }
                            }),
                          ),
                          const Text('Color único'),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'VARIOS',
                            groupValue: _tipoColor,
                            onChanged: (value) => setState(() => _tipoColor = value!),
                          ),
                          const Text('Color múltiple'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Selector de colores componentes (solo para tipo VARIOS)
                      if (_tipoColor == 'VARIOS') ...[
                        const Text(
                          'Seleccionar colores base (2-3):',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 60),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _coloresUnicos.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Cargando colores disponibles...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _coloresUnicos.map((color) {
                                    final isSelected = _coloresSeleccionados.contains(color.id);
                                    return FilterChip(
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: _getColorFromHex(color.hexColor),
                                              borderRadius: BorderRadius.circular(2),
                                              border: Border.all(color: Colors.grey),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(color.nombre),
                                        ],
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) => _toggleColorSelection(color.id, selected),
                                      selectedColor: AppTheme.primaryTurquoise.withOpacity(0.2),
                                      checkmarkColor: AppTheme.primaryTurquoise,
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción completa *',
                            hintText: 'Ej: Media roja con detalles blancos',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (_tipoColor == 'VARIOS' && (value == null || value.trim().isEmpty)) {
                              return 'Descripción requerida para colores múltiples';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 8),

                      // Colores predefinidos (solo para color único)
                      if (_tipoColor == 'UNICO') ...[
                        const Text(
                          'Colores Predefinidos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Grid de colores predefinidos - Expandido para más colores
                        SizedBox(
                          height: 200, // Aumentado para acomodar más colores
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 10, // Más columnas para aprovechar el espacio
                              crossAxisSpacing: 6, // Espaciado reducido para caber más
                              mainAxisSpacing: 6,
                            ),
                            itemCount: _predefinedColors.length,
                            itemBuilder: (context, index) {
                              final color = _predefinedColors[index];
                              final isSelected = _selectedColor.value == color.value;

                              return GestureDetector(
                                onTap: () => _onColorSelected(color),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryTurquoise
                                          : (color == Colors.white ? Colors.grey[300]! : Colors.transparent),
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: color.computeLuminance() > 0.5
                                              ? Colors.black
                                              : Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],

                      // Switch estado activo
                      Row(
                        children: [
                          Switch(
                            value: _activa,
                            onChanged: (value) => setState(() => _activa = value),
                            activeColor: AppTheme.successColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _activa ? 'Color activo' : 'Color inactivo',
                            style: TextStyle(
                              fontSize: 16,
                              color: _activa
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
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
                    onPressed: _isLoading ? null : _saveColor,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.color != null ? 'Actualizar' : 'Crear'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}