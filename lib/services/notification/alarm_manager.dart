import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmManager {
  static final Map<int, Timer> _alarmTimers = {};

  static Future<void> setAlarmWithSound({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: 'assets/mixkit-warning-alarm-buzzer-991.mp3',
      loopAudio: true,
      vibrate: true,
      notificationTitle: title,
      notificationBody: body,
      fadeDuration: 3.0,
      enableNotificationOnKill: true,
    );
    
    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> setAlarmWithAutoStop({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
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

    // Set up a timer to stop the alarm after 2 minutes
    _alarmTimers[id] = Timer(const Duration(minutes: 2), () {
      Alarm.stop(id);
      _alarmTimers.remove(id);
    });
  }

  static Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
    cancelAlarmTimer(id);
  }

  static void cancelAlarmTimer(int id) {
    _alarmTimers[id]?.cancel();
    _alarmTimers.remove(id);
  }
}  