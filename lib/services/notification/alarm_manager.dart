import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmManager {
  static final Map<int, Timer> _alarmTimers = {};

  static Future<void> setAlarmWithAutoStop({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    // Then, set up the alarm to trigger slightly after the notification
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime.add(const Duration(seconds: 1)), // Slight delay
      assetAudioPath: 'assets/mixkit-warning-alarm-buzzer-991.mp3',
      notificationTitle: title,
      notificationBody: body,
      loopAudio: true,
      vibrate: true,
      fadeDuration: 3.0,
      enableNotificationOnKill: true,
    );
    
    await Alarm.set(alarmSettings: alarmSettings);

    // Set up a timer to stop the alarm after 5 minutes
    _alarmTimers[id] = Timer(const Duration(minutes: 2), () {
      Alarm.stop(id);
      _alarmTimers.remove(id);
    });
  }

  static void cancelAlarmTimer(int id) {
    _alarmTimers[id]?.cancel();
    _alarmTimers.remove(id);
  }
}