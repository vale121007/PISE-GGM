import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../widgets/pantalla_base.dart';
import 'reporte_screen.dart';

Future<List<Map<String, dynamic>>> _lista(String ruta) async {
  final r = await ApiClient.get(ruta);
  if (r is! List) return [];
  return r.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

String _nombreCompleto(Map d) => '${t(d['nombre'])} ${t(d['apellido'])}'.trim();

String _desempeno(dynamic p) {
  final s = t(p);
  final d = desempenoDe(s);
  if (d.isNotEmpty) return d;
  return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

String _docenteDe(Map x) {
  if (t(x['docenteNombre']).isNotEmpty) return t(x['docenteNombre']);
  final d = x['docente'];
  if (d is Map) {
    final u = d['usuario'] is Map ? d['usuario'] as Map : d;
    return _nombreCompleto(u);
  }
  return t(d);
}

String _documentoDocenteDe(Map a) {
  for (final k in [
    'docenteDocumento',
    'documentoDocente',
    'docenteNumeroDocumento',
    'numeroDocumentoDocente',
    'docenteCedula',
    'documento',
    'numeroDocumento',
  ]) {
    if (t(a[k]).isNotEmpty) return t(a[k]);
  }
  return '';
}

// ---------------- Docentes ----------------
class ReporteDocentes extends StatelessWidget {
  const ReporteDocentes({super.key});
  @override
  Widget build(BuildContext context) => ReporteScreen(
        titulo: 'Docentes',
        icono: Icons.work,
        cargar: () async => (await _lista('/reportes/docentes'))
            .map((d) => ItemVista(
                  _nombreCompleto(d),
                  etiquetas: [if (t(d['especialidad']).isNotEmpty) t(d['especialidad'])],
                  lineas: lineasDe([
                    campo('Documento', d['numeroDocumento']),
                    campo('Teléfono', d['telefono']),
                    campo('Correo', d['email']),
                  ]),
                ))
            .toList(),
      );
}

// ---------------- Estudiantes ----------------
class ReporteEstudiantes extends StatelessWidget {
  const ReporteEstudiantes({super.key});
  @override
  Widget build(BuildContext context) => ReporteScreen(
        titulo: 'Estudiantes',
        icono: Icons.school,
        cargar: () async => (await _lista('/reportes/estudiantes'))
            .map((e) => ItemVista(
                  _nombreCompleto(e),
                  etiquetas: [if (t(e['cursoActual']).isNotEmpty) t(e['cursoActual'])],
                  lineas: lineasDe([
                    campo(t(e['tipoDocumento']).isEmpty ? 'Documento' : t(e['tipoDocumento']),
                        e['numeroDocumento']),
                    campo('Teléfono', e['telefono']),
                    campo('Correo', e['email']),
                  ]),
                ))
            .toList(),
      );
}

// ---------------- Acudientes ----------------
class ReporteAcudientes extends StatelessWidget {
  const ReporteAcudientes({super.key});
  @override
  Widget build(BuildContext context) => ReporteScreen(
        titulo: 'Acudientes',
        icono: Icons.groups,
        cargar: () async => (await _lista('/reportes/acudientes')).map((a) {
          final cargo = a['estudiantesACargo'];
          final nombres = cargo is List
              ? cargo.map((x) => t(x)).where((x) => x.isNotEmpty).join(', ')
              : '';
          return ItemVista(
            _nombreCompleto(a),
            etiquetas: [if (t(a['parentesco']).isNotEmpty) t(a['parentesco'])],
            lineas: lineasDe([
              campo('Documento', a['numeroDocumento']),
              campo('Teléfono', a['telefono']),
              campo('Correo', a['email']),
              nombres.isEmpty ? null : 'A cargo: $nombres',
            ]),
          );
        }).toList(),
      );
}

// ---------------- Cursos ----------------
class ReporteCursos extends StatelessWidget {
  const ReporteCursos({super.key});
  @override
  Widget build(BuildContext context) => ReporteScreen(
        titulo: 'Cursos',
        icono: Icons.account_tree,
        cargar: () async => (await _lista('/reportes/cursos'))
            .map((c) => ItemVista(
                  'Curso ${t(c['grado'])}',
                  etiquetas: [if (t(c['anio']).isNotEmpty) 'Año ${t(c['anio'])}'],
                  lineas: c.entries
                      .where((e) =>
                          !['idCurso', 'grado', 'anio'].contains(e.key) &&
                          e.value != null &&
                          e.value is! Map &&
                          e.value is! List &&
                          e.value.toString().isNotEmpty)
                      .map((e) => '${e.key}: ${e.value}')
                      .toList(),
                ))
            .toList(),
      );
}

// ---------------- Asignaturas y dimensiones ----------------
class ReporteAsignaturas extends StatelessWidget {
  const ReporteAsignaturas({super.key});
  @override
  Widget build(BuildContext context) => ReporteScreen(
        titulo: 'Asignaturas y dimensiones',
        icono: Icons.menu_book,
        cargar: () async {
          final asig = await _lista('/reportes/asignaturas');
          List<Map<String, dynamic>> dims = [];
          try {
            dims = await _lista('/reportes/dimensiones');
          } catch (_) {}
          return [
            ...asig.map((a) => ItemVista(
                  t(a['nombreAsignatura']),
                  etiquetas: const ['Asignatura'],
                  lineas: lineasDe([
                    campo('Horas semanales', a['horasSemanales']),
                    campo('Docente', _docenteDe(a)),
                  ]),
                )),
            ...dims.map((d) => ItemVista(
                  t(d['nombreDimension'] ?? d['nombre'] ?? d['dimension']),
                  etiquetas: const ['Dimensión'],
                  lineas: lineasDe([
                    campo('Horas semanales', d['horasSemanales']),
                    campo('Docente', _docenteDe(d)),
                  ]),
                )),
          ];
        },
      );
}

// ---------------- Asignaciones ----------------
class ReporteAsignaciones extends StatelessWidget {
  const ReporteAsignaciones({super.key});
  @override
  Widget build(BuildContext context) => ReporteScreen(
        titulo: 'Asignaciones',
        icono: Icons.assignment_ind,
        cargar: () async => (await _lista('/reportes/asignaciones')).map((a) {
          final asig = t(a['asignatura']);
          final dim = t(a['dimension']);
          final nombre = (asig.isNotEmpty && asig != 'No aplica')
              ? asig
              : (dim.isEmpty ? '—' : dim);
          return ItemVista(
            nombre,
            etiquetas: [if (t(a['curso']).isNotEmpty) t(a['curso'])],
            lineas: lineasDe([
              campo('Docente', a['docenteNombre']),
              campo('Documento docente', _documentoDocenteDe(a)),
              campo('Observación', a['observacion']),
            ]),
          );
        }).toList(),
      );
}

// ---------------- Notas ----------------
class ReporteNotas extends StatelessWidget {
  const ReporteNotas({super.key});
  @override
  Widget build(BuildContext context) => ReporteScreen(
        titulo: 'Notas',
        icono: Icons.assessment,
        cargar: () async => (await _lista('/reportes/notas')).map((n) {
          final des = _desempeno(n['promedio']);
          return ItemVista(
            t(n['estudianteNombre']),
            etiquetas: [
              if (t(n['curso']).isNotEmpty) t(n['curso']),
              if (des.isNotEmpty) des,
            ],
            lineas: lineasDe([
              campo('Documento', n['numeroDocumentoEstudiante']),
              campo('Asignatura', n['asignatura']),
              campo('Docente', n['docenteNombre']),
              campo('Periodo', n['periodo']),
              campo('Fecha', n['fechaRegistro']),
            ]),
          );
        }).toList(),
      );
}