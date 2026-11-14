import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/gift_idea.dart';
import '../models/person.dart';

/// Where share links point.
///
/// [landingUrl] hosts `share_page/index.html` from this repo. That page opens
/// the app through the `giftloop://` scheme, and sends people who don't have
/// the app to [appStoreUrl]. The card data travels in the URL fragment (after
/// `#`), which browsers never send to the server.
class ShareConfig {
  static const scheme = 'giftloop';
  static const landingUrl = 'https://kavourei.github.io/giftloop/share/';
}

/// A person card received from someone else.
class SharedCard {
  final String name;
  final String? birthday;
  final String? emoji;
  final String? notes;
  final List<GiftIdea> gifts;

  SharedCard({
    required this.name,
    this.birthday,
    this.emoji,
    this.notes,
    required this.gifts,
  });
}

class ShareService {
  static const _version = 1;

  /// Builds the link to send for [person] with only [giftIds] included.
  static String buildLink(
    Person person, {
    required Set<String> giftIds,
    bool includeBirthday = true,
    bool includeNotes = false,
  }) {
    final gifts = person.giftIdeas.where((g) => giftIds.contains(g.id));
    final data = <String, dynamic>{
      'v': _version,
      'n': person.name,
      if (includeBirthday && person.birthday != null) 'b': person.birthday,
      if (person.avatarEmoji != null) 'e': person.avatarEmoji,
      if (includeNotes && (person.notes?.isNotEmpty ?? false)) 'o': person.notes,
      'g': gifts.map(_giftToJson).toList(),
    };
    return '${ShareConfig.landingUrl}#d=${encode(data)}';
  }

  static String encode(Map<String, dynamic> data) {
    final bytes = ZLibCodec(level: 9).encode(utf8.encode(jsonEncode(data)));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Parses a received link (`giftloop://share?d=…`, the https landing link,
  /// or a whole message pasted from a chat that contains either).
  static SharedCard? parse(String input) {
    final match = RegExp(r'[?#&]d=([A-Za-z0-9_\-]+)').firstMatch(input);
    if (match == null) return null;
    try {
      var payload = match.group(1)!;
      payload += '=' * ((4 - payload.length % 4) % 4);
      final json = jsonDecode(
              utf8.decode(ZLibCodec().decode(base64Url.decode(payload))))
          as Map<String, dynamic>;
      final name = (json['n'] as String?)?.trim();
      if (name == null || name.isEmpty) return null;
      return SharedCard(
        name: name,
        birthday: json['b'] as String?,
        emoji: json['e'] as String?,
        notes: json['o'] as String?,
        gifts: (json['g'] as List? ?? [])
            .map((g) => _giftFromJson(g as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  static bool isShareLink(Uri uri) =>
      (uri.scheme == ShareConfig.scheme) ||
      uri.toString().startsWith(ShareConfig.landingUrl);

  /// Creates a new person from a shared card.
  static Person toNewPerson(SharedCard card) => Person(
        id: const Uuid().v4(),
        name: card.name,
        birthday: card.birthday,
        avatarEmoji: card.emoji ?? '🎁',
        notes: card.notes,
        giftIdeas: card.gifts.map(_copyGift).toList(),
      );

  /// Merges a shared card into [person]. Gift ideas already on the card (same
  /// id, or same title) are skipped. Returns how many were added.
  static int mergeInto(Person person, SharedCard card) {
    String norm(String s) => s.trim().toLowerCase();
    final ids = person.giftIdeas.map((g) => g.id).toSet();
    final titles = person.giftIdeas.map((g) => norm(g.title)).toSet();
    var added = 0;
    for (final g in card.gifts) {
      if (ids.contains(g.id) || titles.contains(norm(g.title))) continue;
      person.giftIdeas.add(_copyGift(g));
      ids.add(g.id);
      titles.add(norm(g.title));
      added++;
    }
    person.birthday ??= card.birthday;
    if ((person.notes ?? '').isEmpty && (card.notes ?? '').isNotEmpty) {
      person.notes = card.notes;
    }
    return added;
  }

  static GiftIdea _copyGift(GiftIdea g) => g.copyWith();

  static Map<String, dynamic> _giftToJson(GiftIdea g) => {
        'i': g.id,
        't': g.title,
        if (g.description != null) 'd': g.description,
        if (g.link != null) 'l': g.link,
        if (g.storeName != null) 's': g.storeName,
        if (g.storeLocation != null) 'sl': g.storeLocation,
        if (g.estimatedPrice != null) 'p': g.estimatedPrice,
        if (g.currency != null) 'c': g.currency,
        if (g.category != null) 'ca': g.category,
        if (g.isPurchased) 'pu': true,
      };

  static GiftIdea _giftFromJson(Map<String, dynamic> j) => GiftIdea(
        id: (j['i'] as String?) ?? const Uuid().v4(),
        title: j['t'] as String,
        description: j['d'] as String?,
        link: j['l'] as String?,
        storeName: j['s'] as String?,
        storeLocation: j['sl'] as String?,
        estimatedPrice: (j['p'] as num?)?.toDouble(),
        currency: j['c'] as String?,
        category: j['ca'] as String?,
        isPurchased: j['pu'] == true,
      );
}
