import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';

/// Diálogo de formulario para crear o editar marcas
class MarcaFormDialog extends StatefulWidget {
  final String title;
  final Marca? marca; // null para crear, Marca para editar
  final List<Marca> existingMarcas;

  const MarcaFormDialog({
    super.key,
    required this.title,
    this.marca,
    required this.existingMarcas,
  });

  @override
  State<MarcaFormDialog> createState() => _MarcaFormDialogState();
}

class _MarcaFormDialogState extends State<MarcaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final ProductsRepository _repository = ProductsRepository();

  bool _isLoading = false;
  bool _activa = true;

  @override
  void initState() {
    super.initState();

    if (widget.marca != null) {
      // Modo edición - cargar datos existentes
      _nombreController.text = widget.marca!.nombre;
      _descripcionController.text = widget.marca!.descripcion ?? '';
      _logoUrlController.text = widget.marca!.logoUrl ?? '';
      _activa = widget.marca!.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  String _generatePrefijoSku(String nombre) {
    // Generar prefijo SKU basado en el nombre
    final baseName = nombre.toLowerCase().replaceAll(' ', '');

    if (baseName.length >= 3) {
      return baseName.substring(0, 3).toUpperCase();
    } else if (baseName.length == 2) {
      return '${baseName.toUpperCase()}0';
    } else if (baseName.length == 1) {
      return '${baseName.toUpperCase()}00';
    }

    return 'MAR'; // Fallback
  }

  Future<void> _saveMarca() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nombre = _nombreController.text.trim();
      final descripcion = _descripcionController.text.trim();
      final logoUrl = _logoUrlController.text.trim();

      // Validar duplicados por nombre
      final isDuplicatedName = widget.existingMarcas.any(
        (m) => m.nombre.toLowerCase() == nombre.toLowerCase(),
      );

      if (isDuplicatedName) {
        _showErrorMessage('Ya existe una marca con ese nombre');
        return;
      }

      final marcaData = {
        'nombre': nombre,
        'descripcion': descripcion.isNotEmpty ? descripcion : null,
        'logo_url': logoUrl.isNotEmpty ? logoUrl : null,
        'activo': _activa,
        'prefijo_sku': _generatePrefijoSku(nombre),
      };

      Marca result;
      if (widget.marca != null) {
        // Actualizar marca existente
        result = await _repository.updateMarca(widget.marca!.id, marcaData);
      } else {
        // Crear nueva marca
        result = await _repository.createMarca(marcaData);
      }

      Navigator.of(context).pop(result);
    } catch (e) {
      String errorMessage = 'Error al guardar marca: ${e.toString()}';

      if (e.toString().contains('23505')) {
        if (e.toString().contains('marcas_nombre_key')) {
          errorMessage = 'Ya existe una marca con ese nombre';
        } else if (e.toString().contains('marcas_prefijo_sku_key')) {
          errorMessage = 'Ya existe una marca con ese prefijo SKU';
        } else {
          errorMessage = 'Ya existe una marca con esos datos';
        }
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
                    Icons.branding_watermark_outlined,
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
                      // Campo nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Marca *',
                          hintText: 'Ej: Nike, Adidas, Puma...',
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

                      // Campo descripción
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Descripción opcional de la marca...',
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value != null && value.trim().length > 500) {
                            return 'La descripción no puede exceder 500 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Campo logo URL
                      TextFormField(
                        controller: _logoUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL del Logo',
                          hintText: 'https://ejemplo.com/logo.png (opcional)',
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final uri = Uri.tryParse(value.trim());
                            if (uri == null || !uri.hasScheme) {
                              return 'URL inválida. Debe incluir http:// o https://';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Preview del prefijo SKU
                      if (_nombreController.text.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTurquoise.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryTurquoise.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prefijo SKU Generado:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _generatePrefijoSku(_nombreController.text),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTurquoise,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
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
                            _activa ? 'Marca activa' : 'Marca inactiva',
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
                    onPressed: _isLoading ? null : _saveMarca,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.marca != null ? 'Actualizar' : 'Crear'),
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