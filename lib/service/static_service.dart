import 'dart:io';
import 'package:magic_life_wheel/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_life_wheel/service/settings.dart';

class Service {
  static const appName = "Magic Life Wheel";
  static const appBaseUrl = "https://magic-life-wheel.j7126.dev/";

  static late SettingsService settingsService;
  static late MTGDataLoader dataLoader;

  static final bool supportScanner = Platform.isAndroid || Platform.isIOS;
}
