import 'package:flutter/material.dart';
import '../models/usuario.dart';

class HomeScreen extends StatelessWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PISE-GGM")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bienvenido, ${usuario.nombre} ${usuario.apellido}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Rol: ${usuario.rol?.nombreRol ?? ''}"),
          ],
        ),
      ),
    );
  }
}