import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_driver_app/screens/car_info_screen.dart';
import 'package:uber_driver_app/static/config.dart';

import '../main.dart';
import '../widgets/progress_dialog.dart';
import 'login_screen.dart';
import 'main_screen.dart';

// ignore: must_be_immutable
class RegisterScreen extends StatelessWidget {
  static const String idScreen = "register";
  RegisterScreen({super.key});

  TextEditingController nameTextEditingcontroller = TextEditingController();
  TextEditingController emailTextEditingcontroller = TextEditingController();
  TextEditingController phoneTextEditingcontroller = TextEditingController();
  TextEditingController passwordTextEditingcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              const Image(
                image: AssetImage("assets/images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 15.0),
              const Text(
                "Register as a Driver",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    TextField(
                      controller: nameTextEditingcontroller,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: emailTextEditingcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: phoneTextEditingcontroller,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: passwordTextEditingcontroller,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 400,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow, // Background color
                        ),
                        onPressed: () {
                          if (nameTextEditingcontroller.text.length < 3) {
                            Fluttertoast.showToast(
                                msg: "Name must be atleast 3 characters.");
                          } else if (!emailTextEditingcontroller.text
                              .contains('@')) {
                            Fluttertoast.showToast(
                                msg: "Email Address is not valid.");
                          } else if (phoneTextEditingcontroller.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Phone Number is mandatory.");
                          } else if (passwordTextEditingcontroller.text.length <
                              6) {
                            Fluttertoast.showToast(
                                msg: "Password must be atleast 6 characters.");
                          } else {
                            registerNewUser(context);
                          }
                        },
                        child: const Center(
                          child: Text(
                            "Register",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: "Brand Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: const Text("Already have an Account ? Login Here."))
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Registering, Please wait ...",
      ),
    );

    UserCredential firebaseUserCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: emailTextEditingcontroller.text,
            password: passwordTextEditingcontroller.text);
    User? user = firebaseUserCredential.user;

    if (user != null) {
      // Save Info User To Databse
      Map userDataMap = {
        "name": nameTextEditingcontroller.text.trim(),
        "email": emailTextEditingcontroller.text.trim(),
        "phone": phoneTextEditingcontroller.text.trim(),
        "password": passwordTextEditingcontroller.text.trim(),
      };
      driversRef.child(user.uid).set(userDataMap);

      currentfirebaseUser = user;
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, CarInfoScreen.idScreen);
    } else {
      // Error Occured
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "New User account has not been Created.");
    }
  }
}
