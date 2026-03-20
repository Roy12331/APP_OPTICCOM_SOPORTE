import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔹 NUEVO: Leer memoria al inicio

import 'screens/login_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/formulario_screen.dart';
import 'models/orden_model.dart';
import 'screens/main_container.dart';
import 'core/app_theme.dart';

// MANEJADOR DE SEGUNDO PLANO
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
    "🔔 Notificación recibida en segundo plano: ${message.notification?.title}",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 NUEVO: REVISAR LA MEMORIA DEL TELÉFONO ANTES DE ARRANCAR
  final prefs = await SharedPreferences.getInstance();
  final int? userId = prefs.getInt('userId');
  final String? userName = prefs.getString('userName');
  final String? userRol = prefs.getString('userRol');

  String rutaInicial = '/'; // Por defecto, va al Login
  Map<String, dynamic>? datosGuardados;

  // Si hay un ID guardado, significa que ya había iniciado sesión
  if (userId != null) {
    rutaInicial = '/home'; // Cambiamos la ruta directa al panel
    datosGuardados = {
      'id': userId,
      'nombre': userName ?? 'Técnico',
      'rol': userRol ?? 'Técnico',
    };
  }

  runApp(MyApp(rutaInicial: rutaInicial, datosGuardados: datosGuardados));
}

class MyApp extends StatefulWidget {
  final String rutaInicial;
  final Map<String, dynamic>? datosGuardados;

  const MyApp({super.key, required this.rutaInicial, this.datosGuardados});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _configurarNotificaciones();
    _inicializarRouter();
  }

  void _inicializarRouter() {
    _router = GoRouter(
      initialLocation: widget.rutaInicial,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            // Usa los datos que vengan de Login o los de la memoria
            final userData =
                state.extra as Map<String, dynamic>? ?? widget.datosGuardados!;
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
  }

  Future<void> _configurarNotificaciones() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permiso de notificaciones concedido.');
      String? token = await messaging.getToken();
      print('🚀 FCM TOKEN GENERADO: $token');
    } else {
      print('❌ Permiso de notificaciones denegado.');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        '🔔 Mensaje recibido con la app abierta: ${message.notification?.title}',
      );

      if (message.notification != null) {
        _mostrarAlertaLocal(
          message.notification!.title,
          message.notification!.body,
        );
      }
    });
  }

  void _mostrarAlertaLocal(String? titulo, String? cuerpo) {
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
