import 'package:frontend/models/schedules/schedules.dart';
import 'package:frontend/services/api.dart';

Future<Schedules?> getAllSchedules(String googleId, String date) async {
  try {
    final response = await Api.dio.get('/users/schedules/$googleId/$date');

    if (response.statusCode == 200) {
      final data = response.data;
      Schedules res = Schedules.fromJson(data);
      return res;
    }
  } catch (e) {
    rethrow;
  }
  return null;
}
