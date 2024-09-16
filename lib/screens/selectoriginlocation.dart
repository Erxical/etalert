import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend/services/maps/select_suggestion.dart';
import 'package:frontend/services/maps/get_suggestions_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/models/maps/location.dart';

class SelectOriginLocation extends StatefulWidget {
  const SelectOriginLocation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectOriginLocationState createState() => _SelectOriginLocationState();
}

class _SelectOriginLocationState extends State<SelectOriginLocation> {
  GoogleMapController? _mapController;
  LatLng _selectedLatLng = const LatLng(13.6512574, 100.4938679); // Default location
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  final List<String> _searchHistory = [];
  String _selectedLocationName = '';

  @override
  void initState() {
    super.initState();
    _goToCurrentLocation();
  }

  Future<String> _getLocationName(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first.name ?? '${latLng.latitude}, ${latLng.longitude}';
      }
    } catch (e) {
      print('Error fetching location name: $e');
    }
    return '${latLng.latitude}, ${latLng.longitude}';
  }

  void _onMapTapped(LatLng latLng) async {
    String locationName = await _getLocationName(latLng);
    setState(() {
      _selectedLatLng = latLng;
      _selectedLocationName = locationName;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: latLng,
          infoWindow: InfoWindow(
            title: locationName,
            snippet: "Tap here to select this location",
            onTap: () {
              _confirmSelection(SelectedLocation(
                  locationName: _selectedLocationName,
                  selectedLatLng: _selectedLatLng));
            },
          ),
        ),
      );
    });
  }

  void _confirmSelection(SelectedLocation selectedLocation) {
    Navigator.pop(context, selectedLocation);
  }

  void _updateSearchHistory(String query) {
    if (!_searchHistory.contains(query) && query.isNotEmpty) {
      setState(() {
        _searchHistory.insert(0, query);
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      _onMapTapped(currentLatLng);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 14.0));
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Origin Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _confirmSelection(
              SelectedLocation(
                  locationName: _selectedLocationName,
                  selectedLatLng: _selectedLatLng),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search origin location',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (query) async {
                if (query.isEmpty) return [];

                final apiSuggestions = await getSuggestions(query);
                final historySuggestions = _searchHistory
                    .where((history) =>
                        history.toLowerCase().contains(query.toLowerCase()))
                    .toList();
                final apiSuggestionsList = apiSuggestions
                    .map((suggestion) => suggestion['description'] as String)
                    .toList();
                final combinedSuggestions = [
                  ...historySuggestions,
                  ...apiSuggestionsList.where(
                      (suggestion) => !historySuggestions.contains(suggestion))
                ];

                return combinedSuggestions;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) async {
                _updateSearchHistory(suggestion);
                String? placeName = await selectSuggestion(
                  suggestion,
                  _mapController,
                  setState,
                  _markers,
                );
                if (placeName != null) {
                  setState(() {
                    _selectedLocationName = placeName;
                  });
                }
                _searchController.clear();
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _selectedLatLng,
                zoom: 14.0,
              ),
              markers: _markers,
              onTap: _onMapTapped,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}