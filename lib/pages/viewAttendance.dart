import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewAttendance extends StatefulWidget {
  const ViewAttendance({Key? key}) : super(key: key);

  @override
  State<ViewAttendance> createState() => _ViewAttendanceState();
}

class _ViewAttendanceState extends State<ViewAttendance> {
  getTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenNew');
  }

  Future viewAttendance() async {
    var url = Uri.parse("https://biomujappback.herokuapp.com/api/attendance/");
    String tok = await getTokenFromStorage();
    print("~~~~~~~~~~~~~~~~~ $tok");

    var response = await http.get(
      url,
      headers: {'Authorization': "TOKEN " + tok},
    );

    final responseJson = jsonDecode(response.body);

    print(responseJson.toString());
  }

  @override
  Widget build(BuildContext context) {
    viewAttendance();
    return Scaffold(
      appBar: AppBar(title: Text('View Attendance')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Half',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Full',
                    ),
                  ),
                ],
                rows: const <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('24 May')),
                      DataCell(Text('Absent')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('25 May')),
                      DataCell(Text('Present')),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
