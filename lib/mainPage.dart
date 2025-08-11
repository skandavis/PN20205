import 'dart:typed_data';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/description.dart';
import 'package:flutter_application_2/fullMapPage.dart';
import 'package:flutter_application_2/imageCarousel.dart';
import 'package:flutter_application_2/locationTimeScrollableWidget.dart';
import 'package:flutter_application_2/utils.dart' as utils;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

Future<void> _launchURL(String websiteUrl) async {
  final Uri url = Uri.parse(websiteUrl);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $websiteUrl';
  }
}

class _mainPageState extends State<mainPage> {
  late GoogleMapController mapController;
  LatLng? center;
  Map<String, dynamic>? info;
  List<Uint8List> images = []; 
  @override
  void initState() {
    super.initState();
    utils.getRoute("evnt/1").then((response) async {
      setState(() {
        info = response["evnt"];
      });

      // Build full address string
      String fullAddress = "${info?["address"]}, ${info?["city"]}, ${info?["state"]} ${info?["zip"]}";

      // Geocode the address to get coordinates
      try {
        List<Location> locations = await locationFromAddress(fullAddress);
        debugPrint(locations.toString());
        if (locations.isNotEmpty) {
          setState(() {
            center = LatLng(locations.first.latitude, locations.first.longitude);
            debugPrint(center.toString());
          });
        }
      } catch (e) {
        print("Geocoding failed: $e");
      }

      for (var i = 0; i < info!["images"].length; i++) {
        final eventResponse = utils.getImage('evnt/1/image/${info!["images"][i]["id"]}').then((response) {
          setState(() {
            images.add(response);
          });
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            ImageCarousel(
              images: images,
            ),
            Container(
              padding: EdgeInsets.all(MediaQuery.sizeOf(context).width*.05),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: List.generate(
                          (info?["_count"]?["users"] ?? 1),
                          (index) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: (10 * index).toDouble(),
                                ),
                                Container(
                                  height: 50,
                                  width: 50,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black, width: 1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Image.asset("assets/genericAccount.png",),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Text(
                        " +${info?["_count"]?["users"] ?? 1} More Going",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                          decoration: TextDecoration.none,
                        ),
                      )
                    ],
                  ),
                  Text((info?["name"] ?? "Event Loading").toString(),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                  height: MediaQuery.sizeOf(context).height*.025,
                  ),
                  Locationtimescrollablewidget(
                    description: (info?["description"] ?? "Description Loading"),
                    geolocation: center!,
                    startTime: DateTime(2025,6,22,12,30),
                    endTime: DateTime(2025,7,22,19,30), 
                    location: ((info?["address"] ?? "Address Loading")+"\n "+(info?["city"] ?? "City Loading")+", "+(info?["state"] ?? "State Loading")+" "+ (info?["zip"] ?? "Zip Loading").toString())
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height*.025,
                  ),
                  Text(
                    "About",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  descriptionBox(
                    ellipsis: true,
                    description:(info?["description"] ?? "Description Loading")
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height*.025,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*.4,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullMapPage(center: center!),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                     initialCameraPosition: CameraPosition(
                        target: center! , // Fallback
                        zoom: 11.0,
                      ),
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
