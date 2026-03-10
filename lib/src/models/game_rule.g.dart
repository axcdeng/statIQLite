// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameRuleImpl _$$GameRuleImplFromJson(Map<String, dynamic> json) =>
    _$GameRuleImpl(
      id: json['id'] as String,
      section: json['section'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      page: (json['page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GameRuleImplToJson(_$GameRuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'section': instance.section,
      'title': instance.title,
      'body': instance.body,
      'tags': instance.tags,
      'page': instance.page,
    };
