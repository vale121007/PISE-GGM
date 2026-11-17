import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'boletin_screen.dart';
import 'mi_curso_screen.dart';
import 'mi_perfil_screen.dart';

class EstudianteHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const EstudianteHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: 'Panel del Estudiante',
      items: [
        PanelCardData(
          icon: Icons.assessment,
          title: 'Mi Boletín',
          subtitle: 'Consultar mi informe de evaluación por periodo',
          destino: () => const BoletinScreen(),
        ),
        PanelCardData(
          icon: Icons.account_tree,
          title: 'Mi Curso',
          subtitle: 'Ver mi curso y sus asignaturas o dimensiones',
          destino: () => const MiCursoScreen(),
        ),
        PanelCardData(
          icon: Icons.badge,
          title: 'Mi Perfil',
          subtitle: 'Ver mis datos personales',
          destino: () => const MiPerfilScreen(),
        ),
      ],
    );
  }
}