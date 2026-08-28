import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';

class StorageService {
  static const _key = 'gift_genie_people';

  static Future<List<Person>> loadPeople() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => Person.fromJson(e)).toList();
  }

  static Future<void> savePeople(List<Person> people) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(people.map((p) => p.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
