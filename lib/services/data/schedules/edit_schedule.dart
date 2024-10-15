import 'package:frontend/services/api.dart';

Future<void> editScheduleService(String scheduleId, String name, String date,
    String startTime, String endTime, bool isHaveEndTime) async {
  try {
    final response = await Api.dio.patch('/users/schedules/$scheduleId', data: {
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'isHaveEndTime': isHaveEndTime,
    });

    if (response.statusCode == 200) {
      return;
    }
  } catch (e) {
    rethrow;
  }
}
