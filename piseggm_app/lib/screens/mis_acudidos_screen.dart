import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';
import 'boletin_screen.dart';

class MisAcudidosScreen extends StatefulWidget {
  const MisAcudidosScreen({super.key});

  @override
  State<MisAcudidosScreen> createState() => _MisAcudidosScreenState();
}

class _MisAcudidosScreenState extends State<MisAcudidosScreen> {
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
      final r = await ApiClient.get('/acudiente/${Sesion.usuario!.idUsuario}/acudidos');
      if (!mounted) return;
      setState(() {
        _lista = r is List ? r : [];
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
      titulo: 'Mis acudidos',
      child: CargaVista(
        cargando: _cargando,
        error: _error,
        reintentar: _cargar,
        child: _lista.isEmpty
            ? Center(
                child: Text('No tienes estudiantes a cargo registrados.',
                    style: GoogleFonts.workSans(color: AppColors.tintaSuave)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: _lista.map((e) {
                  final nombre = '${t(e['nombre'])} ${t(e['apellido'])}'.trim();
                  final doc = t(e['documento'] ?? e['numeroDocumento']);
                  final curso = t(e['curso']);
                  final id = (e['idEstudiante'] as num).toInt();
                  return TarjetaHoja(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(nombre,
                                  style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.5,
                                      color: AppColors.tinta)),
                            ),
                            if (curso.isNotEmpty) Etiqueta(curso),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Documento: ${doc.isEmpty ? '—' : doc}',
                            style: GoogleFonts.workSans(
                                fontSize: 12.5, color: AppColors.tintaSuave)),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BoletinScreen(
                                  esAcudiente: true, idEstudianteInicial: id),
                            ),
                          ),
                          icon: const Icon(Icons.assessment, size: 18),
                          label: const Text('Ver boletín'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verde700,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius: AppColors.hojaChica),
                          ),
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