import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/all_set_cards.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/sets.dart';

class MTGDataLoader {
  MTGDataLoader(this.onLoad) {
    loadAll();
  }

  Function onLoad;

  bool loaded = false;
  
  AllSetCards? allSetCards;
  MtgSets? sets;

  Future loadAll() async {
    await loadCards();
    await loadSets();
    loaded = true;
    onLoad();
  }

  Future loadCards() async {
    String json = await rootBundle.loadString('data/all_cards.json');
    Map<String, dynamic> data = await compute((j) => jsonDecode(j), json);
    allSetCards = AllSetCards.fromJson(data);
  }

  Future loadSets() async {
    String json = await rootBundle.loadString('data/set_list.json');
    Map<String, dynamic> data = await compute((j) => jsonDecode(j), json);
    sets = MtgSets.fromJson(data);
  }
}
