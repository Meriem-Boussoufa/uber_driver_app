import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_driver_app/main.dart';
import 'package:uber_driver_app/screens/main_screen.dart';
import 'package:uber_driver_app/static/config.dart';

// ignore: must_be_immutable
class CarInfoScreen extends StatelessWidget {
  static const String idScreen = "carinfo";

  CarInfoScreen({super.key});

  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 22),
            Image.asset("assets/images/logo.png", width: 300, height: 250),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    "Enter Car Details",
                    style: TextStyle(fontFamily: "Brand-Bold", fontSize: 24),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: carModelTextEditingController,
                    decoration: const InputDecoration(
                      labelText: "Car Model",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: carNumberTextEditingController,
                    decoration: const InputDecoration(
                      labelText: "Car Number",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: carColorTextEditingController,
                    decoration: const InputDecoration(
                      labelText: "Car Color",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 42.0),
                  SizedBox(
                    width: 400,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) => Colors.yellow),
                          ),
                          onPressed: () {
                            if (carModelTextEditingController.text.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please write Car Model");
                            } else if (carNumberTextEditingController
                                .text.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please write Car Number");
                            } else if (carColorTextEditingController
                                .text.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please write Car Color");
                            } else {
                              saveDriverCarInfo(context);
                            }
                          },
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "NEXT",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 26),
                              ])),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void saveDriverCarInfo(context) {
    String userId = currentfirebaseUser!.uid;
    Map carInfoMap = {
      "car_color": carColorTextEditingController.text,
      "car_number": carNumberTextEditingController.text,
      "car_model": carModelTextEditingController.text,
    };
    driversRef.child(userId).child("car_details").set(carInfoMap);
    Fluttertoast.showToast(
        msg: "Congratulations, your account has been created.");
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }
}
