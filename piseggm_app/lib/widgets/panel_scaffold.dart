import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario.dart';
import '../screens/login_screen.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import 'pantalla_base.dart';

class PanelCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget Function() destino;

  PanelCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destino,
  });
}

class PanelScaffold extends StatelessWidget {
  final Usuario usuario;
  final String tituloPanel;
  final List<PanelCardData> items;

  const PanelScaffold({
    super.key,
    required this.usuario,
    required this.tituloPanel,
    required this.items,
  });

  void _cerrarSesion(BuildContext context) {
    Sesion.token = '';
    Sesion.usuario = null;
    Sesion.idPerfil = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verde100,
      appBar: AppBar(
        backgroundColor: AppColors.verde900,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/images/ESCUDOGGMSINFONDO.png', height: 32),
            const SizedBox(width: 10),
            Text('PISE-GGM',
                style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.amarillo300),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
        bottom: franjaDorada(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.verde900, AppColors.verde700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppColors.hojaGrande,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloPanel.toUpperCase(),
                  style: GoogleFonts.workSans(
                    color: AppColors.amarillo300,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bienvenido, ${usuario.nombre}',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Colegio Gabriel García Márquez',
                  style: GoogleFonts.workSans(
                      color: const Color(0xFFCFE3D3), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 230,
            ),
            itemBuilder: (context, i) => _PanelCard(item: items[i]),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final PanelCardData item;
  const _PanelCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blanco,
      borderRadius: AppColors.hojaMedia,
      elevation: 2,
      shadowColor: AppColors.verde900.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: AppColors.hojaMedia,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.destino()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.verde100,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 28, color: AppColors.verde700),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.verde900),
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.workSans(
                    fontSize: 11.5, color: AppColors.tintaSuave),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.verde700,
                  borderRadius: AppColors.hojaChica,
                ),
                child: Text('Ingresar',
                    style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}