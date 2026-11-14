import 'package:flutter_test/flutter_test.dart';
import 'package:giftloop/models/birthday.dart';
import 'package:giftloop/models/gift_idea.dart';
import 'package:giftloop/models/person.dart';
import 'package:giftloop/services/share_service.dart';

void main() {
  group('Birthday', () {
    test('parses and encodes with and without a year', () {
      final full = Birthday.tryParse('1990-06-15')!;
      expect([full.year, full.month, full.day], [1990, 6, 15]);
      expect(full.encode(), '1990-06-15');

      final noYear = Birthday.tryParse('--03-07')!;
      expect(noYear.year, isNull);
      expect([noYear.month, noYear.day], [3, 7]);
      expect(noYear.encode(), '--03-07');
    });

    test('days until next birthday', () {
      final b = Birthday.tryParse('1990-06-15')!;
      expect(b.daysUntil(DateTime(2026, 6, 15, 18)), 0);
      expect(b.daysUntil(DateTime(2026, 6, 8)), 7);
      // Already passed this year -> next year.
      expect(b.daysUntil(DateTime(2026, 6, 16)), 364);
    });

    test('29 February is observed on 28 February in common years', () {
      final b = Birthday.tryParse('2000-02-29')!;
      expect(b.inYear(2027), DateTime(2027, 2, 28));
      expect(b.inYear(2028), DateTime(2028, 2, 29));
    });

    test('turning age', () {
      final b = Birthday(year: 2000, month: 1, day: 1);
      expect(b.turningAge, b.nextOccurrence().year - 2000);
      expect(Birthday(month: 1, day: 1).turningAge, isNull);
    });
  });

  group('ShareService', () {
    Person samplePerson() => Person(
          id: 'p1',
          name: 'Μαρία',
          birthday: '--05-20',
          avatarEmoji: '👩',
          notes: 'Loves tea',
          giftIdeas: [
            GiftIdea(id: 'g1', title: 'Teapot', estimatedPrice: 30, currency: '€'),
            GiftIdea(id: 'g2', title: 'Book', category: '📚 Books & Education'),
            GiftIdea(id: 'g3', title: 'Secret gift'),
          ],
        );

    test('link round-trips only the selected gifts', () {
      final link = ShareService.buildLink(samplePerson(),
          giftIds: {'g1', 'g2'}, includeNotes: false);
      expect(link, startsWith(ShareConfig.landingUrl));

      final card = ShareService.parse('Look at this:\n$link')!;
      expect(card.name, 'Μαρία');
      expect(card.birthday, '--05-20');
      expect(card.notes, isNull);
      expect(card.gifts.map((g) => g.title), ['Teapot', 'Book']);
      expect(card.gifts.first.estimatedPrice, 30);
    });

    test('custom scheme links parse too', () {
      final link = ShareService.buildLink(samplePerson(), giftIds: {'g1'});
      final payload = link.split('#d=').last;
      expect(ShareService.parse('giftloop://share?d=$payload')!.name, 'Μαρία');
    });

    test('merge skips gifts already present by id or title', () {
      final link = ShareService.buildLink(samplePerson(),
          giftIds: {'g1', 'g2', 'g3'}, includeNotes: true);
      final card = ShareService.parse(link)!;
      final existing = Person(id: 'x', name: 'Maria', giftIdeas: [
        GiftIdea(id: 'g1', title: 'Teapot'),
        GiftIdea(id: 'other', title: 'book '),
      ]);
      final added = ShareService.mergeInto(existing, card);
      expect(added, 1);
      expect(existing.giftIdeas.map((g) => g.title),
          ['Teapot', 'book ', 'Secret gift']);
      expect(existing.birthday, '--05-20');
      expect(existing.notes, 'Loves tea');
    });

    test('garbage is rejected', () {
      expect(ShareService.parse('hello'), isNull);
      expect(ShareService.parse('giftloop://share?d=notbase64!!'), isNull);
    });
  });
}
