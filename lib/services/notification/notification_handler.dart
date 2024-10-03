import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:alarm/alarm.dart';

class NotificationsHandler {
  static final NotificationsHandler _instance = NotificationsHandler._internal();

  factory NotificationsHandler() {
    return _instance;
  }

  NotificationsHandler._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _initializeNotifications();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
  }

  Future<void> _initializeNotifications() async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _handleNotificationAction(response);
      },
    );

    await _setupNotificationActions();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _setupNotificationActions() async {
    DarwinNotificationCategory alarmCategory = DarwinNotificationCategory(
      'ALARM_CATEGORY',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          'STOP_ALARM',
          'Stop Alarm',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
    );

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[alarmCategory];

    final DarwinInitializationSettings initializationSettings =
        DarwinInitializationSettings(
      notificationCategories: darwinNotificationCategories,
    );

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(iOS: initializationSettings),
    );
  }

  Future<void> showNotification(AlarmSettings alarmSettings) async {
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(alarmSettings.dateTime, tz.local);

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'mixkit_warning_alarm_buzzer_991',
      categoryIdentifier: 'ALARM_CATEGORY',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: iOSPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmSettings.id,
        alarmSettings.notificationTitle,
        alarmSettings.notificationBody,
        scheduledDate,
        platformChannelSpecifics,
        payload: alarmSettings.id.toString(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> _handleNotificationAction(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null) {
      try {
        int alarmId = int.parse(payload);
        if (response.actionId == 'STOP_ALARM') {
          await Alarm.stop(alarmId);
          print('Alarm with ID $alarmId stopped.');
        }
      } catch (e) {
        print('Error handling notification action: $e');
      }
    } else {
      print('No payload found.');
    }
  }

  Future<void> backgroundNotificationHandler(
      NotificationResponse response) async {
    await _handleNotificationAction(response);
  }
}