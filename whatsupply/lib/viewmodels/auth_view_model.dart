import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.loginWithEmail(email, password);
      _error = null;
    } catch (e) {
      _error = 'Erro ao fazer login: ${e.toString()}';
    }
    _setLoading(false);
  }

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authService.loginWithGoogle();
      _error = null;
    } catch (e) {
      _error = 'Erro ao fazer login com Google: ${e.toString()}';
    }
    _setLoading(false);
  }

  Future<void> registerWithEmail(String email, String password) async {
  _setLoading(true);
  try {
    _user = await _authService.registerWithEmail(email, password);
    _error = null;
  } catch (e) {
    _error = 'Erro ao cadastrar: ${e.toString()}';
  }
  _setLoading(false);
  }

  void logout() {
    _authService.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
