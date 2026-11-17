import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';

class MiCursoScreen extends StatefulWidget {
  const MiCursoScreen({super.key});

  @override
  State<MiCursoScreen> createState() => _MiCursoScreenState();
}

class _MiCursoScreenState extends State<MiCursoScreen> {
  bool _cargando = true;
  String? _error;
  String _curso = '';
  List<Map<String, dynamic>> _mias = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final est = await ApiClient.get('/reportes/estudiantes');
      final lista = est is List ? est : [];
      final idPerfil = t(Sesion.idPerfil);
      final email = (Sesion.usuario?.email ?? '').toLowerCase();

      Map? yo;
      for (final e in lista) {
        if (idPerfil.isNotEmpty && t(e['idEstudiante']) == idPerfil) {
          yo = e;
          break;
        }
      }
      if (yo == null && email.isNotEmpty) {
        for (final e in lista) {
          if (t(e['email']).toLowerCase() == email) {
            yo = e;
            break;
          }
        }
      }
      if (yo == null) throw Exception('No se encontró tu registro de estudiante.');

      _curso = t(yo['cursoActual']);
      final asig = await ApiClient.get('/reportes/asignaciones');
      final todas = asig is List ? asig : [];
      _mias = todas
          .whereType<Map>()
          .where((a) => t(a['curso'] ?? a['nombreCurso']) == _curso)
          .map((a) => Map<String, dynamic>.from(a))
          .toList();
      if (!mounted) return;
      setState(() => _cargando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = msgError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: 'Mi curso',
      child: CargaVista(
        cargando: _cargando,
        error: _error,
        reintentar: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.verde900,
                borderRadius: AppColors.hojaMedia,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURSO ACTUAL',
                      style: GoogleFonts.workSans(
                          color: AppColors.amarillo300,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(_curso.isEmpty ? 'Sin curso' : _curso,
                      style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_mias.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                    'Aún no hay asignaturas o dimensiones asignadas a tu curso.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
              ),
            ..._mias.map((a) {
              final asig = t(a['asignatura'] ?? a['nombreAsignatura']);
              final dim = t(a['dimension'] ?? a['nombreDimension']);
              final esAsig = asig.isNotEmpty && asig != 'No aplica';
              final docente =
                  t(a['docente'] ?? a['docenteNombre'] ?? a['nombreDocente']);
              return TarjetaHoja(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(esAsig ? asig : (dim.isEmpty ? '—' : dim),
                              style: GoogleFonts.workSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.tinta)),
                          const SizedBox(height: 2),
                          Text('Docente: ${docente.isEmpty ? '—' : docente}',
                              style: GoogleFonts.workSans(
                                  fontSize: 12.5,
                                  color: AppColors.tintaSuave)),
                        ],
                      ),
                    ),
                    Etiqueta(esAsig ? 'Asignatura' : 'Dimensión'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}