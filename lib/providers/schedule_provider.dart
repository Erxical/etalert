import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/schedules/schedules.dart';
import 'package:frontend/services/data/schedules/delete_schedule.dart';
import 'package:frontend/services/data/schedules/edit_schedule.dart';
import 'package:frontend/services/data/schedules/get_user_schedules.dart';
import 'package:frontend/services/data/schedules/create_schedule.dart';
import 'package:frontend/models/schedules/schedule_req.dart';

class ScheduleNotifier extends StateNotifier<AsyncValue<List<Schedule>>> {
  final String googleId;

  ScheduleNotifier(this.googleId) : super(const AsyncValue.loading()) {
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await getUserSchedules(googleId);
      state = AsyncValue.data(schedules!);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addSchedule(ScheduleReq scheduleReq) async {
    try {
      await createSchedule(scheduleReq);
      await fetchSchedules();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteSchedule(int groupId) async {
    state = const AsyncValue.loading();
    try {
      await deleteSchedules(groupId);
      await fetchSchedules();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> editSchedule(String scheduleId, String name, String date,
      String startTime, String endTime, bool isHaveEndTime) async {
    try {
      await editScheduleService(
          scheduleId, name, date, startTime, endTime, isHaveEndTime);
      await fetchSchedules();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final scheduleProvider = StateNotifierProvider.family<ScheduleNotifier,
    AsyncValue<List<Schedule>>, String>(
  (ref, googleId) => ScheduleNotifier(googleId),
);
