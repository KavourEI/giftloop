import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/birthday.dart';
import '../models/person.dart';
import '../services/people_store.dart';
import '../services/share_service.dart';
import '../utils/app_theme.dart';
import '../widgets/birthday_picker.dart';
import '../widgets/person_avatar.dart';
import 'person_detail_screen.dart';

/// Shown when a shared card link is opened. The receiver chooses whether the
/// card is a new person or someone they already have; in the second case the
/// gift ideas are merged into that person.
class ImportSharedScreen extends StatefulWidget {
  final SharedCard card;
  const ImportSharedScreen({super.key, required this.card});

  @override
  State<ImportSharedScreen> createState() => _ImportSharedScreenState();
}

class _ImportSharedScreenState extends State<ImportSharedScreen> {
  final _store = PeopleStore.instance;
  late bool _asNew;
  String? _targetId;
  bool _busy = false;

  SharedCard get _card => widget.card;

  String _norm(String s) => s.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    // Suggest merging when someone with the same name already exists.
    final match = _store.people
        .where((p) => _norm(p.name) == _norm(_card.name))
        .firstOrNull;
    _asNew = match == null;
    _targetId = match?.id;
  }

  List<Person> get _candidates {
    final list = [..._store.people];
    list.sort((a, b) {
      final am = _norm(a.name) == _norm(_card.name) ? 0 : 1;
      final bm = _norm(b.name) == _norm(_card.name) ? 0 : 1;
      if (am != bm) return am - bm;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  Future<void> _confirm() async {
    final s = S.of(context);
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    late final String personId;
    late final String message;
    if (_asNew) {
      final person = ShareService.toNewPerson(_card);
      await _store.add(person);
      personId = person.id;
      message = s.importedNew(person.name);
    } else {
      final person = _store.byId(_targetId!)!;
      final added = ShareService.mergeInto(person, _card);
      await _store.update(person);
      personId = person.id;
      message = s.merged(added, person.name);
    }

    nav.popUntil((r) => r.isFirst);
    nav.push(MaterialPageRoute(
        builder: (_) => PersonDetailScreen(personId: personId)));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bday = Birthday.tryParse(_card.birthday);
    final hasPeople = _store.people.isNotEmpty;
    final canConfirm = _asNew || _targetId != null;

    return Scaffold(
      appBar: AppBar(title: Text(s.receivedCard)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // Received card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF4D96FF), Color(0xFFB983FF)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                PersonAvatar(
                  imageName: null,
                  emoji: _card.emoji,
                  size: 56,
                  background: Colors.white.withValues(alpha: 0.25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_card.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      if (bday != null)
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
          const SizedBox(height: 12),
          Text(s.receivedIntro(_card.name, _card.gifts.length),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          if (_card.gifts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: _card.gifts
                    .map((g) => ListTile(
                          dense: true,
                          leading: const Text('🎁',
                              style: TextStyle(fontSize: 18)),
                          title: Text(g.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: g.category != null
                              ? Text(s.categoryLabel(g.category!))
                              : null,
                          trailing: g.priceLabel != null
                              ? Text(g.priceLabel!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700))
                              : null,
                        ))
                    .toList(),
              ),
            ),
          ],

          // New or existing?
          const SizedBox(height: 22),
          Text(s.isThisNew, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _ChoiceCard(
            selected: _asNew,
            icon: Icons.person_add_alt_1_rounded,
            title: s.newPersonOption,
            subtitle: s.newPersonOptionSub,
            onTap: () => setState(() => _asNew = true),
          ),
          const SizedBox(height: 10),
          _ChoiceCard(
            selected: !_asNew,
            enabled: hasPeople,
            icon: Icons.merge_rounded,
            title: s.existingPersonOption,
            subtitle: hasPeople ? s.existingPersonOptionSub : s.noPeopleYet,
            onTap: () => setState(() => _asNew = false),
          ),

          if (!_asNew && hasPeople) ...[
            const SizedBox(height: 18),
            Text(s.choosePerson,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: RadioGroup<String>(
                groupValue: _targetId,
                onChanged: (v) => setState(() => _targetId = v),
                child: Column(
                  children: _candidates.map((p) {
                    final sameName = _norm(p.name) == _norm(_card.name);
                    return RadioListTile<String>(
                      value: p.id,
                      activeColor: AppTheme.coral,
                      secondary: PersonAvatar(
                        imageName: p.avatarImage,
                        emoji: p.avatarEmoji,
                        size: 36,
                        background: AppTheme.softGrey,
                      ),
                      title: Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        sameName
                            ? '${s.likelyMatch} · ${s.ideasCount(p.giftIdeas.length)}'
                            : s.ideasCount(p.giftIdeas.length),
                        style: TextStyle(
                            color: sameName
                                ? AppTheme.coral
                                : Colors.grey.shade500),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton(
            onPressed: canConfirm && !_busy ? _confirm : null,
            child: Text(_asNew ? s.importAsNew : s.mergeInto),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.selected,
    this.enabled = true,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: selected && enabled
            ? AppTheme.coral.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected && enabled
                    ? AppTheme.coral
                    : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: selected && enabled ? AppTheme.coral : Colors.grey),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                if (selected && enabled)
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.coral),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
