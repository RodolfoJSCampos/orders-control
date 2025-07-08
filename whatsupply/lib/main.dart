import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/firebase_options.dart';
import 'routes/app_router.dart';
import 'viewmodels/auth_view_model.dart';

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
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Builder(
        builder: (context) {
          final authVM = Provider.of<AuthViewModel>(context, listen: false);
          final router = createRouter(authVM);

          return MaterialApp.router(
            title: 'WhatSupply',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1C835B),
                brightness: Brightness.light,
              ),
            ),
          );
        },
      ),
    );
  }
}
