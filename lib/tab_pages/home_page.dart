import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uber_driver_app/main.dart';
import 'package:uber_driver_app/notifications/push_notification_service.dart';
import 'package:uber_driver_app/static/config.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14.4746);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;

  Position? currentPosition;

  var geoLocator = Geolocator();

  String driverStatusText = "Offline Now - Go Online";

  Color driverstatusColor = Colors.black;

  bool isDriverAvailable = false;

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

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
        // String address =
        //     // ignore: use_build_context_synchronously
        //     await AssistantMethods.searchCoordinateAddress(position, context);
        // log("This is your Address :: $address");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error getting location: $e");
      }
    } else {
      // Handle case where permission is denied
      Fluttertoast.showToast(msg: "Location permission denied");
    }
  }

  void getCurrentDriverInfo() async {
    currentfirebaseUser = FirebaseAuth.instance.currentUser;
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize();
    pushNotificationService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: HomeTabPage._kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          controllerGoogleMap.complete(controller);
          newGoogleMapController = controller;
          locatePosition();
        },
      ),
      Container(
        height: 140,
        width: double.infinity,
        color: Colors.black54,
      ),
      Positioned(
        top: 60.0,
        left: 0.0,
        right: 0.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => driverstatusColor),
                    ),
                    onPressed: () {
                      if (isDriverAvailable != true) {
                        makeDriverOnlineNow();
                        getLocationLiveUpdates();
                        setState(() {
                          driverstatusColor = Colors.green;
                          driverStatusText = "Online Now";
                          isDriverAvailable = true;
                        });
                        Fluttertoast.showToast(msg: "You are Online Now.");
                      } else {
                        makeDriverOfflinenow();
                        setState(() {
                          driverstatusColor = Colors.black;
                          driverStatusText = "Offline Now - Go Online";
                          isDriverAvailable = false;
                        });
                        Fluttertoast.showToast(msg: "You are Offline Now.");
                      }
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            driverStatusText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(Icons.phone_android,
                              color: Colors.white, size: 26),
                        ])),
              ),
            ),
          ],
        ),
      )
    ]);
  }

  void makeDriverOnlineNow() async {
    if (currentfirebaseUser != null) {
      log("##### Current Firebase Not Null #######");
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;
      Geofire.initialize("availableDrivers");
      Geofire.setLocation(currentfirebaseUser!.uid, currentPosition!.latitude,
          currentPosition!.longitude);

      rideRequestRef.onValue.listen((event) {});
    } else {
      log("##### Current Firebase Is Null #######");
    }
  }

  void getLocationLiveUpdates() {
    homeTabPagestreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvailable == true) {
        Geofire.setLocation(
            currentfirebaseUser!.uid, position.latitude, position.longitude);
      }
      LatLng latlng = LatLng(position.latitude, position.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latlng));
    });
  }

  void makeDriverOfflinenow() {
    Geofire.removeLocation(currentfirebaseUser!.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
  }
}
