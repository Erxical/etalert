import 'package:frontend/services/api.dart';

Future<void> deleteSchedules(int groupId) async {
  try {
    final response = await Api.dio.delete('/users/schedules/$groupId');

    if (response.statusCode == 200) {
      return;
    }
  } catch (e) {
    rethrow;
  }
}
