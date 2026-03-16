import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/login_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/formulario_screen.dart';
import 'models/orden_model.dart';
import 'screens/main_container.dart';
import 'core/app_theme.dart';

// 🔹 1. MANEJADOR DE SEGUNDO PLANO (Cuando la app está cerrada o minimizada)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializa Firebase para poder procesar el mensaje oculto
  await Firebase.initializeApp();
  print(
    "🔔 Notificación recibida en segundo plano: ${message.notification?.title}",
  );
}

void main() async {
  // 🔹 2. INICIALIZACIÓN OBLIGATORIA ANTES DE CORRER LA APP
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registramos el escuchador de segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/home',
      builder: (context, state) {
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

// 🔹 3. CONVERTIMOS A STATEFUL PARA CONFIGURAR FIREBASE AL INICIAR
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configurarNotificaciones();
  }

  // 🔹 4. CONFIGURACIÓN PRINCIPAL DE NOTIFICACIONES
  Future<void> _configurarNotificaciones() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Pedir permiso al usuario (Obligatorio en Android 13+ e iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permiso de notificaciones concedido.');

      // OBTENER EL TOKEN (El DNI del celular)
      String? token = await messaging.getToken();
      print('🚀 FCM TOKEN GENERADO: $token');

      // TODO: Más adelante, enviaremos este token a tu API de PHP al iniciar sesión
    } else {
      print('❌ Permiso de notificaciones denegado.');
    }

    // Escuchar mensajes cuando la app está ABIERTA (Primer plano)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        '🔔 Mensaje recibido con la app abierta: ${message.notification?.title}',
      );

      // Aquí el teléfono no suena por defecto porque estás usando la app,
      // así que mostramos un mensajito verde arriba (SnackBar)
      if (message.notification != null) {
        _mostrarAlertaLocal(
          message.notification!.title,
          message.notification!.body,
        );
      }
    });
  }

  void _mostrarAlertaLocal(String? titulo, String? cuerpo) {
    // Usamos un Key global o un ScaffoldMessenger para mostrar la alerta sin contexto
    // Por ahora, lo imprimiremos en consola, luego lo conectaremos visualmente.
    print("ALERTA VISUAL PARA EL TÉCNICO: $titulo - $cuerpo");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Opticcom App',
      theme: AppTheme.lightTheme,
    );
  }
}
