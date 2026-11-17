import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';

class MiPerfilScreen extends StatefulWidget {
  final bool esAcudiente;
  const MiPerfilScreen({super.key, this.esAcudiente = false});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  late Map<String, dynamic> _d;

  @override
  void initState() {
    super.initState();
    final u = Sesion.usuario!;
    _d = {
      'nombre': u.nombre,
      'apellido': u.apellido,
      'tipoDocumento': u.tipoDocumento,
      'documento': u.documento,
      'email': u.email,
      'telefono': u.telefono,
    };
    if (widget.esAcudiente) _traerPerfil();
  }

  Future<void> _traerPerfil() async {
    try {
      final r = await ApiClient.get('/acudiente/${Sesion.usuario!.idUsuario}/perfil');
      if (r is Map && mounted) {
        setState(() {
          r.forEach((k, v) {
            if (v != null && t(v).isNotEmpty) _d['$k'] = v;
          });
          if (_d['correo'] != null && t(_d['email']).isEmpty) {
            _d['email'] = _d['correo'];
          }
        });
      }
    } catch (_) {
      // El endpoint es opcional: se dejan los datos del login.
    }
  }

  Widget _dato(IconData icono, String etiqueta, String valor) {
    return TarjetaHoja(
      child: Row(
        children: [
          Icon(icono, color: AppColors.verde700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta,
                    style: GoogleFonts.workSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tintaSuave)),
                Text(valor.isEmpty ? '—' : valor,
                    style: GoogleFonts.workSans(
                        fontSize: 15, color: AppColors.tinta)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = '${t(_d['nombre'])} ${t(_d['apellido'])}'.trim();
    final doc = t(_d['documento'] ?? _d['numeroDocumento']);
    final inicial = nombre.isEmpty ? '?' : nombre[0].toUpperCase();
    return PantallaBase(
      titulo: 'Mi perfil',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.verde700,
              child: Text(inicial,
                  style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(nombre,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.verde900)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: Etiqueta(Sesion.usuario?.rol?.nombreRol ?? ''),
            ),
          ),
          _dato(Icons.badge, 'Tipo de documento', t(_d['tipoDocumento'])),
          _dato(Icons.credit_card, 'Documento', doc),
          _dato(Icons.email, 'Correo electrónico', t(_d['email'] ?? _d['correo'])),
          _dato(Icons.phone, 'Teléfono', t(_d['telefono'])),
        ],
      ),
    );
  }
}