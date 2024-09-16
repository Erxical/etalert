import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/components/custom_schedule_dialog.dart';
import 'package:frontend/models/maps/location.dart';
import 'package:frontend/models/schedules/schedule_req.dart';
import 'package:frontend/models/schedules/schedules.dart';
import 'package:frontend/models/user/user_info.dart';
import 'package:frontend/services/data/schedules/create_schedule.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/screens/selectlocation.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:frontend/services/data/schedules/get_schedules.dart';
import 'package:frontend/screens/selectoriginlocation.dart';

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
  final String googleId;
  const Calendar({super.key, required this.googleId});

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
  // Updated to store a list of maps with detailed event info
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  TextEditingController originLocationController = TextEditingController();
  LatLng? _originLatLng;

  GoogleMapController? mapController;
  LatLng _center = const LatLng(13.6512574, 100.4938679);
  Set<Marker> _marker = {};
  late SelectedLocation destinationLocation;
  SelectedLocation originLocation = SelectedLocation(
      locationName: 'muaymi\' home',
      selectedLatLng: const LatLng(13.6337128, 100.4749808));

  @override
  void initState() {
    super.initState();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initializationSettings =
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
          context.push('/');
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          backgroundNotificationHandler, // Use the top-level function here
    );

    Alarm.ringStream.stream.listen((alarmSettings) {
      _showNotification(alarmSettings);
    });
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _marker.clear();
      _marker.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: _center,
      ));
    });
  }

  Future<List<String>> _getSuggestions(String query) async {
    List<Location> locations = await locationFromAddress(query);
    return locations
        .map((location) => "${location.latitude}, ${location.longitude}")
        .toList();
  }

  Future<void> _selectSuggestion(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng latLng = LatLng(location.latitude, location.longitude);

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

        setState(() {
          _marker.clear();
          _marker.add(Marker(
            markerId: const MarkerId('searchedLocation'),
            position: latLng,
          ));
        });
      } else {
        // Handle geocoding failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error: Could not find any result for the supplied address or coordinates.'),
          ),
        );
      }
    } catch (e) {
      // Handle other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
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

  Future<void> setAlarm(
      int id, DateTime dateTime, String title, String body) async {
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
    print('Alarm set for $dateTime with ID $id');
  }

  String formatDate(DateTime date) {
    var dateTime = date.toLocal();
    String formattedDate =
        '${dateTime.day.toString().length == 1 ? '0${dateTime.day}' : '${dateTime.day}'}-${dateTime.month.toString().length == 1 ? '0${dateTime.month}' : '${dateTime.month}'}-${dateTime.year}';
    return formattedDate;
  }

  Future<List<Schedule>?> getSchedule(String date) async {
    final data = await getAllSchedules(widget.googleId, date);

    if (data != null) {
      return data;
    }
    return null;
  }

  Future<void> _createSchedule(
      String scheduleName,
      String date,
      String startTime,
      String? endTime,
      double orilat,
      double orilng,
      double deslat,
      double deslng) async {
    final req = ScheduleReq(
        googleId: widget.googleId,
        name: scheduleName,
        date: date,
        startTime: startTime,
        endTime: endTime,
        isHaveEndTime: true,
        oriLatitude: orilat,
        oriLongtitude: orilng,
        destLatitude: deslat,
        destLongtitude: deslng,
        isHaveLocation: true,
        isFirstSchedule: true);
    await createSchedule(req);
    // print('create successfully');
    final data = await getSchedule(date);
    final dateTime = DateFormat('dd-MM-yyyy').parse(date);

    if (_events[dateTime] == null) {
      _events.remove(dateTime);
    }

    // Convert schedules to the format expected by _events
    List<Map<String, dynamic>> eventsList = data!
        .map((schedule) => {
              'name': schedule.name,
              'startTime': schedule.startTime,
              'endTime': schedule.endTime,
              // Add other fields as needed
            })
        .toList();

    // Add the new events to _events
    _events[dateTime] = eventsList;

    // Trigger a rebuild of the UI
    setState(() {});
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
            body: SafeArea(
              child: Column(
                children: [
                  TableCalendar(
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      markersMaxCount: 2,
                    ),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      return _events[day]
                              ?.map((event) => event['name'] ?? '')
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
                  const SizedBox(height: 8.0),
                  // Expanded(
                  //   child: ListView.builder(
                  //     itemCount: _events[_selectedDay]?.length ?? 0,
                  //     itemBuilder: (context, index) {
                  //       final event = _events[_selectedDay]![index];
                  //       // return GestureDetector(
                  //       //   onTap: () {
                  //       //     _showEventDetailsDialog(context, event);
                  //       //   },
                  //       //   child: ScheduleCard(name: event['name'] ?? 'No name'),
                  //       // );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => _addEventDialog(context),
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
        final time =
            event['time'] as TimeOfDay? ?? const TimeOfDay(hour: 0, minute: 0);
        final title = event['name'] as String? ?? 'No Title';
        final location = event['location'] as String? ?? 'No Location';

        return GestureDetector(
          onTap: () {
            _showEventDetailsDialog(context, event);
          },
          child: TimelineTile(
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
          ),
        );
      },
    );
  }

  void _showEventDetailsDialog(
      BuildContext context, Map<String, dynamic> event) {
    TextEditingController locationController = TextEditingController();
    locationController.text = event['location'] ?? 'No Location';

    TextEditingController originLocationController = TextEditingController();
    originLocationController.text =
        event['originLocation'] ?? 'No Origin Location';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(event['name'] ?? 'No name'),
            IconButton(
              icon: const Icon(Icons.delete), // Trash bin icon
              onPressed: () {
                // Remove the event
                setState(() {
                  if (_events[_selectedDay] != null) {
                    _events[_selectedDay]!.remove(event);
                    if (_events[_selectedDay]!.isEmpty) {
                      _events.remove(_selectedDay);
                    }
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Date: ${event['date']}'),
            Text('Time: ${event['time'].format(context)}'),
            TextField(
              controller: locationController,
              style: TextStyle(
                fontSize: 14.0, // Set the desired font size here
                color: Theme.of(context)
                    .colorScheme
                    .onSurface, // Adjust text color if needed
              ),
              decoration: const InputDecoration(
                labelText: 'Start from?',
                labelStyle: TextStyle(fontSize: 14.0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            // Text field for editing location
            TextField(
              controller: locationController,
              style: TextStyle(
                fontSize: 14.0, // Set the desired font size here
                color: Theme.of(context)
                    .colorScheme
                    .onSurface, // Adjust text color if needed
              ),
              decoration: const InputDecoration(
                labelText: 'Where to?',
                labelStyle: TextStyle(fontSize: 14.0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Save the updated location
              setState(() {
                event['location'] = locationController.text;
                event['originLocation'] = originLocationController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addEventDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        selectedDay: _selectedDay,
        onSave: (eventDetails) async {
          final taskName = eventDetails['name'];
          final dateString = eventDetails['date'];
          final time = eventDetails['time'] as TimeOfDay;
          final location = eventDetails['location'];

          await _createSchedule(
            taskName,
            dateString,
            time.format(context),
            TimeOfDay(hour: time.hour + 1, minute: time.minute).format(context),
            eventDetails['originLatitude'],
            eventDetails['originLongitude'],
            eventDetails['destinationLatitude'],
            eventDetails['destinationLongitude'],
          );

          setState(() {
            if (_events[_selectedDay] != null) {
              _events[_selectedDay]!.add(eventDetails);
            } else {
              _events[_selectedDay] = [eventDetails];
            }
          });
        },
      ),
    );
  }

  Future<SelectedLocation?> _selectLocation(BuildContext context) async {
    SelectedLocation? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocation(),
      ),
    );

    return selectedLocation;
  }

  Future<SelectedLocation?> _selectOriginLocation(BuildContext context) async {
    SelectedLocation? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectOriginLocation(),
      ),
    );

    return selectedLocation;
  }
}
