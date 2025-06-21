import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  bool _isAdmin = false;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _isAdmin;

  Future<void> login(String email, String password) async {
    final data = await ApiService.login(email: email, password: password);
    _token = data['authorisation']['token'];
    ApiService.setToken(_token!);

    final user = data['user'];
    _isAdmin = user['is_admin'] ?? false;

    notifyListeners();
  }

  void logout() {
    _token = null;
    _isAdmin = false;
    ApiService.clearToken();
    notifyListeners();
  }

  Future<void> register({
    required String username,
    required String fName,
    required String lName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await ApiService.post('/register', {
      'username': username,
      'FName': fName,
      'LName': lName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    _token = data['authorisation']['token'];
    ApiService.setToken(_token!);

    final user = data['user'];
    _isAdmin = user['is_admin'] ?? false;

    notifyListeners();
  }
}
