import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:magic_life_wheel/mtgjson/data_updater.dart';
import 'package:magic_life_wheel/mtgjson/file_names.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel/generated/all_set_cards.pb.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel/generated/sets.pb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MTGDataLoader {
  MTGDataLoader(this.onLoad);

  Function onLoad;

  bool loaded = false;

  ProtobufAllSetCards? allSetCards;
  SetList? sets;
  late SharedPreferences prefs;

  void loadAll() async {
    prefs = await SharedPreferences.getInstance();
    await loadCards();
    await loadSets();
    loaded = true;
    onLoad();
    // wait a bit before checking for updates
    await Future.delayed(Duration(seconds: 2));
    await DataUpdater.checkForUpdates(this);
  }

  Future loadCards() async {
    var data = await readData(FileNames.allCards);
    allSetCards = ProtobufAllSetCards.fromBuffer(data.buffer.asUint8List());
  }

  Future loadSets() async {
    var data = await readData(FileNames.setList);
    sets = SetList.fromBuffer(data.buffer.asUint8List());
  }

  Future<Uint8List> readData(String name) async {
    var currentUpdatedRevision = prefs.getInt("currentDataRevision");

    if (!kIsWeb && currentUpdatedRevision != null && currentUpdatedRevision > DataUpdater.minBundledRevision) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/$name.bin");
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    }

    var data = await rootBundle.load('data/$name.bin');
    return data.buffer.asUint8List();
  }
}
