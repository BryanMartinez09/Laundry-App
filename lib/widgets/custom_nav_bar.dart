import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import '../models/user_model.dart';
import '../core/theme/app_theme.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final User? user;
  final bool isAdmin;
  final Function(int) onTabChange;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    this.user,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<GButton> tabs = [
      GButton(
        icon: LineIcons.home,
        text: 'Home',
      ),
      if (user?.hasPermission('Reports', 'View') ?? false)
        GButton(
          icon: LineIcons.fileInvoice,
          text: 'Reports',
        ),
      if (user?.hasPermission('Reports', 'View') ?? false)
        GButton(
          icon: LineIcons.search,
          text: 'Search',
        ),
      if (user?.hasPermission('Profile', 'View') ?? false)
        GButton(
          icon: LineIcons.user,
          text: 'Profile',
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: AppTheme.primaryColor,
            color: AppTheme.primaryColor,
            tabs: tabs,
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}
