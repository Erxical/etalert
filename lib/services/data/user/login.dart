import 'package:frontend/models/user/login.dart';
import 'package:frontend/services/api.dart';

Future<Login?> login(String googleId) async {
  try {
    final response = await Api.dio.post('/login', data: {
      "googleId": googleId,
    });

    if (response.statusCode == 200) {
      final data = response.data;
      Login res = Login.fromJson(data);
      return res;
    }
  } catch (e) {
    rethrow;
  }
  return null;
}
