import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String baseUrl = 'https://opticcomperu.com/api';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {"Content-Type": "application/json"},
        // 🔹 Restauramos el json.encode que necesita tu PHP
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        "success": false,
        "mensaje": "Error del servidor: ${response.statusCode}",
      };
    } catch (e) {
      print("🚨 ERROR CRÍTICO LOGIN: $e");
      return {
        "success": false,
        "mensaje": "Error de conexión. Verifique su internet.",
      };
    }
  }
}
