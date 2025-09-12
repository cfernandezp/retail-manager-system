import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/network/supabase_client.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/products/products_bloc.dart';
import 'data/repositories/products_repository_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();
  
  // Inicializar Supabase
  await SupabaseClientConfig.initialize();
  
  runApp(const RetailManagerApp());
}

class RetailManagerApp extends StatelessWidget {
  const RetailManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            supabase: SupabaseClientConfig.client,
            dio: Dio(),
          ),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<ProductsBloc>(
          create: (context) => ProductsBloc(
            repository: ProductsRepository(),
          ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Navegar automáticamente cuando el estado de auth cambie
          if (state is AuthUnauthenticated) {
            // Asegurar que la navegación se ejecute después del build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (AppRouter.router.routeInformationProvider.value.uri.path != '/login') {
                AppRouter.router.go('/login');
              }
            });
          }
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final themeMode = themeState is ThemeLoaded
                ? themeState.themeMode
                : ThemeMode.light;
            
            return MaterialApp.router(
              title: AppConstants.appName,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
          
              // Configuración de rutas
              routerConfig: AppRouter.router,
              
              // Configuración de localización
              locale: const Locale('es', 'PE'),
              
              // Remover banner de debug
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}