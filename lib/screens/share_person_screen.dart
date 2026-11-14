import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/strings.dart';
import '../models/person.dart';
import '../services/share_service.dart';
import '../utils/app_theme.dart';
import '../widgets/birthday_picker.dart';
import '../widgets/person_avatar.dart';

/// Lets the sender choose which gift ideas to include, then opens the system
/// share sheet (Messages, WhatsApp, AirDrop, Mail…) with a link to the card.
class SharePersonScreen extends StatefulWidget {
  final Person person;
  const SharePersonScreen({super.key, required this.person});

  @override
  State<SharePersonScreen> createState() => _SharePersonScreenState();
}

class _SharePersonScreenState extends State<SharePersonScreen> {
  late final Set<String> _selected =
      widget.person.giftIdeas.map((g) => g.id).toSet();
  bool _includeBirthday = true;
  bool _includeNotes = false;
  final _buttonKey = GlobalKey();

  Person get _person => widget.person;

  Future<void> _share() async {
    final s = S.of(context);
    final link = ShareService.buildLink(
      _person,
      giftIds: _selected,
      includeBirthday: _includeBirthday,
      includeNotes: _includeNotes,
    );
    // iPad needs an anchor for the share popover.
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      text: s.shareMessage(_person.name, link),
      subject: s.shareSubject(_person.name),
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final gifts = _person.giftIdeas;
    final bday = _person.birthdayInfo;
    final hasNotes = (_person.notes ?? '').isNotEmpty;
    final allSelected = _selected.length == gifts.length;

    return Scaffold(
      appBar: AppBar(title: Text(s.share)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // Card preview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                PersonAvatar(
                  imageName: _person.avatarImage,
                  emoji: _person.avatarEmoji,
                  size: 56,
                  background: Colors.white.withValues(alpha: 0.25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.shareTitle(_person.name),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      if (bday != null && _includeBirthday)
                        Text('🎂 ${formatBirthday(context, bday)}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(s.shareIntro,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4)),
          const SizedBox(height: 12),

          // Options
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (bday != null)
                  SwitchListTile.adaptive(
                    value: _includeBirthday,
                    activeTrackColor: AppTheme.coral,
                    title: Text(s.includeBirthday,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    onChanged: (v) => setState(() => _includeBirthday = v),
                  ),
                if (hasNotes)
                  SwitchListTile.adaptive(
                    value: _includeNotes,
                    activeTrackColor: AppTheme.coral,
                    title: Text(s.includeNotes,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    onChanged: (v) => setState(() => _includeNotes = v),
                  ),
              ],
            ),
          ),

          // Gift selection
          if (gifts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(s.giftIdeas,
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    if (allSelected) {
                      _selected.clear();
                    } else {
                      _selected.addAll(gifts.map((g) => g.id));
                    }
                  }),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.coral),
                  child: Text(allSelected ? s.selectNone : s.selectAll),
                ),
              ],
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: gifts.map((g) {
                  return CheckboxListTile(
                    value: _selected.contains(g.id),
                    activeColor: AppTheme.coral,
                    onChanged: (v) => setState(() => v == true
                        ? _selected.add(g.id)
                        : _selected.remove(g.id)),
                    title: Text(g.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      [
                        if (g.category != null) s.categoryLabel(g.category!),
                        ?g.priceLabel,
                      ].join(' · '),
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: _buttonKey,
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(gifts.isEmpty
                      ? s.shareCardOnly
                      : s.shareNGifts(_selected.length)),
                ),
              ),
              const SizedBox(height: 6),
              Text(s.shareHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
