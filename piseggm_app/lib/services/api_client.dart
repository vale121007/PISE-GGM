import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'sesion.dart';

class ApiClient {
  static String get base =>
      "http://${ApiService.servidor}:${ApiService.puerto}/api";

  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${Sesion.token}",
      };

  static Future<dynamic> get(String ruta) =>
      _enviar(() => http.get(Uri.parse("$base$ruta"), headers: _headers));

  static Future<dynamic> post(String ruta, Map<String, dynamic> body) =>
      _enviar(() => http.post(Uri.parse("$base$ruta"),
          headers: _headers, body: jsonEncode(body)));

  static Future<dynamic> put(String ruta, [Map<String, dynamic>? body]) =>
      _enviar(() => http.put(Uri.parse("$base$ruta"),
          headers: _headers, body: body == null ? null : jsonEncode(body)));

  static Future<dynamic> delete(String ruta) =>
      _enviar(() => http.delete(Uri.parse("$base$ruta"), headers: _headers));

  static Future<dynamic> _enviar(
      Future<http.Response> Function() peticion) async {
    try {
      final r = await peticion().timeout(const Duration(seconds: 15));

      if (r.statusCode < 200 || r.statusCode >= 300) {
        var mensaje = "El servidor respondió con estado ${r.statusCode}";
        try {
          final datos = jsonDecode(utf8.decode(r.bodyBytes));
          if (datos is Map && datos['message'] != null) {
            mensaje = datos['message'].toString();
          }
        } catch (_) {}
        throw Exception(mensaje);
      }

      if (r.bodyBytes.isEmpty) return null;
      final texto = utf8.decode(r.bodyBytes);
      try {
        return jsonDecode(texto);
      } catch (_) {
        return texto;
      }
    } on TimeoutException {
      throw Exception(
          "El servidor tardó demasiado. Revisa el WiFi y que el backend esté encendido.");
    } on http.ClientException {
      throw Exception(
          "No se pudo conectar con el servidor. Revisa el WiFi y que el backend esté encendido.");
    }
  }
}