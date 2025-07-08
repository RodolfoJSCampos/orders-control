import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              vm.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Olá, ${vm.user?.email ?? "usuário"}'),
      ),
    );
  }
}
