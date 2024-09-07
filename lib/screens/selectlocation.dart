import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend/services/maps/select_suggestion.dart';
import 'package:frontend/services/maps/get_suggestions_location.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package to get the location name
import 'package:geolocator/geolocator.dart';

class SelectLocation extends StatefulWidget {
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  GoogleMapController? _mapController;
  LatLng _selectedLatLng = LatLng(13.6512574, 100.4938679);
  Set<Marker> _markers = {};
  TextEditingController _searchController = TextEditingController();

  List<String> _searchHistory = []; // List to store search history

  // Method to get the name of the location from coordinates
  Future<String> _getLocationName(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first.name ??
            '${latLng.latitude}, ${latLng.longitude}';
      }
    } catch (e) {
      print('Error fetching location name: $e');
    }
    return '${latLng.latitude}, ${latLng.longitude}';
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _selectedLatLng = latLng;
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selectedLocation'),
        position: latLng,
      ));
    });
  }

  // Modify this method to return the location name instead of coordinates
  void _confirmSelection() async {
    String locationName = await _getLocationName(_selectedLatLng);
    Navigator.pop(context, locationName);
  }

  // Add a method to update search history
  void _updateSearchHistory(String query) {
    if (!_searchHistory.contains(query) && query.isNotEmpty) {
      setState(() {
        _searchHistory.insert(0, query); // Add to the beginning of the list
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLatLng = currentLatLng;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: currentLatLng,
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(currentLatLng),
      );
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmSelection,
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
                  decoration: InputDecoration(
                    labelText: 'Search location',
                    border: OutlineInputBorder(),
                  ),
                ),
                suggestionsCallback: (query) async {
                  if (query.isEmpty) return [];

                  // Fetch new suggestions from the API
                  final apiSuggestions = await getSuggestions(query);

                  // Filter search history based on the query
                  final historySuggestions = _searchHistory
                      .where((history) =>
                          history.toLowerCase().contains(query.toLowerCase()))
                      .toList();

                  // Map API suggestions to a list of descriptions
                  final apiSuggestionsList = apiSuggestions
                      .map((suggestion) => suggestion['description'] as String)
                      .toList();

                  // Combine search history and API suggestions, avoiding duplicates
                  final combinedSuggestions = [
                    ...historySuggestions,
                    ...apiSuggestionsList.where((suggestion) =>
                        !historySuggestions.contains(suggestion))
                  ];

                  return combinedSuggestions;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) async {
                  // Update search history with the selected suggestion
                  _updateSearchHistory(suggestion);

                  // Select the suggestion and update the map location
                  await selectSuggestion(
                    suggestion,
                    _mapController,
                    setState,
                    _markers,
                  );

                  // Clear the search bar after selecting a suggestion
                  _searchController.clear();
                },
              )),
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
