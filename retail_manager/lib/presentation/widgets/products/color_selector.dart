import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../common/safe_hover_widget.dart';

/// Widget selector de colores múltiple para productos
class ColorSelector extends StatefulWidget {
  final List<String> selectedColors;
  final ValueChanged<List<String>> onColorsChanged;
  final bool allowCustomColors;

  const ColorSelector({
    super.key,
    required this.selectedColors,
    required this.onColorsChanged,
    this.allowCustomColors = true,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  final TextEditingController _customColorController = TextEditingController();
  
  // Colores predefinidos comunes en medias
  static const List<ColorOption> _predefinedColors = [
    ColorOption('negro', Colors.black),
    ColorOption('blanco', Colors.white),
    ColorOption('gris', Colors.grey),
    ColorOption('azul', Colors.blue),
    ColorOption('azul marino', Color(0xFF000080)),
    ColorOption('rojo', Colors.red),
    ColorOption('verde', Colors.green),
    ColorOption('amarillo', Colors.yellow),
    ColorOption('naranja', Colors.orange),
    ColorOption('rosado', Colors.pink),
    ColorOption('morado', Colors.purple),
    ColorOption('café', Colors.brown),
    ColorOption('beige', Color(0xFFF5F5DC)),
    ColorOption('crema', Color(0xFFFFFDD0)),
    ColorOption('turquesa', Color(0xFF40E0D0)),
    ColorOption('dorado', Color(0xFFFFD700)),
    ColorOption('plateado', Color(0xFFC0C0C0)),
    ColorOption('vino', Color(0xFF722F37)),
  ];

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

        // Grid de colores predefinidos
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _predefinedColors.length,
          itemBuilder: (context, index) {
            final colorOption = _predefinedColors[index];
            final isSelected = widget.selectedColors.contains(colorOption.name);
            
            return _buildColorChip(
              colorOption,
              isSelected,
              onTap: () => _toggleColor(colorOption.name),
            );
          },
        ),

        if (widget.allowCustomColors) ...[
          const SizedBox(height: 24),
          
          // Sección de color personalizado
          const Text(
            'Color Personalizado',
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
                    hintText: 'Ej: Verde Oliva, Rosa Claro...',
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addCustomColor,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Agregar'),
              ),
            ],
          ),
        ],

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
              final colorOption = _getColorOption(colorName);
              return _buildSelectedColorChip(colorName, colorOption?.color);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildColorChip(
    ColorOption colorOption,
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
                color: colorOption.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorOption.color == Colors.white 
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
                _capitalize(colorOption.name),
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

  Widget _buildSelectedColorChip(String colorName, Color? color) {
    return Chip(
      avatar: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color ?? Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color == Colors.white 
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

  void _addCustomColor() {
    final customColor = _customColorController.text.trim();
    if (customColor.isEmpty) return;
    
    // Verificar que no esté duplicado (case insensitive)
    final isDuplicated = widget.selectedColors.any(
      (color) => color.toLowerCase() == customColor.toLowerCase(),
    );
    
    if (isDuplicated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este color ya está seleccionado'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    final selectedColors = List<String>.from(widget.selectedColors);
    selectedColors.add(customColor.toLowerCase());
    
    widget.onColorsChanged(selectedColors);
    _customColorController.clear();
  }

  ColorOption? _getColorOption(String colorName) {
    return _predefinedColors
        .where((c) => c.name == colorName)
        .firstOrNull;
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

/// Clase para representar una opción de color
class ColorOption {
  final String name;
  final Color color;
  
  const ColorOption(this.name, this.color);
}