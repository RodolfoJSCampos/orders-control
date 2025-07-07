import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegisterMode = false;

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text(isRegisterMode ? 'Criar Conta' : 'Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (authVM.error != null)
                  Text(authVM.error!, style: TextStyle(color: Colors.red)),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'E-mail'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Senha'),
                ),
                const SizedBox(height: 20),
                authVM.isLoading
                    ? CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final email = emailController.text.trim();
                              final senha = passwordController.text.trim();

                              if (isRegisterMode) {
                                authVM.registerWithEmail(email, senha);
                              } else {
                                authVM.loginWithEmail(email, senha);
                              }
                            },
                            child: Text(isRegisterMode ? 'Cadastrar' : 'Entrar'),
                          ),
                          OutlinedButton(
                            onPressed: authVM.loginWithGoogle,
                            child: Text('Entrar com Google'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isRegisterMode = !isRegisterMode;
                              });
                            },
                            child: Text(isRegisterMode
                                ? 'Já tem uma conta? Entrar'
                                : 'Não tem conta? Cadastrar'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
