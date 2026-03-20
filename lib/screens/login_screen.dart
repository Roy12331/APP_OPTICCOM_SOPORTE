import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 🔹 NUEVO: Para guardar sesión

import '../services/login_service.dart';
import '../core/app_theme.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _loading = true);

    final resp = await LoginService.login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _loading = false);
      if (resp['success'] == true) {
        final usuario = resp['usuario'];

        final int idUser = int.tryParse(usuario['id_usuario'].toString()) ?? 0;
        final String nombreUser = usuario['nombre'] ?? 'Usuario';
        final int idRol = int.tryParse(usuario['id_rol_fk'].toString()) ?? 3;

        // =====================================================================
        // 🔹 INICIO DEL BLOQUE FCM: Capturar y enviar Token a PHP
        // =====================================================================
        try {
          String? token = await FirebaseMessaging.instance.getToken();
          if (token != null && idUser > 0) {
            final url = Uri.parse(
              'https://opticcomperu.com/api/actualizar_token.php',
            );

            print("🚀 Intentando enviar Token a: $url");

            final response = await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'id_usuario': idUser, 'fcm_token': token}),
            );

            print(
              "📡 Código de respuesta del servidor: ${response.statusCode}",
            );
            print("📡 Respuesta del servidor: ${response.body}");
          }
        } catch (e) {
          print("⚠️ Error CRÍTICO enviando token al servidor: $e");
        }
        // =====================================================================
        // 🔹 FIN DEL BLOQUE FCM
        // =====================================================================

        // Leemos el Rol desde la BD
        String nombreRol = "Técnico";
        if (idRol == 1) nombreRol = "Administrador";
        if (idRol == 2) nombreRol = "Ventas";

        // 🔹 NUEVO: GUARDAR SESIÓN EN EL TELÉFONO
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', idUser);
        await prefs.setString('userName', nombreUser);
        await prefs.setString('userRol', nombreRol);

        // Enviamos Nombre, ID y Rol al Home
        if (mounted) {
          context.go(
            '/home',
            extra: {'id': idUser, 'nombre': nombreUser, 'rol': nombreRol},
          );
        }
      } else {
        // Mostrar error si las credenciales son incorrectas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Credenciales incorrectas"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary, // Fondo Azul Profundo
      body: Column(
        children: [
          // CABECERA AZUL (35% de la pantalla)
          SafeArea(
            bottom: false,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.30,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.wifi_tethering,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "OPTICCOM",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    "Plataforma de Técnicos",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // FORMULARIO BLANCO (Resto de la pantalla)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Iniciar Sesión",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Ingresa tus credenciales para continuar",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 35),
                    _inputModerno(
                      controller: _emailCtrl,
                      hint: "Correo Corporativo",
                      icon: Icons.email_outlined,
                      isPass: false,
                    ),
                    const SizedBox(height: 20),
                    _inputModerno(
                      controller: _passCtrl,
                      hint: "Contraseña",
                      icon: Icons.lock_outline,
                      isPass: true,
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: "INGRESAR",
                      isLoading: _loading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "Opticcom S.A.C © 2026",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputModerno({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPass,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        keyboardType: isPass ? TextInputType.text : TextInputType.emailAddress,
        style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: AppTheme.primary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 15,
          ),
        ),
      ),
    );
  }
}
