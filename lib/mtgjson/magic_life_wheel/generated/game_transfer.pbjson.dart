// This is a generated file - do not edit.
//
// Generated from game_transfer.proto.

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

@$core.Deprecated('Use gameTransferDescriptor instead')
const GameTransfer$json = {
  '1': 'GameTransfer',
  '2': [
    {'1': 'numPlayers', '3': 1, '4': 1, '5': 5, '10': 'numPlayers'},
    {'1': 'layoutId', '3': 2, '4': 1, '5': 5, '10': 'layoutId'},
    {
      '1': 'players',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.magic_life_wheel.PlayerTransfer',
      '10': 'players'
    },
  ],
};

/// Descriptor for `GameTransfer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameTransferDescriptor = $convert.base64Decode(
    'CgxHYW1lVHJhbnNmZXISHgoKbnVtUGxheWVycxgBIAEoBVIKbnVtUGxheWVycxIaCghsYXlvdX'
    'RJZBgCIAEoBVIIbGF5b3V0SWQSOgoHcGxheWVycxgDIAMoCzIgLm1hZ2ljX2xpZmVfd2hlZWwu'
    'UGxheWVyVHJhbnNmZXJSB3BsYXllcnM=');
