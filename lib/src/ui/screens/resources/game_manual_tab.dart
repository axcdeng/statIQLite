import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roboscout_iq/src/ui/screens/resources/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roboscout_iq/src/models/game_rule.dart';
import 'package:roboscout_iq/src/state/providers.dart';

/// All sections in the game manual, in order of appearance.
const List<String> kManualSections = [
  'G',
  'GG',
  'SG',
  'SC',
  'R',
  'RSC',
  'T',
  'S'
];

const Map<String, String> kSectionNames = {
  'S': 'Safety',
  'G': 'General',
  'GG': 'General Game',
  'SG': 'Specific Game',
  'SC': 'Scoring',
  'R': 'Robot',
  'RSC': 'Robot Skills',
  'T': 'Tournament',
};

class GameManualTab extends ConsumerStatefulWidget {
  const GameManualTab({super.key});

  @override
  ConsumerState<GameManualTab> createState() => _GameManualTabState();
}

class _GameManualTabState extends ConsumerState<GameManualTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _activeSection;
  String _searchQuery = '';

  List<GameRule> _filterRules(List<GameRule> allRules) {
    var rules = allRules.toList();

    if (_activeSection != null) {
      rules = rules.where((r) => r.section == _activeSection).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      rules = rules.where((r) {
        return r.id.toLowerCase().contains(q) ||
            r.title.toLowerCase().contains(q) ||
            r.body.toLowerCase().contains(q) ||
            r.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    return rules;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final rulesAsync = ref.watch(gameManualRulesProvider);

    return rulesAsync.when(
      data: (rules) => _buildContent(context, rules, primaryColor),
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle,
                size: 48, color: CupertinoColors.systemRed),
            const SizedBox(height: 16),
            Text('Error loading manual: $err'),
            CupertinoButton(
              onPressed: () => ref.refresh(gameManualRulesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, List<GameRule> allRules, Color primaryColor) {
    final filtered = _filterRules(allRules);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Search rules, tags, or rule numbers...',
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
          ),
        ),

        // Section quick-filter chips + PDF button
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildChip('All', null, primaryColor),
              for (final section in kManualSections)
                _buildChip(
                  '${kSectionNames[section]} ($section)',
                  section,
                  primaryColor,
                ),
              // PDF button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: _openPdf,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: CupertinoColors.tertiarySystemFill
                          .resolveFrom(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.doc_text,
                            size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'View PDF',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Rules list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No rules found.',
                    style: TextStyle(
                      color: CupertinoColors.inactiveGray.resolveFrom(context),
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final rule = filtered[index];
                    final isFirstOfSection = index == 0 ||
                        filtered[index - 1].section != rule.section;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFirstOfSection) ...[
                          if (index > 0) const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0.2),
                                  primaryColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${kSectionNames[rule.section]} (${rule.section})',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        _buildRuleCard(rule, primaryColor),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openPdf([int? page]) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/game_manual.pdf');

      // Always copy to ensure we have the latest version if the asset changes
      final data = await rootBundle.load('assets/pdfs/game_manual.pdf');
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => PDFViewerScreen(
            filePath: file.path,
            title: 'Game Manual',
            initialPage: page ?? 0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error opening PDF: $e');
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Could not open the game manual PDF.\n\nDetails: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildChip(String label, String? section, Color primaryColor) {
    final isActive = _activeSection == section;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeSection = section;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isActive
                ? primaryColor
                : CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : CupertinoColors.label.resolveFrom(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard(GameRule rule, Color primaryColor) {
    return _RuleCard(
      rule: rule,
      primaryColor: primaryColor,
      onTagTap: (tag) {
        _searchController.text = tag;
        setState(() => _searchQuery = tag);
      },
      onOpenWebsite: (ruleId) => _openWebsite(ruleId),
    );
  }

  Future<void> _openWebsite(String ruleId) async {
    final url = Uri.parse(
        'https://www.vexrobotics.com/mix-and-match-manual#${ruleId.toLowerCase()}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}

class _RuleCard extends StatefulWidget {
  final GameRule rule;
  final Color primaryColor;
  final Function(String)? onTagTap;
  final Function(String)? onOpenWebsite;

  const _RuleCard({
    required this.rule,
    required this.primaryColor,
    this.onTagTap,
    this.onOpenWebsite,
  });

  @override
  State<_RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<_RuleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground
              .resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rule ID + Title + Web Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.rule.id,
                    style: TextStyle(
                      color: widget.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.rule.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final ruleId =
                        widget.rule.id.replaceAll(RegExp(r'[<>]'), '');
                    widget.onOpenWebsite?.call(ruleId);
                  },
                  child: Icon(
                    CupertinoIcons.globe,
                    size: 20,
                    color: widget.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                if (_isExpanded || bounds.height < 100) {
                  return const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ).createShader(bounds);
                }
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.6, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: _isExpanded ? double.infinity : 100,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: MarkdownBody(
                    data: widget.rule.body,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 13,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        height: 1.5,
                      ),
                      listBullet: TextStyle(
                        fontSize: 13,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.rule.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              // Tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.rule.tags.map((tag) {
                  return GestureDetector(
                    onTap: () => widget.onTagTap?.call(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill
                            .resolveFrom(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
