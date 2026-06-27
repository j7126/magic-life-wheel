// This is a generated file - do not edit.
//
// Generated from player_transfer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class PlayerTransfer extends $pb.GeneratedMessage {
  factory PlayerTransfer({
    $core.String? uuid,
    $core.String? name,
    $core.bool? enableDead,
    $core.int? life,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? commanderDamage,
    $core.String? card,
    $core.String? cardPartner,
    $core.Iterable<$core.int>? colors,
  }) {
    final result = create();
    if (uuid != null) result.uuid = uuid;
    if (name != null) result.name = name;
    if (enableDead != null) result.enableDead = enableDead;
    if (life != null) result.life = life;
    if (commanderDamage != null)
      result.commanderDamage.addEntries(commanderDamage);
    if (card != null) result.card = card;
    if (cardPartner != null) result.cardPartner = cardPartner;
    if (colors != null) result.colors.addAll(colors);
    return result;
  }

  PlayerTransfer._();

  factory PlayerTransfer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PlayerTransfer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlayerTransfer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'magic_life_wheel'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uuid')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOB(3, _omitFieldNames ? '' : 'enableDead', protoName: 'enableDead')
    ..aI(4, _omitFieldNames ? '' : 'life')
    ..m<$core.String, $core.int>(5, _omitFieldNames ? '' : 'commanderDamage',
        protoName: 'commanderDamage',
        entryClassName: 'PlayerTransfer.CommanderDamageEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('magic_life_wheel'))
    ..aOS(6, _omitFieldNames ? '' : 'card')
    ..aOS(7, _omitFieldNames ? '' : 'cardPartner', protoName: 'cardPartner')
    ..p<$core.int>(8, _omitFieldNames ? '' : 'colors', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlayerTransfer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlayerTransfer copyWith(void Function(PlayerTransfer) updates) =>
      super.copyWith((message) => updates(message as PlayerTransfer))
          as PlayerTransfer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlayerTransfer create() => PlayerTransfer._();
  @$core.override
  PlayerTransfer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PlayerTransfer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlayerTransfer>(create);
  static PlayerTransfer? _defaultInstance;

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
  $core.bool get enableDead => $_getBF(2);
  @$pb.TagNumber(3)
  set enableDead($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnableDead() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnableDead() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get life => $_getIZ(3);
  @$pb.TagNumber(4)
  set life($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLife() => $_has(3);
  @$pb.TagNumber(4)
  void clearLife() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.int> get commanderDamage => $_getMap(4);

  @$pb.TagNumber(6)
  $core.String get card => $_getSZ(5);
  @$pb.TagNumber(6)
  set card($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCard() => $_has(5);
  @$pb.TagNumber(6)
  void clearCard() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get cardPartner => $_getSZ(6);
  @$pb.TagNumber(7)
  set cardPartner($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCardPartner() => $_has(6);
  @$pb.TagNumber(7)
  void clearCardPartner() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.int> get colors => $_getList(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
