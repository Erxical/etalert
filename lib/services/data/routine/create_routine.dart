import 'package:frontend/services/api.dart';

Future<void> createRoutine(String googleId, String name, int duration) async {
  try {
    final response = Api.dio.post('/users/routines',
        data: {"googleId": googleId, "name": name, "duration": duration});
  } catch (e) {
    rethrow;
  }
}
