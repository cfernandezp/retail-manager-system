import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// BottomNavigationBar para mobile (<768px)
/// Implementación básica placeholder
class MobileBottomNavigation extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const MobileBottomNavigation({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: AppTheme.primaryColor,
      child: const Center(
        child: Text(
          'Mobile Bottom Navigation (Placeholder)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}