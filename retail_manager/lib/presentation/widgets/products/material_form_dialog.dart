import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart' show MaterialModel;
import '../../../data/repositories/products_repository_simple.dart';

/// Diálogo de formulario para crear o editar materiales
class MaterialFormDialog extends StatefulWidget {
  final String title;
  final MaterialModel? material; // null para crear, MaterialModel para editar
  final List<MaterialModel> existingMateriales;

  const MaterialFormDialog({
    super.key,
    required this.title,
    this.material,
    required this.existingMateriales,
  });

  @override
  State<MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends State<MaterialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoController = TextEditingController();
  final ProductsRepository _repository = ProductsRepository();

  bool _isLoading = false;
  bool _activo = true;

  @override
  void initState() {
    super.initState();

    if (widget.material != null) {
      // Modo edición - cargar datos existentes
      _nombreController.text = widget.material!.nombre;
      _descripcionController.text = widget.material!.descripcion ?? '';
      _codigoController.text = widget.material!.codigo ?? '';
      _activo = widget.material!.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  String _generateCodigo(String nombre) {
    // Generar código basado en el nombre
    final baseName = nombre.toLowerCase().replaceAll(' ', '');

    if (baseName.length >= 3) {
      return baseName.substring(0, 3).toUpperCase();
    } else if (baseName.length == 2) {
      return '${baseName.toUpperCase()}0';
    } else if (baseName.length == 1) {
      return '${baseName.toUpperCase()}00';
    }

    return 'MAT'; // Fallback
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nombre = _nombreController.text.trim();
      final descripcion = _descripcionController.text.trim();
      final codigo = _codigoController.text.trim().isNotEmpty
          ? _codigoController.text.trim()
          : _generateCodigo(nombre);

      // Validar duplicados por nombre
      final isDuplicatedName = widget.existingMateriales.any(
        (m) => m.nombre.toLowerCase() == nombre.toLowerCase(),
      );

      if (isDuplicatedName) {
        _showErrorMessage('Ya existe un material con ese nombre');
        return;
      }

      // Validar duplicados por código si se especifica
      if (codigo.isNotEmpty) {
        final isDuplicatedCode = widget.existingMateriales.any(
          (m) => m.codigo?.toLowerCase() == codigo.toLowerCase(),
        );

        if (isDuplicatedCode) {
          _showErrorMessage('Ya existe un material con ese código');
          return;
        }
      }

      final materialData = {
        'nombre': nombre,
        'descripcion': descripcion.isNotEmpty ? descripcion : null,
        'codigo': codigo.isNotEmpty ? codigo : null,
        'activo': _activo,
      };

      MaterialModel result;
      if (widget.material != null) {
        // Actualizar material existente
        result = await _repository.updateMaterial(widget.material!.id, materialData);
      } else {
        // Crear nuevo material
        result = await _repository.createMaterial(materialData);
      }

      Navigator.of(context).pop(result);
    } catch (e) {
      String errorMessage = 'Error al guardar material: ${e.toString()}';

      if (e.toString().contains('23505')) {
        if (e.toString().contains('materiales_nombre_key')) {
          errorMessage = 'Ya existe un material con ese nombre';
        } else if (e.toString().contains('materiales_codigo_key')) {
          errorMessage = 'Ya existe un material con ese código';
        } else {
          errorMessage = 'Ya existe un material con esos datos';
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
                    Icons.fiber_manual_record_outlined,
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
                          labelText: 'Nombre del Material *',
                          hintText: 'Ej: Algodón, Poliéster, Lino...',
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
                        onChanged: (value) {
                          // Auto-generar código si está vacío
                          if (_codigoController.text.isEmpty && value.isNotEmpty) {
                            setState(() {
                              _codigoController.text = _generateCodigo(value);
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Campo código
                      TextFormField(
                        controller: _codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Código del Material',
                          hintText: 'Código único (opcional)',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                            return 'El código debe tener al menos 2 caracteres';
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
                          hintText: 'Descripción opcional del material...',
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
                            _activo ? 'Material activo' : 'Material inactivo',
                            style: TextStyle(
                              fontSize: 16,
                              color: _activo
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
                    onPressed: _isLoading ? null : _saveMaterial,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.material != null ? 'Actualizar' : 'Crear'),
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