import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:magic_life_wheel/pages/life_counter_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Magic Life Wheel',
          theme: ThemeData(
            colorScheme: darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                ),
            useMaterial3: true,
          ),
          home: const LifeCounterPage(),
        );
      },
    );
  }
}
