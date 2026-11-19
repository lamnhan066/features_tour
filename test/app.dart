import 'package:material_ui/material_ui.dart';

class App extends StatelessWidget {
  const new({required this.tours, super.key});

  final List<Widget> tours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisSize: MainAxisSize.min, children: [...tours]),
    );
  }
}
