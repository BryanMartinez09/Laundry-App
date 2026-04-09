import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laundry_app/core/theme/app_theme.dart';
import 'package:laundry_app/providers/auth_provider.dart';
import 'package:laundry_app/providers/company_provider.dart';
import 'package:laundry_app/providers/forms_provider.dart';
import 'package:laundry_app/providers/catalog_provider.dart';
import 'package:laundry_app/screens/login_screen.dart';
import 'package:laundry_app/screens/main_layout.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => FormsProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    // Si está autenticado, mostramos la Home (que crearemos luego)
    // Por ahora, si no está autenticado, mostramos el Login
    if (auth.isAuthenticated) {
      return const MainLayout();
    }
    
    return const LoginScreen();
  }
}
