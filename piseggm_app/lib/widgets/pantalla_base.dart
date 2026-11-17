import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colores.dart';

void avisar(BuildContext context, String texto, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(texto),
    backgroundColor: error ? const Color(0xFF9B2C22) : AppColors.verde700,
  ));
}

String msgError(Object e) => e.toString().replaceAll('Exception: ', '');

String t(dynamic x) => x == null ? '' : x.toString().trim();

String desempenoDe(String valor) {
  final n = double.tryParse(valor.replaceAll(',', '.'));
  if (n == null || n < 1 || n > 5) return '';
  final r = (n * 10).round() / 10;
  if (r >= 4.6) return 'Superior';
  if (r >= 4.0) return 'Alto';
  if (r >= 3.5) return 'Básico';
  return 'Bajo';
}

Color colorDesempeno(String d) {
  final s = d.toLowerCase();
  if (s.startsWith('sup')) return AppColors.verde700;
  if (s.startsWith('alt')) return AppColors.verde500;
  if (s.contains('sic')) return AppColors.dorado600;
  if (s.startsWith('baj')) return const Color(0xFFC0392B);
  return AppColors.tintaSuave;
}

PreferredSizeWidget franjaDorada() => PreferredSize(
      preferredSize: const Size.fromHeight(5),
      child: SizedBox(
        height: 5,
        child: Row(
          children: List.generate(
            30,
            (i) => Expanded(
              child: ColoredBox(
                color: i.isEven ? AppColors.amarillo500 : AppColors.dorado600,
              ),
            ),
          ),
        ),
      ),
    );

class PantallaBase extends StatelessWidget {
  final String titulo;
  final Widget child;
  final List<Widget>? acciones;
  const PantallaBase({
    super.key,
    required this.titulo,
    required this.child,
    this.acciones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verde100,
      appBar: AppBar(
        backgroundColor: AppColors.verde900,
        foregroundColor: Colors.white,
        title: Text(
          titulo,
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: acciones,
        bottom: franjaDorada(),
      ),
      body: child,
    );
  }
}

class CargaVista extends StatelessWidget {
  final bool cargando;
  final String? error;
  final VoidCallback reintentar;
  final Widget child;
  const CargaVista({
    super.key,
    required this.cargando,
    required this.error,
    required this.reintentar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.verde700));
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.tintaSuave),
              const SizedBox(height: 12),
              Text(error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: reintentar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    return child;
  }
}

class Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  const Etiqueta(this.texto, {super.key, this.color = AppColors.verde700});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: GoogleFonts.workSans(
            fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class TarjetaHoja extends StatelessWidget {
  final Widget child;
  const TarjetaHoja({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: AppColors.hojaChica,
        border: Border.all(color: AppColors.borde),
      ),
      child: child,
    );
  }
}

class SelectorCampo<T> extends StatelessWidget {
  final String etiqueta;
  final T? valor;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const SelectorCampo({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<T>(
        key: ValueKey(valor),
        initialValue: valor,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: etiqueta,
          filled: true,
          fillColor: AppColors.blanco,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}