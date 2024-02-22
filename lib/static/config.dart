import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user.dart';

Users? userCurrentInfo;
User? currentfirebaseUser;

StreamSubscription<Position>? homeTabPagestreamSubscription;
