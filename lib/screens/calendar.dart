import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user/user_info.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';

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
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    // _getData();
    super.initState();
  }

  // Future<void> _getData() async {
  //   isLoading = true;
  //   data = await getUserInfo(widget.googleId);
  //   if (mounted) {
  //     setState(() {
  //       data;
  //       isLoading = false;
  //     });
  //   }
  // }

  void setAlarm(int id, DateTime dateTime, String title, String body) async {
    await Alarm.init();
    final alarmSetting = AlarmSettings(
        id: id,
        dateTime: dateTime,
        assetAudioPath: 'assets/alarm.mp3',
        notificationTitle: title,
        notificationBody: body,
        loopAudio: true,
        enableNotificationOnKill: true);
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
              decoration: const InputDecoration(hintText: "Scedule name"),
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
