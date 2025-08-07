import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _mostrarModal(BuildContext context) {
    final String email = 'rodolfojscampos@gmail.com';

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Solicitar Acesso'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para solicitar acesso ao sistema, envie um email para:',
                ),
                const SizedBox(height: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: email));
                    },
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro de Login'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authVM = context.read<AuthViewModel>();

    try {
      await authVM.loginWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'O formato do e-mail é inválido.';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'E-mail ou senha incorretos.';
          break;
        default:
          errorMessage = 'Ocorreu um erro. Tente novamente.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  Future<void> _loginWithGoogle() async {
    final authVM = context.read<AuthViewModel>();
    try {
      await authVM.loginWithGoogle();
    } on FirebaseAuthException {
      // O ViewModel já tratou os casos de cancelamento.
      // Qualquer exceção que chega aqui é um erro real a ser exibido.
      if (!mounted) return;
      _showErrorDialog('Ocorreu um erro durante o login com o Google.');
    } catch (e) {
      // Para qualquer outro erro inesperado.
      if (!mounted) return;
      _showErrorDialog('Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              height: 432,
              child: Card.outlined(
                elevation: 8,
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          spacing: 10,
                          children: [
                            Image(
                              color: Theme.of(context).colorScheme.primary,
                              image:
                                  Image.asset('assets/images/logo.png').image,
                              height: 50,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_passwordFocusNode);
                              },
                              validator:
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira seu e-mail';
                                    }
                                    return null;
                                  },
                            ),
                            TextFormField(
                              controller: passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              validator:
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira sua senha';
                                    }
                                    return null;
                                  },
                            ),
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, child) {
                                return authVM.isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      )
                                    : Column(
                                        children: [
                                          FilledButton(
                                            style: FilledButton.styleFrom(
                                              minimumSize: const Size(
                                                double.infinity,
                                                56,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  6,
                                                ),
                                              ),
                                            ),
                                            onPressed: _login,
                                            child: const Text(
                                              'Entrar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => _mostrarModal(context),
                                            child: const Text(
                                              'Não tem conta? Cadastre-se',
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          OutlinedButton.icon(
                                            onPressed: _loginWithGoogle,
                                            icon: Image.asset(
                                              'assets/images/google_logo.png',
                                              height: 20,
                                            ),
                                            label: const Text(
                                              'Continuar com Google',
                                              style: TextStyle(
                                                fontFamily: 'Roboto Medium',
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(0, 50),
                                            ),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
