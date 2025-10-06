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

    var enablePlanechase = prefs.getBool('enablePlanechase');
    if (enablePlanechase != null) {
      _pref_enablePlanechase = enablePlanechase;
    }

    var symmetricalCommanderDamageButtons = prefs.getBool('symmetricalCommanderDamageButtons');
    if (symmetricalCommanderDamageButtons != null) {
      _pref_asymmetricalCommanderDamageButtons = symmetricalCommanderDamageButtons;
    }

    var commanderDamageButtonsFacePlayer = prefs.getBool('commanderDamageButtonsFacePlayer');
    if (commanderDamageButtonsFacePlayer != null) {
      _pref_commanderDamageButtonsFacePlayer = commanderDamageButtonsFacePlayer;
    }

    var commanderDamageMiniGrid = prefs.getBool('commanderDamageMiniGrid');
    if (commanderDamageMiniGrid != null) {
      _pref_commanderDamageMiniGrid = commanderDamageMiniGrid;
    }

    var showChangingLife = prefs.getBool('showChangingLife');
    if (showChangingLife != null) {
      _pref_showChangingLife = showChangingLife;
    }

    var maximiseFontSize = prefs.getBool('maximiseFontSize');
    if (maximiseFontSize != null) {
      _pref_maximiseFontSize = maximiseFontSize;
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

    var planechaseEnableFunny = prefs.getBool('planechaseEnableFunny');
    if (planechaseEnableFunny != null) {
      _pref_planechaseEnableFunny = planechaseEnableFunny;
    }

    var planechaseDisabledSets = prefs.getStringList('planechaseDisabledSets');
    if (planechaseDisabledSets != null) {
      _pref_planechaseDisabledSets = planechaseDisabledSets.toSet();
    }

    var disableAnimations = prefs.getBool('disableAnimations');
    if (disableAnimations != null) {
      _pref_disableAnimations = disableAnimations;
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

  bool _pref_enablePlanechase = false;
  bool get pref_enablePlanechase => _pref_enablePlanechase;
  set pref_enablePlanechase(bool val) {
    _pref_enablePlanechase = val;
    prefs.setBool('enablePlanechase', val);
  }

  bool _pref_asymmetricalCommanderDamageButtons = true;
  bool get pref_asymmetricalCommanderDamageButtons => _pref_asymmetricalCommanderDamageButtons;
  set pref_asymmetricalCommanderDamageButtons(bool val) {
    _pref_asymmetricalCommanderDamageButtons = val;
    prefs.setBool('symmetricalCommanderDamageButtons', val);
  }

  bool _pref_commanderDamageButtonsFacePlayer = true;
  bool get pref_commanderDamageButtonsFacePlayer => _pref_commanderDamageButtonsFacePlayer;
  set pref_commanderDamageButtonsFacePlayer(bool val) {
    _pref_commanderDamageButtonsFacePlayer = val;
    prefs.setBool('commanderDamageButtonsFacePlayer', val);
  }

  bool _pref_commanderDamageMiniGrid = false;
  bool get pref_commanderDamageMiniGrid => _pref_commanderDamageMiniGrid;
  set pref_commanderDamageMiniGrid(bool val) {
    _pref_commanderDamageMiniGrid = val;
    prefs.setBool('commanderDamageMiniGrid', val);
  }

  bool _pref_showChangingLife = true;
  bool get pref_showChangingLife => _pref_showChangingLife;
  set pref_showChangingLife(bool val) {
    _pref_showChangingLife = val;
    prefs.setBool('showChangingLife', val);
  }

  bool _pref_maximiseFontSize = false;
  bool get pref_maximiseFontSize => _pref_maximiseFontSize;
  set pref_maximiseFontSize(bool val) {
    _pref_maximiseFontSize = val;
    prefs.setBool('maximiseFontSize', val);
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

  bool _pref_planechaseEnableFunny = false;
  bool get pref_planechaseEnableFunny => _pref_planechaseEnableFunny;
  set pref_planechaseEnableFunny(bool val) {
    _pref_planechaseEnableFunny = val;
    prefs.setBool('planechaseEnableFunny', val);
  }

  Set<String> _pref_planechaseDisabledSets = {"DA1"};
  Set<String> get pref_planechaseDisabledSets => _pref_planechaseDisabledSets;
  set pref_planechaseDisabledSets(Set<String> val) {
    _pref_planechaseDisabledSets = val;
    prefs.setStringList("planechaseDisabledSets", val.toList());
  }

  bool _pref_disableAnimations = false;
  bool get pref_disableAnimations => _pref_disableAnimations;
  set pref_disableAnimations(bool val) {
    _pref_disableAnimations = val;
    prefs.setBool('disableAnimations', val);
  }
}
