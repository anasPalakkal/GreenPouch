import 'package:flutter/material.dart';
import '../services/auth_storage.dart';

class UserProfileProvider extends ChangeNotifier {

  String name = "";
  String email = "";
  String mobile = "";

  /// LOAD USER FROM SECURE STORAGE
  Future<void> loadUser() async {
    name = await AuthStorage.getName() ?? "";
    email = await AuthStorage.getEmail() ?? "";

    notifyListeners();
  }

  /// SET USER AFTER LOGIN / SIGNUP
  void setUser({
    required String userName,
    required String userEmail,
    String userMobile = "",
  }) {
    name = userName;
    email = userEmail;

    notifyListeners();
  }

  /// UPDATE PROFILE FROM EDIT SCREEN
  void updateProfile({
    String? newName,
    String? newMobile,
  }) {
    if (newName != null) name = newName;
    if (newMobile != null) mobile = newMobile;

    notifyListeners();
  }

  /// CLEAR USER ON LOGOUT
  void clearUser() {
    name = "";
    email = "";
    mobile = "";

    notifyListeners();
  }
}