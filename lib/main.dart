import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laundry_app/core/theme/app_theme.dart';
import 'package:laundry_app/providers/auth_provider.dart';
import 'package:laundry_app/providers/company_provider.dart';
import 'package:laundry_app/providers/forms_provider.dart';
import 'package:laundry_app/providers/catalog_provider.dart';
import 'package:laundry_app/providers/roles_provider.dart';
import 'package:laundry_app/services/socket_service.dart';
import 'package:laundry_app/screens/login_screen.dart';
import 'package:laundry_app/screens/main_layout.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => FormsProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => RolesProvider()),
        ChangeNotifierProvider(create: (_) => SocketService()),
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _wasAuthenticated;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    
    if (auth.isAuthenticated && _wasAuthenticated != true) {
      _wasAuthenticated = true;
      context.read<SocketService>().connect();
    } else if (!auth.isAuthenticated && _wasAuthenticated == true) {
      _wasAuthenticated = false;
      context.read<SocketService>().disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated) {
      return const MainLayout();
    }
    
    return const LoginScreen();
  }
}
