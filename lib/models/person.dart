import 'dart:convert';
import 'birthday.dart';
import 'gift_idea.dart';

class Person {
  final String id;
  String name;

  /// `YYYY-MM-DD`, or `--MM-DD` when the year is unknown. See [Birthday].
  String? birthday;
  String? avatarEmoji;

  /// File names (not full paths) inside the app's images folder. Full paths
  /// change between installs on iOS, so only the name is stored.
  String? avatarImage;
  String? backgroundImage;

  /// Identifier of the device contact this person was imported from.
  String? contactId;
  String? notes;
  List<GiftIdea> giftIdeas;
  DateTime createdAt;

  Person({
    required this.id,
    required this.name,
    this.birthday,
    this.avatarEmoji,
    this.avatarImage,
    this.backgroundImage,
    this.contactId,
    this.notes,
    List<GiftIdea>? giftIdeas,
    DateTime? createdAt,
  })  : giftIdeas = giftIdeas ?? [],
        createdAt = createdAt ?? DateTime.now();

  Birthday? get birthdayInfo => Birthday.tryParse(birthday);

  /// Days until next birthday (returns null if no birthday set)
  int? get daysUntilBirthday => birthdayInfo?.daysUntil();

  bool get hasBirthdaySoon {
    final d = daysUntilBirthday;
    return d != null && d <= 7;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthday': birthday,
        'avatarEmoji': avatarEmoji,
        'avatarImage': avatarImage,
        'backgroundImage': backgroundImage,
        'contactId': contactId,
        'notes': notes,
        'giftIdeas': giftIdeas.map((g) => g.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'],
        name: json['name'],
        birthday: json['birthday'],
        avatarEmoji: json['avatarEmoji'],
        avatarImage: json['avatarImage'],
        backgroundImage: json['backgroundImage'],
        contactId: json['contactId'],
        notes: json['notes'],
        giftIdeas: (json['giftIdeas'] as List<dynamic>? ?? [])
            .map((g) => GiftIdea.fromJson(g))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );

  String toJsonString() => jsonEncode(toJson());
}
