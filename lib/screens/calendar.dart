import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user/user_info.dart';
import 'package:frontend/screens/selectlocation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend/components/schedule_card.dart';
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
  // Updated to store a list of maps with detailed event info
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  GoogleMapController? mapController;
  LatLng _center = LatLng(13.6512574, 100.4938679);
  Set<Marker> _marker = {};

  @override
  void initState() {
    super.initState();
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
        markerId: MarkerId('currentLocation'),
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
    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      LatLng latLng = LatLng(location.latitude, location.longitude);

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

      setState(() {
        _marker.clear();
        _marker.add(Marker(
          markerId: MarkerId('searchedLocation'),
          position: latLng,
        ));
      });
    }
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
                    onDaySelected: (selectedDay, focusedDay) {
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: _events[_selectedDay]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final event = _events[_selectedDay]![index];
                        // return GestureDetector(
                        //   onTap: () {
                        //     _showEventDetailsDialog(context, event);
                        //   },
                        //   child: ScheduleCard(name: event['name'] ?? 'No name'),
                        // );
                      },
                    ),
                  ),
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
            event['time'] as TimeOfDay? ?? TimeOfDay(hour: 0, minute: 0);
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(event['name'] ?? 'No name'),
            IconButton(
              icon: Icon(Icons.delete), // Trash bin icon
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
              decoration: InputDecoration(
                labelText: 'Location',
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
    TextEditingController taskNameController = TextEditingController();
    TextEditingController dateController = TextEditingController(
      text: "${_selectedDay.toLocal()}".split(' ')[0],
    );
    TextEditingController timeController = TextEditingController();
    TextEditingController locationController = TextEditingController();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    OutlineInputBorder customBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: colorScheme.primaryContainer,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(8.0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'New Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your schedule.',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(
                  border: customBorder,
                  enabledBorder: customBorder,
                  focusedBorder: customBorder,
                  labelText: 'Name',
                  labelStyle: TextStyle(color: colorScheme.primary),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        border: customBorder,
                        enabledBorder: customBorder,
                        focusedBorder: customBorder,
                        labelText: 'Date',
                        labelStyle: TextStyle(color: colorScheme.primary),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDay,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          dateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.access_time, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        border: customBorder,
                        enabledBorder: customBorder,
                        focusedBorder: customBorder,
                        labelText: 'Time',
                        labelStyle: TextStyle(color: colorScheme.primary),
                      ),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          timeController.text = pickedTime.format(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.location_on, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        border: customBorder,
                        enabledBorder: customBorder,
                        focusedBorder: customBorder,
                        labelText: 'Location',
                        labelStyle: TextStyle(color: colorScheme.primary),
                      ),
                      onTap: () async {
                        String? selectedLocation =
                            await _selectLocation(context);
                        if (selectedLocation != null) {
                          locationController.text = selectedLocation;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final taskName = taskNameController.text.isNotEmpty
                        ? taskNameController.text
                        : 'Unnamed Event';
                    final date = dateController.text.isNotEmpty
                        ? dateController.text
                        : 'No date';
                    final timeString = timeController.text.isNotEmpty
                        ? timeController.text
                        : '00:00';
                    final location = locationController.text.isNotEmpty
                        ? locationController.text
                        : 'No location';

                    if (taskName.isNotEmpty &&
                        date.isNotEmpty &&
                        timeString.isNotEmpty &&
                        location.isNotEmpty) {
                      // Parse the timeString back to TimeOfDay
                      final timeParts = timeString.split(':');
                      final time = TimeOfDay(
                        hour: int.parse(timeParts[0]),
                        minute: int.parse(timeParts[1].split(' ')[0]),
                      );

                      final eventDetails = {
                        'name': taskName,
                        'date': date,
                        'time': time, // Store TimeOfDay directly
                        'location': location,
                      };

                      setState(() {
                        if (_events[_selectedDay] != null) {
                          _events[_selectedDay]!.add(eventDetails);
                        } else {
                          _events[_selectedDay] = [eventDetails];
                        }
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _selectLocation(BuildContext context) async {
    String? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocation(),
      ),
    );

    return selectedLocation;
  }

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
}
