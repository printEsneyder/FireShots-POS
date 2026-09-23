import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireshots_pos/core/theme/app_theme.dart';
import 'package:fireshots_pos/core/routes/app_routes.dart';
import 'package:fireshots_pos/features/auth/presentation/login_screen.dart';
import 'package:fireshots_pos/features/menu/presentation/customer_menu_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/cart_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/checkout_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/staff_kds_screen.dart';
import 'package:fireshots_pos/features/cloakroom/presentation/cloakroom_form_screen.dart';
import 'package:fireshots_pos/features/cloakroom/presentation/cloakroom_receipt_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/cloakroom_list_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/external_debt_form_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/external_debt_list_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/customer_support_screen.dart';
import 'package:fireshots_pos/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:fireshots_pos/features/admin/presentation/admin_products_screen.dart';
import 'package:fireshots_pos/features/admin/presentation/admin_product_form_screen.dart';
import 'package:fireshots_pos/features/admin/presentation/admin_reports_screen.dart';
import 'package:fireshots_pos/features/admin/presentation/admin_settings_screen.dart';
import 'package:fireshots_pos/features/orders/presentation/sales_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyD7uv7fz3oZaG4N08MWpntGRwZX1fssbQg',
      appId: '1:100880869453:web:7224cd4f942027c07f1404',
      messagingSenderId: '100880869453',
      projectId: 'fireshots-pos',
      authDomain: 'fireshots-pos.firebaseapp.com',
      storageBucket: 'fireshots-pos.firebasestorage.app',
    ),
  );
  runApp(const ProviderScope(child: FireShotsApp()));
}

class FireShotsApp extends StatelessWidget {
  const FireShotsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireShots POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.customerMenu,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
          case AppRoutes.customerMenu:
            return MaterialPageRoute(
              builder: (_) => const CustomerMenuScreen(),
            );
          case AppRoutes.cart:
            return MaterialPageRoute(
              builder: (_) => const CartScreen(),
            );
          case AppRoutes.checkout:
            return MaterialPageRoute(
              builder: (_) => const CheckoutScreen(),
            );
          case AppRoutes.staffDashboard:
            return MaterialPageRoute(
              builder: (_) => const StaffKDSScreen(),
            );
          case AppRoutes.cloakroomForm:
            return MaterialPageRoute(
              builder: (_) => const CloakroomFormScreen(),
            );
          case AppRoutes.cloakroomReceipt:
            return MaterialPageRoute(
              builder: (_) => const CloakroomReceiptScreen(),
            );
          case AppRoutes.cloakroomList:
            return MaterialPageRoute(
              builder: (_) => const CloakroomListScreen(),
            );
          case AppRoutes.externalDebtForm:
            return MaterialPageRoute(
              builder: (_) => const ExternalDebtFormScreen(),
            );
          case AppRoutes.adminDebts:
            return MaterialPageRoute(
              builder: (_) => const ExternalDebtListScreen(),
            );
          case AppRoutes.customerSupport:
            return MaterialPageRoute(
              builder: (_) => const CustomerSupportScreen(),
            );
          case AppRoutes.adminDashboard:
            return MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen(),
            );
          case AppRoutes.adminProducts:
            return MaterialPageRoute(
              builder: (_) => const AdminProductsScreen(),
            );
          case AppRoutes.adminProductForm:
            return MaterialPageRoute(
              builder: (_) => const AdminProductFormScreen(),
            );
          case AppRoutes.adminReports:
            return MaterialPageRoute(
              builder: (_) => const AdminReportsScreen(),
            );
          case AppRoutes.adminSettings:
            return MaterialPageRoute(
              builder: (_) => const AdminSettingsScreen(),
            );
          case AppRoutes.sales:
            return MaterialPageRoute(
              builder: (_) => const SalesScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
        }
      },
    );
  }
}
