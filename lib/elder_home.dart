import 'package:authtest/elderinfo.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/langpage.dart';
import 'package:authtest/main.dart';
import 'package:authtest/reminder_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
class ElderHomePage extends StatefulWidget {
  const ElderHomePage({Key? key}) : super(key: key);

  @override
  _ElderHomePageState createState() => _ElderHomePageState();
}

class _ElderHomePageState extends State<ElderHomePage> {
  Language _selectedLanguage = Language.languageList()[0]; // Set the default language

  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _assistantsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _doctorsStream;
  late DatabaseReference _dbRef;
  late DatabaseReference _dbRef2;
  late String deviceId = '0';
  String _realTimeValue = '';
  String _realTimeValue2 = '';
  String _deviceID = '10';
  String id = "";
  int i = 0;
  String buh = 'buh';
  Reminder? _nextReminder;
  @override
  void initState() {
    super.initState();
    _assistantsStream = _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('assistants')
        .snapshots();
    _doctorsStream = _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('doctors')
        .snapshots();

    _startRealTimeData();
    _getNextReminder();
  }
  
    Future<void> _getNextReminder() async {
    // Get the current user's ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Query the reminders collection for the current user
    QuerySnapshot remindersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .get();

    // Convert the reminders snapshot to a list of Reminder objects
List<Reminder> reminders = remindersSnapshot.docs.map((doc) {
  return Reminder(
    id: doc.id,
    medicineName: doc.get('medicineName') as String? ?? '',
    imagePath: doc.get('imagePath') as String? ?? '',
    reminderTime: (doc.get('reminderTime') as Timestamp).toDate(),
  );
}).toList();

// Filter out the reminders that are not for the current day
// DateTime currentDate = DateTime.now();
// reminders = reminders.where((reminder) =>
//     reminder.reminderTime.year <= currentDate.year ||
//     reminder.reminderTime.month <= currentDate.month ||
//     reminder.reminderTime.day <= currentDate.day).toList();

// Sort the reminders by time
reminders.sort((a, b) {
  // Compare the hour part of the reminderTime property
  int result = a.reminderTime.hour.compareTo(b.reminderTime.hour);
  if (result != 0) {
    return result;
  }

  // If the hour part is the same, compare the minute part
  return a.reminderTime.minute.compareTo(b.reminderTime.minute);
});


// Set the next reminder as the first reminder in the list
Reminder? nextReminder = reminders.isNotEmpty ? reminders.first : null;

setState(() {
  _nextReminder = nextReminder;
});
    }

Future<void> _startRealTimeData() async {
  final User? user = _auth.currentUser;
  final DocumentSnapshot userDocSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  String deviceId = userDocSnapshot.get('deviceId').toString();
  DatabaseReference bpmRef = FirebaseDatabase.instance
      .ref()
      .child('devices')
      .child(deviceId)
      .child('bpm');
  DatabaseReference spo2Ref = FirebaseDatabase.instance
      .ref()
      .child('devices')
      .child(deviceId)
      .child('spo2');

  bpmRef.onValue.listen((event) {
    int bpmValue = event.snapshot.value as int;
    DateTime timestamp = DateTime.now();

    setState(() {
      _realTimeValue = bpmValue.toString();
      if (bpmValue > 120) {
        _updateElderLocation();
      }

      FirebaseFirestore.instance.collection('data').doc(user.uid).collection('bpm').add({
        'value': bpmValue,
        'time': timestamp,
      });
    });
  });

  spo2Ref.onValue.listen((event) {
    int spo2Value = event.snapshot.value as int;
    DateTime timestamp = DateTime.now();

    setState(() {
      _realTimeValue2 = spo2Value.toString();

      FirebaseFirestore.instance.collection('data').doc(user.uid).collection('spo2').add({
        'value': spo2Value,
        'time': timestamp,
      });
    });
  });
}

Future<void> _updateElderLocation() async {
  Position position = await _determinePosition();
  final User? user = _auth.currentUser;
  FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
    'location': GeoPoint(position.latitude, position.longitude),
  });
}

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error(translation(context).locservdis);
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error(translation(context).locperden);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(translation(context).locperdenperma);
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
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
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
          children: [
           Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromRGBO(235, 69, 95, 0.94),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 35,
                        ),
                        SizedBox(width: 10),
                        Text(
                          translation(context).heartRate,
                          style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "${_realTimeValue}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          translation(context).bpm,
                          style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        
                        
                      ],
                    ),
                  ],
                ),
                Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Image.asset(
      "assets/icons/egc.png",
      color: Colors.white,
      height: 100,
    ),
  ],
)
              ],
            ),

          ),
          const SizedBox(height: 30),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromRGBO(43, 52, 103, 0.8)
            ),
             child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.opacity,
                          color: Colors.white,
                          size: 35,
                        ),
                        SizedBox(width: 10),
                        Text(
                          translation(context).oxygenLvl,
                          style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "${_realTimeValue2} %",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(width: 10),  
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/oxy.png",
                      color: Colors.white,
                      height: 100,
                    ),
                  ],
                )
              ],
            ),

          ),
          const SizedBox(height: 30),
        Container(
  padding: EdgeInsets.all(10),
  height: 160,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Color.fromRGBO(186, 215, 233, 1)
  ),
  child: _nextReminder != null
      ? Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
               
              children: [
                
                Text(
                        translation(context).nextMed,
                        style: TextStyle(
                          color:  Color.fromRGBO(43, 52, 103, 0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Image.asset(
                  _nextReminder!.imagePath,
                  width: 80,
                  height: 80,
                ),
              ),
            
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  _nextReminder!.medicineName,
                  style: TextStyle(
                    color: Color.fromRGBO(43, 52, 103, 0.8),
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  // 'Time: ${DateFormat.jm().format(_nextReminder!.reminderTime)}',
                  translation(context).time('${DateFormat.jm().format(_nextReminder!.reminderTime)}'),
                  style: TextStyle(
                    color: Color.fromRGBO(43, 52, 103, 0.8),
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
    ),
        ],
      )
      : Center(
          child: Text(
            translation(context).noMedsLeft,
            style: TextStyle(
              color:Color.fromRGBO(43, 52, 103, 0.8),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
)

            
              
            ],
          ),
        ),
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
        onPressed: () {
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


}
