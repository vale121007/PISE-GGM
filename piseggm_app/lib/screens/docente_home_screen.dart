import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'docente_asignaciones_screen.dart';
import 'docente_estudiantes_screen.dart';
import 'docente_notas_screen.dart';
import 'docente_periodos_screen.dart';

class DocenteHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const DocenteHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: 'Panel del Docente',
      items: [
        PanelCardData(
          icon: Icons.account_tree,
          title: 'Mis Asignaciones',
          subtitle: 'Mis cursos y asignaturas o dimensiones a cargo',
          destino: () => const DocenteAsignacionesScreen(),
        ),
        PanelCardData(
          icon: Icons.school,
          title: 'Mis Estudiantes',
          subtitle: 'Ver los estudiantes de mis cursos',
          destino: () => const DocenteEstudiantesScreen(),
        ),
        PanelCardData(
          icon: Icons.edit_note,
          title: 'Registrar Notas',
          subtitle: 'Subir promedio y observación de mis estudiantes',
          destino: () => const DocenteNotasScreen(),
        ),
        PanelCardData(
          icon: Icons.calendar_month,
          title: 'Periodo Académico',
          subtitle: 'Ver y describir los periodos del año',
          destino: () => const DocentePeriodosScreen(),
        ),
      ],
    );
  }
}