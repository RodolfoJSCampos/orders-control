import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/viewmodels/theme_view_model.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _mostrarModal(BuildContext context) {
    final String email = 'rodolfojscampos@gmail.com';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                    onTap: () {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      navigator.pop();

                      Clipboard.setData(ClipboardData(text: email)).then((_) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'E-mail copiado para a área de transferência.',
                            ),
                            duration: Duration(seconds: 3),
                            showCloseIcon: true,
                          ),
                        );
                      });
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final themeVM = context.watch<ThemeViewModel>();

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              height: 400,
              child: Card.outlined(
                elevation: 8,
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: 10,
                        children: [
                          Image(
                            color: Theme.of(context).colorScheme.primary,
                            image: Image.asset('assets/images/logo.png').image,
                            height: 50,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          authVM.isLoading
                              ? CircularProgressIndicator()
                              : Column(
                                children: [
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      minimumSize: Size(double.infinity, 56),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () {
                                      final email = emailController.text.trim();
                                      final senha =
                                          passwordController.text.trim();

                                      authVM.loginWithEmail(email, senha);
                                    },
                                    child: Text('Entrar'),
                                  ),
                                  TextButton(
                                    onPressed: () => _mostrarModal(context),
                                    child: Text('Não tem conta? Cadastrar'),
                                  ),
                                  SizedBox(height: 10),
                                  IconButton(
                                    onPressed: authVM.loginWithGoogle,
                                    icon:
                                        themeVM.themeMode == ThemeMode.dark
                                            ? Image.asset(
                                              'assets/images/continue_with_google_button_dark.png',
                                            )
                                            : Image.asset(
                                              'assets/images/continue_with_google_button.png',
                                            ),
                                  ),
                                ],
                              ),
                        ],
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
