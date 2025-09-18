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
  final ProductsRepository _repository = ProductsRepository();

  bool _isLoading = false;
  bool _activa = true;
  Color _selectedColor = Colors.grey[400]!;

  // Colores predefinidos para selección rápida
  final List<Color> _predefinedColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();

    if (widget.color != null) {
      // Modo edición - cargar datos existentes
      _nombreController.text = widget.color!.nombre;
      final hex = widget.color!.hexColor ?? '#808080';
      _hexController.text = hex.startsWith('#') ? hex.substring(1) : hex;
      _codigoController.text = widget.color!.codigoAbrev ?? '';
      _activa = widget.color!.activo;
      _selectedColor = _getColorFromHex(widget.color!.hexColor);
    } else {
      // Modo creación - valores por defecto
      _hexController.text = '808080';
      _selectedColor = Colors.grey[400]!;
    }

    // Listeners para sincronizar color hex con color visual
    _hexController.addListener(_onHexChanged);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _hexController.dispose();
    _codigoController.dispose();
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

    setState(() => _isLoading = true);

    try {
      final nombre = _nombreController.text.trim();
      final hexValue = _hexController.text.trim();
      final hexColor = hexValue.startsWith('#') ? hexValue : '#$hexValue';

      // Validar duplicados por nombre
      final isDuplicatedName = widget.existingColors.any(
        (c) => c.nombre.toLowerCase() == nombre.toLowerCase(),
      );

      if (isDuplicatedName) {
        _showErrorMessage('Ya existe un color con ese nombre');
        return;
      }

      // Generar código abreviado si está vacío
      String codigoAbrev = _codigoController.text.trim();
      if (codigoAbrev.isEmpty) {
        codigoAbrev = await _generateUniqueCode(nombre);
      } else {
        // Validar que el código no esté duplicado
        final isDuplicatedCode = widget.existingColors.any(
          (c) => c.codigoAbrev?.toUpperCase() == codigoAbrev.toUpperCase(),
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
        'activo': _activa, // BD usa 'activo', no 'activa'
      };

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
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedColor == Colors.white
                                ? Colors.grey[300]!
                                : Colors.transparent,
                            width: 1,
                          ),
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

                      // Campo código hex
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
                          if (value == null || value.trim().isEmpty) {
                            return 'El código hex es requerido';
                          }
                          final hexWithHash = value.startsWith('#') ? value : '#$value';
                          if (!_isValidHex(hexWithHash)) {
                            return 'Formato hex inválido (ej: FF0000)';
                          }
                          return null;
                        },
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

                      // Colores predefinidos
                      const Text(
                        'Colores Predefinidos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Grid de colores predefinidos
                      SizedBox(
                        height: 100,
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
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