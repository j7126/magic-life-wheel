import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:magic_life_wheel/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_life_wheel/life_counter_page/life_counter_page.dart';
import 'package:magic_life_wheel/settings/settings.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/platform_util/web/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();
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

  String? waitingUri;
  late AppLinks _appLinks;

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
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
      var str = uri.toString();
      if (str.startsWith(Service.appBaseUrl) && str != Service.appBaseUrl) {
        if (kIsWeb) {
          pushHome();
        }
        setState(() {
          waitingUri = str;
        });
      }
    });

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
            colorScheme: ColorScheme.fromSeed(
              seedColor: darkDynamic?.primary ?? Colors.green,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: ready
              ? LifeCounterPage(
                  waitingUri: waitingUri,
                  onUriConsumed: () {
                    setState(() {
                      waitingUri = null;
                    });
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }
}
