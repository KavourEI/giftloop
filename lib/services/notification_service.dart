import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Person;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../l10n/strings.dart';
import '../models/person.dart';

/// Birthday reminders.
///
/// Each person with a birthday gets two notifications at 09:00 local time:
/// one 7 days before and one on the day. They repeat yearly on the same
/// month/day, and are rebuilt from scratch whenever data changes or the app
/// starts.
///
/// Previous bugs fixed here:
///  * Reminders were scheduled with `DateTimeComponents.dayOfMonthAndTime`,
///    which repeats **every month** on that day number — so people got
///    "birthday in 7 days" alerts on the wrong months.
///  * `tz.local` was never set, so it defaulted to UTC. Reminders were
///    scheduled at 00:00 UTC, which in Greece is 02:00/03:00 and on the
///    American side of UTC falls on the previous day.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// iOS keeps at most 64 pending local notifications per app; leave room.
  static const _maxPending = 60;
  static const _reminderHour = 9;

  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // notifications not supported on web

    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Could not resolve local timezone, using UTC: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macOS = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
          android: android, iOS: ios, macOS: macOS),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> scheduleAllBirthdayReminders(List<Person> people) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    final reminders = <_Reminder>[];
    for (final person in people) {
      final bday = person.birthdayInfo;
      if (bday == null) continue;

      // Week-before reminder: the next 09:00 that is 7 days before a birthday.
      var y = now.year;
      var weekBefore = _at(_weekBefore(bday.inYear(y)));
      if (!weekBefore.isAfter(now)) {
        weekBefore = _at(_weekBefore(bday.inYear(++y)));
      }
      reminders.add(_Reminder(person, weekBefore, isDayOf: false));

      // On-the-day reminder.
      y = now.year;
      var dayOf = _at(bday.inYear(y));
      if (!dayOf.isAfter(now)) dayOf = _at(bday.inYear(++y));
      reminders.add(_Reminder(person, dayOf, isDayOf: true));
    }

    // Keep the soonest ones within the iOS limit; the rest get scheduled on a
    // later app launch once these have fired.
    reminders.sort((a, b) => a.when.compareTo(b.when));
    final s = S.current;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'birthday_channel',
        s.notifChannelName,
        channelDescription: s.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    var id = 0;
    for (final r in reminders.take(_maxPending)) {
      try {
        await _plugin.zonedSchedule(
          id: id++,
          title: r.isDayOf
              ? s.notifDayTitle(r.person.name)
              : s.notifWeekTitle(r.person.name),
          body: r.isDayOf
              ? s.notifDayBody
              : s.notifWeekBody(
                  r.person.giftIdeas.where((g) => !g.isPurchased).length),
          scheduledDate: r.when,
          notificationDetails: details,
          // Inexact so no exact-alarm permission is needed on Android.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          // Repeat yearly on the same month, day and time.
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      } catch (e) {
        debugPrint('Notification scheduling failed: $e');
      }
    }
  }

  // Calendar arithmetic, not `subtract(Duration)`: subtracting 168 hours
  // across a daylight-saving change lands on 23:00 of the wrong day.
  static DateTime _weekBefore(DateTime d) => DateTime(d.year, d.month, d.day - 7);

  static tz.TZDateTime _at(DateTime date) => tz.TZDateTime(
      tz.local, date.year, date.month, date.day, _reminderHour);
}

class _Reminder {
  final Person person;
  final tz.TZDateTime when;
  final bool isDayOf;
  _Reminder(this.person, this.when, {required this.isDayOf});
}
