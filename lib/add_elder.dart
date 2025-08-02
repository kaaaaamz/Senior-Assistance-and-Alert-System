import 'dart:async';

import 'package:authtest/doc_map.dart';
import 'package:authtest/elderinfo.dart';
import 'package:authtest/elderionfoas.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/langpage.dart';
import 'package:authtest/main.dart';
import 'package:authtest/services/aw_noti.dart';
import 'package:authtest/services/notifi_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';

class AddEld extends StatefulWidget {
  const AddEld({super.key});

  @override
  State<AddEld> createState() => _AddEldState();
}

class _AddEldState extends State<AddEld> {
   final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _eldersStream;
  late DatabaseReference _dbRef;
 Map<String, String> _realTimeValues = {}; 
  Map<String, String> _realTimeValues2 = {};  

  Timer? _timer; 
  DateTime? _lastNotificationTimestamp;
  String _realTimeValue = '';
  String deviceId='10';
  bool _send = false;
  int id = 1239;
  Language _selectedLanguage = Language.languageList()[0]; 
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

  Future<String> getCurrentUserRole() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get();
  final currentUserRole = userSnapshot.data()!['rool'];
  return currentUserRole;
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
  int limitspo2 = userDocSnapshot['limitspo2'];
  int dangerThreshold = 110; // Second threshold value
  final String deviceId = userDocSnapshot.get('deviceId').toString();
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('devices').child('$deviceId').child('bpm');
    final DatabaseReference dbRef2 =
      FirebaseDatabase.instance.ref().child('devices').child('$deviceId').child('spo2');
  dbRef.onValue.listen((event) {
    setState(() {
      final String realTimeValue = event.snapshot.value.toString();
      final int bpmValue = int.tryParse(realTimeValue) ?? 0;
      if (!_send && bpmValue >= upperBound1) {
        _send = true;
        final String elderName = userDocSnapshot.get('name').toString();
        final String notificationMessage =
        translation(context).extrhighbpm(elderName);
        NotificationService.showNotification(
          title: translation(context).dangeralrt,
          body: notificationMessage,
          elderId: elderId,
          actionButtons: [
            NotificationActionButton(
              key: 'ELDER_DETAILS',
              label: translation(context).eldloc,
              actionType: ActionType.Default,
              color: Colors.green,
            ),
          ],
        );
        Timer(Duration(seconds: 200), () {
          setState(() {
            _send = false;
          });
        });
      }else
      if (!_send && bpmValue <= lowerBound1) {
        _send = true;
        final String elderName = userDocSnapshot.get('name').toString();
        final String notificationMessage =
            translation(context).extrlowbpm(elderName);
        NotificationService.showNotification(
          title: translation(context).dangeralrt,
          body: notificationMessage,
          elderId: elderId,
          actionButtons: [
            NotificationActionButton(
              key: 'ELDER_DETAILS',
              label: translation(context).eldloc,
              actionType: ActionType.Default,
              color: Colors.green,
            ),
          ],
        );
        Timer(Duration(seconds: 200), () {
          setState(() {
            _send = false;
          });
        });
      }else
      if (!_send &&
          (bpmValue <= lowerBound || bpmValue >= upperBound)) {
        _send = true; // Update state variable
        final String elderName = userDocSnapshot.get('name').toString();
        final String notificationMessage =
            translation(context).anombpm(elderName);
        NotificationService.showNotification(
          title: translation(context).threshalrt,
          body: notificationMessage,
          elderId: elderId,
          actionButtons: [
            NotificationActionButton(
              key: 'ELDER_DETAILS',
              label: translation(context).eldloc,
              actionType: ActionType.Default,
              color: Colors.green,
            ),
          ],
        );
        Timer(Duration(seconds: 200), () {
          setState(() {
            _send = false;
          });
        });
      } 
       
      _realTimeValues[elderId] = realTimeValue;
    });
  });
  dbRef2.onValue.listen((event) {
      setState(() {
        final String realTimeValue2 = event.snapshot.value.toString();
        final int spo2Value = int.tryParse(realTimeValue2) ?? 0;
        if (!_send && spo2Value < limitspo2) {
        _send = true;
        final String elderName = userDocSnapshot.get('name').toString();
        final String notificationMessage =
            translation(context).extrlowspo2(elderName);
        NotificationService.showNotification(
          title: translation(context).dangeralrt,
          body: notificationMessage,
          elderId: elderId,
          actionButtons: [
            NotificationActionButton(
              key: 'ELDER_DETAILS',
              label: translation(context).eldloc,
              actionType: ActionType.Default,
              color: Colors.green,
            ),
          ],
        );
        Timer(Duration(seconds: 200), () {
          setState(() {
            _send = false;
          });
        });
      }
         _realTimeValues2[elderId] = realTimeValue2;
      });
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color.fromRGBO(43, 52, 103, 0.8),
      body: Stack(children: [Container(
        padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 90),
      decoration: BoxDecoration(borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),color: Colors.white),
        child: Column(
          children: [
           Expanded(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _eldersStream,
          builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(translation(context).noEld),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var elder = snapshot.data!.docs[index];
              String elderId = elder.id;
              _startRealTimeData(elderId);
             return Card(
  shadowColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
    side: BorderSide(
      color: Color.fromRGBO(43, 52, 103, 0.8),
      width: 1.0,
    ),
  ),
  elevation: 2,
  child: Padding(
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  elder['name'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final currentUserRole = await getCurrentUserRole();
                if (currentUserRole == 'doctor') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ElderInformationPage(
                        elderId: elderId,
                      ),
                    ),
                  );
                } else if (currentUserRole == 'assistant') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ElderInfoAssistant(elderId: elderId,),
                    ),
                  );
                } else {
                  // Handle other user roles or display an error message
                  print('Unknown user role');
                }
              },
              child: Text(
                translation(context).view,
                style: TextStyle(fontSize: 17, color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteElder(elderId);
              },
              child: Text(
                translation(context).delete,
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 3),
              Flexible(
                child: Text(
                  "${_realTimeValues[elderId] ?? '-'} ${translation(context).bpm}",
                  style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 114, 114, 114)),
                ),
              ),
              SizedBox(width: 20),
              Icon(Icons.opacity, color: Colors.green),
              SizedBox(width: 3),
              Flexible(
                child: Text(
                  "${translation(context).spo2} : ${_realTimeValues2[elderId] ?? '-'} %",
                  style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 114, 114, 114)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
            },
          );
        }
          },
        ),
      ),
      
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: translation(context).entrEldEmail,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      addElder();
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
Positioned(
  top: 33,
  left: 0,
  child: Row(
    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    // crossAxisAlignment: CrossAxisAlignment.baseline,
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: ()  {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Do nothing and keep the current page open.
    }
  },
      ),
      SizedBox(width: 250,),
      PopupMenuButton<Language>(
      icon: Icon(Icons.language, color: Colors.white),
      onSelected: (Language language) async {
        setState(() {
          _selectedLanguage = language;
        });
        Locale _locale = await setLocale(language.languageCode);
        MyApp.setLocale(context, _locale);
      },
      itemBuilder: (BuildContext context) {
        return Language.languageList().map((Language language) {
          return PopupMenuItem<Language>(
            value: language,
            child: Text(language.name),
          );
        }).toList();
      },
    ),
      IconButton(
        icon: Icon(Icons.logout, color: Colors.white),
        onPressed: () {
          logout(context);
        },
      ),
    ],
  ),
),

    ]
    )
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
Future<void> addElder() async {
  String email = _emailController.text.trim();
  var userSnapshot = await _db.collection('users').where('email', isEqualTo: email).where('rool', isEqualTo: 'elder').get();
  if (userSnapshot.docs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translation(context).noEldFound),
      ),
    );
  } else {
    var userDoc = userSnapshot.docs.first;
    var userRef = userDoc.reference;
    var currentUserRef = _db.collection('users').doc(_auth.currentUser!.uid);
    var currentUserDoc = await currentUserRef.get();
    var currentUserRole = currentUserDoc['rool'];

    // Add current user to the appropriate list based on their role
    if (currentUserRole == 'doctor') {
      // Add Doctor to elder's list of Doctors
      currentUserRef.collection('elders').doc(userRef.id).set({
        'name': userDoc['name'],
        'email': userDoc['email'],
      });

      // Update the elder's list of added Doctor with current user
      await userRef.collection('doctors').doc(currentUserRef.id).set({
        'name': currentUserDoc['name'],
        'email': currentUserDoc['email'],
        'rool': currentUserRole,
      });
    } else if (currentUserRole == 'assistant') {
      // Add Assistant to elder's list of Assistants
      currentUserRef.collection('elders').doc(userRef.id).set({
        'name': userDoc['name'],
        'email': userDoc['email'],
      });

      // Update the elder's list of added Assistant with current user
      await userRef.collection('assistants').doc(currentUserRef.id).set({
        'name': currentUserDoc['name'],
        'email': currentUserDoc['email'],
        'rool': currentUserRole,
      });
    }

    var elderDoc = await userRef.get();
    await currentUserRef.update({
      'deviceId': elderDoc['deviceId'], // use current deviceId value
    });

    _emailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translation(context).eldSuccAdd),
      ),
    );
  }
}

Future<void> deleteElder(String elderId) async {
  try {
    final currentUserRef = _db.collection('users').doc(_auth.currentUser!.uid);
    final elderRef = _db.collection('users').doc(elderId);

    // Check the current user's role
    final currentUser = await currentUserRef.get();
    final userRole = currentUser.data()?['rool'];

    // Remove elder from the appropriate list based on the user's role
    if (userRole == 'doctor') {
      await currentUserRef.collection('elders').doc(elderId).delete();
      await elderRef.collection('doctors').doc(currentUserRef.id).delete();
    } else if (userRole == 'assistant') {
      await currentUserRef.collection('elders').doc(elderId).delete();
      await elderRef.collection('assistants').doc(currentUserRef.id).delete();
    }

    // Update the elder's deviceId to null or any appropriate value
    // await elderRef.update({
    //   'deviceId': null,
    // });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translation(context).elddel),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translation(context).eldfaildel),
      ),
    );
  }
}


}
