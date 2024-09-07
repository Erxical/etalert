import 'package:flutter/material.dart';
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
    final suggestions = await getSuggestions(description);
    if (suggestions.isNotEmpty) {
      final placeId = suggestions.first['place_id'];
      final latLng = await getCoordinatesFromPlaceId(placeId);

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

      setState(() {
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId('selectedLocation'),
          position: latLng,
        ));
      });
    } else {
      throw Exception('No suggestions found');
    }
  } catch (e) {
    throw Exception('Error selecting suggestion: $e');
  }
}
