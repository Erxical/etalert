import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<LatLng> getCoordinatesFromPlaceId(String placeId) async {
  try {
    final api = dotenv.env['API_KEY'];
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': api,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final location = data['result']['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];
      return LatLng(lat, lng);
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  } catch (e) {
    throw Exception('Error fetching coordinates from place ID: $e');
  }
}
