import 'package:authtest/add_as_doc.dart';
import 'package:authtest/chart.dart';
import 'package:authtest/elder_home.dart';
import 'package:authtest/map_loc.dart';
import 'package:authtest/reminder_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:authtest/services/notifi_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';
import 'package:geolocator/geolocator.dart';

class ElderPage extends StatefulWidget {
  const ElderPage({Key? key}) : super(key: key);

  @override
  State<ElderPage> createState() => _ElderPageState();
}

class _ElderPageState extends State<ElderPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _assistantsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _doctorsStream;
    TextEditingController _idController = TextEditingController();
  Future<bool>? _isNodeExists;
  // Enable disk persistence
  late DatabaseReference _dbRef;
  late String deviceId='0';
  String _realTimeValue = '';
  String _deviceID='10';
  String id = "";
  int i = 0;
  String buh = 'buh';
  String? _userName;


   int _selectedIndex = 0;

static List<Widget> _widgetOptions = <Widget>[
  ElderHomePage(), // Modified line
  ReminderPage(title: 'elder'),
  CurrentLoc(),
  AssistantAndDoctorsPage(),
  // LiveChartPage(),
];

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor:  Color.fromRGBO(43, 52, 103, 0.8),
        unselectedItemColor: Color.fromRGBO(0, 0, 0, 1),
      ),

    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

}
