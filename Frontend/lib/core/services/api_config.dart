import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // 1. Production URL
  static const String _prodUrl = "https://walletcare-backend.onrender.com";

  // 2. Localhost Logic
  static String get _localUrl {
    if (kIsWeb) return "http://localhost:5000"; 
    
    if (Platform.isAndroid) {
      // ⚠️ EMULATOR: Use "http://10.0.2.2:5000"
      // ✅ PHYSICAL DEVICE: Use your computer's IPv4 address below!
     return "http://192.168.29.122:5000";
    }
    
    return "http://localhost:5000"; // iOS Simulator
  }

  // 3. Environment Switch
  static String get baseUrl => kDebugMode ? _localUrl : _prodUrl;
  static String get socketUrl => kDebugMode ? _localUrl : _prodUrl;
}