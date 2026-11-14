import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';
import '../l10n/strings.dart';
import '../models/birthday.dart';
import '../models/person.dart';
import '../services/image_service.dart';
import '../services/people_store.dart';
import '../utils/app_theme.dart';
import '../widgets/birthday_picker.dart';

/// Lists the phone's contacts so the user can pick who to add. A contact's
/// birthday (with or without a year) and photo come along automatically.
/// Pops with the list of new people, or null if nothing was added.
class ContactsImportScreen extends StatefulWidget {
  const ContactsImportScreen({super.key});

  @override
  State<ContactsImportScreen> createState() => _ContactsImportScreenState();
}

enum _State { loading, denied, ready }

class _ContactsImportScreenState extends State<ContactsImportScreen> {
  _State _state = _State.loading;
  bool _limited = false;
  List<_Entry> _entries = [];
  final _selected = <String>{};
  String _query = '';
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.read);
    if (status != PermissionStatus.granted &&
        status != PermissionStatus.limited) {
      if (mounted) setState(() => _state = _State.denied);
      return;
    }
    final contacts = await FlutterContacts.getAll(properties: {
      ContactProperty.name,
      ContactProperty.event,
      ContactProperty.photoThumbnail,
    });

    // Contacts already imported (by contact id), so they show as added.
    final existing = PeopleStore.instance.people
        .map((p) => p.contactId)
        .whereType<String>()
        .toSet();

    final entries = <_Entry>[];
    for (final c in contacts) {
      final name = (c.displayName ?? '').trim();
      if (c.id == null || name.isEmpty) continue;
      Birthday? bday;
      for (final e in c.events) {
        if (e.label.label == EventLabel.birthday) {
          bday = Birthday(year: e.year, month: e.month, day: e.day);
          break;
        }
      }
      entries.add(_Entry(
        contact: c,
        name: name,
        birthday: bday,
        alreadyAdded: existing.contains(c.id),
      ));
    }
    entries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _limited = status == PermissionStatus.limited;
      _state = _State.ready;
    });
  }

  List<_Entry> get _visible {
    if (_query.isEmpty) return _entries;
    final q = _query.toLowerCase();
    return _entries.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  void _selectAllWithBirthdays() {
    setState(() {
      for (final e in _entries) {
        if (e.birthday != null && !e.alreadyAdded) _selected.add(e.contact.id!);
      }
    });
  }

  Future<void> _addSelected() async {
    setState(() => _adding = true);
    final people = <Person>[];
    for (final e in _entries.where((e) => _selected.contains(e.contact.id))) {
      final thumb = e.contact.photo?.thumbnail;
      final image = (thumb != null && thumb.isNotEmpty)
          ? await ImageService.saveBytes(thumb)
          : null;
      people.add(Person(
        id: const Uuid().v4(),
        name: e.name,
        birthday: e.birthday?.encode(),
        avatarEmoji: '🎁',
        avatarImage: image,
        contactId: e.contact.id,
      ));
    }
    if (mounted) Navigator.pop(context, people);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.contactsTitle)),
      body: switch (_state) {
        _State.loading => const Center(child: CircularProgressIndicator()),
        _State.denied => _buildDenied(s),
        _State.ready => _buildList(s),
      },
      bottomNavigationBar: _state == _State.ready && _selected.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ElevatedButton.icon(
                  onPressed: _adding ? null : _addSelected,
                  icon: _adding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.person_add_rounded),
                  label: Text(s.addNPeople(_selected.length)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDenied(S s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📇', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(s.contactsDenied,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => FlutterContacts.permissions.openSettings(),
              child: Text(s.openSettings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(S s) {
    final visible = _visible;
    final anyWithBirthday =
        _entries.any((e) => e.birthday != null && !e.alreadyAdded);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: s.searchContacts,
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
            ),
          ),
        ),
        if (_limited)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(s.contactsLimited,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (anyWithBirthday)
                TextButton.icon(
                  onPressed: _selectAllWithBirthdays,
                  icon: const Icon(Icons.cake_rounded, size: 18),
                  label: Text(s.selectWithBirthdays),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.coral),
                ),
              const Spacer(),
              if (_selected.isNotEmpty)
                TextButton(
                  onPressed: () => setState(_selected.clear),
                  child: Text(s.clearSelection),
                ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(s.noContacts,
                      style: TextStyle(color: Colors.grey.shade500)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: visible.length,
                  itemBuilder: (context, i) => _buildTile(s, visible[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildTile(S s, _Entry e) {
    final id = e.contact.id!;
    final selected = _selected.contains(id);
    final thumb = e.contact.photo?.thumbnail;
    final subtitle = e.alreadyAdded
        ? s.alreadyAdded
        : e.birthday != null
            ? '🎂 ${formatBirthday(context, e.birthday!)}'
            : s.noBirthdaySaved;
    return Opacity(
      opacity: e.alreadyAdded ? 0.45 : 1,
      child: CheckboxListTile(
        value: selected || e.alreadyAdded,
        onChanged: e.alreadyAdded
            ? null
            : (v) => setState(() => v == true
                ? _selected.add(id)
                : _selected.remove(id)),
        activeColor: AppTheme.coral,
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        secondary: CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.coral.withValues(alpha: 0.12),
          backgroundImage:
              (thumb != null && thumb.isNotEmpty) ? MemoryImage(thumb) : null,
          child: (thumb == null || thumb.isEmpty)
              ? Text(
                  e.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                      color: AppTheme.coral, fontWeight: FontWeight.w800),
                )
              : null,
        ),
        title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: e.birthday != null && !e.alreadyAdded
                ? AppTheme.charcoal
                : Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _Entry {
  final Contact contact;
  final String name;
  final Birthday? birthday;
  final bool alreadyAdded;
  _Entry({
    required this.contact,
    required this.name,
    required this.birthday,
    required this.alreadyAdded,
  });
}
