// This is a generated file - do not edit.
//
// Generated from all_set_cards.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'card_set.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ProtobufAllSetCards extends $pb.GeneratedMessage {
  factory ProtobufAllSetCards({
    $core.Iterable<$0.CardSet>? data,
  }) {
    final result = create();
    if (data != null) result.data.addAll(data);
    return result;
  }

  ProtobufAllSetCards._();

  factory ProtobufAllSetCards.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProtobufAllSetCards.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProtobufAllSetCards',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mtgjson_converter_dart'), createEmptyInstance: create)
    ..pc<$0.CardSet>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PM, subBuilder: $0.CardSet.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtobufAllSetCards clone() => ProtobufAllSetCards()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProtobufAllSetCards copyWith(void Function(ProtobufAllSetCards) updates) =>
      super.copyWith((message) => updates(message as ProtobufAllSetCards)) as ProtobufAllSetCards;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProtobufAllSetCards create() => ProtobufAllSetCards._();
  @$core.override
  ProtobufAllSetCards createEmptyInstance() => create();
  static $pb.PbList<ProtobufAllSetCards> createRepeated() => $pb.PbList<ProtobufAllSetCards>();
  @$core.pragma('dart2js:noInline')
  static ProtobufAllSetCards getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProtobufAllSetCards>(create);
  static ProtobufAllSetCards? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.CardSet> get data => $_getList(0);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
