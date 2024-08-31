import 'package:frontend/models/bedtime/bedtime_info.dart';
import 'package:frontend/services/api.dart';

Future<List?> getBedtimeInfo(String googleId) async {
  try {
    final response = await Api.dio.get('/users/bedtimes/info/$googleId');

    if (response.statusCode == 200) {
      final data = await response.data;
      BedtimeInfo res = BedtimeInfo.fromJson(data);
      List bedtime = [res, response.statusCode];
      return bedtime;
    }
  } catch (e) {
    rethrow;
  }
  return null;
}
