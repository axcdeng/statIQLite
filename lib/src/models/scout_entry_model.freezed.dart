// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scout_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScoutEntry _$ScoutEntryFromJson(Map<String, dynamic> json) {
  return ScoutEntryImpl.fromJson(json);
}

/// @nodoc
mixin _$ScoutEntry {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError; // UUID
  @HiveField(1)
  int get eventId => throw _privateConstructorUsedError;
  @HiveField(2)
  int get matchId => throw _privateConstructorUsedError;
  @HiveField(3)
  String get teamNumber => throw _privateConstructorUsedError;
  @HiveField(4)
  DateTime get timestamp => throw _privateConstructorUsedError;
  @HiveField(5)
  Map<String, dynamic> get data =>
      throw _privateConstructorUsedError; // Flexible form data
  @HiveField(6)
  String? get notes => throw _privateConstructorUsedError;
  @HiveField(7)
  String get scoutName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScoutEntryCopyWith<ScoutEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutEntryCopyWith<$Res> {
  factory $ScoutEntryCopyWith(
          ScoutEntry value, $Res Function(ScoutEntry) then) =
      _$ScoutEntryCopyWithImpl<$Res, ScoutEntry>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) int eventId,
      @HiveField(2) int matchId,
      @HiveField(3) String teamNumber,
      @HiveField(4) DateTime timestamp,
      @HiveField(5) Map<String, dynamic> data,
      @HiveField(6) String? notes,
      @HiveField(7) String scoutName});
}

/// @nodoc
class _$ScoutEntryCopyWithImpl<$Res, $Val extends ScoutEntry>
    implements $ScoutEntryCopyWith<$Res> {
  _$ScoutEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? matchId = null,
    Object? teamNumber = null,
    Object? timestamp = null,
    Object? data = null,
    Object? notes = freezed,
    Object? scoutName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as int,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as int,
      teamNumber: null == teamNumber
          ? _value.teamNumber
          : teamNumber // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      scoutName: null == scoutName
          ? _value.scoutName
          : scoutName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoutEntryImplImplCopyWith<$Res>
    implements $ScoutEntryCopyWith<$Res> {
  factory _$$ScoutEntryImplImplCopyWith(_$ScoutEntryImplImpl value,
          $Res Function(_$ScoutEntryImplImpl) then) =
      __$$ScoutEntryImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) int eventId,
      @HiveField(2) int matchId,
      @HiveField(3) String teamNumber,
      @HiveField(4) DateTime timestamp,
      @HiveField(5) Map<String, dynamic> data,
      @HiveField(6) String? notes,
      @HiveField(7) String scoutName});
}

/// @nodoc
class __$$ScoutEntryImplImplCopyWithImpl<$Res>
    extends _$ScoutEntryCopyWithImpl<$Res, _$ScoutEntryImplImpl>
    implements _$$ScoutEntryImplImplCopyWith<$Res> {
  __$$ScoutEntryImplImplCopyWithImpl(
      _$ScoutEntryImplImpl _value, $Res Function(_$ScoutEntryImplImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? matchId = null,
    Object? teamNumber = null,
    Object? timestamp = null,
    Object? data = null,
    Object? notes = freezed,
    Object? scoutName = null,
  }) {
    return _then(_$ScoutEntryImplImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as int,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as int,
      teamNumber: null == teamNumber
          ? _value.teamNumber
          : teamNumber // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      scoutName: null == scoutName
          ? _value.scoutName
          : scoutName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 3, adapterName: '_ScoutEntryAdapter')
class _$ScoutEntryImplImpl implements ScoutEntryImpl {
  const _$ScoutEntryImplImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.eventId,
      @HiveField(2) required this.matchId,
      @HiveField(3) required this.teamNumber,
      @HiveField(4) required this.timestamp,
      @HiveField(5) required final Map<String, dynamic> data,
      @HiveField(6) this.notes,
      @HiveField(7) required this.scoutName})
      : _data = data;

  factory _$ScoutEntryImplImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutEntryImplImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
// UUID
  @override
  @HiveField(1)
  final int eventId;
  @override
  @HiveField(2)
  final int matchId;
  @override
  @HiveField(3)
  final String teamNumber;
  @override
  @HiveField(4)
  final DateTime timestamp;
  final Map<String, dynamic> _data;
  @override
  @HiveField(5)
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

// Flexible form data
  @override
  @HiveField(6)
  final String? notes;
  @override
  @HiveField(7)
  final String scoutName;

  @override
  String toString() {
    return 'ScoutEntry(id: $id, eventId: $eventId, matchId: $matchId, teamNumber: $teamNumber, timestamp: $timestamp, data: $data, notes: $notes, scoutName: $scoutName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutEntryImplImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.teamNumber, teamNumber) ||
                other.teamNumber == teamNumber) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.scoutName, scoutName) ||
                other.scoutName == scoutName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, eventId, matchId, teamNumber,
      timestamp, const DeepCollectionEquality().hash(_data), notes, scoutName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutEntryImplImplCopyWith<_$ScoutEntryImplImpl> get copyWith =>
      __$$ScoutEntryImplImplCopyWithImpl<_$ScoutEntryImplImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutEntryImplImplToJson(
      this,
    );
  }
}

abstract class ScoutEntryImpl implements ScoutEntry {
  const factory ScoutEntryImpl(
      {@HiveField(0) required final String id,
      @HiveField(1) required final int eventId,
      @HiveField(2) required final int matchId,
      @HiveField(3) required final String teamNumber,
      @HiveField(4) required final DateTime timestamp,
      @HiveField(5) required final Map<String, dynamic> data,
      @HiveField(6) final String? notes,
      @HiveField(7) required final String scoutName}) = _$ScoutEntryImplImpl;

  factory ScoutEntryImpl.fromJson(Map<String, dynamic> json) =
      _$ScoutEntryImplImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override // UUID
  @HiveField(1)
  int get eventId;
  @override
  @HiveField(2)
  int get matchId;
  @override
  @HiveField(3)
  String get teamNumber;
  @override
  @HiveField(4)
  DateTime get timestamp;
  @override
  @HiveField(5)
  Map<String, dynamic> get data;
  @override // Flexible form data
  @HiveField(6)
  String? get notes;
  @override
  @HiveField(7)
  String get scoutName;
  @override
  @JsonKey(ignore: true)
  _$$ScoutEntryImplImplCopyWith<_$ScoutEntryImplImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
