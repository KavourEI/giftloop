import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Person;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/person.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // notifications not supported on web

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macOS = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios, macOS: macOS),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> scheduleAllBirthdayReminders(
      List<Person> people) async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
    for (final person in people) {
      if (person.birthday != null) {
        await scheduleBirthdayReminder(person);
      }
    }
  }

  static Future<void> scheduleBirthdayReminder(Person person) async {
    if (kIsWeb || person.birthday == null) return;

    final bday = DateTime.parse(person.birthday!);
    final now = DateTime.now();

    // Schedule 7 days before birthday
    var reminderDate =
        DateTime(now.year, bday.month, bday.day).subtract(const Duration(days: 7));
    if (reminderDate.isBefore(now)) {
      reminderDate = DateTime(now.year + 1, bday.month, bday.day)
          .subtract(const Duration(days: 7));
    }

    final id = person.id.hashCode.abs() % 100000;

    final androidDetails = const AndroidNotificationDetails(
      'birthday_channel',
      'Birthday Reminders',
      channelDescription: 'Reminds you 7 days before a birthday',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails, macOS: iosDetails);

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: '🎁 ${person.name}\'s birthday is in 7 days!',
        body: 'Time to get a gift! You have ${person.giftIdeas.length} gift idea(s) saved.',
        scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
        notificationDetails: details,
        // Inexact so no exact-alarm permission is needed. The reminder fires a
        // week ahead of the birthday, so a delivery window of minutes or hours
        // is immaterial. A future settings page can offer exact timing (and a
        // configurable lead time) behind a runtime permission request.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } catch (e) {
      debugPrint('Notification scheduling failed: $e');
    }
  }

  static Future<void> cancelReminder(String personId) async {
    if (kIsWeb) return;
    final id = personId.hashCode.abs() % 100000;
    await _plugin.cancel(id: id);
  }
}
