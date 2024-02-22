import 'dart:async';
import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../assistants/assistant_methods.dart';
import '../data_handler/app_data.dart';
import '../models/address.dart';
import '../models/direction_details.dart';
import '../static/config.dart';
import '../widgets/divider.dart';
import '../widgets/progress_dialog.dart';
import 'login_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  DatabaseReference? rideRequestRef;
  void saveRideRequest() {
    log("######### Saving Ride Request ##########" "");
    rideRequestRef =
        FirebaseDatabase.instance.ref().child("Ride Requests").push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;
    Map pickUpLocMap = {
      "latitude": pickUp!.latitude.toString(),
      "longtitude": pickUp.longtitude.toString(),
    };
    Map dropOffLocMap = {
      "latitude": dropOff!.latitude.toString(),
      "longtitude": dropOff.longtitude.toString(),
    };

    Map riderInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo!.name,
      "rider_phone": userCurrentInfo!.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };
    rideRequestRef!.set(riderInfoMap);
  }

  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  bool drawerOpen = true;

  DirectionDetails? tripDirectionDetails;

  List<LatLng> plineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  double rideDetailsContainer = 0;
  double requestRidecontainerHeight = 0;
  double searchContainerHeight = 300.0;
  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300;
      rideDetailsContainer = 0;
      requestRidecontainerHeight = 0;
      bottomPaddingOfMap = 230;
      polylineSet.clear();
      markers.clear();
      circles.clear();
      plineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainer = 240;
      bottomPaddingOfMap = 230;
      drawerOpen = false;
    });
  }

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static const CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14.4746);

  Position? currentPosition;
  var geoLocator = Geolocator();

  double bottomPaddingOfMap = 0;

  void locatePosition() async {
    // Check if permission is granted
    var permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      try {
        // Attempt to get current position
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        currentPosition = position;
        LatLng latLatPosition = LatLng(position.latitude, position.longitude);
        CameraPosition cameraPosition =
            CameraPosition(target: latLatPosition, zoom: 14);
        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        String address =
            // ignore: use_build_context_synchronously
            await AssistantMethods.searchCoordinateAddress(position, context);
        log("This is your Address :: $address");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error getting location: $e");
      }
    } else {
      // Handle case where permission is denied
      Fluttertoast.showToast(msg: "Location permission denied");
    }
  }

  void cancelRideRequest() {
    rideRequestRef!.remove();
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRidecontainerHeight = 250;
      rideDetailsContainer = 0;
      bottomPaddingOfMap = 230;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        title: const Text("Main Screen", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: Container(
        color: Colors.white,
        width: 255,
        child: Drawer(
          child: ListView(
            children: [
              SizedBox(
                height: 165,
                child: DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/user_icon.png",
                          height: 65,
                          width: 65,
                        ),
                        const SizedBox(width: 16.0),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profile Name",
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "Brand-Bold"),
                            ),
                            SizedBox(height: 6.0),
                            Text("Visit Profile"),
                          ],
                        )
                      ],
                    )),
              ),
              const DividerWidget(),
              const SizedBox(height: 12.0),
              const ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: const ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            circles: circles,
            markers: markers,
            polylines: polylineSet,
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });
              locatePosition();
            },
          ),
          Positioned(
            top: 38,
            left: 22,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20.0,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close,
                      color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    Address? initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    Address? finalPos =
        Provider.of<AppData>(context, listen: false).dropOffLocation;
    log(initialPos!.longtitude.toString());
    log(initialPos.latitude.toString());
    log(finalPos!.longtitude.toString());
    log(finalPos.latitude.toString());
    if (initialPos.longtitude != null && finalPos.latitude != null) {
      log("The initialPos and the FinalPos are not null");
      var pickUpLatLng =
          LatLng(initialPos.latitude ?? 0.0, initialPos.longtitude ?? 0.0);
      var dropOffLatLng =
          LatLng(finalPos.latitude ?? 0.0, finalPos.longtitude ?? 0.0);
      log(pickUpLatLng.toString());
      log(dropOffLatLng.toString());
      showDialog(
          context: context,
          builder: (BuildContext context) => ProgressDialog(
                message: "Please wait ...",
              ));
      var details = await AssistantMethods.obtainPlaceDirectionDetails(
          pickUpLatLng, dropOffLatLng);
      setState(() {
        tripDirectionDetails = details;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      log("This is Encoded points :: ");
      log(details!.encodedPoints.toString());
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodePolyLinePointsResult =
          polylinePoints.decodePolyline(details.encodedPoints!);
      //plineCoordinates.clear();
      if (decodePolyLinePointsResult.isNotEmpty) {
        for (var pointLatLng in decodePolyLinePointsResult) {
          plineCoordinates
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        }
      }
      //polylineSet.clear();
      setState(() {
        Polyline polyline = Polyline(
          polylineId: const PolylineId("PolylineID"),
          color: Colors.pink,
          jointType: JointType.round,
          points: plineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polylineSet.add(polyline);
      });
      LatLngBounds latlngBounds;
      if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
          pickUpLatLng.longitude > dropOffLatLng.longitude) {
        log("Here");
        latlngBounds =
            LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
      } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latlngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
        );
      } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
        latlngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
        );
      } else {
        latlngBounds =
            LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
      }

      newGoogleMapController!
          .animateCamera(CameraUpdate.newLatLngBounds(latlngBounds, 70));

      Marker pickUpLocMarker = Marker(
        markerId: const MarkerId("pickUpId"),
        position: pickUpLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      );
      Marker dropOffLocMarker = Marker(
        markerId: const MarkerId("dropOffId"),
        position: dropOffLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      );
      setState(() {
        markers.add(pickUpLocMarker);
        markers.add(dropOffLocMarker);
      });
      Circle pickUpLocCircle = Circle(
        circleId: const CircleId("pickUpId"),
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
      );
      Circle dropOffLocCircle = Circle(
        circleId: const CircleId("dropOffId"),
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
      );
      setState(() {
        circles.add(pickUpLocCircle);
        circles.add(dropOffLocCircle);
      });
    } else {
      log("The initialPos and the FinalPos are null");
      // Handle the case when either initialPos or finalPos is null
    }
  }
}
