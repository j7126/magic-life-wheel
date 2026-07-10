import 'dart:io';

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
import 'package:magic_life_wheel/util/color/darken.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

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
  bool ready = false;

  String? waitingUri;
  late AppLinks _appLinks;

  Color? overrideAcentColor;

  void mtgDataLoaded() {
    setState(() {});
  }

  void loadMtgData() async {
    Service.dataLoader = MTGDataLoader(mtgDataLoaded);
    Service.dataLoader.loadAll();
  }

  Future loadSettingsService() async {
    Service.settingsService = await SettingsService.build();
  }

  void getAccentColor() async {
    if (Platform.isLinux) {
      try {
        var client = XdgDesktopPortalClient();
        var result = await client.settings.read(
          "org.freedesktop.appearance",
          "accent-color",
        );
        var vals = List.from(
          result.asVariant().asStruct().map((x) => x.asDouble()),
        );
        if (vals.length == 3 && !vals.any((x) => x < 0 || x > 1)) {
          var color = Color.fromARGB(
            255,
            (255 * vals[0]).floor(),
            (255 * vals[1]).floor(),
            (255 * vals[2]).floor(),
          );
          if (mounted) {
            setState(() {
              overrideAcentColor = color;
            });
          }
        }
      } catch (exception) {
        overrideAcentColor = null;
      }
    }
  }

  void load() async {
    await loadSettingsService();
    setState(() {
      ready = true;
    });
    loadMtgData();
    getAccentColor();
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

    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        var seedColor = overrideAcentColor ?? darkDynamic?.primary ?? Colors.green;
        var baseColorScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
        );
        var colorScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
          surface: baseColorScheme.surface.darken(0.01),
          surfaceContainerLow: baseColorScheme.surfaceContainerLow.darken(0.01),
          surfaceContainerLowest: baseColorScheme.surfaceContainerLowest.darken(0.01),
          surfaceContainer: baseColorScheme.surfaceContainer.darken(0.01),
          surfaceContainerHigh: baseColorScheme.surfaceContainerHigh.darken(0.09),
          surfaceContainerHighest: baseColorScheme.surfaceContainerHighest.darken(0.01),
        );
        return MaterialApp(
          title: Service.appName,
          theme: ThemeData(
            colorScheme: colorScheme,
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
