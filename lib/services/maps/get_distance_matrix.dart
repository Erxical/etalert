import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/maps/distance_matrix.dart';
import 'package:frontend/services/api.dart';

Future<dynamic> getDistanceMatrix(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude) async {
  try {
    final api = dotenv.env['API_KEY'];
    final response = await Api.dio.get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$endLatitude,$endLongitude&origins=$startLatitude,$startLongitude&mode=driving&key=$api');

    if (response.statusCode == 200) {
      final data = response.data;
      DistanceMatrix res = DistanceMatrix.fromJson(data);
      return res;
    }
  } catch (e) {
    rethrow;
  }
}
