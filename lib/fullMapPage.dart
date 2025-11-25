import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/messageReciever.dart';

class FullMapPage extends StatelessWidget {
  final LatLng center;

  const FullMapPage({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            "Full Map",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: globals.backgroundColor,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: center,
            zoom: 14,
          ),
          zoomControlsEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }
}
