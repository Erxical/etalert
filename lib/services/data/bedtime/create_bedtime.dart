import 'package:frontend/services/api.dart';

Future<void> createBedtime(
    String googleId, String sleepTime, String wakeTime) async {
  try {
    final response = await Api.dio.post('/users/bedtimes', data: {
      "googleId": googleId,
      "sleepTime": sleepTime,
      "wakeTime": wakeTime
    });
  } catch (e) {
    rethrow;
  }
}
