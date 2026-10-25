import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/colores.dart';
import 'admin_home_screen.dart';
import 'docente_home_screen.dart';
import 'estudiante_home_screen.dart';
import 'acudiente_home_screen.dart';
import 'placeholder_screen.dart';
import '../services/sesion.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _documentoController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _roles = [
    "ADMINISTRADOR",
    "DOCENTE",
    "ESTUDIANTE",
    "ACUDIENTE",
  ];
  String? _rolSeleccionado;

  bool _cargando = false;
  bool _verPassword = false;
  String? _errorMsg;

  @override
  void dispose() {
    _documentoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _bonito(String rol) => rol[0] + rol.substring(1).toLowerCase();

  Future<void> _iniciarSesion() async {
    if (_documentoController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _rolSeleccionado == null) {
      setState(() => _errorMsg = "Por favor completa todos los campos.");
      return;
    }

    setState(() {
      _cargando = true;
      _errorMsg = null;
    });

    try {
      final resultado = await ApiService.login(
        _documentoController.text.trim(),
        _passwordController.text.trim(),
        _rolSeleccionado!,
      );

      if (!mounted) return;

      Sesion.token = resultado.token;
      Sesion.usuario = resultado.usuario;
      Sesion.idPerfil = resultado.idPerfil;

      final nombreRol = resultado.usuario.rol?.nombreRol.toUpperCase() ?? '';
      Widget pantallaDestino;
      switch (nombreRol) {
        case "ADMINISTRADOR":
          pantallaDestino = AdminHomeScreen(usuario: resultado.usuario);
          break;
        case "DOCENTE":
          pantallaDestino = DocenteHomeScreen(usuario: resultado.usuario);
          break;
        case "ESTUDIANTE":
          pantallaDestino = EstudianteHomeScreen(usuario: resultado.usuario);
          break;
        case "ACUDIENTE":
          pantallaDestino = AcudienteHomeScreen(usuario: resultado.usuario);
          break;
        default:
          pantallaDestino = const PlaceholderScreen(titulo: "Rol no reconocido");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pantallaDestino),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  InputDecoration _decoracion(String hint, IconData icono, {Widget? sufijo}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.workSans(color: const Color(0xFF6B7A6E), fontSize: 14),
      filled: true,
      fillColor: AppColors.blanco.withValues(alpha: 0.95),
      prefixIcon: Icon(icono, color: AppColors.verde700, size: 20),
      suffixIcon: sufijo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: const OutlineInputBorder(
        borderRadius: AppColors.hojaChica,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppColors.hojaChica,
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppColors.hojaChica,
        borderSide: BorderSide(color: AppColors.amarillo500, width: 2),
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texto,
          style: GoogleFonts.workSans(
            color: const Color(0xFFDFEEE2),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _tarjeta() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.verde900.withValues(alpha: 0.93),
                AppColors.verde700.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: AppColors.hojaGrande,
            border: Border.all(color: AppColors.amarillo300.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.verde900.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/ESCUDOGGMSINFONDO.png', width: 62, height: 62),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PISE-GGM",
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.blanco,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "CAMPUS VIRTUAL",
                        style: GoogleFonts.workSans(
                          color: AppColors.amarillo300,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                "Ingresar",
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.blanco,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Accede con tu documento y contraseña",
                style: GoogleFonts.workSans(
                  color: const Color(0xFFCFE3D3),
                  fontSize: 14,
                ),
              ),

              _etiqueta("Número de documento"),
              TextField(
                controller: _documentoController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.workSans(fontSize: 15, color: AppColors.tinta),
                decoration: _decoracion("Tu documento", Icons.badge_outlined),
              ),

              _etiqueta("Contraseña"),
              TextField(
                controller: _passwordController,
                obscureText: !_verPassword,
                style: GoogleFonts.workSans(fontSize: 15, color: AppColors.tinta),
                decoration: _decoracion(
                  "Tu contraseña",
                  Icons.lock_outline,
                  sufijo: IconButton(
                    icon: Icon(
                      _verPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.verde700,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _verPassword = !_verPassword),
                  ),
                ),
              ),

              _etiqueta("Rol"),
              DropdownButtonFormField<String>(
                initialValue: _rolSeleccionado,
                dropdownColor: AppColors.blanco,
                iconEnabledColor: AppColors.verde700,
                style: GoogleFonts.workSans(fontSize: 15, color: AppColors.tinta),
                decoration: _decoracion("Selecciona tu rol", Icons.person_outline),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(_bonito(r))))
                    .toList(),
                onChanged: (v) => setState(() => _rolSeleccionado = v),
              ),

              if (_errorMsg != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7878).withValues(alpha: 0.16),
                    borderRadius: AppColors.hojaChica,
                    border: Border.all(
                      color: const Color(0xFFFF8C8C).withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    _errorMsg!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(
                      color: const Color(0xFFFFD0D0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amarillo500,
                    foregroundColor: AppColors.verde900,
                    disabledBackgroundColor: const Color(0xFF8A958C),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const RoundedRectangleBorder(borderRadius: AppColors.hojaChica),
                    elevation: 4,
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.verde900,
                          ),
                        )
                      : Text(
                          "INGRESAR",
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),

        // Franja amarilla/dorada superior (igual a tu web)
        Positioned(
          top: 0,
          left: 28,
          right: 28,
          height: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
            child: Row(
              children: List.generate(
                24,
                (i) => Expanded(
                  child: Container(
                    color: i.isEven ? AppColors.amarillo500 : AppColors.dorado600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: Stack(
        children: [
          // Foto del colegio casi transparente
          Positioned.fill(
            child: Opacity(
              opacity: 0.11,
              child: Image.asset('assets/images/ANIMADOCOLGGM.png', fit: BoxFit.cover),
            ),
          ),
          // Velo amarillo
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.64, -0.56),
                  radius: 0.9,
                  colors: [
                    AppColors.amarillo300.withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Velo verde
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.64, 0.44),
                  radius: 0.9,
                  colors: [
                    AppColors.verde500.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: _tarjeta(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}