import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/static_service.dart';

class TransferUrlService {
  static Future<String> buildUrl(List<Player> players, int layoutId) async {
    return await compute(
      (d) {
        var p = d.$1;
        var layoutId = d.$2;
        var players = p.map((e) {
          var jsonMap = e.toJson();
          var bg = (jsonMap["background"] as Map<String, dynamic>);
          bg.remove("_customImage");
          if (bg["_card"] != null) {
            bg["_card"] = bg["_card"]["uuid"];
          }
          if (bg["_cardPartner"] != null) {
            bg["_cardPartner"] = bg["_cardPartner"]["uuid"];
          }
          return jsonMap;
        }).toList();
        var resultMap = <String, dynamic>{};
        resultMap["numPlayers"] = p.length;
        resultMap["players"] = players;
        resultMap["layoutId"] = layoutId;
        var jsonResult = jsonEncode(resultMap);
        var jsonResultUtf8 = utf8.encode(jsonResult);
        var base64Result = base64.encode(jsonResultUtf8);
        return "${Service.appBaseUrl}?import=$base64Result";
      },
      (players, layoutId),
    );
  }

  static Future<(List<Player> players, int layoutId)?> parseUrl(String url) async {
    var jsonDecoded = await compute<String, Map<String, dynamic>?>(
      (url) {
        var exp = RegExp(r'^(https:\/\/[^\/]*\/)\?import=([A-Za-z0-9+\/]*={0,2})$');
        var match = exp.allMatches(url).toList();
        if (match.length == 1 &&
            match.first.groupCount == 2 &&
            match.first[1] == Service.appBaseUrl &&
            match.first[2] != null) {
          var data = match.first[2]!;
          try {
            var base64Decoded = base64.decode(data);
            var utf8Decoded = utf8.decode(base64Decoded);
            var jsonDecoded = jsonDecode(utf8Decoded) as Map<String, dynamic>;
            return jsonDecoded;
          } catch (_) {}
        }
        return null;
      },
      url,
    );
    if (jsonDecoded == null) {
      return null;
    }
    try {
      var layoutId = jsonDecoded["layoutId"] as int;
      var numPlayers = jsonDecoded["numPlayers"] as int;
      var playersJson = jsonDecoded["players"] as List<dynamic>;
      var players = playersJson
          .map((e) {
            if (e is Map<String, dynamic>) {
              var bg = (e["background"] as Map<String, dynamic>);
              var cardUuid = bg["_card"] as String?;
              bg["_card"] = null;
              var cardPartnerUuid = bg["_cardPartner"] as String?;
              bg["_cardPartner"] = null;
              var player = Player.fromJson(e);
              if (cardUuid != null) {
                var card = Service.dataLoader.allSetCards?.data.firstWhereOrNull((element) => element.uuid == cardUuid);
                if (card != null) {
                  player.background.card = card;
                  if (cardPartnerUuid != null) {
                    var cardPartner = Service.dataLoader.allSetCards?.data
                        .firstWhereOrNull((element) => element.uuid == cardPartnerUuid);
                    player.background.cardPartner = cardPartner;
                  }
                }
              }
              return player;
            } else {
              return null;
            }
          })
          .where((element) => element != null)
          .map((e) => e!)
          .toList();

      if (players.length == numPlayers && players.length <= 6 && players.length >= 2) {
        return (players, layoutId);
      }
    } catch (_) {}
    return null;
  }
}
