import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../core/theme/app_theme.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool isExpanded;
  final bool showLabel;
  
  const ThemeToggleButton({
    super.key,
    this.isExpanded = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;
        
        if (isExpanded && showLabel) {
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppTheme.primaryTurquoise,
                size: 24,
              ),
              title: Text(
                isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isDarkMode,
                  onChanged: (_) => _toggleTheme(context),
                  activeColor: AppTheme.primaryTurquoise,
                  activeTrackColor: AppTheme.primaryTurquoise.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
              onTap: () => _toggleTheme(context),
            ),
          );
        }
        
        // Compact version (for collapsed sidebar or minimal display)
        return Tooltip(
          message: isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? AppTheme.primaryTurquoise.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode 
                    ? AppTheme.primaryTurquoise.withOpacity(0.3)
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _toggleTheme(context),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      key: ValueKey(isDarkMode),
                      color: AppTheme.primaryTurquoise,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _toggleTheme(BuildContext context) {
    context.read<ThemeBloc>().add(ToggleTheme());
  }
}