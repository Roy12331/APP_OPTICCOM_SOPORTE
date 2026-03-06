import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orden_model.dart';

class HistorialService {
  static const String baseUrl = 'https://opticcomperu.com/api';

  static Future<List<OrdenTrabajo>> getHistorial(int idTecnico) async {
    try {
      // OJO: Asegúrate de tener este archivo en tu servidor, o usa get_mis_ordenes.php si ese trae todo
      final response = await http.get(
        Uri.parse('$baseUrl/get_historial.php?id_tecnico=$idTecnico'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((e) => OrdenTrabajo.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo historial: $e");
      return [];
    }
  }
}
