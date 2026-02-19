import 'package:flutter/cupertino.dart';
import 'package:roboscout_iq/src/ui/screens/resources/full_screen_image_viewer.dart';

/// Field Setup tab – all field diagrams on one scrollable page
/// with pinch-to-zoom support on each diagram.
class FieldSetupTab extends StatelessWidget {
  const FieldSetupTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Field Setup Diagrams',
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'VEX IQ Mix & Match 2025-2026. Pinch to zoom on any diagram.',
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Teamwork Field
          const _FieldDiagramCard(
            title: 'Teamwork Challenge Field',
            imagePath: 'assets/images/field_teamwork.webp',
          ),
          const SizedBox(height: 16),

          // Skills Field
          const _FieldDiagramCard(
            title: 'Robot Skills Field',
            imagePath: 'assets/images/field_skills.webp',
          ),
        ],
      ),
    );
  }
}

/// A card wrapping a field diagram with title and zoom.
class _FieldDiagramCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const _FieldDiagramCard({
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          // Diagram with zoom
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imagePath: imagePath,
                      title: title,
                    ),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    constraints:
                        const BoxConstraints(minHeight: 200, maxHeight: 400),
                    color: CupertinoColors
                        .black, // Diagrams look better on solid black regardless of mode
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        CupertinoIcons.fullscreen,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
