import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/services/maps/get_suggestions_location.dart';
import 'package:frontend/services/maps/get_coordinates_from_place_id.dart';

Future<void> selectSuggestion(
  String description,
  GoogleMapController? mapController,
  Function(void Function()) setState,
  Set<Marker> markers,
) async {
  try {
    // Fetch suggestions based on the description (autocomplete text)
    final suggestions = await getSuggestions(description);
    
    // If suggestions are available, proceed
    if (suggestions.isNotEmpty) {
      // Get the place_id of the first suggestion
      final placeId = suggestions.first['place_id'];

      // Fetch the coordinates (LatLng) from the place ID
      final latLng = await getCoordinatesFromPlaceId(placeId);

      // Animate the camera to the new location with a zoom level of 14
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

      // Update the markers on the map to reflect the selected location
      setState(() {
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId('selectedLocation'),
          position: latLng,
        ));
      });
    } else {
      // Handle the case where no suggestions were found
      throw Exception('No suggestions found for "$description"');
    }
  } catch (e) {
    // Log or handle the error with a user-friendly message
    print('Error selecting suggestion: $e');
    throw Exception('Error selecting suggestion: $e');
  }
}
