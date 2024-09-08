import 'package:frontend/models/schedules/schedule_req.dart';
import 'package:frontend/services/api.dart';

Future<void> createSchedule(ScheduleReq schedule) async {
  try {
    final response = await Api.dio.post('/schedules', data: {
      'GoogleId': schedule.googleId,
      'Name': schedule.name,
      'Date': schedule.date,
      'StartTime': schedule.startTime,
      'EndTime': schedule.endTime,
      'IsHaveEndTime': schedule.isHaveEndTime,
      'OriLatitude': schedule.oriLatitude,
      'OriLongitude': schedule.oriLongtitude,
      'DestLatitude': schedule.destLatitude,
      'DestLongitude': schedule.destLongtitude,
      'IsHaveLocation': schedule.isHaveLocation,
      'IsFirstSchedule': schedule.isFirstSchedule,
      'DepartTime': schedule.departTime,
    });
  } catch (e) {
    rethrow;
  }
}
