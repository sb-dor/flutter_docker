import 'package:flutter/material.dart';

void main() {
  runApp(MaterialAppInit());
}

class MaterialAppInit extends StatefulWidget {
  const MaterialAppInit({super.key});

  @override
  State<MaterialAppInit> createState() => _MaterialAppInitState();
}

class _MaterialAppInitState extends State<MaterialAppInit> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: App());
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => setState(() {
            _counter++;
          }),
          child: Text("$_counter"),
        ),
      ),
    );
  }
}
