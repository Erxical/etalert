import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/schedules/schedules.dart';
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
      if (schedules != null) {
        state = AsyncValue.data(schedules);
      } else {
        state =
            AsyncValue.error("Failed to fetch schedules", StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addSchedule(ScheduleReq scheduleReq) async {
    try {
      await createSchedule(scheduleReq);
      fetchSchedules();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final scheduleProvider = StateNotifierProvider.family<ScheduleNotifier,
    AsyncValue<List<Schedule>>, String>(
  (ref, googleId) => ScheduleNotifier(googleId),
);
