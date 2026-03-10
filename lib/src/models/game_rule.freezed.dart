// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameRule _$GameRuleFromJson(Map<String, dynamic> json) {
  return _GameRule.fromJson(json);
}

/// @nodoc
mixin _$GameRule {
  String get id => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int? get page => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GameRuleCopyWith<GameRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameRuleCopyWith<$Res> {
  factory $GameRuleCopyWith(GameRule value, $Res Function(GameRule) then) =
      _$GameRuleCopyWithImpl<$Res, GameRule>;
  @useResult
  $Res call(
      {String id,
      String section,
      String title,
      String body,
      List<String> tags,
      int? page});
}

/// @nodoc
class _$GameRuleCopyWithImpl<$Res, $Val extends GameRule>
    implements $GameRuleCopyWith<$Res> {
  _$GameRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? section = null,
    Object? title = null,
    Object? body = null,
    Object? tags = null,
    Object? page = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameRuleImplCopyWith<$Res>
    implements $GameRuleCopyWith<$Res> {
  factory _$$GameRuleImplCopyWith(
          _$GameRuleImpl value, $Res Function(_$GameRuleImpl) then) =
      __$$GameRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String section,
      String title,
      String body,
      List<String> tags,
      int? page});
}

/// @nodoc
class __$$GameRuleImplCopyWithImpl<$Res>
    extends _$GameRuleCopyWithImpl<$Res, _$GameRuleImpl>
    implements _$$GameRuleImplCopyWith<$Res> {
  __$$GameRuleImplCopyWithImpl(
      _$GameRuleImpl _value, $Res Function(_$GameRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? section = null,
    Object? title = null,
    Object? body = null,
    Object? tags = null,
    Object? page = freezed,
  }) {
    return _then(_$GameRuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameRuleImpl implements _GameRule {
  const _$GameRuleImpl(
      {required this.id,
      required this.section,
      required this.title,
      required this.body,
      final List<String> tags = const [],
      this.page})
      : _tags = tags;

  factory _$GameRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameRuleImplFromJson(json);

  @override
  final String id;
  @override
  final String section;
  @override
  final String title;
  @override
  final String body;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final int? page;

  @override
  String toString() {
    return 'GameRule(id: $id, section: $section, title: $title, body: $body, tags: $tags, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.page, page) || other.page == page));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, section, title, body,
      const DeepCollectionEquality().hash(_tags), page);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GameRuleImplCopyWith<_$GameRuleImpl> get copyWith =>
      __$$GameRuleImplCopyWithImpl<_$GameRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameRuleImplToJson(
      this,
    );
  }
}

abstract class _GameRule implements GameRule {
  const factory _GameRule(
      {required final String id,
      required final String section,
      required final String title,
      required final String body,
      final List<String> tags,
      final int? page}) = _$GameRuleImpl;

  factory _GameRule.fromJson(Map<String, dynamic> json) =
      _$GameRuleImpl.fromJson;

  @override
  String get id;
  @override
  String get section;
  @override
  String get title;
  @override
  String get body;
  @override
  List<String> get tags;
  @override
  int? get page;
  @override
  @JsonKey(ignore: true)
  _$$GameRuleImplCopyWith<_$GameRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
