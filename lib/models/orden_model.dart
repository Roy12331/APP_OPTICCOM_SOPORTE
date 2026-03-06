class OrdenTrabajo {
  final int idOrden;
  final String cliente;
  final String tipoTrabajo;
  final String distrito;
  final String estado;
  final String? fecha;

  // 🔹 NUEVOS CAMPOS AGREGADOS PARA EL DETALLE PREMIUM
  final String? telefono;
  final String? direccion;
  final String? referencia;
  final String? coordenadas;

  OrdenTrabajo({
    required this.idOrden,
    required this.cliente,
    required this.tipoTrabajo,
    required this.distrito,
    required this.estado,
    this.fecha,
    this.telefono,
    this.direccion,
    this.referencia,
    this.coordenadas,
  });

  factory OrdenTrabajo.fromJson(Map<String, dynamic> json) {
    return OrdenTrabajo(
      idOrden: int.tryParse(json['id_orden'].toString()) ?? 0,
      cliente: json['cliente'] ?? 'Cliente Desconocido',
      tipoTrabajo: json['tipo_trabajo'] ?? 'Desconocido',
      distrito: json['distrito'] ?? 'Sin distrito',
      estado: json['estado_orden'] ?? 'Pendiente',
      fecha: json['fecha_programada'] ?? json['fecha'],

      // 🔹 MAPEAMOS LOS DATOS NUEVOS (Manejamos nulos por si acaso)
      telefono: json['telefono']?.toString(),
      direccion:
          json['direccion_calle']?.toString() ?? json['direccion']?.toString(),
      referencia: json['referencia']?.toString(),
      coordenadas:
          json['location_link']?.toString() ?? json['coordenadas']?.toString(),
    );
  }
}
