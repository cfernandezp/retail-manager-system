import 'package:flutter/material.dart';

class CorporateFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const CorporateFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<CorporateFormField> createState() => _CorporateFormFieldState();
}

class _CorporateFormFieldState extends State<CorporateFormField> 
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _hasFocus = false;
  String? _errorText;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.grey[600],
      end: const Color(0xFF4ECDC4),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;
            });
            if (hasFocus) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            onChanged: (value) {
              // Validación en tiempo real
              if (widget.validator != null) {
                setState(() {
                  _errorText = widget.validator!(value);
                });
              }
              widget.onChanged?.call(value);
            },
            style: TextStyle(
              fontSize: 16,
              color: theme.brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: widget.label, // Etiqueta integrada en el borde
              hintText: widget.hintText,
              labelStyle: TextStyle(
                color: _hasFocus ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelStyle: TextStyle(
                color: const Color(0xFF6366F1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedBuilder(
                      animation: _colorAnimation,
                      builder: (context, child) {
                        return Icon(
                          widget.prefixIcon,
                          color: _colorAnimation.value ?? Colors.grey[600],
                        );
                      },
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: widget.enabled 
                ? (theme.brightness == Brightness.dark 
                    ? Colors.grey[800] 
                    : Colors.white)
                : const Color(0xFFF3F4F6), // Fondo más claro cuando está deshabilitado
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28), // Super redondeado
                borderSide: BorderSide(
                  color: const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: _errorText != null 
                    ? Colors.red[400]!
                    : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: _errorText != null 
                    ? Colors.red[400]!
                    : const Color(0xFF6366F1), // Azul/morado como en la imagen
                  width: 2.5, // Borde más grueso al enfocar
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: Colors.red[400]!,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: Colors.red[400]!,
                  width: 2.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.red[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}