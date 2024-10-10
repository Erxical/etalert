import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/components/custom_schedule_dialog.dart';
import 'package:frontend/models/maps/location.dart';
import 'package:frontend/models/schedules/schedule_req.dart';
import 'package:frontend/models/schedules/schedules.dart';
import 'package:frontend/models/user/user_info.dart';
import 'package:frontend/providers/schedule_provider.dart';
import 'package:frontend/services/notification/notification_handler.dart';
import 'package:frontend/screens/selectlocation.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:frontend/services/data/schedules/get_schedules.dart';
import 'package:frontend/screens/selectoriginlocation.dart';

class Calendar extends ConsumerStatefulWidget {
  final String googleId;
  const Calendar({super.key, required this.googleId});

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now().toLocal();
  DateTime _focusedDay = DateTime.now().toLocal();
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
  // SelectedLocation originLocation = SelectedLocation(
  //     locationName: 'muaymi\' home',
  //     selectedLatLng: const LatLng(13.6337128, 100.4749808));
  final NotificationsHandler _notificationsHandler = NotificationsHandler();

  @override
  void initState() {
    super.initState();
    _notificationsHandler.initialize();
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
    await _notificationsHandler.showNotification(alarmSetting);
    print('Alarm set for $dateTime with ID $id');
  }

  String formatDate(DateTime date) {
    var dateTime = date.toLocal();
    String formattedDate =
        '${dateTime.day.toString().length == 1 ? '0${dateTime.day}' : '${dateTime.day}'}-${dateTime.month.toString().length == 1 ? '0${dateTime.month}' : '${dateTime.month}'}-${dateTime.year}';
    return formattedDate;
  }

  TimeOfDay formatTime(String time) {
    final times = time.split(':');
    return TimeOfDay(hour: int.parse(times[0]), minute: int.parse(times[1]));
  }

  Future<List<Schedule>?> getSchedule(String date) async {
    final data = await getAllSchedules(widget.googleId, date);

    if (data != null) {
      return data;
    }
    return null;
  }

  void _processSchedules(List<Schedule> schedules) {
    setState(() {
      _events.clear(); // Clear existing events before processing
      for (var schedule in schedules) {
        final date = DateFormat('dd-MM-yyyy')
            .parse(schedule.date)
            .add(const Duration(hours: 7));

        schedule.endTime == "" ? schedule.startTime : schedule.endTime;
        final event;

        if (schedule.isHaveEndTime) {
          event = {
            'id': schedule.id,
            'name': schedule.name,
            'date': schedule.date,
            'time': TimeOfDay(
              hour: int.parse(schedule.startTime.split(':')[0]),
              minute: int.parse(schedule.startTime.split(':')[1]),
            ),
            'endTime': TimeOfDay(
                hour: int.parse(schedule.endTime!.split(':')[0]),
                minute: int.parse(schedule.endTime!.split(':')[1])),
            'location': schedule.destinationName,
            'originLocation': schedule.originName,
            'isHaveEndTime': schedule.isHaveEndTime,
            'groupId': schedule.groupId,
          };
        } else {
          event = {
            'id': schedule.id,
            'name': schedule.name,
            'date': schedule.date,
            'time': TimeOfDay(
              hour: int.parse(schedule.startTime.split(':')[0]),
              minute: int.parse(schedule.startTime.split(':')[1]),
            ),
            'location': schedule.destinationName,
            'originLocation': schedule.originName,
            'isHaveEndTime': schedule.isHaveEndTime,
            'groupId': schedule.groupId,
          };
        }

        if (_events[date.toUtc()] == null) {
          _events[date.toUtc()] = [];
        }
        _events[date.toUtc()]!.add(event);
      }
      _buildTimeline();
    });
  }

  Future<void> _createSchedule(
    String scheduleName,
    String date,
    String startTime,
    String? endTime,
    String? oriName,
    double? orilat,
    double? orilng,
    String? desName,
    double? deslat,
    double? deslng,
    bool isFirstSchedule,
    DateTime selectedDay,
    bool isTraveling,
  ) async {
    final bool isHaveLocation = oriName != null &&
        desName != null &&
        orilat != null &&
        orilng != null &&
        deslat != null &&
        deslng != null;
    final req = ScheduleReq(
      googleId: widget.googleId,
      name: scheduleName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isHaveEndTime: true,
      oriName: oriName,
      oriLatitude: orilat,
      oriLongtitude: orilng,
      desName: desName,
      destLatitude: deslat,
      destLongtitude: deslng,
      isHaveLocation: isHaveLocation,
      isFirstSchedule: isFirstSchedule,
      isTraveling: isTraveling,
    );
    await ref.read(scheduleProvider(widget.googleId).notifier).addSchedule(req);
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider(widget.googleId));

    return scheduleState.when(
      data: (schedules) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _processSchedules(schedules);
        });

        return Scaffold(
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
                    await getSchedule(formatDate(selectedDay));
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
      },
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error Stack: $stack')),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
            Flexible(
              child: Text(
                event['name'] ?? 'No name',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete), // Trash bin icon
              onPressed: () async {
                // Delete the event
                await ref
                    .read(scheduleProvider(widget.googleId).notifier)
                    .deleteSchedule(event['groupId']);
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
            Text(
                'Time: ${event['time'].format(context)} ${event['isHaveEndTime'] ? '- ' + event['endTime'].format(context) : ''}'),
            TextField(
              controller: originLocationController,
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
          final isChecked = eventDetails['isChecked'];
          final oriLocationName = eventDetails['originLocation'];
          final desLocationName = eventDetails['destinationLocation'];

          final scheduledDateTime = DateTime(
            _selectedDay.year,
            _selectedDay.month,
            _selectedDay.day,
            time.hour,
            time.minute,
          );

          await _createSchedule(
            taskName,
            dateString,
            time.format(context),
            TimeOfDay(hour: time.hour + 1, minute: time.minute).format(context),
            oriLocationName,
            eventDetails['originLatitude'],
            eventDetails['originLongitude'],
            desLocationName,
            eventDetails['destinationLatitude'],
            eventDetails['destinationLongitude'],
            isChecked,
            _selectedDay,
            isChecked,
          );

          final notificationId =
              DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;

          await _notificationsHandler.showNotification(
            AlarmSettings(
              id: notificationId,
              dateTime: scheduledDateTime,
              notificationTitle: taskName,
              notificationBody: "Your schedule is about to start!",
              assetAudioPath: 'assets/mixkit-warning-alarm-buzzer-991.mp3',
              loopAudio: true,
              enableNotificationOnKill: true,
            ),
          );
          setState(() {});
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
