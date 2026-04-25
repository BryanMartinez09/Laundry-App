import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_nav_bar.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'reports_history_screen.dart';
import 'search_reports_screen.dart';
import 'profile_screen.dart';
import '../services/socket_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _lastConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socket = context.read<SocketService>();
      _lastConnected = socket.isConnected;
      socket.addListener(_onSocketChange);
      
      // Setup listeners if already connected
      if (socket.isConnected) {
        _setupSocketListeners(socket);
      }
    });
  }

  @override
  void dispose() {
    // Es importante remover el listener para evitar fugas de memoria
    context.read<SocketService>().removeListener(_onSocketChange);
    super.dispose();
  }

  void _onSocketChange() {
    if (!mounted) return;
    final socketService = context.read<SocketService>();
    
    // Si pasamos de desconectado a conectado (reinicio del server), refrescamos permisos
    if (socketService.isConnected && !_lastConnected) {
      debugPrint('[MainLayout] Server re-connected, refreshing permissions...');
      context.read<AuthProvider>().fetchProfile();
      
      // Re-vincular eventos al reconectar
      _setupSocketListeners(socketService);
    }
    _lastConnected = socketService.isConnected;
  }

  void _setupSocketListeners(SocketService socketService) {
    final s = socketService.socket;
    if (s == null) return;

    s.off('reload_permissions');
    s.on('reload_permissions', (_) {
      debugPrint('[MainLayout] Permissions updated via socket, refreshing...');
      context.read<AuthProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isAdmin = user?.email == 'admin@laundry.com';

    // Build the list of allowed screens dynamically
    final List<Map<String, dynamic>> navigationItems = [
      {
        'title': 'Dashboard',
        'screen': const DashboardScreen(),
        'permission': user?.hasPermission('Forms', 'View') ?? false,
      },
      {
        'title': 'Advanced Search',
        'screen': const SearchReportsScreen(),
        'permission': user?.hasPermission('Reports', 'View') ?? false,
      },
      {
        'title': 'Reports History',
        'screen': const ReportsHistoryScreen(),
        'permission': user?.hasPermission('Forms', 'View') ?? false,
      },
      {
        'title': 'My Profile',
        'screen': const ProfileScreen(),
        'permission': user?.hasPermission('Profile', 'View') ?? false,
      },
    ];

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentItem = navigationItems[_selectedIndex];
    final bool hasPermission = currentItem['permission'] as bool;
    final currentTitle = currentItem['title'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          _buildNotificationButton(context, context.watch<SocketService>()),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: hasPermission 
            ? currentItem['screen'] as Widget
            : _buildAccessDeniedView(currentTitle),
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

  Widget _buildAccessDeniedView(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_person_outlined, size: 80, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            Text(
              'Access Restricted',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 12),
            Text(
              'You do not have the required permissions to view the section: "$title".',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'Please contact your administrator to request access.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, SocketService socketService) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showNotificationTray(context, socketService),
        ),
        if (socketService.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '${socketService.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationTray(BuildContext context, SocketService socketService) {
    socketService.clearUnreadCount();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final notifications = socketService.notifications;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      socketService.clearAll();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const Divider(),
              if (notifications.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (ctx, idx) {
                      final notif = notifications[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.pending_actions, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif['title'] ?? 'Notification',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(notif['message'] ?? '',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            }, 
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
