import 'package:NagaratharEvents/accountPage.dart';
import 'package:NagaratharEvents/eventInfo.dart';
import 'package:NagaratharEvents/expandableHighlightext.dart';
import 'package:NagaratharEvents/loadingScreen.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/imageCarousel.dart';
import 'package:NagaratharEvents/locationTimeScrollableWidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class mainPage extends StatefulWidget {
  final ValueNotifier<int> isVisible;
  const mainPage({super.key, required this.isVisible});

  @override
  State<mainPage> createState() => _mainPageState();
}
class _mainPageState extends State<mainPage> {
  late GoogleMapController mapController;
  static LatLng center = LatLng(47.3769, 8.5417);
  EventInfo eventInfo = EventInfo.instance; 
  User user = User.instance; 
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    widget.isVisible.addListener(_onVisibilityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
        loadInitialData();
    });
  }

  @override
  void dispose() {
    widget.isVisible.removeListener(_onVisibilityChanged);
    super.dispose();
  }

  void _onVisibilityChanged() {
    if (widget.isVisible.value == 1) {
    } else if(widget.isVisible.value == 0){
      eventInfo.clear(); 
      user.clear();
    }
  }
  void loadInitialData() async {
    if(eventInfo.isLoaded)
    {
      setState(() {
        isConnected = true;
      });
    }else{
      final givenEventInfo = await NetworkService().getSingleRoute("events", forceRefresh: true);
      if(givenEventInfo == null)
      {
        setState(() {
          isConnected = false;
        });
      }else{
        setState(() {
          user.fromJson(givenEventInfo.remove('user'));
          eventInfo.fromJson(givenEventInfo);
          eventInfo.addImages(givenEventInfo["photos"]);
          isConnected = true;
        });   
      }
    }
    if(user.firstTime)
    {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => accountPage(firstTime: true,),
        ),
      );
    }
  }

  void geocode() async{
    String fullAddress = "${eventInfo.address}, ${eventInfo.city}, ${eventInfo.state} ${eventInfo.zip}";
    try {
      List<Location> locations = await locationFromAddress(fullAddress);
      (locations.toString());
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
    geocode();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if(isConnected && eventInfo.isLoaded)
        ListView(
          children: [
            if(eventInfo.images.isNotEmpty)
            ImageCarousel(
              imageUrls: eventInfo.images,
            ),
            Container(
              padding: EdgeInsets.all(MediaQuery.sizeOf(context).width*.05),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: List.generate(
                          (eventInfo.userCount > 5) ? 5 : eventInfo.userCount,
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: globals.bodyFontSize,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                  Text(
                    eventInfo.description,
                    style:  TextStyle(
                      color: Colors.white, 
                      fontSize: globals.subTitleFontSize,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                  height: MediaQuery.sizeOf(context).height*.025,
                  ),
                  Locationtimescrollablewidget(
                    name: eventInfo.name,
                    description: (eventInfo.description),
                    geolocation: center,
                    startTime: eventInfo.startDate,
                    endTime: eventInfo.endDate,
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
                            fontSize: globals.bodyFontSize,
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
                            style: TextStyle(color: Colors.white,
                            fontSize: globals.paraFontSize,
                            ),
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
            SizedBox(
              height: MediaQuery.sizeOf(context).height*.4,
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
          ],
        ),
        if(!isConnected)
        Center(child: const Text("No Internet Connection!", style: TextStyle(color: Colors.white, fontSize: 20),)),
        if(!eventInfo.isLoaded)
        loadingScreen(),
      ],
    );
  }
}
