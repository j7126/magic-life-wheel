// This is a generated file - do not edit.
//
// Generated from sets.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'set.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SetList extends $pb.GeneratedMessage {
  factory SetList({
    $core.Iterable<$0.SetListSet>? sets,
    $core.String? buildDate,
  }) {
    final result = create();
    if (sets != null) result.sets.addAll(sets);
    if (buildDate != null) result.buildDate = buildDate;
    return result;
  }

  SetList._();

  factory SetList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetList',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'mtgjson_converter_dart'),
      createEmptyInstance: create)
    ..pPM<$0.SetListSet>(1, _omitFieldNames ? '' : 'sets',
        subBuilder: $0.SetListSet.create)
    ..aOS(2, _omitFieldNames ? '' : 'buildDate', protoName: 'buildDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetList copyWith(void Function(SetList) updates) =>
      super.copyWith((message) => updates(message as SetList)) as SetList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetList create() => SetList._();
  @$core.override
  SetList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetList>(create);
  static SetList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.SetListSet> get sets => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get buildDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set buildDate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuildDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuildDate() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
