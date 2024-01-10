// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CardSet _$CardSetFromJson(Map<String, dynamic> json) {
  return _CardSet.fromJson(json);
}

/// @nodoc
mixin _$CardSet {
  String get name => throw _privateConstructorUsedError;
  String get uuid => throw _privateConstructorUsedError;
  Identifiers get identifiers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CardSetCopyWith<CardSet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardSetCopyWith<$Res> {
  factory $CardSetCopyWith(CardSet value, $Res Function(CardSet) then) =
      _$CardSetCopyWithImpl<$Res, CardSet>;
  @useResult
  $Res call({String name, String uuid, Identifiers identifiers});
}

/// @nodoc
class _$CardSetCopyWithImpl<$Res, $Val extends CardSet>
    implements $CardSetCopyWith<$Res> {
  _$CardSetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? uuid = null,
    Object? identifiers = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      identifiers: null == identifiers
          ? _value.identifiers
          : identifiers // ignore: cast_nullable_to_non_nullable
              as Identifiers,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardSetImplCopyWith<$Res> implements $CardSetCopyWith<$Res> {
  factory _$$CardSetImplCopyWith(
          _$CardSetImpl value, $Res Function(_$CardSetImpl) then) =
      __$$CardSetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String uuid, Identifiers identifiers});
}

/// @nodoc
class __$$CardSetImplCopyWithImpl<$Res>
    extends _$CardSetCopyWithImpl<$Res, _$CardSetImpl>
    implements _$$CardSetImplCopyWith<$Res> {
  __$$CardSetImplCopyWithImpl(
      _$CardSetImpl _value, $Res Function(_$CardSetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? uuid = null,
    Object? identifiers = null,
  }) {
    return _then(_$CardSetImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      identifiers: null == identifiers
          ? _value.identifiers
          : identifiers // ignore: cast_nullable_to_non_nullable
              as Identifiers,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CardSetImpl implements _CardSet {
  const _$CardSetImpl(
      {required this.name, required this.uuid, required this.identifiers});

  factory _$CardSetImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardSetImplFromJson(json);

  @override
  final String name;
  @override
  final String uuid;
  @override
  final Identifiers identifiers;

  @override
  String toString() {
    return 'CardSet(name: $name, uuid: $uuid, identifiers: $identifiers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardSetImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.identifiers, identifiers) ||
                other.identifiers == identifiers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, uuid, identifiers);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardSetImplCopyWith<_$CardSetImpl> get copyWith =>
      __$$CardSetImplCopyWithImpl<_$CardSetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardSetImplToJson(
      this,
    );
  }
}

abstract class _CardSet implements CardSet {
  const factory _CardSet(
      {required final String name,
      required final String uuid,
      required final Identifiers identifiers}) = _$CardSetImpl;

  factory _CardSet.fromJson(Map<String, dynamic> json) = _$CardSetImpl.fromJson;

  @override
  String get name;
  @override
  String get uuid;
  @override
  Identifiers get identifiers;
  @override
  @JsonKey(ignore: true)
  _$$CardSetImplCopyWith<_$CardSetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
