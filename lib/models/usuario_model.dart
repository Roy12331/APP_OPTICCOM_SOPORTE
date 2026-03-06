class Usuario {
  final int idUsuario;
  final String nombre;
  final String email;
  final String rol;
  final int totalTrabajos;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.email,
    required this.rol,
    this.totalTrabajos = 0,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'] ?? 0,
      nombre: json['nombre'] ?? 'Técnico Opticcom',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'Tecnico',
      totalTrabajos: json['total_trabajos'] ?? 0,
    );
  }
}
