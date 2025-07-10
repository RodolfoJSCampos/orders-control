import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool isRailExtended = false;

  final List<NavigationRailDestination> destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: Text('Produtos'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: Text('Pedidos'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.contacts_outlined),
      selectedIcon: Icon(Icons.contacts),
      label: Text('Contatos'),
    ),
  ];

  final List<Widget> pages = const [
    Center(child: Text('Página Home')),
    Center(child: Text('Página Produtos')),
    Center(child: Text('Página Pedidos')),
    Center(child: Text('Página Contatos')),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Image(
            image: Image.asset('assets/images/icon.png').image,
          ),
        ),
        title: Padding(
          padding:
              isRailExtended
                  ? EdgeInsets.only(left: 95)
                  : EdgeInsets.only(left: 0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    isRailExtended
                        ? Icons.keyboard_arrow_left
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      isRailExtended = !isRailExtended;
                    });
                  },
                ),
              ),
              SearchBar(
                overlayColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onSecondary,
                ),
                side: WidgetStateProperty.all(
                  BorderSide(color: Colors.grey.shade600, width: 1),
                ),
                textStyle: WidgetStateProperty.all(
                  TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onSecondary,
                ),
                elevation: WidgetStateProperty.all(0),
                constraints: BoxConstraints(minHeight: 40, maxWidth: 500),
                hintText: "Pesquisar",
                trailing: [
                  IconButton(
                    icon: Icon(
                      Icons.tune_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {},
                  ),
                ],
                leading: Icon(Icons.search, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: NavigationRail(
                selectedIconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.primary,
                ),
                extended: isRailExtended,
                minExtendedWidth: 200,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                labelType:
                    isRailExtended
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                destinations: destinations,
              ),
            ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
