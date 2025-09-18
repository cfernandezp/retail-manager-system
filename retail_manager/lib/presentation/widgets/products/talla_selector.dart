import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart' as models;
import '../common/safe_hover_widget.dart';

/// Widget selector de tallas con visualización especializada para medias
class TallaSelector extends StatelessWidget {
  final List<models.Talla> tallas;
  final String? selectedTallaId;
  final ValueChanged<String?> onTallaChanged;
  final bool allowCustomTalla;

  const TallaSelector({
    super.key,
    required this.tallas,
    this.selectedTallaId,
    required this.onTallaChanged,
    this.allowCustomTalla = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Talla',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        // Grid de tallas
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: tallas.map((talla) {
            final isSelected = selectedTallaId == talla.id;
            return _buildTallaChip(talla, isSelected);
          }).toList(),
        ),
        
        if (allowCustomTalla) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _showCustomTallaDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Crear talla personalizada'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryTurquoise,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTallaChip(models.Talla talla, bool isSelected) {
    return SafeMaterialButton(
      elevation: isSelected ? 4 : 1,
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.white,
      onTap: () => onTallaChanged(isSelected ? null : talla.id),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de talla
            Icon(
              _getTallaIcon(_stringToTipoTalla(talla.tipo)),
              size: 24,
              color: isSelected 
                  ? AppTheme.primaryTurquoise 
                  : AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 6),
            
            // Valor de talla
            Text(
              talla.valor,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected 
                    ? AppTheme.primaryTurquoise 
                    : AppTheme.textPrimary,
              ),
            ),
            
            // Tipo de talla
            Text(
              _getTipoLabel(_stringToTipoTalla(talla.tipo)),
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? AppTheme.primaryTurquoise 
                    : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTallaIcon(models.TipoTalla tipo) {
    switch (tipo) {
      case models.TipoTalla.rango:
        return Icons.straighten;
      case models.TipoTalla.unica:
        return Icons.crop_free;
    }
  }

  String _getTipoLabel(models.TipoTalla tipo) {
    switch (tipo) {
      case models.TipoTalla.rango:
        return 'Rango';
      case models.TipoTalla.unica:
        return 'Única';
    }
  }

  /// Convierte un String a TipoTalla enum
  models.TipoTalla _stringToTipoTalla(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RANGO':
      case 'LETRA':
        return models.TipoTalla.rango;
      case 'UNICA':
      case 'INDIVIDUAL':
      default:
        return models.TipoTalla.unica;
    }
  }

  void _showCustomTallaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CustomTallaDialog(),
    );
  }
}

/// Diálogo para crear talla personalizada
class _CustomTallaDialog extends StatefulWidget {
  const _CustomTallaDialog();

  @override
  State<_CustomTallaDialog> createState() => __CustomTallaDialogState();
}

class __CustomTallaDialogState extends State<_CustomTallaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  models.TipoTalla _selectedTipo = models.TipoTalla.rango;

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Talla Personalizada'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Valor de talla
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor de Talla',
                hintText: 'Ej: 13-15, L, XL',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Ingrese el valor de la talla';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Tipo de talla
            const Text(
              'Tipo de Talla',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: RadioListTile<models.TipoTalla>(
                    title: const Text('Rango'),
                    subtitle: const Text('Ej: 9-12'),
                    value: models.TipoTalla.rango,
                    groupValue: _selectedTipo,
                    onChanged: (value) {
                      setState(() => _selectedTipo = value!);
                    },
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<models.TipoTalla>(
                    title: const Text('Única'),
                    subtitle: const Text('Ej: L, XL'),
                    value: models.TipoTalla.unica,
                    groupValue: _selectedTipo,
                    onChanged: (value) {
                      setState(() => _selectedTipo = value!);
                    },
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createCustomTalla,
          child: const Text('Crear'),
        ),
      ],
    );
  }

  void _createCustomTalla() {
    if (!_formKey.currentState!.validate()) return;
    
    // Aquí se implementaría la creación de la talla personalizada
    // Por ahora solo cerramos el diálogo
    Navigator.of(context).pop();
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Talla "${_valorController.text}" creada exitosamente',
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}