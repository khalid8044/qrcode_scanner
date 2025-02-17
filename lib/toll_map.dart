import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tollcalculator/search_field.dart';

import 'utils/db_helper.dart';

class TollCalculatorScreen extends StatefulWidget {
  const TollCalculatorScreen({super.key});

  @override
  State<TollCalculatorScreen> createState() => _TollCalculatorScreenState();
}

class _TollCalculatorScreenState extends State<TollCalculatorScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  List<Map<String, dynamic>> filteredPlazas = [];
  final DatabaseHelper dbHelper = DatabaseHelper();
  final List<Map<String, dynamic>> tollStations = [
  {
    "name": "Islamabad Toll Plaza",
    "location": LatLng(33.6844, 72.9744),
    "motorway": "M1",
    "toll": 300,
    "cities": ["Islamabad", "Rawalpindi"]
  },
  {
    "name": "Wah Toll Plaza",
    "location": LatLng(33.7721, 72.7470),
    "motorway": "M1",
    "toll": 300,
    "cities": ["Wah", "Taxila"]
  },
  {
    "name": "Burhan Toll Plaza",
    "location": LatLng(33.8903, 72.4321),
    "motorway": "M1",
    "toll": 300,
    "cities": ["Attock", "Hasan Abdal"]
  },
  {
    "name": "Swabi Toll Plaza",
    "location": LatLng(34.1234, 72.4678),
    "motorway": "M1",
    "toll": 300,
    "cities": ["Swabi", "Mardan"]
  },
  {
    "name": "Charsadda Toll Plaza",
    "location": LatLng(34.1632, 71.7357),
    "motorway": "M1",
    "toll": 300,
    "cities": ["Charsadda", "Peshawar"]
  },
  {
    "name": "Peshawar Toll Plaza",
    "location": LatLng(34.0151, 71.5250),
    "motorway": "M1",
    "toll": 300,
    "cities": ["Peshawar", "Nowshera"]
  },
  {
    "name": "Bhera Toll Plaza",
    "location": LatLng(32.4812, 72.9245),
    "motorway": "M2",
    "toll": 750,
    "cities": ["Bhera", "Sargodha"]
  },
  {
    "name": "Lillah Toll Plaza",
    "location": LatLng(32.6401, 73.0042),
    "motorway": "M2",
    "toll": 750,
    "cities": ["Lillah", "Jhelum"]
  },
  {
    "name": "Kallar Kahar Toll Plaza",
    "location": LatLng(32.7246, 72.7075),
    "motorway": "M2",
    "toll": 750,
    "cities": ["Kallar Kahar", "Chakwal"]
  },
  {
    "name": "Chakri Toll Plaza",
    "location": LatLng(33.1523, 72.8320),
    "motorway": "M2",
    "toll": 750,
    "cities": ["Chakri", "Rawalpindi"]
  },
  {
    "name": "Lahore Toll Plaza",
    "location": LatLng(31.5204, 74.3587),
    "motorway": "M2",
    "toll": 750,
    "cities": ["Lahore", "Sheikhupura"]
  },
  {
    "name": "Faisalabad Toll Plaza",
    "location": LatLng(31.4504, 73.1350),
    "motorway": "M3",
    "toll": 450,
    "cities": ["Faisalabad", "Jaranwala"]
  },
  {
    "name": "Multan Toll Plaza",
    "location": LatLng(30.1575, 71.5249),
    "motorway": "M5",
    "toll": 800,
    "cities": ["Multan", "Khanewal"]
  },
  {
    "name": "Jalalpur Pirwala Toll Plaza",
    "location": LatLng(29.4953, 71.2205),
    "motorway": "M5",
    "toll": 800,
    "cities": ["Jalalpur Pirwala", "Lodhran"]
  },
  {
    "name": "Sukkur Toll Plaza",
    "location": LatLng(27.7139, 68.8441),
    "motorway": "M5",
    "toll": 800,
    "cities": ["Sukkur", "Rohri"]
  },
  {
    "name": "Karachi Toll Plaza",
    "location": LatLng(24.8607, 67.0011),
    "motorway": "M9",
    "toll": 300,
    "cities": ["Karachi", "Thatta"]
  },
  {
    "name": "Nooriabad Toll Plaza",
    "location": LatLng(25.3089, 68.0578),
    "motorway": "M9",
    "toll": 300,
    "cities": ["Nooriabad", "Kotri"]
  },
  {
    "name": "Hyderabad Toll Plaza",
    "location": LatLng(25.3960, 68.3798),
    "motorway": "M9",
    "toll": 300,
    "cities": ["Hyderabad", "Jamshoro"]
  },
  {
    "name": "Sialkot Toll Plaza",
    "location": LatLng(32.5001, 74.5403),
    "motorway": "M11",
    "toll": 750,
    "cities": ["Sialkot", "Daska"]
  },
  {
    "name": "Kala Shah Kaku Toll Plaza",
    "location": LatLng(31.7134, 74.1234),
    "motorway": "M11",
    "toll": 750,
    "cities": ["Kala Shah Kaku", "Lahore"]
  },
  {
    "name": "Daska Toll Plaza",
    "location": LatLng(32.3245, 74.2156),
    "motorway": "M11",
    "toll": 750,
    "cities": ["Daska", "Sambrial"]
  },
  {
    "name": "Hakla Toll Plaza",
    "location": LatLng(33.7482, 72.8385),
    "motorway": "M14",
    "toll": 900,
    "cities": ["Hakla", "Attock"]
  },
  {
    "name": "Mianwali Toll Plaza",
    "location": LatLng(32.5876, 71.5432),
    "motorway": "M14",
    "toll": 900,
    "cities": ["Mianwali", "Isa Khel"]
  },
  {
    "name": "Dera Ismail Khan Toll Plaza",
    "location": LatLng(31.8345, 70.9001),
    "motorway": "M14",
    "toll": 900,
    "cities": ["Dera Ismail Khan", "Tank"]
  }
];

  @override
  void initState() {
    super.initState();
    // insert();
    _loadTollStations();  // Fetch toll stations from the database
    _getUserLocation();  
 // Get user location for initial map positioning
  }

  // Load toll stations from the database
  void _loadTollStations() async {
    filteredPlazas = await dbHelper.getTollStations();  // Fetch data asynchronously
    setState(() {});  // Trigger UI update after loading data
  }

void insert(){
  dbHelper.insertTollStations(tollStations);
}
  // Get user location for the map
  void _getUserLocation() async {
    var userLocation = await _location.getLocation();
    if (_mapController != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(userLocation.latitude!, userLocation.longitude!),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Toll Calculator"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          TollPlazaSearchField(
            tollStations: filteredPlazas,  // Pass filteredPlazas instead of tollStations
            onSelected: (plaza) {
              // Handle the selected toll plaza if needed
            },
          ),
          Expanded(
            flex: 5,
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: LatLng(31.5204, 74.3587),  // Default location
                zoom: 10,
              ),
              markers: Set<Marker>.from(filteredPlazas.map((toll) => Marker(
                    markerId: MarkerId(toll['name']),
                    position: LatLng(toll['latitude'], toll['longitude']),
                    infoWindow: InfoWindow(title: toll['name']),
                  ))),
            ),
          ),
        ],
      ),
    );
  }
}
