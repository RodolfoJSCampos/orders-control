import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:whatsupply/viewmodels/auth_view_model.dart';
import 'package:whatsupply/viewmodels/navigation_rail_view_model.dart';
import 'package:whatsupply/viewmodels/navigation_view_model.dart';
import 'package:whatsupply/viewmodels/product_view_model.dart';
import 'package:whatsupply/viewmodels/contact_view_model.dart';
import 'package:whatsupply/viewmodels/brand_view_model.dart';
import 'package:whatsupply/viewmodels/category_view_model.dart';
import 'package:whatsupply/viewmodels/theme_view_model.dart';

import 'firebase_options.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthViewModel _authViewModel;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Cria o AuthViewModel uma vez.
    _authViewModel = AuthViewModel();
    // Cria o GoRouter uma vez, passando o ViewModel.
    _router = createRouter(_authViewModel);
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fornece a instância já criada do AuthViewModel.
        ChangeNotifierProvider.value(value: _authViewModel),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationRailViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => BrandViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
      ],
      // O Consumer agora só precisa observar o ThemeViewModel para o tema.
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp.router(
            title: 'WhatSupply',
            theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1C835B), brightness: Brightness.light)),
            darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1C835B), brightness: Brightness.dark)),
            themeMode: themeVM.themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}