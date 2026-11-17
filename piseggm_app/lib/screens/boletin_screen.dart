import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';

class BoletinScreen extends StatefulWidget {
  final bool esAcudiente;
  final int? idEstudianteInicial;
  const BoletinScreen({super.key, this.esAcudiente = false, this.idEstudianteInicial});

  @override
  State<BoletinScreen> createState() => _BoletinScreenState();
}

class _BoletinScreenState extends State<BoletinScreen> {
  List<dynamic> _hijos = [];
  List<dynamic> _periodos = [];
  dynamic _hijoSel;
  dynamic _periodoSel;
  Map<String, dynamic>? _boletin;
  bool _cargando = true;
  String? _error;

  int get _idUsuario => Sesion.usuario!.idUsuario;

  String get _rutaBase => widget.esAcudiente
      ? '/boletin/acudiente/$_idUsuario/hijos/$_hijoSel'
      : '/boletin/estudiante/$_idUsuario';

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      if (widget.esAcudiente) {
        _hijos = await ApiClient.get('/boletin/acudiente/$_idUsuario/hijos');
        if (_hijos.isEmpty) {
          setState(() { _cargando = false; _error = 'No tienes estudiantes a tu cargo.'; });
          return;
        }
        final inicial = widget.idEstudianteInicial;
        final hay = _hijos.any((h) => h['idEstudiante'] == inicial);
        _hijoSel = hay ? inicial : _hijos.first['idEstudiante'];
      }
      await _cargarPeriodos();
    } catch (e) {
      setState(() { _cargando = false; _error = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  Future<void> _cargarPeriodos() async {
    setState(() { _cargando = true; _error = null; _boletin = null; });
    try {
      _periodos = await ApiClient.get('$_rutaBase/periodos');
      if (_periodos.isEmpty) {
        setState(() { _cargando = false; _error = 'Todavía no hay notas publicadas.'; });
        return;
      }
      _periodoSel = _periodos.first['idPeriodo'];
      await _cargarBoletin();
    } catch (e) {
      setState(() { _cargando = false; _error = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  Future<void> _cargarBoletin() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final b = await ApiClient.get('$_rutaBase?periodo=$_periodoSel');
      setState(() { _boletin = Map<String, dynamic>.from(b); _cargando = false; });
    } catch (e) {
      setState(() { _cargando = false; _error = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  Color _colorDesempeno(String d) {
    final s = d.toLowerCase();
    if (s.startsWith('sup')) return AppColors.verde700;
    if (s.startsWith('alt')) return AppColors.verde500;
    if (s.startsWith('b') && s.contains('sic')) return AppColors.dorado600;
    return const Color(0xFFC0392B);
  }

  Widget _selector<T>(String etiqueta, T? valor, List<DropdownMenuItem<T>> items, ValueChanged<T?> cambio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<T>(
        initialValue: valor,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: etiqueta,
          filled: true,
          fillColor: AppColors.blanco,
          border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
        ),
        items: items,
        onChanged: cambio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final materias = (_boletin?['materias'] as List?) ?? [];
    return Scaffold(
      backgroundColor: AppColors.verde100,
      appBar: AppBar(
        backgroundColor: AppColors.verde900,
        foregroundColor: Colors.white,
        title: Text(widget.esAcudiente ? 'Boletín de mis acudidos' : 'Mi boletín',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.esAcudiente && _hijos.isNotEmpty)
            _selector<dynamic>(
              'Estudiante',
              _hijoSel,
              _hijos.map((h) => DropdownMenuItem<dynamic>(
                  value: h['idEstudiante'], child: Text('${h['nombre']}'))).toList(),
              (v) { _hijoSel = v; _cargarPeriodos(); },
            ),
          if (_periodos.isNotEmpty)
            _selector<dynamic>(
              'Periodo',
              _periodoSel,
              _periodos.map((p) => DropdownMenuItem<dynamic>(
                  value: p['idPeriodo'],
                  child: Text('${p['nombre']}${p['anio'] != null ? ' (${p['anio']})' : ''}'))).toList(),
              (v) { _periodoSel = v; _cargarBoletin(); },
            ),
          if (_cargando)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
            )
          else if (_boletin != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.verde900,
                borderRadius: AppColors.hojaMedia,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INFORME DE EVALUACIÓN',
                      style: GoogleFonts.workSans(
                          color: AppColors.amarillo300, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text('${_boletin!['estudiante'] ?? ''}',
                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Doc. ${_boletin!['documento'] ?? '—'}  ·  Curso ${_boletin!['grado'] ?? '—'}\n'
                    'Vigencia ${_boletin!['anio'] ?? '—'}  ·  ${_boletin!['periodo'] ?? ''}',
                    style: GoogleFonts.workSans(color: const Color(0xFFCFE3D3), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (materias.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Todavía no hay notas publicadas para este periodo.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
              ),
            ...materias.map((m) {
              final des = '${m['desempeno'] ?? ''}';
              final color = _colorDesempeno(des);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: AppColors.hojaChica,
                  border: Border.all(color: AppColors.borde),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${m['asignatura'] ?? ''}',
                                  style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.tinta)),
                              if (m['docente'] != null)
                                Text('Docente: ${m['docente']}',
                                    style: GoogleFonts.workSans(fontSize: 12, color: AppColors.tintaSuave)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                          child: Text(des.toUpperCase(),
                              style: GoogleFonts.workSans(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    if ((m['descripcion'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('${m['descripcion']}',
                          style: GoogleFonts.workSans(fontSize: 13, height: 1.4, color: AppColors.tinta)),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}