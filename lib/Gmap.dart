import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  Set<Marker> markers = Set<Marker>();

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
            markerId: MarkerId('current_location'),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            infoWindow: InfoWindow(
              title: 'Current Location',
            ),
          );
          markers.add(marker);
        }
      });
    }
  }

  void navigateToDestination(LatLng destination) async {
    if (currentLocation == null) {
      print('Current location not available.');
      return;
    }

    final String origin =
        '${currentLocation!.latitude},${currentLocation!.longitude}';

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=${destination.latitude},${destination.longitude}';

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
        title: Text('Google Maps Navigation'),
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
        onTap: (LatLng position) {
          setState(() {
            markers.clear();
            markers.add(
              Marker(
                markerId: MarkerId('selected_location'),
                position: position,
                infoWindow: InfoWindow(
                  title: 'Selected Location',
                ),
              ),
            );
          });
          navigateToDestination(position);
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapsPage(),
  ));
}
