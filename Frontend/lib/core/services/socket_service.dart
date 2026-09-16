import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:front_end/core/services/api_config.dart';
import 'auth_storage.dart';

/*
 // [PROD] Socket.IO handles foreground realtime updates; FCM handles background and terminated delivery.
*/
class SocketService {
  static IO.Socket? _socket;
  static Function(dynamic)? _onNotification;
  static bool _isConnecting = false;

  // [PROD] Expose socket state for FCM foreground fallback routing.
  static bool get isConnected => _socket?.connected == true;

  /// Single entry-point: connects (if needed) and registers the listener.
  static Future<void> connectAndListen(Function(dynamic) onNotification) async {
    _onNotification = onNotification;

    // ── If already connected, just (re-)register the listener and return ──
    if (_socket != null && _socket!.connected) {
      // [PROD] Clear duplicate listeners before re-registering.
      // [PROD] Clear stale handlers before re-binding notification listener.
      _socket!.clearListeners();
      _socket!.off('new_notification');
      _socket!.on('new_notification', (data) => _onNotification!(data));
      return;
    }

    // Prevent concurrent startup calls (like Splash + Provider constr) from killing each other
    if (_isConnecting) {
      return;
    }

    final token = await AuthStorage.getToken();
    if (token == null) {
      return;
    }

    _isConnecting = true;

    // Dispose stale socket before creating a new one
    _socket?.dispose();

    _socket = IO.io(
      ApiConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableForceNew()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(99)
          .setExtraHeaders({'Connection': 'upgrade', 'Upgrade': 'websocket'})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnecting = false;
      if (_onNotification != null) {
        // [PROD] Remove stale listeners to prevent duplicate notifications.
        // [PROD] Clear stale handlers before re-binding notification listener.
        _socket!.clearListeners();
        _socket!.off('new_notification');
        _socket!.on('new_notification', (data) => _onNotification!(data));
      }
    });

    _socket!.onDisconnect((_) {
      _isConnecting = false;
    });

    _socket!.onConnectError((e) {
      _isConnecting = false;
    });

    _socket!.onError((e) {
      _isConnecting = false;
    });

    // Now manually trigger connection since auto-connect is disabled
    _socket!.connect();
  }

  static void disconnect() {
    _isConnecting = false;
    _socket?.dispose();
    _socket = null;
    _onNotification = null;
  }
}
