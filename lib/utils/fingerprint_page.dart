import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FingerPrint extends StatefulWidget {
  @override
  State<FingerPrint> createState() => _FingerPrintState();
}

class _FingerPrintState extends State<FingerPrint> {
  final LocalAuthentication auth = LocalAuthentication();
  String? tokenValue;

  String? emailid;
  bool fingerprint = false;
  String _authorized = "Not Authorized";
  bool _isAuthenticating = false;
  bool authorized = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    await _getAvailableBiometrics();
  }

  Future markAttendance() async {
    // getToken();
    // Navigator.pushNamed(context, MyRoutes.fingerprintRoute);
    String url = "https://biomujappback.herokuapp.com/api/attendance/";

    var response = await http.post(Uri.parse(url), headers: {
      'Authorization': "TOKEN " + "4a41d76ccff38b0f3bdf76c5a7b733bc79b46db8"
    }, body: {
      'email': "Harsh",
    });

    print(response.body.toString());
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    if (mounted) super.setState(fn);
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    try {
      fingerprint = availableBiometrics.contains(BiometricType.fingerprint);
      setState(() {});
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = "Authenticating";
      });

      authenticated = await auth.authenticate(
          localizedReason: "Scan Biometrics To mark attendance",
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
          androidAuthStrings: AndroidAuthMessages(
            signInTitle: "Biometric Authentication",
            biometricRequiredTitle: "Scan Biometric to mark attendance",
            cancelButton: "cancel",
            goToSettingsButton: "Settings",
            goToSettingsDescription: "Please Setup your Biometrics First",
            biometricSuccess: "Success",
            biometricNotRecognized: "User Not Recognized",
          ));
      authorized = authenticated;
      if (authorized == authenticated) {
        markAttendance();
      }
      setState(() {
        _isAuthenticating = false;
        _authorized = "Authenticating";
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            ),
            SizedBox(
              width: 100,
              height: 70,
            ),
            Center(
              child: Text(
                "Mark Attendance",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.pink,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.5),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/fingerprint.png',
                    width: 120.0,
                  ),
                  Text(
                    "Touch The Biometric Sensor",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 2.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: ElevatedButton(
                onPressed: _authenticate,
                child: Image.asset(
                  'assets/images/fingerprint2.png',
                  width: 80,
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 241, 239, 243)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
