import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/address.dart';

class AppData extends ChangeNotifier {
  Address? pickUpLocation;
  Address? dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    log("Updating Destination Address .....................");
    dropOffLocation = dropOffAddress;
    log("The Drop Off Location Updated :: ");
    log(dropOffAddress.placeName.toString());
    notifyListeners();
  }
}
