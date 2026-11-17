import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/docente_api.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';
import 'docente_estudiantes_screen.dart';
import 'docente_notas_screen.dart';

class DocenteAsignacionesScreen extends StatefulWidget {
  const DocenteAsignacionesScreen({super.key});

  @override
  State<DocenteAsignacionesScreen> createState() =>
      _DocenteAsignacionesScreenState();
}

class _DocenteAsignacionesScreenState extends State<DocenteAsignacionesScreen> {
  List<dynamic> _lista = [];
  bool _cargando = true;
  String? _error;

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
      final r = await DocenteApi.asignaciones();
      if (!mounted) return;
      setState(() {
        _lista = r;
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
      titulo: 'Mis asignaciones',
      child: CargaVista(
        cargando: _cargando,
        error: _error,
        reintentar: _cargar,
        child: _lista.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                      'Aún no tienes asignaciones. Pide al administrador que te asigne un curso.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: _lista.map((a) {
                  final id = (a['idAsignacion'] as num).toInt();
                  return TarjetaHoja(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(etiquetaAsignacion(a),
                            style: GoogleFonts.workSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.tinta)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DocenteEstudiantesScreen(
                                        idAsignacionInicial: id)),
                              ),
                              child: const Text('Ver estudiantes'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DocenteNotasScreen(
                                        idAsignacionInicial: id)),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.verde700,
                                  foregroundColor: Colors.white),
                              child: const Text('Registrar notas'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}