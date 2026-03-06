class Cliente {
  final int idCliente;
  final String nombreCompleto;
  final String dni;
  final String correo;
  final String telefono;
  final String estadoServicio;

  Cliente({
    required this.idCliente,
    required this.nombreCompleto,
    required this.dni,
    required this.correo,
    required this.telefono,
    required this.estadoServicio,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'] ?? 0,
      nombreCompleto: "${json['nombre']} ${json['apellido']}",
      dni: json['dni'] ?? 'Sin DNI',
      correo: json['email'] ?? 'Sin correo',
      telefono: json['telefono'] ?? 'Sin teléfono',
      estadoServicio: json['estado_servicio'] ?? 'Desconocido',
    );
  }
}
