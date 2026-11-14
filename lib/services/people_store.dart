import 'package:flutter/foundation.dart';
import '../models/person.dart';
import 'image_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

/// Single source of truth for the people list. Screens listen to it, and every
/// change is persisted and the birthday reminders rebuilt.
class PeopleStore extends ChangeNotifier {
  PeopleStore._();
  static final instance = PeopleStore._();

  List<Person> _people = [];
  bool _loaded = false;
  Future<void>? _loading;

  List<Person> get people => List.unmodifiable(_people);
  bool get isLoaded => _loaded;

  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    _people = await StorageService.loadPeople();
    _loaded = true;
    notifyListeners();
    await NotificationService.scheduleAllBirthdayReminders(_people);
  }

  Person? byId(String id) {
    for (final p in _people) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> add(Person p) => addAll([p]);

  Future<void> addAll(List<Person> list) async {
    _people.addAll(list);
    await _commit();
  }

  Future<void> update(Person p) async {
    final idx = _people.indexWhere((x) => x.id == p.id);
    if (idx == -1) {
      _people.add(p);
    } else {
      _people[idx] = p;
    }
    await _commit();
  }

  Future<void> delete(String id) async {
    final p = byId(id);
    _people.removeWhere((x) => x.id == id);
    await _commit();
    if (p != null) {
      await ImageService.delete(p.avatarImage);
      await ImageService.delete(p.backgroundImage);
    }
  }

  /// Re-schedules reminders, e.g. after the language changes.
  Future<void> refreshReminders() =>
      NotificationService.scheduleAllBirthdayReminders(_people);

  Future<void> _commit() async {
    notifyListeners();
    await StorageService.savePeople(_people);
    await NotificationService.scheduleAllBirthdayReminders(_people);
  }
}
