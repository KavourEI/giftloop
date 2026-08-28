import 'dart:convert';
import 'gift_idea.dart';

class Person {
  final String id;
  String name;
  String? birthday; // ISO date string e.g. "2024-06-15"
  String? avatarEmoji;
  String? notes;
  List<GiftIdea> giftIdeas;
  DateTime createdAt;

  Person({
    required this.id,
    required this.name,
    this.birthday,
    this.avatarEmoji,
    this.notes,
    List<GiftIdea>? giftIdeas,
    DateTime? createdAt,
  })  : giftIdeas = giftIdeas ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Days until next birthday (returns null if no birthday set)
  int? get daysUntilBirthday {
    if (birthday == null) return null;
    final bday = DateTime.parse(birthday!);
    final now = DateTime.now();
    var next = DateTime(now.year, bday.month, bday.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, bday.month, bday.day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  bool get hasBirthdaySoon {
    final d = daysUntilBirthday;
    return d != null && d <= 7;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthday': birthday,
        'avatarEmoji': avatarEmoji,
        'notes': notes,
        'giftIdeas': giftIdeas.map((g) => g.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'],
        name: json['name'],
        birthday: json['birthday'],
        avatarEmoji: json['avatarEmoji'],
        notes: json['notes'],
        giftIdeas: (json['giftIdeas'] as List<dynamic>? ?? [])
            .map((g) => GiftIdea.fromJson(g))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );

  String toJsonString() => jsonEncode(toJson());
}
