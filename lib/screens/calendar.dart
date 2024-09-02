import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/models/user/user_info.dart';
import 'package:frontend/providers/router_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';

Future<void> backgroundNotificationHandler(
    NotificationResponse response) async {
  final String? payload = response.payload;
  if (payload != null) {
    try {
      int alarmId = int.parse(payload);
      await Alarm.stop(alarmId);
      print('Alarm with ID $alarmId stopped.');
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  } else {
    print('No payload found.');
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  UserData? data;
  bool isLoading = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;
        if (payload != null) {
          int alarmId = int.parse(payload);
          await Alarm.stop(alarmId);

          // Optionally, navigate to a specific screen if needed
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => Calendar()));
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          backgroundNotificationHandler, // Use the top-level function here
    );

    Alarm.ringStream.stream.listen((alarmSettings) {
      _showNotification(alarmSettings);
    });
  }

  Future<void> _showNotification(AlarmSettings alarmSettings) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(
          'mixkit_warning_alarm_buzzer_991'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.show(
      alarmSettings.id,
      alarmSettings.notificationTitle,
      alarmSettings.notificationBody,
      platformChannelSpecifics,
      payload: alarmSettings.id.toString(), // Ensure the payload is correct
    );
  }

  void setAlarm(int id, DateTime dateTime, String title, String body) async {
    await Alarm.init();
    final alarmSetting = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: 'assets/mixkit-warning-alarm-buzzer-991.mp3',
      notificationTitle: title,
      notificationBody: body,
      loopAudio: true,
      enableNotificationOnKill: true,
    );
    await Alarm.set(alarmSettings: alarmSetting);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
                child: Text(
              'Loading...',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 20),
            )),
          )
        : Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'ETAlert',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  // RoundedImage(url: data!.image)
                ],
              ),
            ),
            body: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  calendarStyle: CalendarStyle(
                      markersMaxCount: 1,
                      selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle),
                      todayTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) {
                    return _events[day]
                            ?.map((event) => event['title'])
                            .toList() ??
                        [];
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _buildTimeline(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () => _addEventDialog(context),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildTimeline() {
    List<Map<String, dynamic>> events = _events[_selectedDay] ?? [];

    // Sort events by time
    events.sort((a, b) {
      TimeOfDay timeA = a['time'];
      TimeOfDay timeB = b['time'];
      return timeA.hour.compareTo(timeB.hour) == 0
          ? timeA.minute.compareTo(timeB.minute)
          : timeA.hour.compareTo(timeB.hour);
    });

    if (events.isEmpty) {
      return const Center(child: Text('No events today'));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final time = event['time'] as TimeOfDay;
        final title = event['title'] as String;

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.2,
          beforeLineStyle: LineStyle(
              color: Theme.of(context).colorScheme.primary, thickness: 2),
          afterLineStyle: LineStyle(
              color: Theme.of(context).colorScheme.primary, thickness: 2),
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(6),
          ),
          startChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              time.format(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(16)),
                child: Text(
                  title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500),
                )),
          ),
        );
      },
    );
  }

  void _addEventDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Schedule name"),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: Text(
                selectedTime == null
                    ? "Pick a time"
                    : "Time: ${selectedTime!.format(context)}",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty || selectedTime == null) return;

              setState(() {
                final event = {
                  'title': titleController.text,
                  'time': selectedTime,
                };

                if (_events[_selectedDay] != null) {
                  _events[_selectedDay]!.add(event);
                } else {
                  _events[_selectedDay] = [event];
                }

                // Set the alarm
                final DateTime selectedDateTime = DateTime(
                  _selectedDay.year,
                  _selectedDay.month,
                  _selectedDay.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                final int alarmId =
                    _events[_selectedDay]!.length; // unique ID for each alarm

                setAlarm(
                  alarmId,
                  selectedDateTime,
                  titleController.text,
                  'This is your reminder for ${titleController.text}',
                );
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
