import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic_life_wheel/datamodel/background.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel/generated/game_transfer.pb.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel/generated/player_transfer.pb.dart';
import 'package:magic_life_wheel/static_service.dart';

class TransferUrlService {
  static Future<String> buildUrl(List<Player> players, int layoutId) async {
    var base64String = await buildBase64ProtobufString(players, layoutId);
    return "${Service.appBaseUrl}?import=$base64String";
  }

  static Future<String> buildBase64ProtobufString(List<Player> players, int layoutId) async {
    return await compute(
      (d) {
        var p = d.$1;
        var layoutId = d.$2;
        var transfer = GameTransfer(
          numPlayers: p.length,
          layoutId: layoutId,
          players: p.map(
            (e) => PlayerTransfer(
              uuid: e.uuid,
              name: e.name,
              enableDead: e.enableDead,
              life: e.life,
              commanderDamage: e.commanderDamage.entries,
              card: e.background.card?.uuid,
              cardPartner: e.background.cardPartner?.uuid,
              colors: e.background.colors?.map((e) => e.toARGB32()).toList(),
            ),
          ),
        );
        var protobufData = transfer.writeToBuffer();
        var compressedData = ZLibEncoder().encodeBytes(protobufData);
        var encodedData = base64.encode(compressedData);
        return encodedData;
      },
      (players, layoutId),
    );
  }

  static Future<(List<Player> players, int layoutId)?> parseUrl(String url) async {
    var exp = RegExp(r'^(https:\/\/[^\/]*\/)\?import=([A-Za-z0-9+\/]*={0,2})$');
    var match = exp.allMatches(url).toList();
    if (match.length == 1 &&
        match.first.groupCount == 2 &&
        match.first[1] == Service.appBaseUrl &&
        match.first[2] != null) {
      var data = match.first[2]!;
      return await parseBase64Data(data);
    }
    return null;
  }

  static Future<(List<Player> players, int layoutId)?> parseBase64Data(String data) async {
    // try to parse as protobuf
    var result = await parseBase64ProtobufData(data);
    if (result != null) {
      return result;
    }

    // try to parse as json
    return await parseBase64JsonData(data);
  }

  static Future<(List<Player> players, int layoutId)?> parseBase64ProtobufData(String data) async {
    var transfer = await compute<String, GameTransfer?>(
      (data) {
        try {
          var base64Decoded = base64.decode(data);
          var decompressedData = ZLibDecoder().decodeBytes(base64Decoded);
          return GameTransfer.fromBuffer(decompressedData);
        } catch (_) {
          return null;
        }
      },
      data,
    );
    if (transfer == null) {
      return null;
    }
    try {
      var players = transfer.players
          .map((e) {
              var player = Player(name: e.name);
              player.uuid = e.uuid;
              player.enableDead = e.enableDead;
              player.life = e.life;
              player.commanderDamage = e.commanderDamage;
              if (e.colors.isNotEmpty) {
                player.background = Background();
                player.background.colors = e.colors.map((e) => Color(e)).toList();
              }
              else if (e.hasCard()) {
                var card = Service.dataLoader.allSetCards?.data.firstWhereOrNull((element) => element.uuid == e.card);
                if (card != null) {
                  player.background.card = card;
                  if (e.hasCardPartner()) {
                    var cardPartner = Service.dataLoader.allSetCards?.data.firstWhereOrNull(
                      (element) => element.uuid == e.cardPartner,
                    );
                    player.background.cardPartner = cardPartner;
                  }
                }
              }
              return player;
          })
          .toList();

      if (players.length == transfer.numPlayers && players.length <= 6 && players.length >= 2) {
        return (players, transfer.layoutId);
      }
    } catch (_) {}
    return null;
  }

  static Future<(List<Player> players, int layoutId)?> parseBase64JsonData(String data) async {
    var jsonDecoded = await compute<String, Map<String, dynamic>?>(
      (data) {
        try {
          var base64Decoded = base64.decode(data);
          var utf8Decoded = utf8.decode(base64Decoded);
          var jsonDecoded = jsonDecode(utf8Decoded) as Map<String, dynamic>;
          return jsonDecoded;
        } catch (_) {
          return null;
        }
      },
      data,
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
              e["damageHistory"] = [];
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
                    var cardPartner = Service.dataLoader.allSetCards?.data.firstWhereOrNull(
                      (element) => element.uuid == cardPartnerUuid,
                    );
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
