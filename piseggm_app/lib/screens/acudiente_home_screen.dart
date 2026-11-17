import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../widgets/panel_scaffold.dart';
import 'boletin_screen.dart';
import 'mi_perfil_screen.dart';
import 'mis_acudidos_screen.dart';

class AcudienteHomeScreen extends StatelessWidget {
  final Usuario usuario;
  const AcudienteHomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return PanelScaffold(
      usuario: usuario,
      tituloPanel: 'Panel del Acudiente',
      items: [
        PanelCardData(
          icon: Icons.groups,
          title: 'Mis Acudidos',
          subtitle: 'Ver los estudiantes a mi cargo',
          destino: () => const MisAcudidosScreen(),
        ),
        PanelCardData(
          icon: Icons.assessment,
          title: 'Boletín',
          subtitle: 'Consultar el boletín de mis acudidos',
          destino: () => const BoletinScreen(esAcudiente: true),
        ),
        PanelCardData(
          icon: Icons.badge,
          title: 'Mi Perfil',
          subtitle: 'Ver mis datos personales',
          destino: () => const MiPerfilScreen(esAcudiente: true),
        ),
      ],
    );
  }
}