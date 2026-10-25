import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import 'usuario_form.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<dynamic> _usuarios = [];
  List<dynamic> _roles = [];
  List<dynamic> _pendientes = [];
  final Map<int, int> _rolPendiente = {};
  final _buscador = TextEditingController();
  int? _filtroRol;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  String _msg(Object e) => e.toString().replaceAll("Exception: ", "");

  void _avisar(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: error ? const Color(0xFF9B2C22) : AppColors.verde700,
    ));
  }

  Future<bool> _confirmar(String titulo, String texto) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Aceptar")),
        ],
      ),
    );
    return r == true;
  }

  // ---------- Carga ----------
  Future<void> _cargarTodo() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      _roles = (await ApiClient.get('/rol')) as List<dynamic>;
      await _cargarPendientes();
      await _cargarUsuarios();
    } catch (e) {
      _error = _msg(e);
    }
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _cargarUsuarios() async {
    final ruta = _filtroRol == null
        ? '/reportes/usuarios'
        : '/reportes/usuarios/rol/$_filtroRol';
    _usuarios = (await ApiClient.get(ruta)) as List<dynamic>;
  }

  Future<void> _cargarPendientes() async {
    try {
      _pendientes = (await ApiClient.get('/usuario/pendientes')) as List<dynamic>;
    } catch (_) {
      _pendientes = [];
    }
  }

  Future<void> _recargar() async {
    try {
      await _cargarPendientes();
      await _cargarUsuarios();
    } catch (e) {
      _avisar(_msg(e), error: true);
    }
    if (mounted) setState(() {});
  }

  // ---------- Utilidades ----------
  String _nombreRol(dynamic id) {
    for (final r in _roles) {
      if (r['idRol'] == id) return (r['nombreRol'] ?? '').toString().trim();
    }
    return 'Sin rol';
  }

  int? _valorRol(dynamic id) =>
      _roles.any((r) => r['idRol'] == id) ? id as int : null;

  List<DropdownMenuItem<int>> _itemsRol() => _roles
      .map<DropdownMenuItem<int>>((r) => DropdownMenuItem<int>(
            value: r['idRol'] as int,
            child: Text((r['nombreRol'] ?? '').toString().trim()),
          ))
      .toList();

  bool _esYo(dynamic u) =>
      Sesion.usuario != null && Sesion.usuario!.idUsuario == u['idUsuario'];

  List<dynamic> get _filtrados {
    final t = _buscador.text.trim().toLowerCase();
    if (t.isEmpty) return _usuarios;
    return _usuarios.where((u) {
      final base =
          "${u['nombre'] ?? ''} ${u['apellido'] ?? ''} ${u['numeroDocumento'] ?? ''}"
              .toLowerCase();
      return base.contains(t);
    }).toList();
  }

  // ---------- Acciones ----------
  Future<void> _abrirForm([Map<String, dynamic>? u]) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.blanco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => UsuarioForm(usuario: u, roles: _roles),
    );
    if (ok == true) {
      _avisar(u == null ? "Usuario creado." : "Usuario actualizado.");
      await _recargar();
    }
  }

  Future<void> _cambiarRol(dynamic u, int idRol) async {
    final ok = await _confirmar("Cambiar rol",
        "¿Cambiar el rol de ${u['nombre']} ${u['apellido']} a ${_nombreRol(idRol)}?");
    if (ok) {
      try {
        await ApiClient.put('/usuario/${u['idUsuario']}/rol/$idRol');
        _avisar("Rol actualizado.");
      } catch (e) {
        _avisar(_msg(e), error: true);
      }
    }
    await _recargar();
  }

  Future<void> _eliminar(dynamic u) async {
    final ok = await _confirmar("Eliminar usuario",
        "¿Eliminar a ${u['nombre']} ${u['apellido']}? Esta acción no se puede deshacer.");
    if (!ok) return;
    try {
      await ApiClient.delete('/usuario/${u['idUsuario']}');
      _avisar("Usuario eliminado.");
    } catch (e) {
      _avisar(_msg(e), error: true);
    }
    await _recargar();
  }

  Future<void> _aprobar(dynamic p) async {
    final id = p['idUsuario'] as int;
    final rolMap = p['rol'];
    final idRol =
        _rolPendiente[id] ?? (rolMap is Map ? rolMap['idRol'] as int? : null);
    if (idRol == null) {
      _avisar("Elige un rol para ${p['nombre']} antes de aceptar.", error: true);
      return;
    }
    try {
      await ApiClient.put('/usuario/$id/aprobar/$idRol', {});
      _avisar("${p['nombre']} ya puede ingresar al sistema.");
    } catch (e) {
      _avisar(_msg(e), error: true);
    }
    await _recargar();
  }

  Future<void> _rechazar(dynamic p) async {
    final ok = await _confirmar(
        "Rechazar solicitud", "¿Rechazar la solicitud de ${p['nombre']} ${p['apellido']}?");
    if (!ok) return;
    try {
      await ApiClient.put('/usuario/${p['idUsuario']}/rechazar');
      _avisar("Solicitud rechazada.");
    } catch (e) {
      _avisar(_msg(e), error: true);
    }
    await _recargar();
  }

  // ---------- Interfaz ----------
  Widget _bloquePendientes() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F5),
        borderRadius: AppColors.hojaMedia,
        border: const Border(
          top: BorderSide(color: Color(0xFFC0392B), width: 5),
          left: BorderSide(color: Color(0xFFE8B4B0)),
          right: BorderSide(color: Color(0xFFE8B4B0)),
          bottom: BorderSide(color: Color(0xFFE8B4B0)),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active, color: Color(0xFFC0392B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Nuevos usuarios por aprobar",
                  style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w700, color: const Color(0xFF9B2C22)),
                ),
              ),
              CircleAvatar(
                radius: 13,
                backgroundColor: const Color(0xFFC0392B),
                child: Text("${_pendientes.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          ..._pendientes.map<Widget>((p) {
            final id = p['idUsuario'] as int;
            final rolMap = p['rol'];
            final actual = _rolPendiente[id] ??
                (rolMap is Map ? rolMap['idRol'] as int? : null);
            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borde)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${p['nombre']} ${p['apellido']}",
                      style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFC0392B))),
                  Text(
                    "${p['tipoDocumento'] ?? ''} ${p['numeroDocumento'] ?? ''} · ${p['email'] ?? ''}",
                    style: GoogleFonts.workSans(
                        fontSize: 12, color: AppColors.tintaSuave),
                  ),
                  const SizedBox(height: 6),
                  DropdownButton<int>(
                    isExpanded: true,
                    hint: const Text("Elige un rol"),
                    value: _valorRol(actual),
                    items: _itemsRol(),
                    onChanged: (v) {
                      if (v != null) setState(() => _rolPendiente[id] = v);
                    },
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _aprobar(p),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Aceptar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verde700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => _rechazar(p),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Rechazar"),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC0392B)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _filtros(int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.verde100,
        borderRadius: AppColors.hojaMedia,
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<int?>(
            initialValue: _filtroRol,
            isExpanded: true,
            decoration: const InputDecoration(
                labelText: "Filtrar por rol",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: AppColors.hojaChica)),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text("Todos los roles")),
              ..._roles.map<DropdownMenuItem<int?>>((r) => DropdownMenuItem<int?>(
                    value: r['idRol'] as int,
                    child: Text((r['nombreRol'] ?? '').toString().trim()),
                  )),
            ],
            onChanged: (v) async {
              setState(() => _filtroRol = v);
              try {
                await _cargarUsuarios();
              } catch (e) {
                _avisar(_msg(e), error: true);
              }
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _buscador,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: "Nombre, apellido o documento...",
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: AppColors.hojaChica),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.verde900,
                borderRadius: AppColors.hojaChica,
              ),
              child: Text("$total registros",
                  style: GoogleFonts.workSans(
                      color: AppColors.amarillo300, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaUsuario(dynamic u) {
    final yo = _esYo(u);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppColors.hojaMedia,
        border: const Border(
          top: BorderSide(color: AppColors.amarillo500, width: 4),
          left: BorderSide(color: AppColors.borde),
          right: BorderSide(color: AppColors.borde),
          bottom: BorderSide(color: AppColors.borde),
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.verde900.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${u['nombre'] ?? ''} ${u['apellido'] ?? ''}",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.verde900)),
          const SizedBox(height: 4),
          Text("${u['tipoDocumento'] ?? ''} ${u['numeroDocumento'] ?? ''}",
              style: GoogleFonts.workSans(fontSize: 13, color: AppColors.tinta)),
          Text("${u['email'] ?? '—'}",
              style: GoogleFonts.workSans(fontSize: 12, color: AppColors.tintaSuave)),
          if ((u['telefono'] ?? '').toString().isNotEmpty)
            Text("Tel. ${u['telefono']}",
                style: GoogleFonts.workSans(
                    fontSize: 12, color: AppColors.tintaSuave)),
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text("Sin rol"),
                  value: _valorRol(u['idRol']),
                  items: _itemsRol(),
                  onChanged: yo
                      ? null
                      : (v) {
                          if (v != null && v != u['idRol']) _cambiarRol(u, v);
                        },
                ),
              ),
              IconButton(
                tooltip: "Editar",
                icon: const Icon(Icons.edit, color: AppColors.verde700),
                onPressed: () => _abrirForm(Map<String, dynamic>.from(u)),
              ),
              IconButton(
                tooltip: yo ? "No puedes eliminar tu propia cuenta" : "Eliminar",
                icon: Icon(Icons.delete,
                    color: yo ? Colors.grey : const Color(0xFFC0392B)),
                onPressed: yo ? null : () => _eliminar(u),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;

    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        backgroundColor: AppColors.verde900,
        foregroundColor: Colors.white,
        title: Text("Gestión de usuarios",
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.amarillo500,
        foregroundColor: AppColors.verde900,
        onPressed: () => _abrirForm(),
        icon: const Icon(Icons.person_add),
        label: const Text("Nuevo usuario"),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.verde700))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _cargarTodo, child: const Text("Reintentar")),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _recargar,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    children: [
                      if (_pendientes.isNotEmpty) _bloquePendientes(),
                      _filtros(lista.length),
                      if (lista.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text("Sin resultados")),
                        )
                      else
                        ...lista.map(_tarjetaUsuario),
                    ],
                  ),
                ),
    );
  }
}