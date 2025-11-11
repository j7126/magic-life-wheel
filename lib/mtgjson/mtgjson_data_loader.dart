import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/sets.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel_protobuf/all_set_cards.pb.dart';

class MTGDataLoader {
  MTGDataLoader(this.onLoad) {
    loadAll();
  }

  Function onLoad;

  bool loaded = false;

  ProtobufAllSetCards? allSetCards;
  MtgSets? sets;

  Future loadAll() async {
    await loadCards();
    await loadSets();
    loaded = true;
    onLoad();
  }

  Future loadCards() async {
    var data = await rootBundle.load('data/all_cards.bin');
    allSetCards = ProtobufAllSetCards.fromBuffer(data.buffer.asUint8List());
  }

  Future loadSets() async {
    String json = await rootBundle.loadString('data/set_list.json');
    Map<String, dynamic> data = await compute((j) => jsonDecode(j), json);
    sets = MtgSets.fromJson(data);
  }
}
