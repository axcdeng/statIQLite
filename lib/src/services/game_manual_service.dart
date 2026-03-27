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
  static const String _kManualPdfUrl =
      'https://link.vex.com/docs/25-26/viqrc-mixandmatch-manual';
  static final RegExp _kRuleIdPattern = RegExp(r'^<([A-Z]+)\d+>$');
  static const Map<String, int> _kRulePdfPages = {
    'SC1': 33,
    'SC2': 33,
    'SC3': 33,
    'SC4': 35,
    'SC5': 35,
    'SC6': 35,
    'SC7': 36,
    'SC8': 36,
    'S1': 41,
    'S2': 41,
    'S3': 41,
    'G1': 42,
    'G2': 43,
    'G3': 44,
    'G4': 44,
    'G5': 46,
    'GG1': 48,
    'GG2': 49,
    'GG3': 49,
    'GG4': 49,
    'GG5': 49,
    'GG6': 50,
    'GG7': 50,
    'GG8': 50,
    'GG9': 50,
    'GG10': 51,
    'GG11': 51,
    'GG12': 52,
    'GG13': 53,
    'SG1': 54,
    'SG2': 55,
    'SG3': 55,
    'SG4': 55,
    'SG5': 55,
    'SG6': 56,
    'R1': 58,
    'R2': 59,
    'R3': 59,
    'R4': 60,
    'R5': 60,
    'R6': 61,
    'R7': 61,
    'R8': 61,
    'R9': 62,
    'R10': 62,
    'R11': 62,
    'R12': 62,
    'R13': 63,
    'R14': 63,
    'R15': 64,
    'R16': 64,
    'R17': 64,
    'R18': 65,
    'R19': 65,
    'RSC1': 68,
    'RSC2': 68,
    'RSC3': 68,
    'RSC4': 69,
    'RSC5': 69,
    'RSC6': 70,
    'RSC7': 70,
    'RSC8': 71,
    'T1': 74,
    'T2': 75,
    'T3': 75,
    'T4': 75,
    'T5': 76,
    'T6': 76,
    'T7': 77,
    'T8': 77,
    'T9': 77,
    'T10': 77,
    'T11': 78,
    'T12': 78,
    'T13': 79,
    'T14': 79,
    'T15': 79,
    'T16': 80,
    'T17': 80,
    'T18': 81,
    'T19': 81,
  };

  GameManualService(this._dio, this._cache);

  String manualPdfUrlForPage(int page) => '$_kManualPdfUrl#page=$page';

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
        page: _kRulePdfPages[id.replaceAll(RegExp(r'[<>]'), '')],
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
        page: rule.page ?? _kRulePdfPages[id.replaceAll(RegExp(r'[<>]'), '')],
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
