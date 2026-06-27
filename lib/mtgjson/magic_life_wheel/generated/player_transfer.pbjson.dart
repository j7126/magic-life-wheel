// This is a generated file - do not edit.
//
// Generated from player_transfer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use playerTransferDescriptor instead')
const PlayerTransfer$json = {
  '1': 'PlayerTransfer',
  '2': [
    {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'enableDead', '3': 3, '4': 1, '5': 8, '10': 'enableDead'},
    {'1': 'life', '3': 4, '4': 1, '5': 5, '10': 'life'},
    {
      '1': 'commanderDamage',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.magic_life_wheel.PlayerTransfer.CommanderDamageEntry',
      '10': 'commanderDamage'
    },
    {'1': 'card', '3': 6, '4': 1, '5': 9, '10': 'card'},
    {'1': 'cardPartner', '3': 7, '4': 1, '5': 9, '10': 'cardPartner'},
    {'1': 'colors', '3': 8, '4': 3, '5': 13, '10': 'colors'},
  ],
  '3': [PlayerTransfer_CommanderDamageEntry$json],
};

@$core.Deprecated('Use playerTransferDescriptor instead')
const PlayerTransfer_CommanderDamageEntry$json = {
  '1': 'CommanderDamageEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `PlayerTransfer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List playerTransferDescriptor = $convert.base64Decode(
    'Cg5QbGF5ZXJUcmFuc2ZlchISCgR1dWlkGAEgASgJUgR1dWlkEhIKBG5hbWUYAiABKAlSBG5hbW'
    'USHgoKZW5hYmxlRGVhZBgDIAEoCFIKZW5hYmxlRGVhZBISCgRsaWZlGAQgASgFUgRsaWZlEl8K'
    'D2NvbW1hbmRlckRhbWFnZRgFIAMoCzI1Lm1hZ2ljX2xpZmVfd2hlZWwuUGxheWVyVHJhbnNmZX'
    'IuQ29tbWFuZGVyRGFtYWdlRW50cnlSD2NvbW1hbmRlckRhbWFnZRISCgRjYXJkGAYgASgJUgRj'
    'YXJkEiAKC2NhcmRQYXJ0bmVyGAcgASgJUgtjYXJkUGFydG5lchIWCgZjb2xvcnMYCCADKA1SBm'
    'NvbG9ycxpCChRDb21tYW5kZXJEYW1hZ2VFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1'
    'ZRgCIAEoBVIFdmFsdWU6AjgB');
