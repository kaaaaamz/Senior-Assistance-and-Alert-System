
import 'package:authtest/langconsts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
//import 'package:uuid/uuid.dart';

class NotificationManager {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    DarwinInitializationSettings initializationIos =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationIos);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }
Future<void> scheduleNotification(TimeOfDay selectedTime, String name, String id, String text) async {
  var androidDetails = const AndroidNotificationDetails(
    'channelName',
    'channelDescription ',
    importance: Importance.high,
    icon: 'flutter_logo',
  );
  var platformDetails = NotificationDetails(android: androidDetails);

  var now = DateTime.now();
  var scheduledDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  // If the selected time is before the current time, schedule for tomorrow
  if (scheduledDateTime.isBefore(now)) {
    scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
  }

  await notificationsPlugin.zonedSchedule(
    id.hashCode,
    name,
    text,
    tz.TZDateTime.from(scheduledDateTime, tz.local),
    platformDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
Future<void> cancelNotification(String id) async {
  await notificationsPlugin.cancel(id.hashCode);

}
}