import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login com email e senha
  Future<User?> loginWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Cadastro de novo usuário com email e senha
  Future<User?> registerWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Login com Google (suporte total ao Flutter Web)
  Future<User?> loginWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();

      final result = await _auth.signInWithPopup(googleProvider);

      return result.user;
    } catch (e) {
      throw Exception("Erro no login com Google: $e");
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
