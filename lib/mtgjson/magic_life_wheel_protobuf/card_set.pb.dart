// This is a generated file - do not edit.
//
// Generated from card_set.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CardSet extends $pb.GeneratedMessage {
  factory CardSet({
    $core.String? uuid,
    $core.String? name,
    $core.String? setCode,
    $core.String? scryfallId,
    $core.bool? commander,
    $core.String? cardSearchString,
    $core.Iterable<$core.String>? cardSearchStringWords,
    $core.String? cardSearchStringAlt,
    $core.Iterable<$core.String>? cardSearchStringWordsAlt,
    $core.String? artist,
    $core.String? text,
    $core.String? flavorName,
    $core.bool? isFunny,
    $core.bool? keywordPartner,
    $core.bool? keywordFriendsForever,
    $core.bool? keywordDoctorsCompanion,
    $core.bool? keywordChooseBackground,
    $core.bool? subtypeBackground,
    $core.bool? subtypeTimeLordDoctor,
    $core.bool? typePlane,
  }) {
    final result = create();
    if (uuid != null) result.uuid = uuid;
    if (name != null) result.name = name;
    if (setCode != null) result.setCode = setCode;
    if (scryfallId != null) result.scryfallId = scryfallId;
    if (commander != null) result.commander = commander;
    if (cardSearchString != null) result.cardSearchString = cardSearchString;
    if (cardSearchStringWords != null)
      result.cardSearchStringWords.addAll(cardSearchStringWords);
    if (cardSearchStringAlt != null)
      result.cardSearchStringAlt = cardSearchStringAlt;
    if (cardSearchStringWordsAlt != null)
      result.cardSearchStringWordsAlt.addAll(cardSearchStringWordsAlt);
    if (artist != null) result.artist = artist;
    if (text != null) result.text = text;
    if (flavorName != null) result.flavorName = flavorName;
    if (isFunny != null) result.isFunny = isFunny;
    if (keywordPartner != null) result.keywordPartner = keywordPartner;
    if (keywordFriendsForever != null)
      result.keywordFriendsForever = keywordFriendsForever;
    if (keywordDoctorsCompanion != null)
      result.keywordDoctorsCompanion = keywordDoctorsCompanion;
    if (keywordChooseBackground != null)
      result.keywordChooseBackground = keywordChooseBackground;
    if (subtypeBackground != null) result.subtypeBackground = subtypeBackground;
    if (subtypeTimeLordDoctor != null)
      result.subtypeTimeLordDoctor = subtypeTimeLordDoctor;
    if (typePlane != null) result.typePlane = typePlane;
    return result;
  }

  CardSet._();

  factory CardSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CardSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CardSet',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'mtgjson_converter_dart'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uuid')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'setCode', protoName: 'setCode')
    ..aOS(4, _omitFieldNames ? '' : 'scryfallId', protoName: 'scryfallId')
    ..aOB(5, _omitFieldNames ? '' : 'commander')
    ..aOS(6, _omitFieldNames ? '' : 'cardSearchString',
        protoName: 'cardSearchString')
    ..pPS(7, _omitFieldNames ? '' : 'cardSearchStringWords',
        protoName: 'cardSearchStringWords')
    ..aOS(8, _omitFieldNames ? '' : 'cardSearchStringAlt',
        protoName: 'cardSearchStringAlt')
    ..pPS(9, _omitFieldNames ? '' : 'cardSearchStringWordsAlt',
        protoName: 'cardSearchStringWordsAlt')
    ..aOS(10, _omitFieldNames ? '' : 'artist')
    ..aOS(11, _omitFieldNames ? '' : 'text')
    ..aOS(12, _omitFieldNames ? '' : 'flavorName', protoName: 'flavorName')
    ..aOB(13, _omitFieldNames ? '' : 'isFunny', protoName: 'isFunny')
    ..aOB(14, _omitFieldNames ? '' : 'keywordPartner',
        protoName: 'keywordPartner')
    ..aOB(15, _omitFieldNames ? '' : 'keywordFriendsForever',
        protoName: 'keywordFriendsForever')
    ..aOB(16, _omitFieldNames ? '' : 'keywordDoctorsCompanion',
        protoName: 'keywordDoctorsCompanion')
    ..aOB(17, _omitFieldNames ? '' : 'keywordChooseBackground',
        protoName: 'keywordChooseBackground')
    ..aOB(18, _omitFieldNames ? '' : 'subtypeBackground',
        protoName: 'subtypeBackground')
    ..aOB(19, _omitFieldNames ? '' : 'subtypeTimeLordDoctor',
        protoName: 'subtypeTimeLordDoctor')
    ..aOB(20, _omitFieldNames ? '' : 'typePlane', protoName: 'typePlane')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CardSet clone() => CardSet()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CardSet copyWith(void Function(CardSet) updates) =>
      super.copyWith((message) => updates(message as CardSet)) as CardSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CardSet create() => CardSet._();
  @$core.override
  CardSet createEmptyInstance() => create();
  static $pb.PbList<CardSet> createRepeated() => $pb.PbList<CardSet>();
  @$core.pragma('dart2js:noInline')
  static CardSet getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CardSet>(create);
  static CardSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uuid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uuid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get setCode => $_getSZ(2);
  @$pb.TagNumber(3)
  set setCode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSetCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearSetCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get scryfallId => $_getSZ(3);
  @$pb.TagNumber(4)
  set scryfallId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScryfallId() => $_has(3);
  @$pb.TagNumber(4)
  void clearScryfallId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get commander => $_getBF(4);
  @$pb.TagNumber(5)
  set commander($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCommander() => $_has(4);
  @$pb.TagNumber(5)
  void clearCommander() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cardSearchString => $_getSZ(5);
  @$pb.TagNumber(6)
  set cardSearchString($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCardSearchString() => $_has(5);
  @$pb.TagNumber(6)
  void clearCardSearchString() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get cardSearchStringWords => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get cardSearchStringAlt => $_getSZ(7);
  @$pb.TagNumber(8)
  set cardSearchStringAlt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCardSearchStringAlt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCardSearchStringAlt() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get cardSearchStringWordsAlt => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get artist => $_getSZ(9);
  @$pb.TagNumber(10)
  set artist($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasArtist() => $_has(9);
  @$pb.TagNumber(10)
  void clearArtist() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get text => $_getSZ(10);
  @$pb.TagNumber(11)
  set text($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasText() => $_has(10);
  @$pb.TagNumber(11)
  void clearText() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get flavorName => $_getSZ(11);
  @$pb.TagNumber(12)
  set flavorName($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFlavorName() => $_has(11);
  @$pb.TagNumber(12)
  void clearFlavorName() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get isFunny => $_getBF(12);
  @$pb.TagNumber(13)
  set isFunny($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsFunny() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsFunny() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get keywordPartner => $_getBF(13);
  @$pb.TagNumber(14)
  set keywordPartner($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasKeywordPartner() => $_has(13);
  @$pb.TagNumber(14)
  void clearKeywordPartner() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get keywordFriendsForever => $_getBF(14);
  @$pb.TagNumber(15)
  set keywordFriendsForever($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasKeywordFriendsForever() => $_has(14);
  @$pb.TagNumber(15)
  void clearKeywordFriendsForever() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get keywordDoctorsCompanion => $_getBF(15);
  @$pb.TagNumber(16)
  set keywordDoctorsCompanion($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasKeywordDoctorsCompanion() => $_has(15);
  @$pb.TagNumber(16)
  void clearKeywordDoctorsCompanion() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get keywordChooseBackground => $_getBF(16);
  @$pb.TagNumber(17)
  set keywordChooseBackground($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasKeywordChooseBackground() => $_has(16);
  @$pb.TagNumber(17)
  void clearKeywordChooseBackground() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get subtypeBackground => $_getBF(17);
  @$pb.TagNumber(18)
  set subtypeBackground($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasSubtypeBackground() => $_has(17);
  @$pb.TagNumber(18)
  void clearSubtypeBackground() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.bool get subtypeTimeLordDoctor => $_getBF(18);
  @$pb.TagNumber(19)
  set subtypeTimeLordDoctor($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasSubtypeTimeLordDoctor() => $_has(18);
  @$pb.TagNumber(19)
  void clearSubtypeTimeLordDoctor() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.bool get typePlane => $_getBF(19);
  @$pb.TagNumber(20)
  set typePlane($core.bool value) => $_setBool(19, value);
  @$pb.TagNumber(20)
  $core.bool hasTypePlane() => $_has(19);
  @$pb.TagNumber(20)
  void clearTypePlane() => $_clearField(20);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
