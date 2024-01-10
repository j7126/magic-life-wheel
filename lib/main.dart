import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:magic_life_wheel/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_life_wheel/pages/life_counter_page.dart';
import 'package:magic_life_wheel/service/settings.dart';
import 'package:magic_life_wheel/service/static_service.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool settingsReady = false;
  bool get ready => settingsReady;

  void mtgDataOnLoad() {
    setState(() {});
  }

  void loadSettingsService() async {
    Service.settingsService = await SettingsService.build();
    setState(() {
      settingsReady = true;
    });
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    Service.dataLoader = MTGDataLoader(mtgDataOnLoad);
    loadSettingsService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: Service.appName,
          theme: ThemeData(
            colorScheme: darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                ),
            useMaterial3: true,
          ),
          home: ready
              ? const LifeCounterPage()
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }
}
