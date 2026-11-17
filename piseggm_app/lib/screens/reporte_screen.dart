import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';

class ItemVista {
  final String titulo;
  final List<String> lineas;
  final List<String> etiquetas;
  const ItemVista(this.titulo,
      {this.lineas = const [], this.etiquetas = const []});
}

List<String> lineasDe(List<String?> l) => l.whereType<String>().toList();

String? campo(String etiqueta, dynamic v) {
  final s = t(v);
  return s.isEmpty ? null : '$etiqueta: $s';
}

class ReporteScreen extends StatefulWidget {
  final String titulo;
  final IconData icono;
  final Future<List<ItemVista>> Function() cargar;
  const ReporteScreen({
    super.key,
    required this.titulo,
    required this.icono,
    required this.cargar,
  });

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  List<ItemVista> _items = [];
  final _buscador = TextEditingController();
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final r = await widget.cargar();
      if (!mounted) return;
      setState(() {
        _items = r;
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
    final q = _buscador.text.trim().toLowerCase();
    final filtrados = _items.where((i) {
      if (q.isEmpty) return true;
      final texto =
          '${i.titulo} ${i.lineas.join(' ')} ${i.etiquetas.join(' ')}'.toLowerCase();
      return texto.contains(q);
    }).toList();

    return PantallaBase(
      titulo: widget.titulo,
      acciones: [
        IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar'),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: TextField(
              controller: _buscador,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.blanco,
                isDense: true,
                border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${filtrados.length} registros',
                  style: GoogleFonts.workSans(
                      fontSize: 12, color: AppColors.tintaSuave)),
            ),
          ),
          Expanded(
            child: CargaVista(
              cargando: _cargando,
              error: _error,
              reintentar: _cargar,
              child: filtrados.isEmpty
                  ? Center(
                      child: Text('Sin resultados',
                          style: GoogleFonts.workSans(
                              color: AppColors.tintaSuave)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtrados.length,
                      itemBuilder: (_, i) {
                        final it = filtrados[i];
                        return TarjetaHoja(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(widget.icono,
                                      size: 20, color: AppColors.verde700),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(it.titulo,
                                        style: GoogleFonts.workSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppColors.tinta)),
                                  ),
                                ],
                              ),
                              if (it.etiquetas.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: it.etiquetas
                                      .map((e) => Etiqueta(e))
                                      .toList(),
                                ),
                              ],
                              if (it.lineas.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...it.lineas.map((l) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(l,
                                          style: GoogleFonts.workSans(
                                              fontSize: 12.5,
                                              color: AppColors.tintaSuave)),
                                    )),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}