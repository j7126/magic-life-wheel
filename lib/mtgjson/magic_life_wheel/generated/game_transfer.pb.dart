// This is a generated file - do not edit.
//
// Generated from game_transfer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'player_transfer.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GameTransfer extends $pb.GeneratedMessage {
  factory GameTransfer({
    $core.int? numPlayers,
    $core.int? layoutId,
    $core.Iterable<$0.PlayerTransfer>? players,
  }) {
    final result = create();
    if (numPlayers != null) result.numPlayers = numPlayers;
    if (layoutId != null) result.layoutId = layoutId;
    if (players != null) result.players.addAll(players);
    return result;
  }

  GameTransfer._();

  factory GameTransfer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GameTransfer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GameTransfer',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'magic_life_wheel'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'numPlayers', protoName: 'numPlayers')
    ..aI(2, _omitFieldNames ? '' : 'layoutId', protoName: 'layoutId')
    ..pPM<$0.PlayerTransfer>(3, _omitFieldNames ? '' : 'players',
        subBuilder: $0.PlayerTransfer.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameTransfer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameTransfer copyWith(void Function(GameTransfer) updates) =>
      super.copyWith((message) => updates(message as GameTransfer))
          as GameTransfer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GameTransfer create() => GameTransfer._();
  @$core.override
  GameTransfer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GameTransfer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GameTransfer>(create);
  static GameTransfer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get numPlayers => $_getIZ(0);
  @$pb.TagNumber(1)
  set numPlayers($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNumPlayers() => $_has(0);
  @$pb.TagNumber(1)
  void clearNumPlayers() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get layoutId => $_getIZ(1);
  @$pb.TagNumber(2)
  set layoutId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLayoutId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLayoutId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$0.PlayerTransfer> get players => $_getList(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
