import 'dart:async';

import 'package:flutter/services.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/pages/viewAttendance.dart';
import 'package:my_app/utils/fingerprint_page.dart';
import 'package:my_app/utils/routes.dart';
import 'package:flutter/material.dart';
import '/widgets/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isInRadius = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream =
          Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
              .listen((Position position) {
        print(position == null
            ? 'Unknown'
            : position.latitude.toString() +
                ', ' +
                position.longitude.toString());

        double distance = Geolocator.distanceBetween(
          26.842112,
          75.562064,
          position.latitude,
          position.longitude,
        );

        if (distance <= 1000) {
          if (mounted) {
            setState(() {
              isInRadius = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isInRadius = false;
            });
          }
        }
      });

      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
      } else {
        _positionStreamSubscription!.pause();
      }
    });
  }

  Future<Position> _determinelocation() async {
    bool isenabled;
    LocationPermission permission;
    isenabled = await Geolocator.isLocationServiceEnabled();
    if (!isenabled) {
      return Future.error("Location services are disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Please Change Your Location Settings');
    }
    return await Geolocator.getCurrentPosition();
  }

  // Future<void> _fetchLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   double distance = Geolocator.distanceBetween(
  //     26.842112,
  //     75.562064,
  //     position.latitude,
  //     position.longitude,
  //   );

  //   if (distance <= 1000) {
  //     try {
  //       if (mounted) {
  //         setState(() {
  //           isInRadius = true;
  //         });
  //       }
  //     } on PlatformException catch (e) {
  //       print(e);
  //     }
  //   } else {
  //     try {
  //       if (!mounted) {
  //         super.setState(() {
  //           isInRadius = false;
  //         });
  //       }
  //     } on PlatformException catch (e) {
  //       print(e);
  //     }
  //   }
  //   print("--------------- $isInRadius");
  // }

  @override
  void initState() {
    super.initState();

    _determinelocation();
    _toggleListening();
    // _fetchLocation();
  }

  @override
  void dispose() {
    super.dispose();
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Center(child: Text("Biometric Attendance")),
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences pf = await SharedPreferences.getInstance();

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false);

                pf.clear();
              },
              icon: Icon(Icons.abc))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Text(
                "Dashboard:",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink),
              ),
            ),
            Visibility(
              visible: isInRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    children: [
                      GestureDetector(
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Card(
                            color: Colors.white,
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(children: [
                                  Image.asset(
                                    "assets/images/attendance.png",
                                    height: 120,
                                    width: 160,
                                    alignment: Alignment.center,
                                  ),
                                  SizedBox(height: 25),
                                  Text(
                                    "Mark Attendance",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.pink),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FingerPrint()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ViewAttendance()));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Card(
                          color: Colors.white,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(children: [
                                Image.asset(
                                  "assets/images/view.png",
                                  height: 120,
                                  width: 160,
                                  alignment: Alignment.center,
                                ),
                                SizedBox(height: 25),
                                Text(
                                  "View Attendance",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.pink),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      //drawer: MyDrawer(),
    );
  }
}
