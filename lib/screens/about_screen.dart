import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/strings.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.about)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Center(
            child: Image.asset('assets/logo.png',
                width: 180, filterQuality: FilterQuality.medium),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 4),
          Center(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) => Text(
                snap.hasData ? s.version(snap.data!.version) : '',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            emoji: '🎁',
            color: AppTheme.coral,
            title: s.aboutWhatTitle,
            body: s.aboutWhatBody,
          ),
          _Section(
            emoji: '💡',
            color: AppTheme.peach,
            title: s.aboutWhyTitle,
            body: s.aboutWhyBody,
          ),
          _Section(
            emoji: '🔒',
            color: AppTheme.mint,
            title: s.aboutPrivacyTitle,
            body: s.aboutPrivacyBody,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              s.madeWithLove,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const _MadeBy(),
        ],
      ),
    );
  }
}

/// "by KV TecHub", with the name linking to the website.
class _MadeBy extends StatefulWidget {
  const _MadeBy();

  @override
  State<_MadeBy> createState() => _MadeByState();
}

class _MadeByState extends State<_MadeBy> {
  static final _url = Uri.parse('https://kvtechub.com');
  late final _tap = TapGestureRecognizer()
    ..onTap = () => launchUrl(_url, mode: LaunchMode.externalApplication);

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: TextStyle(color: Colors.grey.shade600),
          children: [
            TextSpan(text: S.of(context).madeByPrefix),
            TextSpan(
              text: 'KV TecHub',
              recognizer: _tap,
              style: const TextStyle(
                color: AppTheme.coral,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.coral,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String emoji;
  final Color color;
  final String title;
  final String body;

  const _Section({
    required this.emoji,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(body,
                    style: const TextStyle(fontSize: 14, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}
