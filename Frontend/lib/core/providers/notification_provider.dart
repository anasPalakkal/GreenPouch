import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import '../services/notification_channel_service.dart';
import '../services/socket_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _isLoading = false;
  bool _fcmInitialized = false;

  NotificationProvider() {
    // Kick off socket init immediately when the provider is created (main.dart
    // MultiProvider creates it before any screen mounts).
    // Using Future.microtask so the constructor finishes before async work begins.
    Future.microtask(() {
      initializeSocketListeners();
    });
  }

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((n) => n["isRead"] == false).length;

  // ── 🔴 WEB-SOCKET SYNC ──────────────────────────────────────────────────
  /// Awaiting connectAndListen ensures _socket is non-null before the callback
  /// is registered — this eliminates the race condition that caused missed events.
  Future<void> initializeSocketListeners() async {
    await SocketService.connectAndListen((data) {
      if (data != null) {
        addRealTimeNotification(data);
      }
    });
  }

  Future<void> initializeFcm() async {
    try {
      final FirebaseMessaging fcm = FirebaseMessaging.instance;
      NotificationSettings settings = await fcm.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (!_fcmInitialized) {
          fcm.onTokenRefresh.listen((newToken) {
            NotificationService.updateFcmToken(newToken);
          });

          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            if (message.notification != null || message.data.isNotEmpty) {
              final Map<String, dynamic> mockEvent = {
                '_id': message.data['notificationId'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                'title': message.notification?.title ??
                    message.data['title'] ??
                    'New Notification',
                'message':
                    message.notification?.body ?? message.data['body'] ?? '',
                'category': message.data['category'] ?? 'FCM',
                'isRead': false,
              };
              addRealTimeNotification(mockEvent);
              // [PROD] Show local foreground push only when socket stream is inactive.
              if (!SocketService.isConnected) {
                NotificationChannelService.showForegroundNotification(
                  title: mockEvent['title']?.toString() ?? 'New Notification',
                  body: mockEvent['message']?.toString() ?? '',
                );
              }
            }
          });

          _fcmInitialized = true;
        }
      }
    } catch (e) {
      debugPrint("FCM init skipped or failed: $e");
    }
  }

  Future<void> registerFcmToken() async {
    try {
      final FirebaseMessaging fcm = FirebaseMessaging.instance;
      NotificationSettings settings = await fcm.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Add timeout to prevent hang on emulators without Google Play Services
        String? token = await fcm.getToken().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint("FCM getToken() timed out.");
            return null;
          },
        );
        if (token != null) {
          await NotificationService.updateFcmToken(token);
        }
      }
    } catch (e) {
      debugPrint("FCM token registration failed: $e");
    }
  }

  // 🔥 Handles the live injection and triggers the Red Dot instantly.
  // Uses JSON round-trip to safely flatten nested Map<dynamic,dynamic> and
  // ObjectId values that the socket_io_client sometimes delivers.
  void addRealTimeNotification(dynamic data) {
    try {
      debugPrint("🎯 DATA ARRIVED AT PHONE: $data");

      // JSON round-trip: handles Map<dynamic,dynamic>, ObjectId, and any
      // nested types that Map<String,dynamic>.from() would choke on.
      final String jsonStr = jsonEncode(data);
      final Map<String, dynamic> newNotif =
          Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);

      // Ensure isRead is present and set to false for unread-count accuracy
      newNotif.putIfAbsent('isRead', () => false);

      if (_notifications
          .any((n) => n['_id'] != null && n['_id'] == newNotif['_id'])) {
        debugPrint("⏳ Duplicate notification skipped based on _id.");
        return;
      }

      _notifications.insert(0, newNotif);
      notifyListeners();

      debugPrint(
          "✅ UI notified. Unread: $unreadCount, Total: ${notifications.length}");

      // Trigger Toastification
      final title = newNotif['title']?.toString() ?? 'New Notification';
      final message = newNotif['message']?.toString() ?? '';

      final titleStr = title.toLowerCase();

      Color themeColor = Colors.blueAccent; // Antigravity brand blue
      IconData iconData = Icons.notifications;

      if (titleStr.contains('income') || titleStr.contains('received')) {
        themeColor = Colors.green;
        iconData = Icons.arrow_downward;
      } else if (titleStr.contains('expense') || titleStr.contains('spent')) {
        themeColor = Colors.red;
        iconData = Icons.arrow_upward;
      }

      toastification.show(
        type: ToastificationType.info,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        description: message.isNotEmpty ? Text(message) : null,
        autoCloseDuration: const Duration(seconds: 4),
        style: ToastificationStyle.flat,
        alignment: Alignment.topCenter,
        primaryColor: themeColor,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: themeColor),
        ),
      );
    } catch (e, st) {
      debugPrint("❌ Error adding live notification: $e\n$st");
    }
  }

  // ── 🔵 REST API FETCH ───────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    _isLoading = true;
    _notifications = await NotificationService.fetchNotifications();
    _isLoading = false;
    notifyListeners();
  }

  // ── 🟢 ACTION: MARK AS READ ─────────────────────────────────────────────
  Future<void> markSingleAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n["_id"] == id);

    if (index != -1 && _notifications[index]["isRead"] == false) {
      _notifications[index]["isRead"] = true;
      notifyListeners();

      try {
        await NotificationService.markAsRead(id);
      } catch (e) {
        debugPrint("Error syncing read status: $e");
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i]["isRead"] = true;
    }
    notifyListeners();
    await NotificationService.markAllAsRead();
  }

  // ── 🟠 ACTION: DELETE ───────────────────────────────────────────────────
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n["_id"] == id);
    notifyListeners();

    bool success = await NotificationService.deleteNotification(id);
    if (!success) {
      loadNotifications();
    }
  }

  Future<void> clearAllHistory() async {
    _notifications.clear();
    notifyListeners();
    await NotificationService.deleteAllNotifications();
  }
}
