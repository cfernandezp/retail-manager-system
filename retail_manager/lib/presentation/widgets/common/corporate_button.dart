import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'shimmer_widget.dart';

class CorporateButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const CorporateButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Colores según el tipo de botón
    final Color bgColor = backgroundColor ?? 
      (isSecondary 
        ? Colors.transparent 
        : theme.primaryColor);
    
    final Color txtColor = textColor ?? 
      (isSecondary 
        ? theme.primaryColor 
        : Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: isSecondary ? 0 : 3,
          shadowColor: theme.primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Bordes menos redondeados
            side: isSecondary 
              ? BorderSide(color: theme.primaryColor, width: 2)
              : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.white.withOpacity(0.1);
            }
            if (states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.2);
            }
            return null;
          }),
        ),
        child: isLoading
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ShimmerWidget(
                    baseColor: txtColor.withOpacity(0.3),
                    highlightColor: txtColor.withOpacity(0.1),
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: txtColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: txtColor,
                    size: 22,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: txtColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}