import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/orden_model.dart';

class OrdenService {
  static const String baseUrl = 'https://opticcomperu.com/api';

  static Future<List<OrdenTrabajo>> getOrdenes(int idTecnico) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_mis_ordenes.php?id_tecnico=$idTecnico'),
      );

      if (response.statusCode == 200) {
        // 🔹 AQUÍ ESTABA EL ERROR: Tu PHP devuelve una lista directa, no un mapa con "data"
        final List<dynamic> body = json.decode(response.body);
        return body.map((e) => OrdenTrabajo.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo órdenes: $e");
      return [];
    }
  }
}
