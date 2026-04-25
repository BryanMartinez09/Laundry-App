import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laundry_app/core/api/api_client.dart';

class SocketService extends ChangeNotifier {
  IO.Socket? _socket;
  
  // Notification state
  int _unreadCount = 0;
  List<Map<String, dynamic>> _notifications = [];

  int get unreadCount => _unreadCount;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isConnected => _socket?.connected ?? false;
  IO.Socket? get socket => _socket;

  static String get _baseUrl => ApiClient.baseUrl;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) {
      debugPrint('[Socket] No token found, skipping connection.');
      return;
    }

    if (_socket != null && _socket!.connected) {
      debugPrint('[Socket] Already connected.');
      return;
    }

    _socket = IO.io(_baseUrl, IO.OptionBuilder()
      .setTransports(['websocket', 'polling'])
      .setAuth({'token': token})
      .disableAutoConnect()
      .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected: ${_socket!.id}');
      notifyListeners();
    });

    _socket!.onConnectError((data) {
      debugPrint('[Socket] Connection error: $data');
      notifyListeners();
    });

    _socket!.on('notification', (data) {
      debugPrint('[Socket] Notification received: $data');
      final notification = Map<String, dynamic>.from(data);
      _notifications.insert(0, notification);
      _unreadCount++;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected');
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    debugPrint('[Socket] Disconnected and cleaned up');
  }

  void clearUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}
