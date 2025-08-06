import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/viewmodels/auth_view_model.dart';
import 'package:whatsupply/viewmodels/navigation_rail_view_model.dart';
import 'package:whatsupply/viewmodels/navigatioon_view_model.dart';
import 'package:whatsupply/viewmodels/product_view_model.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationRailViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ],
      child: Consumer2<AuthViewModel, ThemeViewModel>(
        builder: (context, authVM, themeVM, _) {
          final router = createRouter(authVM);
          return MaterialApp.router(
            title: 'WhatSupply',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1C835B),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1C835B),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeVM.themeMode,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}