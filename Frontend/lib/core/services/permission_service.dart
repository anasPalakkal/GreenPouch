import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  /// -------------------------------
  /// Gallery Permission
  /// -------------------------------
  static Future<bool> requestGalleryPermission() async {

    // ✅ Desktop platforms → No runtime permission needed
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return true;
    }

    // ✅ Android 13+ and iOS
    Permission permission = Permission.photos;

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// -------------------------------
  /// Camera Permission
  /// -------------------------------
  static Future<bool> requestCameraPermission() async {

    // ✅ Desktop platforms → No runtime permission needed
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return true;
    }

    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }
}