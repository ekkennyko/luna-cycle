import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _channelId = 'luna_reminders';
  static const _channelName = 'Reminders';

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  static Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final impl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await impl?.requestNotificationsPermission() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final impl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await impl?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return false;
  }

  static Future<void> rescheduleAll({
    required DateTime nextPeriodDate,
    required DateTime fertileWindowStart,
    required bool periodReminderEnabled,
    required int periodReminderDays,
    required bool fertileWindowEnabled,
    required bool latePeriodEnabled,
    required int daysLate,
    required bool appLockEnabled,
  }) async {
    await cancelAll();

    final locale = PlatformDispatcher.instance.locale;
    final l10n = lookupAppLocalizations(locale);
    final now = tz.TZDateTime.now(tz.local);
    final visibility = appLockEnabled ? NotificationVisibility.secret : NotificationVisibility.private;

    // ID 1: Period reminder
    if (periodReminderEnabled) {
      final reminderDate = nextPeriodDate.subtract(Duration(days: periodReminderDays));
      final tzDate = tz.TZDateTime(tz.local, reminderDate.year, reminderDate.month, reminderDate.day, 9, 0);
      if (tzDate.isAfter(now)) {
        await _plugin.zonedSchedule(
          1,
          l10n.notificationLunaPrivate,
          l10n.notificationPeriodReminder(periodReminderDays),
          tzDate,
          _details(visibility),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    // ID 2: Fertile window
    if (fertileWindowEnabled) {
      final tzDate = tz.TZDateTime(
        tz.local,
        fertileWindowStart.year,
        fertileWindowStart.month,
        fertileWindowStart.day,
        9,
        0,
      );
      if (tzDate.isAfter(now)) {
        await _plugin.zonedSchedule(
          2,
          l10n.notificationLunaPrivate,
          l10n.notificationFertileWindow,
          tzDate,
          _details(visibility),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }

    // IDs 3–9: Late period (day 1 through 7 after nextPeriodDate)
    if (latePeriodEnabled) {
      final startDay = max(1, daysLate);
      for (int d = startDay; d <= 7; d++) {
        final lateDate = nextPeriodDate.add(Duration(days: d));
        final tzDate = tz.TZDateTime(tz.local, lateDate.year, lateDate.month, lateDate.day, 10, 0);
        if (tzDate.isAfter(now)) {
          await _plugin.zonedSchedule(
            2 + d,
            l10n.notificationLunaPrivate,
            l10n.notificationLatePeriod(d),
            tzDate,
            _details(visibility),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  static NotificationDetails _details(NotificationVisibility visibility) => NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          visibility: visibility,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
}
