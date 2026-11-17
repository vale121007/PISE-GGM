import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/docente_api.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';

class DocentePeriodosScreen extends StatefulWidget {
  const DocentePeriodosScreen({super.key});

  @override
  State<DocentePeriodosScreen> createState() => _DocentePeriodosScreenState();
}

class _DocentePeriodosScreenState extends State<DocentePeriodosScreen> {
  List<dynamic> _periodos = [];
  String? _anioSel;
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
      final r = await DocenteApi.periodos();
      final anios = r.map((p) => anioDe(p as Map)).toSet().toList();
      String? sel;
      for (final p in r) {
        if (p['actual'] == true) sel = anioDe(p as Map);
      }
      sel ??= anios.isNotEmpty ? anios.last : null;
      if (!mounted) return;
      setState(() {
        _periodos = r;
        _anioSel = sel;
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
    final anios = _periodos.map((p) => anioDe(p as Map)).toSet().toList();
    final lista =
        _periodos.where((p) => anioDe(p as Map) == _anioSel).toList();
    return PantallaBase(
      titulo: 'Periodo académico',
      child: CargaVista(
        cargando: _cargando,
        error: _error,
        reintentar: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (anios.isNotEmpty)
              SelectorCampo<String>(
                etiqueta: 'Año',
                valor: _anioSel,
                items: anios
                    .map((a) => DropdownMenuItem<String>(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => setState(() => _anioSel = v),
              ),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No hay periodos registrados para este año.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
              ),
            ...lista.map((p) => _TarjetaPeriodo(
                  key: ValueKey(p['idPeriodo']),
                  p: Map<String, dynamic>.from(p as Map),
                )),
          ],
        ),
      ),
    );
  }
}

class _TarjetaPeriodo extends StatefulWidget {
  final Map<String, dynamic> p;
  const _TarjetaPeriodo({super.key, required this.p});

  @override
  State<_TarjetaPeriodo> createState() => _TarjetaPeriodoState();
}

class _TarjetaPeriodoState extends State<_TarjetaPeriodo> {
  late final TextEditingController _desc;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _desc = TextEditingController(text: t(widget.p['descripcion']));
  }

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await DocenteApi.guardarDescripcion(
          (widget.p['idPeriodo'] as num).toInt(), _desc.text.trim());
      if (!mounted) return;
      avisar(context, 'Descripción guardada.');
    } catch (e) {
      if (!mounted) return;
      avisar(context, msgError(e), error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actual = widget.p['actual'] == true;
    return TarjetaHoja(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t(widget.p['nombre']),
                    style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.verde900)),
              ),
              if (actual) const Etiqueta('En curso', color: AppColors.dorado600),
            ],
          ),
          Text('${t(widget.p['fechaInicio'])} a ${t(widget.p['fechaFin'])}',
              style: GoogleFonts.workSans(
                  fontSize: 12.5, color: AppColors.tintaSuave)),
          const SizedBox(height: 10),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción del periodo',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _guardando ? null : _guardar,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verde700,
                foregroundColor: Colors.white),
            child: const Text('Guardar descripción'),
          ),
        ],
      ),
    );
  }
}