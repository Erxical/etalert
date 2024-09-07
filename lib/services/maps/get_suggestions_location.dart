import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
  try {
    final apiKey = dotenv.env['API_KEY'];
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': query,
        'key': apiKey,
        //kin'types': 'geocode',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final predictions = data['predictions'] as List<dynamic>;
      return predictions.map((prediction) => prediction as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  } catch (e) {
    print('Error getting suggestions: $e');
    rethrow;
  }
}
