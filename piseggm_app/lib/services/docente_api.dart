import 'api_client.dart';
import 'sesion.dart';

List<dynamic> _lista(dynamic r) => r is List ? r : <dynamic>[];

bool _hay(dynamic x) =>
    x != null && x.toString().trim().isNotEmpty && x.toString() != 'No aplica';

String etiquetaAsignacion(Map a) {
  final asig = _hay(a['asignatura']) ? a['asignatura'] : null;
  final dim = _hay(a['dimension']) ? a['dimension'] : null;
  final nombre = asig ?? dim ?? '—';
  final extra = (asig != null && dim != null) ? ' ($dim)' : '';
  return '${a['grado']} ${a['anio']} — $nombre$extra';
}

String anioDe(Map p) {
  if (p['anio'] != null) return '${p['anio']}';
  final f = '${p['fechaInicio'] ?? ''}';
  return f.length >= 4 ? f.substring(0, 4) : 'Sin año';
}

class DocenteApi {
  static int get _id => Sesion.usuario!.idUsuario;
  static String get _b => '/docente/$_id';
  static String get _bb => '/docente-boletin/$_id';

  static Future<List<dynamic>> asignaciones() async =>
      _lista(await ApiClient.get('$_b/asignaciones'));

  static Future<List<dynamic>> estudiantes(int idAsignacion) async =>
      _lista(await ApiClient.get('$_b/asignaciones/$idAsignacion/estudiantes'));

  static Future<List<dynamic>> periodos() async =>
      _lista(await ApiClient.get('$_b/periodos'));

  static Future<List<dynamic>> estudiantesConNota(
          int idAsignacion, int idPeriodo) async =>
      _lista(await ApiClient.get(
          '$_bb/asignaciones/$idAsignacion/estudiantes?periodo=$idPeriodo'));

  static Future<void> subirNota({
    required int idAsignacion,
    required int idPeriodo,
    required int idMatricula,
    required String promedio,
    required String descripcion,
  }) async {
    await ApiClient.post('$_bb/notas', {
      'idAsignacion': idAsignacion,
      'idPeriodo': idPeriodo,
      'idMatricula': idMatricula,
      'promedio': promedio,
      'descripcion': descripcion,
    });
  }

  static Future<void> eliminarNota(int idNota) async {
    await ApiClient.delete('$_bb/notas/$idNota');
  }

  static Future<void> guardarDescripcion(int idPeriodo, String d) async {
    await ApiClient.put('$_b/periodos/$idPeriodo', {'descripcion': d});
  }
}