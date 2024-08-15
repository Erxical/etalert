import 'package:frontend/services/api.dart';

Future<void> editUser(String googleId, String name, String image) async {
  try {
    await Api.dio
        .patch('/users/$googleId', data: {"name": name, "image": image});
  } catch (e) {
    rethrow;
  }
}
