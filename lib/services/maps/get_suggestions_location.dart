import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
  try {
    final apiKey = dotenv.env['API_KEY'];
    
    // Check if API key is present
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not found in .env file');
    }

    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': query,
        'key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      
      // Check if 'predictions' exists in the response
      if (data != null && data['predictions'] != null) {
        final predictions = data['predictions'] as List<dynamic>;
        return predictions.map((prediction) => prediction as Map<String, dynamic>).toList();
      } else {
        throw Exception('No predictions found');
      }
    } else {
      throw Exception('Failed to load suggestions: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error getting suggestions: $e');
    rethrow;  // Propagate the error upwards
  }
}
