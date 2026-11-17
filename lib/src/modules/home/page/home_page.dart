import 'package:material_ui/material_ui.dart';

/// Tela principal do FastLocation.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FastLocation')),
      body: const Center(child: Text('Consulta de CEP')),
    );
  }
}
