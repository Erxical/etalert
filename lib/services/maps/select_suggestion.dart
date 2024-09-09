import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/services/maps/get_suggestions_location.dart';
import 'package:frontend/services/maps/get_coordinates_from_place_id.dart';

Future<String?> selectSuggestion(
    String description,
    GoogleMapController? mapController,
    Function(void Function()) setState,
    Set<Marker> markers,
) async {
  try {
    // Get autocomplete suggestions for the query
    final suggestions = await getSuggestions(description);
    
    if (suggestions.isNotEmpty) {
      final placeId = suggestions.first['place_id'];

      // Get the coordinates and place details for the selected suggestion
      final placeDetails = await getCoordinatesFromPlaceId(placeId);

      // Place the marker on the map and animate the camera
      final latLng = LatLng(placeDetails.latitude, placeDetails.longitude);
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

      // Update the marker
      setState(() {
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId('selectedLocation'),
          position: latLng,
          infoWindow: InfoWindow(
            title: placeDetails.name, // Display the place name in InfoWindow
          ),
        ));
      });

      // Return the place name for use elsewhere in the app
      return placeDetails.name;
    } else {
      throw Exception('No suggestions found');
    }
  } catch (e) {
    throw Exception('Error selecting suggestion: $e');
  }
}
