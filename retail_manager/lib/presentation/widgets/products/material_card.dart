import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../common/safe_hover_widget.dart';

/// Tarjeta que muestra información de un material con acciones de administración
class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const MaterialCard({
    super.key,
    required this.material,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeMaterialButton(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: material.activo ? 2 : 1,
      onTap: onEdit,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: material.activo
                  ? Colors.grey[300]!
                  : Colors.grey[400]!,
              width: 1,
            ),
            color: material.activo
                ? Colors.white
                : Colors.grey[50],
          ),
          child: Column(
            children: [
              // Header con ícono y estado
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: material.activo
                      ? AppTheme.primaryTurquoise.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Ícono de material
                    Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: material.activo
                              ? AppTheme.primaryTurquoise.withOpacity(0.2)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fiber_manual_record,
                          color: material.activo
                              ? AppTheme.primaryTurquoise
                              : Colors.grey[600],
                          size: 30,
                        ),
                      ),
                    ),

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
                          color: material.activo
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          material.activo ? 'ACTIVO' : 'INACTIVO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Información del material
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del material
                      Text(
                        _capitalize(material.nombre),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: material.activo
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Descripción
                      if (material.descripcion != null && material.descripcion!.isNotEmpty)
                        Flexible(
                          child: Text(
                            material.descripcion!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(height: 6),

                      // Código del material (si existe)
                      if (material.codigo != null && material.codigo!.isNotEmpty)
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
                            'COD: ${material.codigo}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryTurquoise,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                      const SizedBox(height: 6),

                      // Botones de acción
                      Row(
                        children: [
                          // Botón editar
                          Expanded(
                            child: IconButton(
                              onPressed: onEdit,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: AppTheme.primaryTurquoise,
                              ),
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: 'Editar',
                            ),
                          ),

                          // Botón toggle estado
                          Expanded(
                            child: IconButton(
                              onPressed: onToggleStatus,
                              icon: Icon(
                                material.activo
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 16,
                                color: material.activo
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                              ),
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              tooltip: material.activo ? 'Desactivar' : 'Activar',
                            ),
                          ),

                          // Botón eliminar
                          Expanded(
                            child: IconButton(
                              onPressed: onDelete,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: AppTheme.errorColor,
                              ),
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}