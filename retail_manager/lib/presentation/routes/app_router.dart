import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/supabase_client.dart';
import '../pages/auth/auth_page.dart';
import '../pages/admin/user_management_page_optimized.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/pos/pos_page.dart';
import '../pages/products/products_page.dart';
import '../pages/products/create_product_page.dart';
import '../pages/products/product_detail_page.dart';
import '../pages/products/edit_product_page.dart';
import '../pages/products/colors_page.dart';
import '../pages/products/marcas_page.dart';
import '../pages/products/categorias_page.dart';
import '../pages/products/materiales_page.dart';
import '../pages/products/tallas_page.dart';
import '../pages/inventory/inventory_page.dart';
import '../pages/sales/sales_page.dart';
import '../pages/customers/customers_page.dart';
import '../pages/reports/reports_page.dart';
import '../pages/admin/admin_page.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/user_management/user_management_bloc.dart';
import '../bloc/products/products_bloc.dart';
import '../../data/repositories/products_repository_simple.dart';
import '../widgets/common/corporate_button.dart';
import '../widgets/navigation/adaptive_navigation_scaffold.dart';

class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String pos = '/pos';
  static const String products = '/products';
  static const String inventory = '/inventory';
  static const String sales = '/sales';
  static const String customers = '/customers';
  static const String reports = '/reports';
  static const String admin = '/admin';
  static const String userManagement = '/admin/users';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) {
      final isAuthenticated = SupabaseClientConfig.isAuthenticated;
      final isOnLoginPage = state.matchedLocation == login;

      // Si no está autenticado y no está en login, redirigir a login
      if (!isAuthenticated && !isOnLoginPage) {
        return login;
      }

      // Si está autenticado y está en login, redirigir a dashboard
      if (isAuthenticated && isOnLoginPage) {
        return dashboard;
      }

      // No redirigir
      return null;
    },

    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const AuthPage(),
      ),

      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: dashboard,
          pageTitle: 'Dashboard',
          child: const DashboardPage(),
        ),
      ),

      GoRoute(
        path: pos,
        name: 'pos',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: pos,
          pageTitle: 'Punto de Venta',
          child: const PosPage(),
        ),
      ),

      GoRoute(
        path: products,
        name: 'products',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: products,
          pageTitle: 'Productos',
          child: const ProductsPage(),
        ),
        routes: [
          // Crear producto
          GoRoute(
            path: 'create',
            name: 'create_product',
            builder: (context, state) => const CreateProductPage(),
          ),

          // Gestión de colores
          GoRoute(
            path: 'colors',
            name: 'colors',
            builder: (context, state) => AdaptiveNavigationScaffold(
              currentRoute: '$products/colors',
              pageTitle: 'Gestión de Colores',
              child: const ColorsPage(),
            ),
          ),

          // Gestión de marcas
          GoRoute(
            path: 'marcas',
            name: 'marcas',
            builder: (context, state) => AdaptiveNavigationScaffold(
              currentRoute: '$products/marcas',
              pageTitle: 'Gestión de Marcas',
              child: const MarcasPage(),
            ),
          ),

          // Gestión de categorías
          GoRoute(
            path: 'categorias',
            name: 'categorias',
            builder: (context, state) => AdaptiveNavigationScaffold(
              currentRoute: '$products/categorias',
              pageTitle: 'Gestión de Categorías',
              child: const CategoriasPage(),
            ),
          ),

          // Gestión de materiales
          GoRoute(
            path: 'materiales',
            name: 'materiales',
            builder: (context, state) => AdaptiveNavigationScaffold(
              currentRoute: '$products/materiales',
              pageTitle: 'Gestión de Materiales',
              child: const MaterialesPage(),
            ),
          ),

          // Gestión de tallas
          GoRoute(
            path: 'tallas',
            name: 'tallas',
            builder: (context, state) => AdaptiveNavigationScaffold(
              currentRoute: '$products/tallas',
              pageTitle: 'Gestión de Tallas',
              child: const TallasPage(),
            ),
          ),

          // Ver detalle de producto
          GoRoute(
            path: ':productId',
            name: 'product_detail',
            builder: (context, state) {
              final productId = state.pathParameters['productId']!;
              return BlocProvider(
                create: (context) => ProductsBloc(
                  repository: ProductsRepository(),
                ),
                child: ProductDetailPage(
                  productId: productId,
                ),
              );
            },
            routes: [
              // Editar producto
              GoRoute(
                path: 'edit',
                name: 'edit_product',
                builder: (context, state) {
                  final productId = state.pathParameters['productId']!;
                  return EditProductPage(productId: productId);
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: inventory,
        name: 'inventory',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: inventory,
          pageTitle: 'Inventario',
          child: const InventoryPage(),
        ),
      ),

      GoRoute(
        path: sales,
        name: 'sales',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: sales,
          pageTitle: 'Ventas',
          child: const SalesPage(),
        ),
      ),

      GoRoute(
        path: customers,
        name: 'customers',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: customers,
          pageTitle: 'Clientes',
          child: const CustomersPage(),
        ),
      ),

      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: reports,
          pageTitle: 'Reportes',
          child: const ReportsPage(),
        ),
      ),

      GoRoute(
        path: admin,
        name: 'admin',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: admin,
          pageTitle: 'Administración',
          child: const AdminPage(),
        ),
      ),

      GoRoute(
        path: userManagement,
        name: 'user_management',
        builder: (context, state) => AdaptiveNavigationScaffold(
          currentRoute: userManagement,
          pageTitle: 'Gestión de Usuarios',
          child: BlocProvider(
            create: (context) => UserManagementBloc(
              supabase: SupabaseClientConfig.client,
            ),
            child: const UserManagementPageOptimized(),
          ),
        ),
      ),
    ],
  );
}
