import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_nav_bar.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'reports_history_screen.dart';
import 'search_reports_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isAdmin = user?.email == 'admin@laundry.com';

    // Build the list of allowed screens dynamically
    final List<Map<String, dynamic>> navigationItems = [
      {
        'screen': const DashboardScreen(),
        'permission': user?.hasPermission('Reports', 'View') ?? false,
      },
      {
        'screen': const SearchReportsScreen(),
        'permission': user?.hasPermission('Forms', 'View') ?? false,
      },
      {
        'screen': const ReportsHistoryScreen(),
        'permission': user?.hasPermission('Forms', 'View') ?? false,
      },
      {
        'screen': const ProfileScreen(),
        'permission': user?.hasPermission('Profile', 'View') ?? false,
      },
    ];

    final List<Widget> allowedScreens = navigationItems
        .where((item) => item['permission'] == true)
        .map((item) => item['screen'] as Widget)
        .toList();

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedIndex < allowedScreens.length 
            ? allowedScreens[_selectedIndex] 
            : allowedScreens[0],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        user: user,
        isAdmin: isAdmin,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
