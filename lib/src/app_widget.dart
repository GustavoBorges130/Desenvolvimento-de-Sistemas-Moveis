import 'package:material_ui/material_ui.dart';

/// Widget raiz do aplicativo.
class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FastLocation',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('FastLocation')),
      ),
    );
  }
}
