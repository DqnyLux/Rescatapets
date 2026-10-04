import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';

/// Clave global del navegador para que go_router pueda operar
/// sin depender de un BuildContext específico.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router principal de la aplicación.
///
/// Redirige automáticamente:
/// - Si NO hay sesión activa → /login
/// - Si hay sesión activa y el usuario está en /login o /registro → /
final routerProvider = Provider<GoRouter>((ref) {
  final sesion = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final estaLogueado = sesion != null;
      final enPantallaAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/registro';

      // Sin sesión y fuera de login/registro → mandar a login
      if (!estaLogueado && !enPantallaAuth) return '/login';

      // Con sesión pero en pantalla de auth → mandar al feed
      if (estaLogueado && enPantallaAuth) return '/';

      return null; // dejar pasar
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/registro',
        builder: (context, state) => const RegistroScreen(),
      ),
    ],
  );
});
