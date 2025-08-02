import 'dart:async';

import 'package:authtest/add_elder.dart';
import 'package:authtest/doc_map.dart';
import 'package:authtest/elderinfo.dart';
import 'package:authtest/services/aw_noti.dart';
import 'package:authtest/services/notifi_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({Key? key}) : super(key: key);

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _eldersStream;
  late DatabaseReference _dbRef;
  Map<String, String> _realTimeValues = {}; 
  Timer? _timer; 
  DateTime? _lastNotificationTimestamp;
  String _realTimeValue = '';
  String deviceId='10';
  bool _send = false;
  int id = 1239;
  // _dbRef = FirebaseDatabase.instance.ref().child('$id').child('BPM');

  @override
  void initState() {
    super.initState();
    _eldersStream = _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('elders')
        .snapshots();
    //_startRealTimeData();
  }
int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    AddEld(),
    DocMap(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }




    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '',
          ),
          
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(43, 52, 103, 0.8),
        onTap: _onItemTapped,
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
