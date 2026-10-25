class Rol {
  final int idRol;
  final String nombreRol;

  Rol({required this.idRol, required this.nombreRol});

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['idRol'],
      nombreRol: json['nombreRol'] ?? '',
    );
  }
}