import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/formulario_screen.dart';
import 'models/orden_model.dart';
import 'screens/main_container.dart';
import 'core/app_theme.dart'; // 🔹 Importamos el sistema de diseño

void main() => runApp(const MyApp());

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        // Salvavidas temporal por si reinicias el emulador de golpe
        final userData =
            state.extra as Map<String, dynamic>? ??
            {'id': 1, 'nombre': 'Juan Perez', 'rol': 'Técnico'};

        return MainContainer(userData: userData);
      },
    ),
    GoRoute(
      path: '/detalle',
      builder: (context, state) {
        final orden = state.extra as OrdenTrabajo;
        return DetalleScreen(orden: orden);
      },
    ),
    GoRoute(
      path: '/formulario',
      builder: (context, state) {
        final orden = state.extra as OrdenTrabajo;
        return FormularioScreen(orden: orden);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Opticcom App',
      theme: AppTheme.lightTheme, // 🔹 AQUÍ CONECTAMOS LA MAGIA VISUAL
    );
  }
}
