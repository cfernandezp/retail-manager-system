import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales para retail - Turquesa moderno
  static const Color primaryTurquoise = Color(0xFF4ECDC4);  // Turquesa principal
  static const Color primaryLight = Color(0xFF7DEDE8);
  static const Color primaryDark = Color(0xFF26A69A);
  static const Color primaryColor = primaryTurquoise; // Alias para compatibilidad
  static const Color secondaryColor = Color(0xFF45B7AA); // Color secundario
  static const Color accentColor = Color(0xFF96E6B3); // Color de acento
  
  // Colores para UI moderna
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Colores de superficie
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF495057);
  static const Color textSecondaryColor = Color(0xFF6C757D);

  // Colores para tema oscuro
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkOnSurfaceColor = Color(0xFFE0E0E0);

  // Breakpoints responsive específicos del cliente
  static const double mobileBreakpoint = 768;    // Mobile: < 768px
  static const double tabletBreakpoint = 1200;   // Tablet: 768px - 1200px  
  static const double desktopBreakpoint = 1200;  // Desktop: ≥ 1200px
  
  // Breakpoints adicionales para transiciones suaves
  static const double mobileLargeBreakpoint = 480;  // Mobile large: 480px - 767px
  static const double tabletLargeBreakpoint = 1024; // Tablet large: 1024px - 1199px
  
  // Tema claro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: primaryTurquoise,
      primaryContainer: primaryLight,
      secondary: successColor,
      error: errorColor,
      surface: cardWhite,
      background: backgroundLight,
    ),
    
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 2,
      backgroundColor: primaryTurquoise,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTurquoise,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: cardColor,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryTurquoise, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryDark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    ),
  );
  
  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: primaryTurquoise,
      secondary: successColor,
      error: errorColor,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
    ),
    
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 2,
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );

  // Helper methods para responsive design específico del cliente
  static bool isMobile(double width) => width < mobileBreakpoint;
  static bool isMobileLarge(double width) => width >= mobileLargeBreakpoint && width < mobileBreakpoint;
  static bool isTablet(double width) => width >= mobileBreakpoint && width < desktopBreakpoint;
  static bool isTabletLarge(double width) => width >= tabletLargeBreakpoint && width < desktopBreakpoint;
  static bool isDesktop(double width) => width >= desktopBreakpoint;
  
  // Platform-specific helpers
  static PlatformType getPlatformType(double width) {
    if (width >= desktopBreakpoint) return PlatformType.desktop;
    if (width >= mobileBreakpoint) return PlatformType.tablet;
    return PlatformType.mobile;
  }
  
  static int getCrossAxisCount(double width) {
    if (isMobile(width)) return 1;
    if (isTablet(width)) return 2;
    return 3; // Desktop - grid de 3 columnas
  }
  
  // Navigation-specific helpers
  static NavigationType getNavigationType(double width) {
    if (isDesktop(width)) return NavigationType.sidebar;
    if (isTablet(width)) return NavigationType.rail;
    return NavigationType.drawer;
  }
  
  // Layout configuration helpers
  static bool shouldShowSidebarByDefault(double width) => isDesktop(width);
  static bool shouldUseBottomNavigation(double width) => isMobile(width);
  static bool shouldUseMultiPanel(double width) => isDesktop(width);
  static bool shouldUseSwipeGestures(double width) => !isDesktop(width);
}

// Enums para mejor type safety
enum PlatformType { mobile, tablet, desktop }
enum NavigationType { drawer, rail, sidebar }
enum LayoutMode { single, dual, multi }