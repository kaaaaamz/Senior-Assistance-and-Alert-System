import 'package:authtest/langconsts.dart';
import 'package:authtest/login.dart';
import 'package:authtest/services/notifi_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ElderInfoAssistant extends StatefulWidget {
  final String elderId;

  const ElderInfoAssistant({Key? key, required this.elderId}) : super(key: key);

  @override
  _ElderInfoAssistantState createState() => _ElderInfoAssistantState();
}

class _ElderInfoAssistantState extends State<ElderInfoAssistant> {

  late Stream<DocumentSnapshot<Map<String, dynamic>>> _elderStream;
  late DatabaseReference _dbRef;
  late String deviceId;
  late String _realTimeValue;
  final FirebaseAuth _auth = FirebaseAuth.instance;
String threshold = ' - '; 
Map<String, String> _realTimeValues = {}; 
  Map<String, String> _realTimeValues2 = {}; 
  void _updateThreshold(String threshold) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.elderId).update({
        'threshold': threshold,
      });
      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
    }
  }
  
Future<void> _startRealTimeData(String elderId) async {
  final User? user = _auth.currentUser;
  final DocumentSnapshot userDocSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(elderId).get();
  final List<String> thresholdString =
      userDocSnapshot.get('threshold').toString().split('-');
  int lowerBound = userDocSnapshot['threshold'][0];
  int upperBound = userDocSnapshot['threshold'][1];
  int lowerBound1 = userDocSnapshot['threshold1'][0];
  int upperBound1 = userDocSnapshot['threshold1'][1];
  int dangerThreshold = 110; // Second threshold value
  final String deviceId = userDocSnapshot.get('deviceId').toString();
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('devices').child('$deviceId').child('bpm');
    final DatabaseReference dbRef2 =
      FirebaseDatabase.instance.ref().child('devices').child('$deviceId').child('spo2');
  dbRef.onValue.listen((event) {
    setState(() {
      final String realTimeValue = event.snapshot.value.toString();
      _realTimeValues[elderId] = realTimeValue;
    });
  });
  dbRef2.onValue.listen((event) {
      setState(() {
        final String realTimeValue2 = event.snapshot.value.toString();
         _realTimeValues2[elderId] = realTimeValue2;
      });
  });
}

  @override
  void initState() {
    super.initState();
    //_startRealTimeData();
    _startRealTimeData(widget.elderId);
    _elderStream = FirebaseFirestore.instance.collection('users').doc(widget.elderId).snapshots();
  }
  Future<String> getCurrentUserRole() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get();
  final currentUserRole = userSnapshot.data()!['role'];
  return currentUserRole;
}
@override
Widget build(BuildContext context) {
  // debugPrint('ElderInfoAssistant - elderId: $widget.elderId');
  return Scaffold(
    
    backgroundColor:Color.fromRGBO(43, 52, 103, 0.8),
    body: Stack(children: [Container(
      // color: Colors.white,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 90),
      decoration: BoxDecoration(borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),color: Colors.white),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _elderStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var elder = snapshot.data!.data()!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Color.fromRGBO(43, 52, 103, 0.8),
                    width: 1.0,
                  ),
                ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translation(context).nameField,
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            elder['name'],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                // SizedBox(height: 16),
               SizedBox(
                  width: double.infinity,
                  child: Card(
                     shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Color.fromRGBO(43, 52, 103, 0.8),
                    width: 1.0,
                  ),
                ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translation(context).emailField,
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            elder['email'],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
Row(
  children: [
    Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Color.fromRGBO(43, 52, 103, 0.8),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      "${_realTimeValues[widget.elderId] ?? '-'}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      // maxLines: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(

                    child: Text(
                      translation(context).bpm,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Color.fromRGBO(43, 52, 103, 0.8),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.opacity, color: Colors.green),
                  SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      translation(context).spo2,
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(

                      "${_realTimeValues2[widget.elderId] ?? '-'}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      // maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ]
),


              
              ],
            );
          }
        },
      ),
    ),
    Positioned(
        top: 33,
        left: 0,
        child: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    ]
    )
  );
}
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