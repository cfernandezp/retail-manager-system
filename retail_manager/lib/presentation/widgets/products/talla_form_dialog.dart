import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_models.dart';
import '../../../data/repositories/products_repository_simple.dart';

/// Diálogo de formulario para crear o editar tallas
class TallaFormDialog extends StatefulWidget {
  final String title;
  final Talla? talla; // null para crear, Talla para editar
  final List<Talla> existingTallas;

  const TallaFormDialog({
    super.key,
    required this.title,
    this.talla,
    required this.existingTallas,
  });

  @override
  State<TallaFormDialog> createState() => _TallaFormDialogState();
}

class _TallaFormDialogState extends State<TallaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _valorController = TextEditingController();
  final _nombreController = TextEditingController();
  final ProductsRepository _repository = ProductsRepository();

  bool _isLoading = false;
  bool _activo = true;
  String _tipo = 'ROPA';
  int _ordenDisplay = 0;

  final List<String> _tiposDisponibles = ['ROPA', 'CALZADO', 'ACCESORIOS', 'INDIVIDUAL'];

  @override
  void initState() {
    super.initState();

    if (widget.talla != null) {
      // Modo edición - cargar datos existentes
      _codigoController.text = widget.talla!.codigo;
      _valorController.text = widget.talla!.valor;
      _nombreController.text = widget.talla!.nombre ?? '';
      _tipo = widget.talla!.tipo;
      _ordenDisplay = widget.talla!.ordenDisplay ?? 0;
      _activo = widget.talla!.activo;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _valorController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  String _generateCodigo(String valor) {
    // Generar código basado en el valor
    final baseValue = valor.toUpperCase().replaceAll(' ', '');

    if (baseValue.length >= 2) {
      return baseValue.substring(0, 2);
    } else if (baseValue.length == 1) {
      return baseValue;
    }

    return 'T'; // Fallback
  }

  Future<void> _saveTalla() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final codigo = _codigoController.text.trim();
      final valor = _valorController.text.trim();
      final nombre = _nombreController.text.trim();

      // Validar duplicados por código
      final isDuplicatedCode = widget.existingTallas.any(
        (t) => t.codigo.toLowerCase() == codigo.toLowerCase(),
      );

      if (isDuplicatedCode) {
        _showErrorMessage('Ya existe una talla con ese código');
        return;
      }

      // Validar duplicados por valor
      final isDuplicatedValue = widget.existingTallas.any(
        (t) => t.valor.toLowerCase() == valor.toLowerCase(),
      );

      if (isDuplicatedValue) {
        _showErrorMessage('Ya existe una talla con ese valor');
        return;
      }

      final tallaData = {
        'codigo': codigo,
        'valor': valor,
        'nombre': nombre.isNotEmpty ? nombre : null,
        'tipo': _tipo,
        'orden_display': _ordenDisplay,
        'activo': _activo,
      };

      Talla result;
      if (widget.talla != null) {
        // Actualizar talla existente
        result = await _repository.updateTalla(widget.talla!.id, tallaData);
      } else {
        // Crear nueva talla
        result = await _repository.createTalla(tallaData);
      }

      Navigator.of(context).pop(result);
    } catch (e) {
      String errorMessage = 'Error al guardar talla: ${e.toString()}';

      if (e.toString().contains('23505')) {
        if (e.toString().contains('tallas_codigo_key')) {
          errorMessage = 'Ya existe una talla con ese código';
        } else if (e.toString().contains('tallas_valor_key')) {
          errorMessage = 'Ya existe una talla con ese valor';
        } else {
          errorMessage = 'Ya existe una talla con esos datos';
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
                    Icons.straighten_outlined,
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
                      // Campo valor (principal)
                      TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(
                          labelText: 'Valor de la Talla *',
                          hintText: 'Ej: S, M, L, XL, 38, 40...',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El valor es requerido';
                          }
                          if (value.trim().length < 1) {
                            return 'El valor debe tener al menos 1 caracter';
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
                          labelText: 'Código de la Talla *',
                          hintText: 'Código único para identificación',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El código es requerido';
                          }
                          if (value.trim().length < 1) {
                            return 'El código debe tener al menos 1 caracter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Campo nombre (opcional)
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre Descriptivo',
                          hintText: 'Nombre opcional más descriptivo...',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value != null && value.trim().length > 100) {
                            return 'El nombre no puede exceder 100 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Dropdown tipo
                      DropdownButtonFormField<String>(
                        value: _tipo,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Talla *',
                          hintText: 'Selecciona el tipo',
                        ),
                        items: _tiposDisponibles.map((String tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(_getTipoDisplayName(tipo)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _tipo = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El tipo es requerido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Campo orden de visualización
                      TextFormField(
                        initialValue: _ordenDisplay.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Orden de Visualización',
                          hintText: 'Número para ordenar (0 = primero)',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          _ordenDisplay = int.tryParse(value) ?? 0;
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final num = int.tryParse(value);
                            if (num == null || num < 0) {
                              return 'Debe ser un número válido mayor o igual a 0';
                            }
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
                            _activo ? 'Talla activa' : 'Talla inactiva',
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
                    onPressed: _isLoading ? null : _saveTalla,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.talla != null ? 'Actualizar' : 'Crear'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTipoDisplayName(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROPA':
        return 'Ropa (S, M, L, XL...)';
      case 'CALZADO':
        return 'Calzado (36, 37, 38...)';
      case 'ACCESORIOS':
        return 'Accesorios';
      case 'INDIVIDUAL':
        return 'Talla Única';
      default:
        return tipo;
    }
  }
}