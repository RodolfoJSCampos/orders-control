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

  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  AuthViewModel() {
    // Observa mudanças no estado de autenticação
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners(); // Isso vai acionar o GoRouter
    });
  }

  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.loginWithEmail(email, password);
      _error = null;
    } on FirebaseAuthException catch (e) {
      // Se o usuário cancelou o login, não tratamos como um erro que precisa ser exibido.
      // Apenas interrompemos o processo. O 'finally' cuidará do estado de loading.
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        return; // Sai silenciosamente, sem propagar erro.
      }
      // Para outros erros reais do Firebase, propagamos para a UI.
      _error = 'Erro ao fazer login com Google: ${e.toString()}';
      rethrow;
    } catch (e) {
      _error = 'Erro ao fazer login: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.loginWithGoogle();
      _error = null;
    } on FirebaseAuthException catch (e) {
      // Se o usuário cancelou o login, não tratamos como um erro que precisa ser exibido.
      // Apenas interrompemos o processo. O 'finally' cuidará do estado de loading.
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        return; // Sai silenciosamente, sem propagar erro.
      }
      // Para outros erros reais do Firebase, propagamos para a UI.
      _error = 'Erro ao fazer login com Google: ${e.toString()}';
      rethrow;
    } catch (e) {
      _error = 'Erro ao fazer login com Google: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    // _user será atualizado automaticamente via authStateChanges
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}