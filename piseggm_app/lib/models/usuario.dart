import 'rol.dart';

class Usuario {
  final int idUsuario;
  final Rol? rol;
  final String tipoDocumento;
  final String documento;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;

  Usuario({
    required this.idUsuario,
    this.rol,
    required this.tipoDocumento,
    required this.documento,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      rol: json['rol'] != null ? Rol.fromJson(json['rol']) : null,
      tipoDocumento: json['tipoDocumento'] ?? '',
      documento: json['documento'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }
}