import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import '../theme/colores.dart';

const Map<int, String> _rolesPorId = {
  1: "ESTUDIANTE",
  2: "ACUDIENTE",
  3: "DOCENTE",
  4: "ADMINISTRADOR",
};

class UsuarioForm extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final List<dynamic> roles;

  const UsuarioForm({super.key, this.usuario, required this.roles});

  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _tipos = const ["CC", "TI", "CE", "RC"];
  String? _tipoDoc;
  int? _idRol;
  int? _idAcudiente;

  final _numDoc = TextEditingController();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _password = TextEditingController();
  final _parentesco = TextEditingController();
  final _especialidad = TextEditingController();
  final _licenciatura = TextEditingController();
  final _grado = TextEditingController();

  List<dynamic> _acudientes = [];
  List<dynamic> _estudiantes = [];
  final Set<int> _seleccionados = {};

  bool _guardando = false;
  String? _error;

  bool get _editando => widget.usuario != null;

  String get _rolNombre {
    for (final r in widget.roles) {
      if (r['idRol'] == _idRol) {
        return (r['nombreRol'] ?? '').toString().trim().toUpperCase();
      }
    }
    return _rolesPorId[_idRol] ?? '';
  }

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    if (u != null) {
      final t = (u['tipoDocumento'] ?? '').toString();
      _tipoDoc = _tipos.contains(t) ? t : null;
      _numDoc.text = (u['numeroDocumento'] ?? '').toString();
      _nombre.text = (u['nombre'] ?? '').toString();
      _apellido.text = (u['apellido'] ?? '').toString();
      _email.text = (u['email'] ?? '').toString();
      _telefono.text = (u['telefono'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _numDoc, _nombre, _apellido, _email, _telefono, _password,
      _parentesco, _especialidad, _licenciatura, _grado
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _alCambiarRol(int? id) async {
    setState(() => _idRol = id);
    try {
      if (_rolNombre == "ESTUDIANTE" && _acudientes.isEmpty) {
        final d = await ApiClient.get('/reportes/acudientes');
        if (mounted) setState(() => _acudientes = d as List<dynamic>);
      } else if (_rolNombre == "ACUDIENTE" && _estudiantes.isEmpty) {
        final d = await ApiClient.get('/reportes/estudiantes');
        if (mounted) setState(() => _estudiantes = d as List<dynamic>);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  Future<void> _guardar() async {
    setState(() => _error = null);

    final dto = <String, dynamic>{
      'tipoDocumento': _tipoDoc ?? '',
      'numeroDocumento': _numDoc.text.trim(),
      'nombre': _nombre.text.trim(),
      'apellido': _apellido.text.trim(),
      'email': _email.text.trim(),
      'telefono': _telefono.text.trim(),
    };

    if (dto['tipoDocumento'] == '' ||
        dto['numeroDocumento'] == '' ||
        dto['nombre'] == '' ||
        dto['apellido'] == '' ||
        dto['email'] == '') {
      setState(() => _error =
          "Completa tipo y número de documento, nombre, apellido y correo.");
      return;
    }
    if (!_editando && _password.text.isEmpty) {
      setState(() => _error = "La contraseña es obligatoria para crear un usuario.");
      return;
    }
    if (!_editando && _idRol == null) {
      setState(() => _error = "Selecciona un rol.");
      return;
    }
    if (_password.text.isNotEmpty) dto['password'] = _password.text;

    setState(() => _guardando = true);
    try {
      if (!_editando) {
        dto['rol'] = {'idRol': _idRol};
        switch (_rolNombre) {
          case "ACUDIENTE":
            dto['parentesco'] = _parentesco.text.trim();
            dto['estudiantesIds'] = _seleccionados.toList();
            break;
          case "DOCENTE":
            dto['especialidad'] = _especialidad.text.trim();
            dto['licenciatura'] = _licenciatura.text.trim();
            dto['gradoFormacion'] = _grado.text.trim();
            break;
          case "ESTUDIANTE":
            if (_idAcudiente != null) dto['idAcudiente'] = _idAcudiente;
            break;
        }
        await ApiClient.post('/usuario', dto);
      } else {
        await ApiClient.put('/usuario/${widget.usuario!['idUsuario']}', dto);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _guardando = false;
        });
      }
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.workSans(color: AppColors.tintaSuave, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: const OutlineInputBorder(borderRadius: AppColors.hojaChica),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppColors.hojaChica,
          borderSide: BorderSide(color: AppColors.borde, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppColors.hojaChica,
          borderSide: BorderSide(color: AppColors.amarillo500, width: 2),
        ),
      );

  Widget _campo(String label, TextEditingController c,
      {TextInputType? tipo, bool oculto = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: tipo,
        obscureText: oculto,
        decoration: _dec(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = _rolNombre;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editando ? "Editar usuario" : "Nuevo usuario",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.verde900,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoDoc,
                  decoration: _dec("Tipo de documento"),
                  items: _tipos
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _tipoDoc = v),
                ),
              ),
              _campo("Número de documento", _numDoc, tipo: TextInputType.number),
              _campo("Nombre", _nombre),
              _campo("Apellido", _apellido),
              _campo("Correo", _email, tipo: TextInputType.emailAddress),
              _campo("Teléfono", _telefono, tipo: TextInputType.phone),
              _campo(
                _editando
                    ? "Contraseña (vacía = conservar la actual)"
                    : "Contraseña",
                _password,
                oculto: true,
              ),

              if (!_editando) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int>(
                    initialValue: _idRol,
                    decoration: _dec("Rol"),
                    items: widget.roles
                        .map<DropdownMenuItem<int>>((r) => DropdownMenuItem<int>(
                              value: r['idRol'] as int,
                              child: Text((r['nombreRol'] ?? '').toString().trim()),
                            ))
                        .toList(),
                    onChanged: _alCambiarRol,
                  ),
                ),

                if (rol == "DOCENTE") ...[
                  _campo("Especialidad", _especialidad),
                  _campo("Licenciatura", _licenciatura),
                  _campo("Grado de formación", _grado),
                ],

                if (rol == "ESTUDIANTE")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField<int?>(
                      initialValue: _idAcudiente,
                      isExpanded: true,
                      decoration: _dec("Acudiente"),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text("Sin acudiente por ahora"),
                        ),
                        ..._acudientes.map<DropdownMenuItem<int?>>((a) =>
                            DropdownMenuItem<int?>(
                              value: a['idAcudiente'] as int,
                              child: Text(
                                "${a['nombre']} ${a['apellido']} (${a['numeroDocumento']})",
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (v) => setState(() => _idAcudiente = v),
                    ),
                  ),

                if (rol == "ACUDIENTE") ...[
                  _campo("Parentesco (padre, madre...)", _parentesco),
                  Text(
                    "Estudiantes a cargo (${_seleccionados.length})",
                    style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w700, color: AppColors.verde900),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borde, width: 2),
                      borderRadius: AppColors.hojaChica,
                    ),
                    child: _estudiantes.isEmpty
                        ? const Center(child: Text("Cargando estudiantes..."))
                        : ListView(
                            children: _estudiantes.map<Widget>((e) {
                              final id = e['idEstudiante'] as int;
                              return CheckboxListTile(
                                dense: true,
                                activeColor: AppColors.verde700,
                                value: _seleccionados.contains(id),
                                title: Text(
                                  "${e['nombre']} ${e['apellido']} (${e['numeroDocumento']})",
                                  style: GoogleFonts.workSans(fontSize: 13),
                                ),
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _seleccionados.add(id);
                                  } else {
                                    _seleccionados.remove(id);
                                  }
                                }),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: GoogleFonts.workSans(
                        color: const Color(0xFFC0392B), fontWeight: FontWeight.w600),
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _guardando ? null : () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verde700,
                        foregroundColor: Colors.white,
                      ),
                      child: _guardando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Guardar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}