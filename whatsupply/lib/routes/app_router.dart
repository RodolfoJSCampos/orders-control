import 'package:go_router/go_router.dart';

import '../viewmodels/auth_view_model.dart';
import '../views/login_screen.dart';
import '../views/home_screen.dart';

GoRouter createRouter(AuthViewModel authVM) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authVM, // escuta mudanças no estado
    redirect: (context, state) {
      final isLoggedIn = authVM.user != null;
      final isOnLoginPage = state.uri.toString() == '/login';

      if (!isLoggedIn && !isOnLoginPage) return '/login';
      if (isLoggedIn && isOnLoginPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}
