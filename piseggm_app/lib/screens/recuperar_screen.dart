import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/api_client.dart';
import '../theme/colores.dart';
import '../widgets/pantalla_base.dart';

class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});

  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  final _doc = TextEditingController();
  final _correo = TextEditingController();
  final _codigo = TextEditingController();
  final _nueva = TextEditingController();
  final _repite = TextEditingController();

  int _paso = 1;
  bool _ocupado = false;
  bool _ver = false;
  String? _mensaje;
  int _espera = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _doc.dispose();
    _correo.dispose();
    _codigo.dispose();
    _nueva.dispose();
    _repite.dispose();
    super.dispose();
  }

  Future<void> _enviar(String ruta, Map<String, dynamic> datos) async {
    try {
      final r = await http
          .post(
            Uri.parse('${ApiClient.base}/recuperacion$ruta'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 20));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        var m = 'No se pudo completar la solicitud (error ${r.statusCode}).';
        try {
          final c = jsonDecode(utf8.decode(r.bodyBytes));
          if (c is Map && c['message'] != null) m = c['message'].toString();
        } catch (_) {}
        throw Exception(m);
      }
    } on TimeoutException {
      throw Exception('El servidor tardó demasiado. Revisa el WiFi.');
    } on http.ClientException {
      throw Exception('No se pudo conectar con el servidor. Revisa el WiFi.');
    }
  }

  Future<void> _con(Future<void> Function() accion) async {
    setState(() {
      _ocupado = true;
      _mensaje = null;
    });
    try {
      await accion();
    } catch (e) {
      if (mounted) setState(() => _mensaje = msgError(e));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _iniciarEspera() {
    _timer?.cancel();
    setState(() => _espera = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _espera--);
      if (_espera <= 0) t.cancel();
    });
  }

  bool _claveValida(String c) =>
      c.length >= 6 &&
      RegExp(r'\p{Lu}', unicode: true).hasMatch(c) &&
      RegExp(r'\p{Ll}', unicode: true).hasMatch(c) &&
      RegExp(r'\d').hasMatch(c) &&
      RegExp(r'[^\p{L}\p{N}\s]', unicode: true).hasMatch(c);

  Future<void> _solicitar({bool reenvio = false}) async {
    final doc = _doc.text.trim();
    final mail = _correo.text.trim();
    if (!RegExp(r'^[0-9A-Za-z]{5,15}$').hasMatch(doc)) {
      setState(() => _mensaje = 'Escribe un documento válido (5 a 15 caracteres).');
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(mail)) {
      setState(() => _mensaje = 'Escribe un correo válido.');
      return;
    }
    await _con(() async {
      await _enviar('/solicitar', {'documento': doc, 'email': mail});
      _iniciarEspera();
      if (!mounted) return;
      if (reenvio) {
        avisar(context, 'Te enviamos un nuevo código.');
      } else {
        setState(() {
          _paso = 2;
          _codigo.clear();
        });
      }
    });
  }

  Future<void> _verificar() async {
    final c = _codigo.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(c)) {
      setState(() => _mensaje = 'El código tiene 6 dígitos.');
      return;
    }
    await _con(() async {
      await _enviar('/verificar', {'documento': _doc.text.trim(), 'codigo': c});
      if (mounted) setState(() => _paso = 3);
    });
  }

  Future<void> _restablecer() async {
    final n = _nueva.text;
    if (!_claveValida(n)) {
      setState(() => _mensaje =
          'La contraseña necesita 6+ caracteres, mayúscula, minúscula, número y un símbolo.');
      return;
    }
    if (n != _repite.text) {
      setState(() => _mensaje = 'Las contraseñas no coinciden.');
      return;
    }
    await _con(() async {
      await _enviar('/restablecer', {
        'documento': _doc.text.trim(),
        'codigo': _codigo.text.trim(),
        'nuevaPassword': n,
      });
      if (!mounted) return;
      avisar(context, 'Contraseña actualizada. Ya puedes ingresar.');
      Navigator.pop(context);
    });
  }

  InputDecoration _deco(String etiqueta, IconData icono) => InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono, color: AppColors.verde700),
        filled: true,
        fillColor: AppColors.blanco,
        border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
      );

  @override
  Widget build(BuildContext context) {
    const titulos = [
      '¿Olvidaste tu contraseña?',
      'Revisa tu correo',
      'Crea tu nueva contraseña',
    ];
    const subs = [
      'Escribe tu documento y el correo con el que te registraste.',
      'Escribe el código de 6 dígitos que te enviamos.',
      'Elige una contraseña segura para volver a ingresar.',
    ];
    return PantallaBase(
      titulo: 'Recuperar contraseña',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Paso $_paso de 3',
              style: GoogleFonts.workSans(
                  color: AppColors.dorado600,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
          const SizedBox(height: 4),
          Text(titulos[_paso - 1],
              style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.verde900)),
          const SizedBox(height: 4),
          Text(subs[_paso - 1],
              style: GoogleFonts.workSans(color: AppColors.tintaSuave)),
          const SizedBox(height: 18),
          if (_paso == 1) ...[
            TextField(
                controller: _doc,
                decoration: _deco('Número de documento', Icons.badge)),
            const SizedBox(height: 12),
            TextField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                decoration: _deco('Correo electrónico', Icons.email)),
          ],
          if (_paso == 2) ...[
            TextField(
                controller: _codigo,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _deco('Código de 6 dígitos', Icons.pin)),
            TextButton(
              onPressed: (_espera > 0 || _ocupado)
                  ? null
                  : () => _solicitar(reenvio: true),
              child: Text(_espera > 0
                  ? 'Reenviar código ($_espera s)'
                  : 'Reenviar código'),
            ),
          ],
          if (_paso == 3) ...[
            TextField(
              controller: _nueva,
              obscureText: !_ver,
              decoration: _deco('Nueva contraseña', Icons.lock).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_ver ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _ver = !_ver),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _repite,
                obscureText: !_ver,
                decoration: _deco('Repite la contraseña', Icons.lock_outline)),
          ],
          if (_mensaje != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFC0392B).withValues(alpha: 0.1),
                borderRadius: AppColors.hojaChica,
              ),
              child: Text(_mensaje!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                      color: const Color(0xFF9B2C22),
                      fontWeight: FontWeight.w600)),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _ocupado
                ? null
                : (_paso == 1
                    ? _solicitar
                    : _paso == 2
                        ? _verificar
                        : _restablecer),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amarillo500,
              foregroundColor: AppColors.verde900,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const RoundedRectangleBorder(
                  borderRadius: AppColors.hojaChica),
            ),
            child: _ocupado
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.verde900))
                : Text(
                    _paso == 1
                        ? 'ENVIAR CÓDIGO'
                        : _paso == 2
                            ? 'VERIFICAR'
                            : 'GUARDAR CONTRASEÑA',
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}