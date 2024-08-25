import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/api.dart';

Future<dynamic> getDistanceMatrix(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude, DateTime arriveTime) async {
  try {
    final api = dotenv.env['API_KEY'];
    final startDate = DateTime.utc(1970, 1, 1);
    final isStartUtc = startDate.isUtc;
    final arrivalTime = arriveTime.difference(startDate).inSeconds;
    final isArriveUtc = arriveTime.isUtc;
    // print('Start Date: $startDate and is UTC? $isStartUtc');
    // print('Arrive Time: $arriveTime and is UTC? $isArriveUtc');
    // print('Arrival Time: $arrivalTime');
    final response = await Api.dio.get(
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$endLatitude,$endLongitude&origins=$startLatitude,$startLongitude&mode=driving&key=$api');

    if (response.statusCode == 200) {
      final data = response.data;
      return data;
    }
  } catch (e) {
    rethrow;
  }
}
