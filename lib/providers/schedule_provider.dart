import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/schedules/schedules.dart';
import 'package:frontend/services/data/schedules/delete_schedule.dart';
import 'package:frontend/services/data/schedules/get_user_schedules.dart';
import 'package:frontend/services/data/schedules/create_schedule.dart';
import 'package:frontend/models/schedules/schedule_req.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/services/notification/notification_handler.dart';
import 'package:frontend/services/notification/alarm_manager.dart';
import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/data/schedules/get_schedules.dart';

class ScheduleState {
  final List<Schedule> schedules;
  final bool isProcessing;
  final Map<DateTime, List<Schedule>> schedulesMap;

  ScheduleState({
    required this.schedules,
    this.isProcessing = false,
    Map<DateTime, List<Schedule>>? schedulesMap,
  }) : schedulesMap = schedulesMap ?? {};

  ScheduleState copyWith({
    List<Schedule>? schedules,
    bool? isProcessing,
    Map<DateTime, List<Schedule>>? schedulesMap,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isProcessing: isProcessing ?? this.isProcessing,
      schedulesMap: schedulesMap ?? this.schedulesMap,
    );
  }
}

class ScheduleNotifier extends StateNotifier<AsyncValue<ScheduleState>> {
  final String googleId;
  final NotificationsHandler _notificationsHandler = NotificationsHandler();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ScheduleNotifier(this.googleId) : super(const AsyncValue.loading()) {
    fetchAllSchedules();
    _initializeAlarm();
  }

  Future<void> _initializeAlarm() async {
    await Alarm.init();
  }

  Map<DateTime, List<Schedule>> _organizeSchedulesByDate(
      List<Schedule> schedules) {
    final Map<DateTime, List<Schedule>> organized = {};
    for (final schedule in schedules) {
      final date = DateFormat('dd-MM-yyyy').parse(schedule.date);
      final dateKey = DateTime(date.year, date.month, date.day);

      if (!organized.containsKey(dateKey)) {
        organized[dateKey] = [];
      }
      organized[dateKey]!.add(schedule);
    }
    return organized;
  }

  Future<void> fetchAllSchedules() async {
    state = const AsyncValue.loading();
    try {
      // Fetch user-created and backend schedules
      final List<Schedule>? userSchedules = await getUserSchedules(googleId);
      final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final List<Schedule>? backendSchedules =
          await getAllSchedules(googleId, today);

      // Combine schedules, ensuring no duplicates
      final List<Schedule> allSchedules = [
        if (userSchedules != null) ...userSchedules,
        if (backendSchedules != null)
          ...backendSchedules.where((backendSchedule) =>
              userSchedules?.every(
                  (userSchedule) => userSchedule.id != backendSchedule.id) ??
              true),
      ];

      // Organize schedules by date and update state
      final Map<DateTime, List<Schedule>> schedulesMap =
          _organizeSchedulesByDate(allSchedules);

      state = AsyncValue.data(ScheduleState(
        schedules: allSchedules,
        schedulesMap: schedulesMap,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> fetchSchedulesForDate(String date) async {
    try {
      // Fetch user schedules and ensure it's a List<Schedule>
      final List<Schedule>? userSchedules = await getUserSchedules(googleId);

      // Fetch backend schedules and ensure it's a List<Schedule>
      final List<Schedule>? backendSchedules =
          await getAllSchedules(googleId, date);

      // Combine the schedules, filtering out duplicates based on schedule ID
      final List<Schedule> allSchedules = [
        if (userSchedules != null)
          ...userSchedules, // Null-checking and spreading
        if (backendSchedules != null)
          ...backendSchedules.where((backendSchedule) =>
              userSchedules?.every(
                  (userSchedule) => userSchedule.id != backendSchedule.id) ??
              true),
      ];

      // Organize schedules by date
      final Map<DateTime, List<Schedule>> schedulesMap =
          _organizeSchedulesByDate(allSchedules);

      // Update state with the combined schedules and schedules map
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.copyWith(
          schedules: allSchedules,
          schedulesMap: schedulesMap,
        ));
      });

      // Set alarms for backend schedules, but only for future schedules
      if (backendSchedules != null) {
        for (final backendSchedule in backendSchedules) {
          final scheduleDate =
              DateFormat('dd-MM-yyyy').parse(backendSchedule.date);
          final timeParts = backendSchedule.startTime.split(':');
          final scheduleDateTime = DateTime(
            scheduleDate.year,
            scheduleDate.month,
            scheduleDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          // Only set alarms for future schedules
          if (scheduleDateTime.isAfter(DateTime.now())) {
            await _setNotificationAndAlarm(backendSchedule);
          }
        }
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addSchedule(ScheduleReq scheduleReq) async {
    try {
      // Step 1: Create the schedule
      await createSchedule(scheduleReq);

      // Step 2: Set alarm for the user-created schedule
      await _setNotificationAndAlarmFromRequest(scheduleReq, autoStop: false);

      // Step 3: Fetch backend schedules related to the new schedule
      final relatedBackendSchedules =
          await getAllSchedules(googleId, scheduleReq.date);

      if (relatedBackendSchedules != null &&
          relatedBackendSchedules.isNotEmpty) {
        for (final backendSchedule in relatedBackendSchedules) {
          // Set alarms only for backend schedules that don't match the user-created one
          if (backendSchedule.name != scheduleReq.name ||
              backendSchedule.startTime != scheduleReq.startTime) {
            await _setNotificationAndAlarm(backendSchedule, autoStop: false);
          }
        }
      }

      // Step 4: Refresh all schedules after adding
      await fetchAllSchedules();
    } catch (e, stackTrace) {
      print('Error while adding schedule: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> _setNotificationAndAlarm(Schedule schedule,
      {bool autoStop = false}) async {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(schedule.date);
      final time = schedule.startTime.split(':');
      final scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(time[0]),
        int.parse(time[1]),
      );

      if (scheduledDateTime.isAfter(DateTime.now())) {
        final alarmId = schedule.id.hashCode % 0x7FFFFFFF;
        await _setAlarm(
          id: alarmId,
          dateTime: scheduledDateTime,
          title: schedule.name,
          body: "Your schedule '${schedule.name}' is starting now!",
          autoStop: autoStop,
        );
      }
    } catch (e) {
      print('Error while setting notification or alarm: $e');
    }
  }

  Future<void> _setNotificationAndAlarmFromRequest(ScheduleReq scheduleReq,
      {bool autoStop = false}) async {
    final date = DateFormat('dd-MM-yyyy').parse(scheduleReq.date);
    final time = scheduleReq.startTime.split(':');
    final scheduledDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(time[0]),
      int.parse(time[1]),
    );

    if (scheduledDateTime.isAfter(DateTime.now())) {
      final alarmId = scheduledDateTime.millisecondsSinceEpoch % 0x7FFFFFFF;
      await _setAlarm(
        id: alarmId,
        dateTime: scheduledDateTime,
        title: scheduleReq.name,
        body: "Your schedule '${scheduleReq.name}' is starting now!",
        autoStop: autoStop,
      );
    }
  }

  Future<void> _setAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    bool autoStop = false,
  }) async {
    await _notificationsHandler.showNotification(
      AlarmSettings(
        id: id,
        dateTime: dateTime,
        notificationTitle: title,
        notificationBody: body,
        assetAudioPath: 'assets/mixkit-warning-alarm-buzzer-991.mp3',
        loopAudio: true,
        vibrate: true,
        enableNotificationOnKill: true,
      ),
    );

    if (autoStop) {
      await AlarmManager.setAlarmWithAutoStop(
        id: id,
        dateTime: dateTime,
        title: title,
        body: body,
        flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      );
    } else {
      await AlarmManager.setAlarmWithSound(
        id: id,
        dateTime: dateTime,
        title: title,
        body: body,
      );
    }
  }

  Future<void> deleteSchedule(int groupId) async {
    try {
      await deleteSchedules(groupId);
      // Stop the alarm and cancel the timer when deleting a schedule
      await AlarmManager.stopAlarm(groupId);
      await fetchAllSchedules();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  List<Schedule> getSchedulesForDate(DateTime date) {
    return state.when(
      data: (state) {
        final dateKey = DateTime(date.year, date.month, date.day);
        return state.schedulesMap[dateKey] ?? [];
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

final scheduleProvider = StateNotifierProvider.family<ScheduleNotifier,
    AsyncValue<ScheduleState>, String>(
  (ref, googleId) => ScheduleNotifier(googleId),
);
