import 'package:frontend/models/user/user_info.dart';
import 'package:frontend/services/api.dart';

Future<UserData?> getUserInfo(String googleId) async {
  try {
    final response = await Api.dio.get('/users/info/$googleId');

    if (response.statusCode == 200) {
      final data = response.data;
      UserData res = UserData.fromJson(data);
      return res;
    }
  } catch (e) {
    rethrow;
  }
  return null;
}
