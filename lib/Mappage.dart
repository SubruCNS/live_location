import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  Set<Marker> markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();

    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
      print('Error getting location: $e');
    }

    if (mounted) {
      setState(() {
        if (currentLocation != null) {
          final marker = Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            infoWindow: const InfoWindow(
              title: 'Current Location',
            ),
          );
          markers.add(marker);
        }
      });
    }
  }

  void navigateToDestination(String destination) async {
    const String apiKey = 'AIzaSyDuzovnCqu-QSZng5hPD8NWFGTbmO9uFH0';
    const String baseUrl = 'https://www.google.com/maps/dir/?api=1';

    if (currentLocation == null) {
      print('Current location not available.');
      return;
    }

    final String origin =
        '${currentLocation!.latitude},${currentLocation!.longitude}';

    final url = '$baseUrl&origin=$origin&destination=$destination&key=$apiKey';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Navigation'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            currentLocation?.latitude ?? 0.0,
            currentLocation?.longitude ?? 0.0,
          ),
          zoom: 15.0,
        ),
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.navigation),
        onPressed: () {
          String destination = "Your Destination";
          navigateToDestination(destination);
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MapsPage(),
  ));
}
