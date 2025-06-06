import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/layouts/layout_2a.dart';
import 'package:magic_life_wheel/layouts/layouts.dart';
import 'package:magic_life_wheel/static_service.dart';

class Game {
  Game(List<String>? players, int? layout) {
    if (players == null || layout == null || players.length < 2 || players.length > 6) {
      setupNew();
    } else {
      import(players, layout);
    }
  }

  Game.fromPlayerList(this.players, int layout) {
    setPlayers(
      players.length,
      layoutId: layout,
      reset: false,
    );
  }

  late Layout layout;
  List<Player> players = [];
  int layoutId = 0;

  bool get rotated => layout.rotated;
  set rotated(bool val) => layout.rotated = val;

  bool get isGameReset => !players.any((x) => !x.isGameReset);

  bool get isPlayersReset => !players.any((x) => !x.isReset);

  void setupNew() {
    setPlayers(3);
  }

  void import(List<String> playerStrings, int layout) {
    for (var playerString in playerStrings) {
      Player player;
      try {
        player = Player.fromJson(jsonDecode(playerString));
      } catch (_) {
        player = Player(
          name: "",
        );
      }
      players.add(player);
    }
    setPlayers(
      players.length,
      layoutId: layout,
      reset: false,
    );
  }

  void setPlayers(int numPlayers, {int layoutId = 0, bool reset = true}) {
    this.layoutId = layoutId;
    layout = Layout2a();
    var layouts = Layouts.layoutsBySize[numPlayers];
    if (layouts != null) {
      if (layouts.length <= this.layoutId) {
        this.layoutId = 0;
      }
      layout = layouts[this.layoutId];
    }
    setupPlayers(reset: reset);
  }

  void setupPlayers({bool reset = true}) {
    if (layout.players > players.length) {
      for (var i = players.length; i < layout.players; i++) {
        players.add(
          Player(
            name: "",
          ),
        );
      }
    } else {
      var diff = players.length - layout.players;
      for (var i = 0; i < diff; i++) {
        players.removeLast();
      }
    }

    if (reset) {
      resetGame(save: false);
    }

    save();
  }

  void resetGame({bool save = true}) {
    for (var player in players) {
      player.resetGame();
    }
    if (save) {
      this.save();
    }
  }

  void resetPlayers() {
    players.clear();
    setupPlayers();
  }

  void deletePlayer(int i) {
    if (layout.players > 2) {
      players.removeAt(i);
      var numPlayers = players.length;
      var layouts = Layouts.layoutsBySize[numPlayers]!;
      if (layouts.length <= layoutId) {
        layoutId = 0;
      }
      layout = layouts[layoutId];
    }
  }

  void switchLayout() {
    rotated = false;
    var layouts = Layouts.layoutsBySize[players.length];
    if (layouts == null) return;
    layoutId++;
    if (layoutId >= layouts.length) layoutId = 0;
    layout = layouts[layoutId];
    save();
  }

  void save() async {
    await Future.delayed(const Duration(milliseconds: 200));
    Service.settingsService.conf_layout = layoutId;
    Service.settingsService.conf_players = await compute(
      (p) => p.map((e) => jsonEncode(e)).toList(),
      players,
    );
  }
}
