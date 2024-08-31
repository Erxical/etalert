import 'package:frontend/services/api.dart';

Future<void> createRoutine(
    String googleId, String name, int duration, int order) async {
  try {
    final response = await Api.dio.post('/users/routines', data: {
      "googleId": googleId,
      "name": name,
      "duration": duration,
      "order": order
    });
  } catch (e) {
    rethrow;
  }
}
