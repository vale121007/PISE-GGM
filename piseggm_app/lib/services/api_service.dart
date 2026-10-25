import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class LoginResult {
  final Usuario usuario;
  final String token;
  final dynamic idPerfil;

  LoginResult({
    required this.usuario,
    required this.token,
    required this.idPerfil,
  });
}

class ApiService {
  // IP de tu PC en la red WiFi (la ves con "ipconfig", campo "Dirección IPv4").
  // Cámbiala solo aquí, es el único lugar donde se usa.
  static const String servidor = "192.168.137.43";
  static const String puerto = "8081";

  static const String baseUrl = "http://$servidor:$puerto/api/auth";

  static Future<LoginResult> login(
      String documento, String password, String rol) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "documento": documento,
              "password": password,
              "rol": rol,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginResult(
          usuario: Usuario.fromJson(data['usuario']),
          token: data['token'] ?? '',
          idPerfil: data['idPerfil'],
        );
      } else {
        throw Exception(data['error'] ?? "Error al iniciar sesión");
      }
    } on TimeoutException {
      throw Exception(
          "No se pudo conectar con el servidor. Verifica que estés en el mismo WiFi y que el backend esté encendido.");
    } on http.ClientException {
      throw Exception(
          "No se pudo conectar con el servidor. Verifica el WiFi y que el backend esté encendido.");
    }
  }
}