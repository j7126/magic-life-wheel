import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:github/github.dart' show GitHub, Release, ReleaseAsset, RepositorySlug;
import 'package:http/http.dart' as http;
import 'package:magic_life_wheel/mtgjson/file_names.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel/generated/all_set_cards.pb.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel/generated/sets.pb.dart';
import 'package:magic_life_wheel/mtgjson/mtgjson_data_loader.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:path_provider/path_provider.dart';

class DataUpdater {
  static const String supportedVersion = "1.2.0";
  static RepositorySlug slug = RepositorySlug("j7126", "mtgjson_converter_dart");
  static GitHub github = GitHub();
  static String? status;
  static bool checked = false;

  static Future checkForUpdates(MTGDataLoader loader, {bool force = false}) async {
    if (!loader.loaded || !Service.settingsService.pref_getScryfallImages || kIsWeb) {
      return;
    }

    if (checked && !force) {
      return;
    }
    checked = true;

    try {
      // get the release
      var release = await github.repositories.getLatestRelease(slug);
      if (release.tagName == supportedVersion) {
        // get the correct asset download url
        var (setListUrl, setListBuildDate) = getFileDownloadUrl(FileNames.setList, loader.sets!.buildDate, release);
        var (allCardsUrl, allCardsBuildDate) = getFileDownloadUrl(
          FileNames.allCards,
          loader.allSetCards!.buildDate,
          release,
        );
        if (setListUrl == null || allCardsUrl == null) {
          return;
        }
        if (setListBuildDate != allCardsBuildDate) {
          status = "Error: File build dates did not match.";
          return;
        }

        // download the data
        var setListData = await getFileContent(setListUrl, FileNames.setList);
        var allCardsData = await getFileContent(allCardsUrl, FileNames.allCards);
        if (setListData == null || allCardsData == null) {
          return;
        }

        // parse the data to confirm it's valid
        var setList = SetList.fromBuffer(setListData);
        var allCards = ProtobufAllSetCards.fromBuffer(allCardsData);
        if (int.tryParse(setList.buildDate) != setListBuildDate ||
            int.tryParse(allCards.buildDate) != allCardsBuildDate) {
          status = "Error: The build date did not match the file name.";
          return;
        }
        if (setList.sets.isEmpty || allCards.data.isEmpty) {
          status = "Error: The fetched data was empty";
          return;
        }

        // store the data
        await writeData(setListData, FileNames.setList);
        await writeData(allCardsData, FileNames.allCards);
        status = "Data updated successfully";

        // reload the data
        loader.loadAll();
      } else {
        status = "Latest release does not match the supported version, please update the app to get new data.";
      }
    } catch (e) {
      // store the error, it can be displayed to the user in the about menu
      status = "Unhandled error: ${e.toString()}";
    }
  }

  static (String? url, int? buildDate) getFileDownloadUrl(String name, String currentBuildDate, Release release) {
    var currentBuildDateInt = int.tryParse(currentBuildDate);
    if (currentBuildDateInt == null) {
      status = "Error: Current build date for `$name` was not valid";
      return (null, null);
    }

    ReleaseAsset? releaseAsset;
    int assetBuildDate = 0;
    for (var asset in release.assets ?? []) {
      var match = RegExp(r'^([^0-9]*)_([0-9]*)[^0-9]*$').firstMatch(asset.name!);
      if (match?.groupCount == 2 && match!.group(1) == name) {
        var buildDate = int.tryParse(match.group(2) ?? "");
        if (buildDate != null) {
          if (buildDate > currentBuildDateInt) {
            releaseAsset = asset;
            assetBuildDate = buildDate;
          } else if (buildDate == currentBuildDateInt) {
            status = "The data is already up to date.";
            return (null, null);
          }
        }
        continue;
      }
    }

    if (releaseAsset?.browserDownloadUrl == null && assetBuildDate != 0) {
      status = "Error: Release artifact `$name` was not found";
      return (null, null);
    }

    return (releaseAsset!.browserDownloadUrl!, assetBuildDate);
  }

  static Future<Uint8List?> getFileContent(String uri, String name) async {
    var response = await http.get(Uri.parse(uri));
    var result = response.statusCode == 200 ? response.bodyBytes : null;
    if (result == null) {
      status = "Error: Failed to download `$name`";
    }
    return result;
  }

  static Future writeData(Uint8List data, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/$name.bin");
    await file.writeAsBytes(data);
  }
}
