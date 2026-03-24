import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:roboscout_iq/src/models/game_rule.dart';

class GameManualService {
  final Dio _dio;
  final Box _cache;

  static const String _kRulesCacheKey = 'game_rules_json_v2';
  static const String _kLastUpdateKey = 'rules_last_update_v2';
  static const String _kManualUrl =
      'https://www.vexrobotics.com/mix-and-match-manual';
  static final RegExp _kRuleIdPattern = RegExp(r'^<([A-Z]+)\d+>$');

  GameManualService(this._dio, this._cache);

  Future<List<GameRule>> getRules({bool forceRefresh = false}) async {
    final lastUpdateStr = _cache.get(_kLastUpdateKey);
    final DateTime? lastUpdate =
        lastUpdateStr != null ? DateTime.parse(lastUpdateStr) : null;

    // Check if we have any data at all
    final cachedData = _cache.get(_kRulesCacheKey);

    if (cachedData == null) {
      debugPrint('No cached rules found. Loading from assets...');
      try {
        final initialRules = _sanitizeRules(await _loadFromAssets());
        await _saveToCache(initialRules);
        return initialRules;
      } catch (e) {
        debugPrint('Failed to load rules from assets: $e');
      }
    }

    // Refresh if forced, or cache older than 24h
    if (forceRefresh ||
        lastUpdate == null ||
        DateTime.now().difference(lastUpdate).inHours >= 24) {
      try {
        final rules = await refreshRules();
        return rules;
      } catch (e) {
        debugPrint('Failed to refresh manual from web: $e. Using cache.');
      }
    }

    if (cachedData != null) {
      final List<dynamic> jsonList = jsonDecode(cachedData);
      final cachedRules = jsonList
          .map((j) => GameRule.fromJson((j as Map).cast<String, dynamic>()))
          .toList();
      final sanitizedRules = _sanitizeRules(cachedRules);

      // Self-heal stale cache entries (e.g., malformed "rules" from bad parse).
      if (!listEquals(cachedRules, sanitizedRules)) {
        await _saveToCache(sanitizedRules);
      }

      return sanitizedRules;
    }

    return [];
  }

  Future<List<GameRule>> _loadFromAssets() async {
    final String content =
        await rootBundle.loadString('assets/game_manual.json');
    final List<dynamic> jsonList = jsonDecode(content);

    return jsonList.map((j) {
      final map = (j as Map).cast<String, dynamic>();

      // If the JSON is already in the correct format (e.g. from cache but somehow loaded here), handle it gracefully.
      if (map.containsKey('body') && map.containsKey('section')) {
        return GameRule.fromJson(map);
      }

      // Read from Python script's generated format
      final id = map['id'] as String? ?? '';
      final title = map['title'] as String? ?? '';
      final body = map['description'] as String? ?? '';
      final type = map['type'] as String? ?? 'rule';

      String section = 'G';
      final match = RegExp(r'^<([A-Z]+)\d+>$').firstMatch(id);
      if (match != null) {
        section = match.group(1)!;
      } else if (id.startsWith('<S')) {
        section = 'S';
      }

      return GameRule(
        id: id,
        title: title,
        body: body,
        section: section,
        tags: type == 'definition' ? ['definition'] : const [],
      );
    }).toList();
  }

  Future<void> _saveToCache(List<GameRule> rules) async {
    await _cache.put(
        _kRulesCacheKey, jsonEncode(rules.map((r) => r.toJson()).toList()));
    await _cache.put(_kLastUpdateKey, DateTime.now().toIso8601String());
  }

  Future<List<GameRule>> refreshRules() async {
    final response = await _dio.get(
      _kManualUrl,
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
        },
      ),
    );

    if (response.statusCode == 200) {
      final String html = response.data.toString();
      final rules = _sanitizeRules(_parseManualHtml(html));
      if (rules.isNotEmpty) {
        await _saveToCache(rules);
        return rules;
      }
    }

    throw Exception('Failed to fetch rules from manual website');
  }

  List<GameRule> _parseManualHtml(String html) {
    // The VEX website often uses a structured format for rules.
    // For now, if we can't parse it robustly on-device (due to dynamic content),
    // we should return an empty list to fallback to cache.
    // TODO: Implement regex-based parsing from the HTML if possible.
    return [];
  }

  List<GameRule> _sanitizeRules(List<GameRule> rules) {
    final seenIds = <String>{};
    final cleaned = <GameRule>[];

    for (final rule in rules) {
      final id = rule.id.trim();
      final section = _sectionFromRuleId(id);
      final title = rule.title.trim();
      final body = rule.body.trim();

      if (section == null || title.isEmpty || body.isEmpty) {
        continue;
      }

      if (!seenIds.add(id)) {
        continue;
      }

      cleaned.add(rule.copyWith(
        id: id,
        section: section,
        title: title,
        body: body,
      ));
    }

    return cleaned;
  }

  String? _sectionFromRuleId(String id) {
    final match = _kRuleIdPattern.firstMatch(id);
    return match?.group(1);
  }

  // ignore: unused_element
  String _cleanText(String text) {
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    // Simplify LaTeX-style IDs
    text = text.replaceAllMapped(
        RegExp(r'\$\{\s*\\\\?tt\s*(<[A-Z0-9]+>)\s*\}\$'), (m) => m.group(1)!);
    return text.trim();
  }
}
