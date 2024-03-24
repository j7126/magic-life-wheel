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
    _readData();
  }

  void _readData() {
    var getScryfallImages = prefs.getBool('getScryfallImages');
    if (getScryfallImages != null) {
      _pref_getScryfallImages = getScryfallImages;
    }

    var enableCommanderDamage = prefs.getBool('enableCommanderDamage');
    if (enableCommanderDamage != null) {
      _pref_enableCommanderDamage = enableCommanderDamage;
    }

    var symmetricalCommanderDamageButtons = prefs.getBool('symmetricalCommanderDamageButtons');
    if (symmetricalCommanderDamageButtons != null) {
      _pref_asymmetricalCommanderDamageButtons = symmetricalCommanderDamageButtons;
    }

    var showChangingLife = prefs.getBool('showChangingLife');
    if (showChangingLife != null) {
      _pref_showChangingLife = showChangingLife;
    }

    var startingLife = prefs.getInt('startingLife');
    if (startingLife != null) {
      _pref_startingLife = startingLife;
    }

    var enableSaveState = prefs.getBool('enableSaveState');
    if (enableSaveState != null) {
      _pref_enableSaveState = enableSaveState;
    }

    var players = prefs.getStringList('players');
    if (players != null) {
      _conf_players = players;
    }

    var layout = prefs.getInt('layout');
    if (layout != null) {
      _conf_layout = layout;
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

  bool _pref_asymmetricalCommanderDamageButtons = true;
  bool get pref_asymmetricalCommanderDamageButtons => _pref_asymmetricalCommanderDamageButtons;
  set pref_asymmetricalCommanderDamageButtons(bool val) {
    _pref_asymmetricalCommanderDamageButtons = val;
    prefs.setBool('symmetricalCommanderDamageButtons', val);
  }

  bool _pref_showChangingLife = true;
  bool get pref_showChangingLife => _pref_showChangingLife;
  set pref_showChangingLife(bool val) {
    _pref_showChangingLife = val;
    prefs.setBool('showChangingLife', val);
  }

  int _pref_startingLife = 40;
  int get pref_startingLife => _pref_startingLife;
  set pref_startingLife(int val) {
    _pref_startingLife = val;
    prefs.setInt('startingLife', val);
  }

  bool _pref_enableSaveState = true;
  bool get pref_enableSaveState => _pref_enableSaveState;
  set pref_enableSaveState(bool val) {
    if (!val) {
      conf_players = [];
      conf_layout = 0;
    }
    _pref_enableSaveState = val;
    prefs.setBool('enableSaveState', val);
  }

  List<String> _conf_players = [];
  List<String> get conf_players => _conf_players;
  set conf_players(List<String> val) {
    if (pref_enableSaveState) {
      _conf_players = val;
      prefs.setStringList('players', val);
    }
  }

  int _conf_layout = 0;
  int get conf_layout => _conf_layout;
  set conf_layout(int val) {
    if (pref_enableSaveState) {
      _conf_layout = val;
      prefs.setInt('layout', val);
    }
  }
}
