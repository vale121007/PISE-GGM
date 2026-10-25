import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'placeholder_screen.dart';

class DocenteHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const DocenteHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: "Panel del Docente",
      items: [
        PanelCardData(
          icon: Icons.account_tree,
          title: "Mis Asignaciones",
          subtitle: "Ver mis cursos y asignaturas/dimensiones a cargo",
          destino: () => const PlaceholderScreen(titulo: "Mis Asignaciones"),
        ),
        PanelCardData(
          icon: Icons.school,
          title: "Mis Estudiantes",
          subtitle: "Ver estudiantes de mis cursos",
          destino: () => const PlaceholderScreen(titulo: "Mis Estudiantes"),
        ),
        PanelCardData(
          icon: Icons.assessment,
          title: "Registrar Notas",
          subtitle: "Ingresar y actualizar notas de mis estudiantes",
          destino: () => const PlaceholderScreen(titulo: "Registrar Notas"),
        ),
        PanelCardData(
          icon: Icons.calendar_month,
          title: "Periodo Académico",
          subtitle: "Consultar el periodo académico actual",
          destino: () => const PlaceholderScreen(titulo: "Periodo Académico"),
        ),
      ],
    );
  }
}