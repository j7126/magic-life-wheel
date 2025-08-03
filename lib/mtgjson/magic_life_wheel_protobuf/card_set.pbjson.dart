// This is a generated file - do not edit.
//
// Generated from card_set.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use cardSetDescriptor instead')
const CardSet$json = {
  '1': 'CardSet',
  '2': [
    {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'setCode', '3': 3, '4': 1, '5': 9, '10': 'setCode'},
    {
      '1': 'scryfallId',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'scryfallId',
      '17': true
    },
    {
      '1': 'commander',
      '3': 5,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'commander',
      '17': true
    },
    {'1': 'cardSearchString', '3': 6, '4': 1, '5': 9, '10': 'cardSearchString'},
    {
      '1': 'cardSearchStringWords',
      '3': 7,
      '4': 3,
      '5': 9,
      '10': 'cardSearchStringWords'
    },
    {
      '1': 'cardSearchStringAlt',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'cardSearchStringAlt',
      '17': true
    },
    {
      '1': 'cardSearchStringWordsAlt',
      '3': 9,
      '4': 3,
      '5': 9,
      '10': 'cardSearchStringWordsAlt'
    },
    {
      '1': 'artist',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'artist',
      '17': true
    },
    {'1': 'text', '3': 11, '4': 1, '5': 9, '9': 4, '10': 'text', '17': true},
    {
      '1': 'flavorName',
      '3': 12,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'flavorName',
      '17': true
    },
    {
      '1': 'isFunny',
      '3': 13,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'isFunny',
      '17': true
    },
    {
      '1': 'keywordPartner',
      '3': 14,
      '4': 1,
      '5': 8,
      '9': 7,
      '10': 'keywordPartner',
      '17': true
    },
    {
      '1': 'keywordFriendsForever',
      '3': 15,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'keywordFriendsForever',
      '17': true
    },
    {
      '1': 'keywordDoctorsCompanion',
      '3': 16,
      '4': 1,
      '5': 8,
      '9': 9,
      '10': 'keywordDoctorsCompanion',
      '17': true
    },
    {
      '1': 'keywordChooseBackground',
      '3': 17,
      '4': 1,
      '5': 8,
      '9': 10,
      '10': 'keywordChooseBackground',
      '17': true
    },
    {
      '1': 'subtypeBackground',
      '3': 18,
      '4': 1,
      '5': 8,
      '9': 11,
      '10': 'subtypeBackground',
      '17': true
    },
    {
      '1': 'subtypeTimeLordDoctor',
      '3': 19,
      '4': 1,
      '5': 8,
      '9': 12,
      '10': 'subtypeTimeLordDoctor',
      '17': true
    },
    {
      '1': 'typePlane',
      '3': 20,
      '4': 1,
      '5': 8,
      '9': 13,
      '10': 'typePlane',
      '17': true
    },
  ],
  '8': [
    {'1': '_scryfallId'},
    {'1': '_commander'},
    {'1': '_cardSearchStringAlt'},
    {'1': '_artist'},
    {'1': '_text'},
    {'1': '_flavorName'},
    {'1': '_isFunny'},
    {'1': '_keywordPartner'},
    {'1': '_keywordFriendsForever'},
    {'1': '_keywordDoctorsCompanion'},
    {'1': '_keywordChooseBackground'},
    {'1': '_subtypeBackground'},
    {'1': '_subtypeTimeLordDoctor'},
    {'1': '_typePlane'},
  ],
};

/// Descriptor for `CardSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cardSetDescriptor = $convert.base64Decode(
    'CgdDYXJkU2V0EhIKBHV1aWQYASABKAlSBHV1aWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIYCgdzZX'
    'RDb2RlGAMgASgJUgdzZXRDb2RlEiMKCnNjcnlmYWxsSWQYBCABKAlIAFIKc2NyeWZhbGxJZIgB'
    'ARIhCgljb21tYW5kZXIYBSABKAhIAVIJY29tbWFuZGVyiAEBEioKEGNhcmRTZWFyY2hTdHJpbm'
    'cYBiABKAlSEGNhcmRTZWFyY2hTdHJpbmcSNAoVY2FyZFNlYXJjaFN0cmluZ1dvcmRzGAcgAygJ'
    'UhVjYXJkU2VhcmNoU3RyaW5nV29yZHMSNQoTY2FyZFNlYXJjaFN0cmluZ0FsdBgIIAEoCUgCUh'
    'NjYXJkU2VhcmNoU3RyaW5nQWx0iAEBEjoKGGNhcmRTZWFyY2hTdHJpbmdXb3Jkc0FsdBgJIAMo'
    'CVIYY2FyZFNlYXJjaFN0cmluZ1dvcmRzQWx0EhsKBmFydGlzdBgKIAEoCUgDUgZhcnRpc3SIAQ'
    'ESFwoEdGV4dBgLIAEoCUgEUgR0ZXh0iAEBEiMKCmZsYXZvck5hbWUYDCABKAlIBVIKZmxhdm9y'
    'TmFtZYgBARIdCgdpc0Z1bm55GA0gASgISAZSB2lzRnVubnmIAQESKwoOa2V5d29yZFBhcnRuZX'
    'IYDiABKAhIB1IOa2V5d29yZFBhcnRuZXKIAQESOQoVa2V5d29yZEZyaWVuZHNGb3JldmVyGA8g'
    'ASgISAhSFWtleXdvcmRGcmllbmRzRm9yZXZlcogBARI9ChdrZXl3b3JkRG9jdG9yc0NvbXBhbm'
    'lvbhgQIAEoCEgJUhdrZXl3b3JkRG9jdG9yc0NvbXBhbmlvbogBARI9ChdrZXl3b3JkQ2hvb3Nl'
    'QmFja2dyb3VuZBgRIAEoCEgKUhdrZXl3b3JkQ2hvb3NlQmFja2dyb3VuZIgBARIxChFzdWJ0eX'
    'BlQmFja2dyb3VuZBgSIAEoCEgLUhFzdWJ0eXBlQmFja2dyb3VuZIgBARI5ChVzdWJ0eXBlVGlt'
    'ZUxvcmREb2N0b3IYEyABKAhIDFIVc3VidHlwZVRpbWVMb3JkRG9jdG9yiAEBEiEKCXR5cGVQbG'
    'FuZRgUIAEoCEgNUgl0eXBlUGxhbmWIAQFCDQoLX3NjcnlmYWxsSWRCDAoKX2NvbW1hbmRlckIW'
    'ChRfY2FyZFNlYXJjaFN0cmluZ0FsdEIJCgdfYXJ0aXN0QgcKBV90ZXh0Qg0KC19mbGF2b3JOYW'
    '1lQgoKCF9pc0Z1bm55QhEKD19rZXl3b3JkUGFydG5lckIYChZfa2V5d29yZEZyaWVuZHNGb3Jl'
    'dmVyQhoKGF9rZXl3b3JkRG9jdG9yc0NvbXBhbmlvbkIaChhfa2V5d29yZENob29zZUJhY2tncm'
    '91bmRCFAoSX3N1YnR5cGVCYWNrZ3JvdW5kQhgKFl9zdWJ0eXBlVGltZUxvcmREb2N0b3JCDAoK'
    'X3R5cGVQbGFuZQ==');
