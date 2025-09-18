import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../common/safe_hover_widget.dart';

/// Widget selector de colores que usa únicamente colores de la BD
class ColorSelectorFromDB extends StatelessWidget {
  final List<ColorData> availableColors;
  final List<String> selectedColorIds;
  final ValueChanged<List<String>> onColorsChanged;

  const ColorSelectorFromDB({
    super.key,
    required this.availableColors,
    required this.selectedColorIds,
    required this.onColorsChanged,
  });

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
        if (selectedColorIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTurquoise.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${selectedColorIds.length} colores seleccionados',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryTurquoise,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Grid de colores de la BD
        if (availableColors.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = selectedColorIds.contains(color.id);

              return _buildColorChip(
                color,
                isSelected,
                onTap: () => _toggleColor(color.id),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Text(
              '❌ No hay colores disponibles en la base de datos',
              style: TextStyle(color: Colors.red),
            ),
          ),

        if (selectedColorIds.isNotEmpty) ...[
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
            children: selectedColorIds.map((colorId) {
              final color = availableColors.where((c) => c.id == colorId).firstOrNull;
              return _buildSelectedColorChip(color);
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

  Widget _buildSelectedColorChip(ColorData? color) {
    if (color == null) {
      return Chip(
        label: const Text('Color desconocido'),
        backgroundColor: Colors.grey[200],
      );
    }

    return Chip(
      avatar: Container(
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
      label: Text(
        _capitalize(color.nombre),
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeColor(color.id),
      backgroundColor: AppTheme.primaryTurquoise.withOpacity(0.1),
      deleteIconColor: AppTheme.primaryTurquoise,
    );
  }

  void _toggleColor(String colorId) {
    final selectedColors = List<String>.from(selectedColorIds);

    if (selectedColors.contains(colorId)) {
      selectedColors.remove(colorId);
    } else {
      selectedColors.add(colorId);
    }

    onColorsChanged(selectedColors);
  }

  void _removeColor(String colorId) {
    final selectedColors = List<String>.from(selectedColorIds);
    selectedColors.remove(colorId);
    onColorsChanged(selectedColors);
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey[400]!;
    }

    try {
      // Remover # si existe
      String hex = hexColor.replaceAll('#', '');

      // Asegurar que tiene 6 dígitos
      if (hex.length == 6) {
        hex = 'FF$hex'; // Agregar alpha
      }

      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.grey[400]!;
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