import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/strings.dart';
import '../services/people_store.dart';
import '../services/settings_service.dart';
import '../services/share_service.dart';
import '../utils/app_theme.dart';
import '../widgets/category_dialog.dart';
import 'about_screen.dart';
import 'import_shared_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _languages = {'en': ('🇬🇧', 'English'), 'el': ('🇬🇷', 'Ελληνικά')};

  Future<void> _chooseLanguage(BuildContext context) async {
    final s = S.of(context);
    final current = SettingsService.instance.language;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.language, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._languages.entries.map((e) {
                final selected = e.key == current;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: selected
                        ? AppTheme.coral.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: selected
                                ? AppTheme.coral
                                : Colors.transparent,
                            width: 2),
                      ),
                      leading: Text(e.value.$1,
                          style: const TextStyle(fontSize: 26)),
                      title: Text(e.value.$2,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      trailing: selected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppTheme.coral)
                          : null,
                      onTap: () => Navigator.pop(context, e.key),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
    if (picked != null && picked != current) {
      await SettingsService.instance.setLanguage(picked);
      // Reminder texts are written in the chosen language.
      await PeopleStore.instance.refreshReminders();
    }
  }

  Future<void> _importSharedCard(BuildContext context) async {
    final s = S.of(context);
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(s.importSharedCard),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.importSharedCardSub,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'https://…',
                suffixIcon: IconButton(
                  tooltip: s.pasteLink,
                  icon: const Icon(Icons.content_paste_rounded),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) controller.text = data!.text!;
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(s.continueLabel,
                style: const TextStyle(
                    color: AppTheme.coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.trim().isEmpty || !context.mounted) return;
    final card = ShareService.parse(text);
    if (card == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.invalidShareLink)));
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ImportSharedScreen(card: card)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final settings = SettingsService.instance;
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _SectionTitle(s.general),
            _Group(children: [
              _Tile(
                icon: Icons.translate_rounded,
                color: AppTheme.sky,
                title: s.language,
                trailing: Text(
                  '${_languages[settings.language]!.$1}  ${_languages[settings.language]!.$2}',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
                onTap: () => _chooseLanguage(context),
              ),
            ]),
            _SectionTitle(s.categories),
            _Group(children: [
              if (settings.customCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(s.noCustomCategories,
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
              ...settings.customCategories.map((c) => ListTile(
                    title: Text(c,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                      tooltip: s.delete,
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.red.shade300),
                      onPressed: () => settings.removeCategory(c),
                    ),
                  )),
              _Tile(
                icon: Icons.add_rounded,
                color: AppTheme.coral,
                title: s.newCategory,
                onTap: () => showCreateCategoryDialog(context),
              ),
            ]),
            _SectionTitle(s.sharing),
            _Group(children: [
              _Tile(
                icon: Icons.download_rounded,
                color: AppTheme.mint,
                title: s.importSharedCard,
                subtitle: s.importSharedCardSub,
                onTap: () => _importSharedCard(context),
              ),
            ]),
            _SectionTitle(s.about),
            _Group(children: [
              _Tile(
                icon: Icons.info_outline_rounded,
                color: AppTheme.lavender,
                title: s.aboutGiftLoop,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
            ]),
            const SizedBox(height: 24),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) => Center(
                child: Text(
                  snap.hasData
                      ? 'GiftLoop · ${s.version(snap.data!.version)}'
                      : 'GiftLoop',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
          ),
        ),
      );
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      );
}
