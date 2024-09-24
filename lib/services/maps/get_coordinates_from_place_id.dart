import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

// Define a class to store place details
class PlaceDetails {
  final String name;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

Future<PlaceDetails> getCoordinatesFromPlaceId(String placeId) async {
  try {
    final apiKey = dotenv.env['API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not found in .env file');
    }

    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      
      if (data['result'] != null && data['result']['geometry'] != null) {
        final location = data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        
        // Get the name of the place
        final name = data['result']['name'] ?? 'Unnamed Place';

        return PlaceDetails(
          name: name,
          latitude: lat,
          longitude: lng,
        );
      } else {
        throw Exception('No geometry or location data found for place ID');
      }
    } else {
      throw Exception('Failed to fetch coordinates: ${response.statusMessage}');
    }
  } catch (e) {
    throw Exception('Error fetching coordinates from place ID: $e');
  }
}
