import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tollcalculator/calculator/age_calculator.dart';
import 'package:tollcalculator/calculator/splash.dart';


import 'utils/db_helper.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State <LocationScreen>createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<LatLng> pakistanBoundary = [];
  List<Marker> rechargeLocationMarkers = [];

  @override
  void initState() {
    super.initState();
    loadAndParseGeoJson();
    addCityMarkers();
  }

  Future<List<LatLng>> parseGeoJson(String filePath) async {
    try {
      String data = await rootBundle.loadString(filePath);
      final geoJson = json.decode(data);

      final List<LatLng> coordinates = [];
      for (var feature in geoJson['features']) {
        final geometry = feature['geometry'];
        if (geometry['type'] == 'Polygon') {
          for (var ring in geometry['coordinates']) {
            for (var point in ring) {
              coordinates.add(LatLng(point[1].toDouble(), point[0].toDouble()));
            }
          }
        } else if (geometry['type'] == 'MultiPolygon') {
          for (var polygon in geometry['coordinates']) {
            for (var ring in polygon) {
              for (var point in ring) {
                coordinates
                    .add(LatLng(point[1].toDouble(), point[0].toDouble()));
              }
            }
          }
        }
      }

      return coordinates;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing GeoJSON: $e');
      }
      return [];
    }
  }
final List<LatLng> routePoints = [
    LatLng(25.2687, 67.1955), // Starting Point (Karachi)
    LatLng(28.7041, 70.2785), // Intermediate Point
    LatLng(33.5834, 72.8755), // Ending Point (Islamabad)
  ];
  // Load and parse the GeoJSON
  void loadAndParseGeoJson() async {
    String filePath = 'assets/map.geojson';
    List<LatLng> boundary = await parseGeoJson(filePath);
    setState(() {
      pakistanBoundary = boundary;
    });
    if (kDebugMode) {
      print('Parsed Coordinates: ${pakistanBoundary.length} points');
    }
  }

  void addCityMarkers() {
    final rechargeCenter = [
      {
        'name': 'Karachi M-Tag Center',
        'location': LatLng(25.268718769198127, 67.19556167065171),
        'information':
            'Include all \nKHI Drive Thru 6\nKHI Drive Thru 8\nKHI Drive Thru 9'
      },
      {
        'name': 'Islamabad M-Tag Center',
        'location': LatLng(33.58346001663757, 72.87557303251401),
        'information': ''
      },
      {
        'name': 'M-Tag Registration and Recharge Center Bhera',
        'location': LatLng(32.45402611122732, 72.8888646597812),
        'information': ''
      },
    ];

    setState(() {
      rechargeLocationMarkers = rechargeCenter.map((locations) {
        return Marker(
          point: locations['location'] as LatLng,
          child: GestureDetector(
            onTap: () {
              // Trigger action on tap
              _showCityInfoDialog(locations['name'] as String,
                  locations['information'] as String);
            },
            child: Image.asset(
              "assets/location.png",
              width: 40, // Adjust the size as needed
              height: 40,
            ),
          ),
        );
      }).toList();
    });
  }

  void _showCityInfoDialog(String cityName, String information) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(cityName),
          content: Text(information),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
              LatLng(30.3753, 69.3451), // Default to the center of Pakistan
        initialZoom: 5,
        ),
        children: [
        
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          // Draw the Pakistan boundary using PolygonLayer
          if (pakistanBoundary.isNotEmpty)
            PolygonLayer(
              polygons: [
                Polygon(
                  points: pakistanBoundary,
                  color: Colors.blue.withAlpha(80),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2.0,
                ),
              ],
            ),
          // City markers
          MarkerLayer(
            markers: rechargeLocationMarkers,
          ),
     
           
        ],
      ),
    );
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

   await DatabaseHelper().database;
  runApp(MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData(  textTheme:TextTheme(displayMedium:  GoogleFonts.aBeeZee(),),inputDecorationTheme: InputDecorationTheme(hintStyle:    GoogleFonts.aBeeZee(),)),
    home:SplashPage()
  ));
}