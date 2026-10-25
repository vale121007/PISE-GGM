import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'placeholder_screen.dart';

class AcudienteHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const AcudienteHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: "Panel del Acudiente",
      items: [
        PanelCardData(
          icon: Icons.groups,
          title: "Mis Acudidos",
          subtitle: "Ver los estudiantes a mi cargo",
          destino: () => const PlaceholderScreen(titulo: "Mis Acudidos"),
        ),
        PanelCardData(
          icon: Icons.assessment,
          title: "Notas",
          subtitle: "Consultar las notas de mis acudidos",
          destino: () => const PlaceholderScreen(titulo: "Notas"),
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