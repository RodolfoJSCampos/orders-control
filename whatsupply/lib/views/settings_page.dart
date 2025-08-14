import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:whatsupply/viewmodels/auth_view_model.dart';
import 'package:whatsupply/viewmodels/theme_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return ListView(
              children: [
                ListTile(
                  leading: Icon(themeViewModel.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Tema'),
                  trailing: Switch(
                    value: themeViewModel.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeViewModel.toggleTheme();
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.branding_watermark),
                  title: const Text('Gerenciar Marcas'),
                  onTap: () {
                    context.go('/home/settings/brands');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Gerenciar Categorias'),
                  onTap: () {
                    context.go('/home/settings/categories');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Sobre'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Página Sobre ainda não implementada.')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sair'),
                  onTap: () {
                    authViewModel.logout();
                  },
                ),
              ],
            );
          } else {
            // Tablet/Desktop layout (single column of cards)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center( // Center the column of cards
                child: ConstrainedBox( // Apply max width to the column of cards
                  constraints: const BoxConstraints(maxWidth: 600.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Appearance Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aparência',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(themeViewModel.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                                title: const Text('Tema'),
                                trailing: Switch(
                                  value: themeViewModel.themeMode == ThemeMode.dark,
                                  onChanged: (value) {
                                    themeViewModel.toggleTheme();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0), // Spacing between cards
                      // Data Management Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gerenciamento de Dados',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.branding_watermark),
                                title: const Text('Gerenciar Marcas'),
                                onTap: () {
                                  context.go('/home/settings/brands');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.category),
                                title: const Text('Gerenciar Categorias'),
                                onTap: () {
                                  context.go('/home/settings/categories');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0), // Spacing between cards
                      // About & Account Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Geral',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text('Sobre'),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Página Sobre ainda não implementada.')),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text('Sair'),
                                onTap: () {
                                  authViewModel.logout();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
