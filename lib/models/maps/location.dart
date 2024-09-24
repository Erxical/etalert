import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedLocation {
  final String? locationName;
  final LatLng? selectedLatLng;

  SelectedLocation({
    this.locationName,
    this.selectedLatLng,
  });
}
