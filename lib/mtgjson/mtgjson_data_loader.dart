import 'dart:convert';
import 'package:magic_life_wheel/mtgjson/dataModel/all_set_cards.dart';
import 'package:flutter/services.dart';

class MTGDataLoader {
  MTGDataLoader(this.onLoad) {
    loadAll();
  }

  Function onLoad;

  bool loaded = false;
  
  AllSetCards? allSetCards;

  Future loadAll() async {
    await loadCards();
    loaded = true;
    onLoad();
  }

  Future loadCards() async {
    String json = await rootBundle.loadString('data/all_cards.json');
    Map<String, dynamic> data = jsonDecode(json);
    allSetCards = AllSetCards.fromJson(data);
  }
}
