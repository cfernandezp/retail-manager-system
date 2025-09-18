import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';
import '../common/safe_hover_widget.dart';

/// Widget selector de colores que usa colores de BD + permite crear nuevos
class ColorSelectorEnhanced extends StatefulWidget {
  final List<ColorData> availableColors;
  final List<String> selectedColors;
  final ValueChanged<List<String>> onColorsChanged;
  final ValueChanged<ColorData>? onColorCreated;

  const ColorSelectorEnhanced({
    super.key,
    required this.availableColors,
    required this.selectedColors,
    required this.onColorsChanged,
    this.onColorCreated,
  });

  @override
  State<ColorSelectorEnhanced> createState() => _ColorSelectorEnhancedState();
}

class _ColorSelectorEnhancedState extends State<ColorSelectorEnhanced> {
  final TextEditingController _customColorController = TextEditingController();
  final ProductsRepository _repository = ProductsRepository();
  bool _isCreatingColor = false;

  @override
  void dispose() {
    _customColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Colores Disponibles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Información de selección
        if (widget.selectedColors.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTurquoise.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.selectedColors.length} colores seleccionados',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryTurquoise,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Grid de colores de la BD
        if (widget.availableColors.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: widget.availableColors.length,
            itemBuilder: (context, index) {
              final color = widget.availableColors[index];
              final isSelected = widget.selectedColors.contains(color.nombre.toLowerCase());

              return _buildColorChip(
                color,
                isSelected,
                onTap: () => _toggleColor(color.nombre.toLowerCase()),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              '⚠️ Cargando colores de la base de datos...',
              style: TextStyle(color: Colors.orange),
            ),
          ),

        const SizedBox(height: 24),

        // Sección de color personalizado
        const Text(
          'Crear Nuevo Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customColorController,
                decoration: const InputDecoration(
                  hintText: 'Ej: Verde Oliva, Rosa Claro, Azul Marino...',
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.words,
                enabled: !_isCreatingColor,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isCreatingColor ? null : _createNewColor,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
              ),
              child: _isCreatingColor
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear'),
            ),
          ],
        ),

        if (widget.selectedColors.isNotEmpty) ...[
          const SizedBox(height: 24),

          // Lista de colores seleccionados
          const Text(
            'Colores Seleccionados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedColors.map((colorName) {
              final color = _getColorByName(colorName);
              return _buildSelectedColorChip(colorName, color);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildColorChip(
    ColorData color,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return SafeMaterialButton(
      elevation: isSelected ? 4 : 1,
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.white,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryTurquoise
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppTheme.primaryTurquoise.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getColorFromHex(color.hexColor),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getColorFromHex(color.hexColor) == Colors.white
                      ? Colors.grey[400]!
                      : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Color name
            Expanded(
              child: Text(
                _capitalize(color.nombre),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryTurquoise
                      : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: AppTheme.primaryTurquoise,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedColorChip(String colorName, ColorData? color) {
    return Chip(
      avatar: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color != null
              ? _getColorFromHex(color.hexColor)
              : _getFallbackColor(colorName),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (color != null
                    ? _getColorFromHex(color.hexColor)
                    : _getFallbackColor(colorName)) == Colors.white
                ? Colors.grey[400]!
                : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      label: Text(
        _capitalize(colorName),
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeColor(colorName),
      backgroundColor: AppTheme.primaryTurquoise.withOpacity(0.1),
      deleteIconColor: AppTheme.primaryTurquoise,
    );
  }

  void _toggleColor(String colorName) {
    final selectedColors = List<String>.from(widget.selectedColors);

    if (selectedColors.contains(colorName)) {
      selectedColors.remove(colorName);
    } else {
      selectedColors.add(colorName);
    }

    widget.onColorsChanged(selectedColors);
  }

  void _removeColor(String colorName) {
    final selectedColors = List<String>.from(widget.selectedColors);
    selectedColors.remove(colorName);
    widget.onColorsChanged(selectedColors);
  }

  Future<void> _createNewColor() async {
    final customColor = _customColorController.text.trim();
    if (customColor.isEmpty) return;

    // Verificar que no esté duplicado (case insensitive)
    final isDuplicated = widget.availableColors.any(
      (color) => color.nombre.toLowerCase() == customColor.toLowerCase(),
    );

    if (isDuplicated) {
      _showMessage(
        'El color "$customColor" ya existe en la base de datos',
        AppTheme.warningColor,
      );
      return;
    }

    setState(() => _isCreatingColor = true);

    try {
      // Generar código abreviado único
      final codigoAbrev = await _generateUniqueColorCode(customColor);

      final nuevoColor = await _repository.createColor({
        'nombre': customColor,
        'codigo_hex': _getHexFromColorName(customColor),
        'codigo_abrev': codigoAbrev,
        'activo': true,
      });

      // Agregar a la lista de seleccionados
      final selectedColors = List<String>.from(widget.selectedColors);
      selectedColors.add(customColor.toLowerCase());
      widget.onColorsChanged(selectedColors);

      // Notificar que se creó un nuevo color
      widget.onColorCreated?.call(nuevoColor);

      _customColorController.clear();

      _showMessage(
        'Color "$customColor" creado exitosamente',
        AppTheme.successColor,
      );
    } catch (e) {
      String mensajeError = 'Error al crear color: ${e.toString()}';

      if (e.toString().contains('23505')) {
        mensajeError = 'El código del color ya existe. Intenta con otro nombre.';
      }

      _showMessage(mensajeError, AppTheme.errorColor);
    } finally {
      setState(() => _isCreatingColor = false);
    }
  }

  Future<String> _generateUniqueColorCode(String colorName) async {
    // Intentar diferentes estrategias para generar código único
    final baseName = colorName.toLowerCase().replaceAll(' ', '');

    // Estrategia 1: Primeras 3 letras
    String code = baseName.substring(0, baseName.length > 3 ? 3 : baseName.length).toUpperCase();

    // Verificar si ya existe
    final existingCodes = widget.availableColors.map((c) => c.codigoAbrev?.toUpperCase()).toSet();

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

  ColorData? _getColorByName(String colorName) {
    return widget.availableColors
        .where((c) => c.nombre.toLowerCase() == colorName.toLowerCase())
        .firstOrNull;
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey[400]!;
    }

    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey[400]!;
    }
  }

  Color _getFallbackColor(String colorName) {
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
      'azul marino': const Color(0xFF000080),
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

    return colorsHex[colorName.toLowerCase()] ?? '#808080';
  }

  void _showMessage(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }
}