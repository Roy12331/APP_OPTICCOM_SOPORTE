import 'dart:io';

class ReporteTecnico {
  final int idOrden;
  final String tipoOrden;
  String? serieOnu;
  String? codigoNap;
  int? puertoNap;
  double potenciaOptica;
  int metrosCable;
  int conectoresUsados;
  String? solucionAplicada;
  String observaciones;
  File? fotoFachada;
  File? fotoEquipo;
  File? fotoPotencia;
  String? firmaBase64;
  String? latitud;
  String? longitud;
  ReporteTecnico({
    required this.idOrden,
    required this.tipoOrden,
    this.serieOnu,
    this.codigoNap,
    this.puertoNap,
    this.potenciaOptica = 0.0,
    this.metrosCable = 0,
    this.conectoresUsados = 0,
    this.solucionAplicada,
    this.observaciones = '',
  });
  Map<String, dynamic> toJson() {
    return {
      "id_orden": idOrden,
      "serie": serieOnu,
      "nap": codigoNap,
      "puerto": puertoNap,
      "potencia": potenciaOptica,
      "metros": metrosCable,
      "conectores": conectoresUsados,
      "solucion": solucionAplicada,
      "observaciones": observaciones,
      "lat": latitud,
      "lon": longitud,
      "firma": firmaBase64,
    };
  }
}
