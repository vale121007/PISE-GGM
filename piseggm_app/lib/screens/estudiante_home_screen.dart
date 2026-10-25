import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'placeholder_screen.dart';

class EstudianteHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const EstudianteHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: "Panel del Estudiante",
      items: [
        PanelCardData(
          icon: Icons.assessment,
          title: "Mis Notas",
          subtitle: "Consultar mis calificaciones por periodo",
          destino: () => const PlaceholderScreen(titulo: "Mis Notas"),
        ),
        PanelCardData(
          icon: Icons.account_tree,
          title: "Mi Curso",
          subtitle: "Ver mi curso y asignaturas/dimensiones",
          destino: () => const PlaceholderScreen(titulo: "Mi Curso"),
        ),
        PanelCardData(
          icon: Icons.badge,
          title: "Mi Perfil",
          subtitle: "Ver mis datos personales",
          destino: () => const PlaceholderScreen(titulo: "Mi Perfil"),
        ),
      ],
    );
  }
}