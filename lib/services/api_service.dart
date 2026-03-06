import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orden_model.dart';

class ApiService {
  // ---------------------------------------------------------
  // ✅ TU DOMINIO REAL CONFIGURADO
  // ---------------------------------------------------------
  static const String baseUrl = 'https://opticcomperu.com/api';

  // 1. LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {"Content-Type": "application/json"},
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
      print("🚨 ERROR CRÍTICO: $e");
      return {
        "success": false,
        "mensaje": "Error de conexión. Verifique su internet.",
      };
    }
  }

  // 2. OBTENER ÓRDENES
  static Future<List<OrdenTrabajo>> getOrdenes(int idTecnico) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_mis_ordenes.php?id_tecnico=$idTecnico'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((e) => OrdenTrabajo.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo órdenes: $e");
      return [];
    }
  }

  // 3. ENVIAR REPORTE
  static Future<Map<String, dynamic>> enviarReporte(
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guardar_reporte.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(datos),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        "success": false,
        "mensaje": "Error servidor: ${response.statusCode}",
      };
    } catch (e) {
      return {"success": false, "mensaje": "Error al enviar: $e"};
    }
  }
}
