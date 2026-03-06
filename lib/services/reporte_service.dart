import 'dart:convert';
import 'package:http/http.dart' as http;

class ReporteService {
  static const String baseUrl = 'https://opticcomperu.com/api';

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
      print("Error enviando reporte: $e");
      return {
        "success": false,
        "mensaje": "Error al enviar el reporte. Revise su conexión.",
      };
    }
  }
}
