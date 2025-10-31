import 'package:PN2025/eventInfo.dart';
import 'package:PN2025/expandableHighlightext.dart';
import 'package:PN2025/networkService.dart';
import 'package:PN2025/user.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/fullMapPage.dart';
import 'package:PN2025/imageCarousel.dart';
import 'package:PN2025/locationTimeScrollableWidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}
class _mainPageState extends State<mainPage> {
  late GoogleMapController mapController;
  static LatLng center = LatLng(47.3769, 8.5417);
  EventInfo eventInfo = EventInfo.instance; 
  User user = User.instance; 
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();


  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

Future<bool> requestCalendarPermission(BuildContext context) async {
  var status = await Permission.calendarFullAccess.status;

  if (status.isGranted) {
    return true;
  }
  debugPrint(status.toString());
  if (status.isPermanentlyDenied||status.isDenied) {
    // Show dialog to guide user to settings
    bool openSettings = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text(
            "Calendar permission is permanently denied. Please enable it in Settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Open Settings"),
          ),
        ],
      ),
    );

    if (openSettings == true) {
      await openAppSettings();
    }

    return false;
  }

  // Request permission normally
  status = await Permission.calendarFullAccess.request();
  return status.isGranted;
}
  void loadInitialData() async {
    // prefs.getString()
    if(!eventInfo.isLoaded)
    {
      NetworkService().getSingleRoute("events").then((response) {
        if(response == null) return;
        setState(() {
          user.fromJson(response.remove('user'));
          eventInfo.fromJson(response);
          for (var photo in response["photos"]) {
            globals.mainPageImages.add(photo["url"].substring(1));
          }
        });
      });
    }
    // if(user.firstTime)
    // {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => accountPage(
    //       ),
    //     ),
    //   );
    // }
  }

  void geocode() async{
    String fullAddress = "${eventInfo.address}, ${eventInfo.city}, ${eventInfo.state} ${eventInfo.zip}";
    debugPrint(fullAddress);
    try {
      List<Location> locations = await locationFromAddress(fullAddress);
      debugPrint(locations.toString());
      if (locations.isNotEmpty) {
        setState(() {
          center = LatLng(locations.first.latitude, locations.first.longitude);
          mapController.animateCamera(CameraUpdate.newLatLng(center));
        });
      }
    } catch (e) {
      print("Geocoding failed: $e");
    }
  }
  void onMapCreated(GoogleMapController controller) async{
    mapController = controller;
    debugPrint("Why Here Of All Places?");
    geocode();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*.05,
        title: Text(
          'Home',
          style: TextStyle(
            fontSize:Theme.of(context).textTheme.displaySmall?.fontSize
          ),
        ),
        backgroundColor: globals.backgroundColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      body: ListView(
        children: [
          if(globals.mainPageImages.isNotEmpty)
          ImageCarousel(
            imageUrls: globals.mainPageImages,
          ),
          Container(
            padding: EdgeInsets.all(MediaQuery.sizeOf(context).width*.05),
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){
                    requestCalendarPermission(context);
                  },
                  child: Row(
                    children: [
                      Stack(
                        children: List.generate(
                          (eventInfo.userCount),
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
                        " +${eventInfo.userCount} Going",
                        style: GoogleFonts.roboto(fontSize: 24,color: Colors.white),
                      )
                    ],
                  ),
                ),
                Text(eventInfo.description,
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
                  description: (eventInfo.description ),
                  geolocation: center,
                  startTime: DateTime(2025,6,22,12,30),
                  endTime: DateTime(2025,7,22,19,30), 
                  location: ("${eventInfo.address}\n ${eventInfo.city}, ${eventInfo.state} ${eventInfo.zip}")
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height*.025,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        eventInfo.mainSection,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width*.05),
                    expandableHighlightText(
                      text:(eventInfo.subSection)
                    ),
                    // expandableHighlightText(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Why do we use it? It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",),  
                    SizedBox(height: MediaQuery.of(context).size.width*.05),
                    Container(
                      padding: EdgeInsets.all(4), // Thickness of the border
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [globals.highlightColor, globals.iceBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black, // Inner background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          eventInfo.aside,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height*.025,
                ),
              ],
            ),
          ),
          if(eventInfo.isLoaded)
          SizedBox(
            height: MediaQuery.sizeOf(context).height*.4,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullMapPage(center: center),
                  ),
                );
              },
              child: AbsorbPointer(
                child: GoogleMap(
                  onMapCreated: onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: center , // Fallback
                      zoom: 11.0,
                    ),
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
