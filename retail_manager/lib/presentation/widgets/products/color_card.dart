import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../common/safe_hover_widget.dart';

/// Tarjeta que muestra información de un color con acciones de administración
class ColorCard extends StatelessWidget {
  final ColorData color;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const ColorCard({
    super.key,
    required this.color,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeMaterialButton(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: color.activo ? 2 : 1,
      onTap: onEdit,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.activo
                  ? Colors.grey[300]!
                  : Colors.grey[400]!,
              width: 1,
            ),
            color: color.activo
                ? Colors.white
                : Colors.grey[50],
          ),
          child: Column(
            children: [
              // Header con preview del color y estado
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: _getColorFromHex(color.hexColor),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border.all(
                    color: _getColorFromHex(color.hexColor) == Colors.white
                        ? Colors.grey[300]!
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Indicador de estado
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          color.activo ? 'ACTIVO' : 'INACTIVO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Código hex centrado
                    if (color.hexColor != null)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getContrastColor(_getColorFromHex(color.hexColor))
                                .withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            color.hexColor!.toUpperCase(),
                            style: TextStyle(
                              color: _getContrastColor(_getColorFromHex(color.hexColor)) == Colors.white
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Información del color
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del color
                      Text(
                        _capitalize(color.nombre),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color.activo
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Código abreviado
                      if (color.codigoAbrev != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTurquoise.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'COD: ${color.codigoAbrev}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryTurquoise,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Botones de acción
                      Row(
                        children: [
                          // Botón editar
                          Expanded(
                            child: IconButton(
                              onPressed: onEdit,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppTheme.primaryTurquoise,
                              ),
                              tooltip: 'Editar',
                            ),
                          ),

                          // Botón toggle estado
                          Expanded(
                            child: IconButton(
                              onPressed: onToggleStatus,
                              icon: Icon(
                                color.activo
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: color.activo
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                              ),
                              tooltip: color.activo ? 'Desactivar' : 'Activar',
                            ),
                          ),

                          // Botón eliminar
                          Expanded(
                            child: IconButton(
                              onPressed: onDelete,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppTheme.errorColor,
                              ),
                              tooltip: 'Eliminar',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Color _getContrastColor(Color color) {
    // Calcular luminancia para determinar si usar texto claro u oscuro
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}