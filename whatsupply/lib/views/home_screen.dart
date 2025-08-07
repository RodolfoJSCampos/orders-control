import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/viewmodels/auth_view_model.dart';
import 'package:whatsupply/viewmodels/navigation_rail_view_model.dart';
import 'package:whatsupply/viewmodels/navigation_view_model.dart';
import 'package:whatsupply/viewmodels/theme_view_model.dart';
import 'package:whatsupply/views/home_page.dart';

import 'contatos_page.dart';
import 'pedidos_page.dart';
import 'produtos_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isRailExtended = false;

  final List<NavigationRailDestination> destinations = [
    NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 5),
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 5),
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: Text('Produtos'),
    ),
    NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 5),
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: Text('Pedidos'),
    ),
    NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 5),
      icon: Icon(Icons.contacts_outlined),
      selectedIcon: Icon(Icons.contacts),
      label: Text('Contatos'),
    ),
  ];

  final List<Widget> pages = [
    HomePage(),
    ProdutosPage(),
    PedidosPage(),
    ContatosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navVM = context.watch<NavigationViewModel>();
    final bool isWide = MediaQuery.of(context).size.width >= 600;
    final railVM = context.watch<NavigationRailViewModel>();
    final isRailExtended = railVM.isExtended;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Image.asset('assets/images/icon.png'),
        ),
        title: Padding(
          padding: isRailExtended ? EdgeInsets.only(left: 95) : EdgeInsets.zero,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isRailExtended
                      ? Icons.keyboard_arrow_left
                      : Icons.keyboard_arrow_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  context.read<NavigationRailViewModel>().toggle();
                },
              ),
              SearchBar(
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    width: 1,
                  ),
                ),
                textStyle: WidgetStateProperty.all(
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainer,
                ),
                elevation: WidgetStateProperty.all(0),
                constraints: BoxConstraints(minHeight: 40, maxWidth: 500),
                hintText: "Pesquisar",
                trailing: [
                  IconButton(
                    icon: Icon(
                      Icons.tune_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                ],
                leading: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              extended: isRailExtended,
              minExtendedWidth: 180,
              selectedIndex: navVM.selectedIndex,
              onDestinationSelected: navVM.setIndex,
              labelType:
                  isRailExtended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
              destinations: destinations,
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          onPressed: () {
                            context.read<ThemeViewModel>().toggleTheme();
                          },
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          tooltip: 'Sair',
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            context.read<AuthViewModel>().logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: pages[navVM.selectedIndex]),
        ],
      ),
    );
  }
}
