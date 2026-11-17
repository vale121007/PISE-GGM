import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'admin_reportes.dart';
import 'usuarios_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const AdminHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: 'Panel de administración',
      items: [
        PanelCardData(
          icon: Icons.people,
          title: 'Usuarios',
          subtitle: 'Cuentas, roles y usuarios nuevos por aprobar',
          destino: () => const UsuariosScreen(),
        ),
        PanelCardData(
          icon: Icons.work,
          title: 'Docentes',
          subtitle: 'Reporte de docentes',
          destino: () => const ReporteDocentes(),
        ),
        PanelCardData(
          icon: Icons.school,
          title: 'Estudiantes',
          subtitle: 'Reporte de estudiantes y su curso',
          destino: () => const ReporteEstudiantes(),
        ),
        PanelCardData(
          icon: Icons.groups,
          title: 'Acudientes',
          subtitle: 'Reporte de acudientes y sus estudiantes',
          destino: () => const ReporteAcudientes(),
        ),
        PanelCardData(
          icon: Icons.account_tree,
          title: 'Cursos',
          subtitle: 'Cursos del colegio',
          destino: () => const ReporteCursos(),
        ),
        PanelCardData(
          icon: Icons.menu_book,
          title: 'Asignaturas',
          subtitle: 'Asignaturas y dimensiones',
          destino: () => const ReporteAsignaturas(),
        ),
        PanelCardData(
          icon: Icons.assignment_ind,
          title: 'Asignaciones',
          subtitle: 'Docentes asignados a cada curso',
          destino: () => const ReporteAsignaciones(),
        ),
        PanelCardData(
          icon: Icons.assessment,
          title: 'Notas',
          subtitle: 'Desempeño de los estudiantes',
          destino: () => const ReporteNotas(),
        ),
      ],
    );
  }
}