import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor:
          CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('About'),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),

              _buildInfoSection(
                context,
                title: 'Description',
                content:
                    'statIQ Lite is a scouting and analytics app for the VEX IQ Robotics Competition.\n\nIt allows students, coaches, and parents to browse events, view rankings, analyze teams, and track competitions in real time.',
              ),

              _buildInfoSection(
                context,
                title: 'Data Source Disclosure',
                content:
                    'Competition data is provided via the RobotEvents API and the RoboSTEM API.\n\nstatIQ Lite is an independent application and is not affiliated with or endorsed by VEX Robotics or the REC Foundation.',
              ),

              _buildInfoSection(
                context,
                title: 'Privacy Statement',
                content:
                    'statIQ Lite does not collect personal data.\nAll saved favorites and preferences are stored locally on your device.',
              ),

              // Privacy Policy Link
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground
                      .resolveFrom(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(CupertinoIcons.arrow_up_right, size: 16),
                  onTap: () =>
                      _launchUrl('https://robostem.org/statiq-privacy'),
                ),
              ),

              _buildInfoSection(
                context,
                title: 'Contact',
                content: 'Questions or feedback?\nEmail: contact@robostem.org',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context,
      {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemGroupedBackground
                .resolveFrom(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.normal,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
