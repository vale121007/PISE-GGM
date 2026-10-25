import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'placeholder_screen.dart';
import 'usuarios_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const AdminHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: "Panel de administración",
      items: [
        PanelCardData(
          icon: Icons.people,
          title: "Usuarios",
          subtitle: "Gestionar cuentas de usuario y roles",
          destino: () => const UsuariosScreen(),
        ),
        PanelCardData(
          icon: Icons.work,
          title: "Docentes",
          subtitle: "Ver y administrar docentes",
          destino: () => const PlaceholderScreen(titulo: "Docentes"),
        ),
        PanelCardData(
          icon: Icons.school,
          title: "Estudiantes",
          subtitle: "Ver y administrar estudiantes",
          destino: () => const PlaceholderScreen(titulo: "Estudiantes"),
        ),
        PanelCardData(
          icon: Icons.account_tree,
          title: "Cursos",
          subtitle: "Gestionar cursos del colegio",
          destino: () => const PlaceholderScreen(titulo: "Cursos"),
        ),
        PanelCardData(
          icon: Icons.menu_book,
          title: "Asignaturas",
          subtitle: "Gestionar asignaturas y dimensiones",
          destino: () => const PlaceholderScreen(titulo: "Asignaturas"),
        ),
        PanelCardData(
          icon: Icons.assignment_ind,
          title: "Asignaciones",
          subtitle: "Asignar docentes a cursos",
          destino: () => const PlaceholderScreen(titulo: "Asignaciones"),
        ),
        PanelCardData(
          icon: Icons.assessment,
          title: "Notas",
          subtitle: "Consultar y gestionar notas",
          destino: () => const PlaceholderScreen(titulo: "Notas"),
        ),
        PanelCardData(
          icon: Icons.groups,
          title: "Acudientes",
          subtitle: "Ver y administrar acudientes",
          destino: () => const PlaceholderScreen(titulo: "Acudientes"),
        ),
      ],
    );
  }
}