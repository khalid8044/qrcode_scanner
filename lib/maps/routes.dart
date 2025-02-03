import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:location/location.dart' as loc;

class MapsRoutesPage extends StatefulWidget {
  const MapsRoutesPage({super.key, required this.title});
  final String title;

  @override
  State<MapsRoutesPage> createState() => _MapsRoutesPageState();
}

class _MapsRoutesPageState extends State<MapsRoutesPage> {
  final Completer<GoogleMapController> _controller = Completer();
  loc.Location location = loc.Location();
  LatLng? currentLocation;
  Set<Marker> motorwayStations = {};
  MapsRoutes route = MapsRoutes();
  DistanceCalculator distanceCalculator = DistanceCalculator();
  String googleApiKey = 'AIzaSyBM7OEX3gwpKld5ipoqyuEWH4Y6e9hyrGE';
  String totalDistance = 'No route';

  List<LatLng> points = [
    LatLng(33.6844, 73.0479), // Islamabad
    LatLng(33.6261, 73.0718), // Rawalpindi
    LatLng(33.4338, 72.8154), // Chakri (M-2)
    LatLng(32.7876, 72.7060), // Kallar Kahar
    LatLng(31.8972, 73.2731), // Pindi Bhattian
    LatLng(31.5204, 73.1850), // Faisalabad
    LatLng(31.1488, 72.6880), // Gojra
    LatLng(30.9747, 72.4822), // Toba Tek Singh
    LatLng(30.2912, 71.9321), // Khanewal
    LatLng(30.1091, 71.3250), // Shujabad
    LatLng(30.1575, 71.5249), // Multan
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      loc.LocationData locationData = await location.getLocation();
      setState(() {
        currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
      _fetchMotorwayStations(currentLocation!);
    } catch (e) {
      log("Error getting location: $e");
    }
  }

  Future<void> _fetchMotorwayStations(LatLng position) async {
    final places.GoogleMapsPlaces placesApi = places.GoogleMapsPlaces(apiKey: googleApiKey);
    places.PlacesSearchResponse response = await placesApi.searchNearbyWithRadius(
      places.Location(lat: position.latitude, lng: position.longitude),
      50000,
      type: "gas_station",
    );

    setState(() {
      motorwayStations = response.results.map((place) {
        return Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.geometry!.location.lat, place.geometry!.location.lng),
          infoWindow: InfoWindow(title: place.name),
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            trafficEnabled: true,
            markers: motorwayStations,
            polylines: route.routes,
            initialCameraPosition: CameraPosition(
              zoom: 10.0,
              target: currentLocation ?? LatLng(33.6844, 73.0479),
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(totalDistance, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await route.drawRoute(points, 'Islamabad to Multan Route', Colors.blue, googleApiKey, travelMode: TravelModes.driving);
          setState(() {
            totalDistance = distanceCalculator.calculateRouteDistance(points, decimals: 1);
          });
        },
        child: Icon(Icons.route),
      ),
    );
  }
}
