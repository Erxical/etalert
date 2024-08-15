import 'package:frontend/services/api.dart';

Future<int?> createUser(
    String googleId, String email, String? name, String? image) async {
  try {
    final response = await Api.dio.post("/users", data: {
      "googleId": googleId,
      "email": email,
      "name": name ?? "",
      "image": image ?? ""
    });

    if (response.statusCode == 200) {
      return response.statusCode;
    }
    if (response.statusCode == 208) {
      return response.statusCode;
    }
  } catch (e) {
    rethrow;
  }
  return null;
}
