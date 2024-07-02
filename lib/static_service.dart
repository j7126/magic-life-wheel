import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:magic_life_wheel/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_life_wheel/settings/settings.dart';

class Service {
  static const appName = "Magic Life Wheel";
  static const appBaseUrl = "https://magic-life-wheel.j7126.dev/";

  static late SettingsService settingsService;
  static late MTGDataLoader dataLoader;

  static final bool supportScanner = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static final bool supportFullScreenButton = kIsWeb || (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
}
