import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/docente_api.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';

class DocenteNotasScreen extends StatefulWidget {
  final int? idAsignacionInicial;
  const DocenteNotasScreen({super.key, this.idAsignacionInicial});

  @override
  State<DocenteNotasScreen> createState() => _DocenteNotasScreenState();
}

class _DocenteNotasScreenState extends State<DocenteNotasScreen> {
  List<dynamic> _asignaciones = [];
  List<dynamic> _periodos = [];
  List<dynamic> _filas = [];
  int? _asigSel;
  int? _perSel;
  bool _cargando = true;
  String? _error;

  int _id(dynamic x) => (x as num).toInt();

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
      final r = await Future.wait([
        DocenteApi.asignaciones(),
        DocenteApi.periodos(),
      ]);
      _asignaciones = r[0];
      _periodos = r[1];
      if (_asignaciones.isEmpty || _periodos.isEmpty) {
        setState(() => _cargando = false);
        return;
      }
      final ini = widget.idAsignacionInicial;
      _asigSel = _asignaciones.any((a) => _id(a['idAsignacion']) == ini)
          ? ini
          : _id(_asignaciones.first['idAsignacion']);
      final actual = _periodos.firstWhere((p) => p['actual'] == true,
          orElse: () => _periodos.first);
      _perSel = _id(actual['idPeriodo']);
      await _cargarFilas();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = msgError(e);
      });
    }
  }

  Future<void> _cargarFilas({bool silencioso = false}) async {
    if (!silencioso) setState(() => _cargando = true);
    try {
      final r = await DocenteApi.estudiantesConNota(_asigSel!, _perSel!);
      if (!mounted) return;
      setState(() {
        _filas = r;
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

  Future<void> _subir(Map e, String prom, String obs) async {
    try {
      await DocenteApi.subirNota(
        idAsignacion: _asigSel!,
        idPeriodo: _perSel!,
        idMatricula: _id(e['idMatricula']),
        promedio: prom,
        descripcion: obs,
      );
      if (!mounted) return;
      avisar(context, 'Nota subida: ya aparece en el boletín.');
      await _cargarFilas(silencioso: true);
    } catch (er) {
      if (!mounted) return;
      avisar(context, msgError(er), error: true);
    }
  }

  Future<void> _eliminar(Map e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text(
            '¿Eliminar la nota de este estudiante? Dejará de aparecer en su boletín.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await DocenteApi.eliminarNota(_id(e['idNota']));
      if (!mounted) return;
      avisar(context, 'Nota eliminada.');
      await _cargarFilas(silencioso: true);
    } catch (er) {
      if (!mounted) return;
      avisar(context, msgError(er), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: 'Registrar notas',
      child: CargaVista(
        cargando: _cargando && _filas.isEmpty && _asignaciones.isEmpty,
        error: _error,
        reintentar: _iniciar,
        child: (_asignaciones.isEmpty || _periodos.isEmpty)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                      'No hay asignaciones o periodos disponibles todavía.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SelectorCampo<int>(
                    etiqueta: 'Curso / asignatura',
                    valor: _asigSel,
                    items: _asignaciones
                        .map((a) => DropdownMenuItem<int>(
                              value: _id(a['idAsignacion']),
                              child: Text(etiquetaAsignacion(a),
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) {
                      _asigSel = v;
                      _cargarFilas();
                    },
                  ),
                  SelectorCampo<int>(
                    etiqueta: 'Periodo',
                    valor: _perSel,
                    items: _periodos
                        .map((p) => DropdownMenuItem<int>(
                              value: _id(p['idPeriodo']),
                              child: Text('${p['nombre']} (${anioDe(p)})'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      _perSel = v;
                      _cargarFilas();
                    },
                  ),
                  if (_cargando)
                    const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.verde700)))
                  else if (_filas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                          'Este curso no tiene estudiantes matriculados.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(
                              color: AppColors.tintaSuave)),
                    )
                  else
                    ..._filas.map((e) => _FilaNota(
                          key: ValueKey(
                              '${e['idMatricula']}-${e['idNota']}-$_perSel-$_asigSel'),
                          e: Map<String, dynamic>.from(e as Map),
                                                    onSubir: (p, o) => _subir(e, p, o),
                          onEliminar: () => _eliminar(e),
                        )),
                ],
              ),
      ),
    );
  }
}

class _FilaNota extends StatefulWidget {
  final Map<String, dynamic> e;
  final Future<void> Function(String promedio, String obs) onSubir;
  final Future<void> Function() onEliminar;
  const _FilaNota({
    super.key,
    required this.e,
    required this.onSubir,
    required this.onEliminar,
  });

  @override
  State<_FilaNota> createState() => _FilaNotaState();
}

class _FilaNotaState extends State<_FilaNota> {
  late final TextEditingController _prom;
  late final TextEditingController _obs;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    final n = double.tryParse('${widget.e['promedio'] ?? ''}'.replaceAll(',', '.'));
    _prom = TextEditingController(text: n == null ? '' : n.toStringAsFixed(1));
    _obs = TextEditingController(text: t(widget.e['descripcion']));
    _prom.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _prom.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _subir() async {
    final p = _prom.text.trim();
    if (p.isEmpty || desempenoDe(p).isEmpty) {
      avisar(context, 'Escribe un promedio entre 1.0 y 5.0.', error: true);
      return;
    }
    setState(() => _ocupado = true);
    try {
      await widget.onSubir(p, _obs.text.trim());
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final des = desempenoDe(_prom.text.trim());
    final tieneNota = widget.e['idNota'] != null;
    return TarjetaHoja(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t(widget.e['nombre']),
              style: GoogleFonts.workSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.tinta)),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _prom,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Promedio',
                    hintText: '0.0',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (des.isNotEmpty)
                Etiqueta(des.toUpperCase(), color: colorDesempeno(des)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _obs,
            maxLines: 3,
            maxLength: 1500,
            decoration: InputDecoration(
              labelText: 'Observación',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _ocupado ? null : _subir,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verde700,
                    foregroundColor: Colors.white),
                child: _ocupado
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Subir'),
              ),
              const SizedBox(width: 10),
              if (tieneNota)
                OutlinedButton(
                  onPressed: _ocupado ? null : widget.onEliminar,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC0392B)),
                  child: const Text('Eliminar'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}