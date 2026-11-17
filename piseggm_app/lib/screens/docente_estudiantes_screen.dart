import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/docente_api.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';

class DocenteEstudiantesScreen extends StatefulWidget {
  final int? idAsignacionInicial;
  const DocenteEstudiantesScreen({super.key, this.idAsignacionInicial});

  @override
  State<DocenteEstudiantesScreen> createState() =>
      _DocenteEstudiantesScreenState();
}

class _DocenteEstudiantesScreenState extends State<DocenteEstudiantesScreen> {
  List<dynamic> _asignaciones = [];
  List<dynamic> _estudiantes = [];
  int? _asigSel;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      _asignaciones = await DocenteApi.asignaciones();
      if (_asignaciones.isEmpty) {
        setState(() => _cargando = false);
        return;
      }
      final ini = widget.idAsignacionInicial;
      _asigSel = _asignaciones.any((a) => (a['idAsignacion'] as num).toInt() == ini)
          ? ini
          : (_asignaciones.first['idAsignacion'] as num).toInt();
      await _cargarEstudiantes();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = msgError(e);
      });
    }
  }

  Future<void> _cargarEstudiantes() async {
    setState(() => _cargando = true);
    try {
      final r = await DocenteApi.estudiantes(_asigSel!);
      if (!mounted) return;
      setState(() {
        _estudiantes = r;
        _cargando = false;
      });
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
      titulo: 'Mis estudiantes',
      child: CargaVista(
        cargando: _cargando && _asignaciones.isEmpty,
        error: _error,
        reintentar: _iniciar,
        child: _asignaciones.isEmpty
            ? Center(
                child: Text('Aún no tienes asignaciones.',
                    style: GoogleFonts.workSans(color: AppColors.tintaSuave)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SelectorCampo<int>(
                    etiqueta: 'Curso / asignatura',
                    valor: _asigSel,
                    items: _asignaciones
                        .map((a) => DropdownMenuItem<int>(
                              value: (a['idAsignacion'] as num).toInt(),
                              child: Text(etiquetaAsignacion(a),
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) {
                      _asigSel = v;
                      _cargarEstudiantes();
                    },
                  ),
                  if (_cargando)
                    const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.verde700)))
                  else if (_estudiantes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Este curso no tiene estudiantes matriculados.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(
                              color: AppColors.tintaSuave)),
                    )
                  else
                    ..._estudiantes.map((e) => TarjetaHoja(
                          child: Row(
                            children: [
                              const Icon(Icons.school, color: AppColors.verde700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t(e['nombre']),
                                        style: GoogleFonts.workSans(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.tinta)),
                                    Text(
                                        'Documento: ${t(e['documento']).isEmpty ? '—' : t(e['documento'])}',
                                        style: GoogleFonts.workSans(
                                            fontSize: 12.5,
                                            color: AppColors.tintaSuave)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
      ),
    );
  }
}