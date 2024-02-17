// ignore_for_file: non_constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  late SharedPreferences prefs;

  static Future<SettingsService> build() async {
    SettingsService service = SettingsService();
    await service._setup();
    return service;
  }

  Future _setup() async {
    prefs = await SharedPreferences.getInstance();
    await _readData();
  }

  Future _readData() async {
    var getScryfallImages = prefs.getBool('getScryfallImages');
    if (getScryfallImages != null) {
      _pref_getScryfallImages = getScryfallImages;
    }

    var enableCommanderDamage = prefs.getBool('enableCommanderDamage');
    if (enableCommanderDamage != null) {
      _pref_enableCommanderDamage = enableCommanderDamage;
    }
  }

  bool _pref_getScryfallImages = true;
  bool get pref_getScryfallImages => _pref_getScryfallImages;
  set pref_getScryfallImages(bool val) {
    _pref_getScryfallImages = val;
    prefs.setBool('getScryfallImages', val);
  }

  bool _pref_enableCommanderDamage = true;
  bool get pref_enableCommanderDamage => _pref_enableCommanderDamage;
  set pref_enableCommanderDamage(bool val) {
    _pref_enableCommanderDamage = val;
    prefs.setBool('enableCommanderDamage', val);
  }
}
