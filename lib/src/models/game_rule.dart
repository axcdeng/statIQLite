import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_rule.freezed.dart';
part 'game_rule.g.dart';

@freezed
class GameRule with _$GameRule {
  const factory GameRule({
    required String id,
    required String section,
    required String title,
    required String body,
    @Default([]) List<String> tags,
    int? page,
  }) = _GameRule;

  factory GameRule.fromJson(Map<String, dynamic> json) =>
      _$GameRuleFromJson(json);
}
