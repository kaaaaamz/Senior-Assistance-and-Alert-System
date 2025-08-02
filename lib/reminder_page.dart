import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:authtest/elderinfo.dart';
import 'package:authtest/langconsts.dart';
import 'package:flutter/rendering.dart';
import 'package:authtest/services/notifi_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';


class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  String _medicineName = '';
  late TimeOfDay _timeOfDay;
  // late TimeOfDay timeOfDay;
    final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _timeOfDay = TimeOfDay.now();
  }
  void _deleteReminder(String id) async {
  // Get a Firestore instance
  final firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final userId = currentUser!.uid;
  try {
    // Delete the reminder document from the "reminders" collection
    await firestore.collection('users').doc(userId).collection('reminders').doc(id).delete();
    final docRef = await firestore.collection('users').doc(userId).collection('reminders').doc(id); 
    String reminderId = docRef.id.split('/').last;
    await NotificationManager().cancelNotification(reminderId);
    // Show a snackbar to confirm the reminder has been deleted
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(translation(context).remDel)),
    );
  } catch (e) {
    print('Error deleting reminder: $e');
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(translation(context).failDelRem)),
    );
  }
}

void _modifyReminder(Reminder reminder) async {
  // Create a text controller for the medicine name field
  final medicineNameController = TextEditingController(text: reminder.medicineName);
  final currentUser = FirebaseAuth.instance.currentUser;
  final userId = currentUser!.uid;
  // Create a TimeOfDay object from the reminder's reminderTime field
  var timeOfDay = TimeOfDay(hour: reminder.reminderTime.hour, minute: reminder.reminderTime.minute);

  // Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text(translation(context).modRem),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: medicineNameController,
              decoration: InputDecoration(
                labelText: translation(context).enterMedName,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            MaterialButton(
              height: 50,
              minWidth: 150,
              color:Color.fromRGBO(43, 52, 103, 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child:  Text(
                translation(context).openTimePick,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: timeOfDay,
                );
                if (pickedTime != null) {
                  timeOfDay = pickedTime;
                }
              },
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () async {
              // Get a Firestore instance
              final firestore = FirebaseFirestore.instance;
                  final docRef = await firestore.collection('users').doc(userId).collection('reminders').doc(reminder.id); 
                  String reminderId = docRef.id.split('/').last;
                  await NotificationManager().cancelNotification(reminderId);
              try {
                // Update the reminder document in the "reminders" collection
                await firestore.collection('users').doc(userId).collection('reminders').doc(reminder.id).update({
                  'medicineName': medicineNameController.text,
                  'reminderTime': Timestamp.fromDate(
                    DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      timeOfDay.hour,
                      timeOfDay.minute,
                    ),
                  ),
                });
                // Schedule the new notification at the updated time
                await _scheduleNotification(reminder.id,);

                // Show a snackbar to confirm the reminder has been updated
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(translation(context).remUpdt)),
                );

                // Close the dialog
                Navigator.pop(context);
              } catch (e) {
                print('Error updating reminder: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(translation(context).failUpdtRem)),
                );
              }
            },
            child:  Text(translation(context).update),
          ),
          MaterialButton(
            onPressed: () {
              // Close the dialog
              Navigator.pop(context);
            },
            child:  Text(translation(context).cancel),
          ),
        ],
      );
    },
  );
}

Future<void> _scheduleNotification(String id) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final userId = currentUser!.uid;
  final firestore = FirebaseFirestore.instance;

  try {
    final docSnapshot = await firestore.collection('users').doc(userId).collection('reminders').doc(id).get();
    if (docSnapshot.exists) {
      final reminder = Reminder.fromFirestore(docSnapshot);
      final time = reminder.reminderTime;
      final medicineName = reminder.medicineName;
       final now = DateTime.now();
  //DateTime dateTime = DateTime.now();
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(time);
      await NotificationManager().scheduleNotification(timeOfDay, medicineName, id, translation(context).medtime(medicineName));
      print('Scheduling notification for reminder with id $id');
    } else {
      print('No reminder found with id $id');
    }
  } catch (e) {
    print('Error scheduling reminder: $e');
  }
}
Future<void> _createReminder() async {
  // Check if medicine name is empty
  if (_medicineName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(translation(context).emptyMed)),
    );
    return;
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  final userId = currentUser!.uid;

  // Get a Firestore instance
  final firestore = FirebaseFirestore.instance;
  try {
    final docRef = await firestore.collection('users').doc(_auth.currentUser!.uid).collection('reminders').add({
      'medicineName': _medicineName,
      'reminderTime': Timestamp.fromDate(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _timeOfDay.hour,
          _timeOfDay.minute,
        ),
      ),
      'imagePath': _selectedIconPath, // Add the path to the image as a string
    });

    String reminderId = docRef.id.split('/').last;
    print ('$reminderId');
    _scheduleNotification(reminderId);

    // Show a snackbar to confirm the reminder has been scheduled
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(translation(context).remSched)),
    );

    // Clear the medicine name field
    setState(() {
      _medicineName = '';
    });
  } catch (e) {
    print('Error scheduling reminder: $e');
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(translation(context).failRemSched)),
    );
  }
}

final List<Widget> medicineIcons = [
  Image.asset('assets/icons/med1.png'),
  Image.asset('assets/icons/med2.png'),
  Image.asset('assets/icons/med3.png'),
  Image.asset('assets/icons/med4.png'),
  Image.asset('assets/icons/med5.png'),
  Image.asset('assets/icons/med6.png'),
  Image.asset('assets/icons/med7.png'),
  Image.asset('assets/icons/med8.png'),
  Image.asset('assets/icons/med9.png'),
];

// Define a variable to store the selected medicine icon
Widget? _selectedMedicineIcon;
String? _selectedIconPath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color.fromRGBO(43, 52, 103, 0.8),
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Stack(children: [Container(
         padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 90),
      decoration: BoxDecoration(borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),color: Colors.white),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).collection('reminders').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
      
            List<Widget> reminders = [];
            reminders.clear();
            snapshot.data!.docs.forEach((doc) {
              final reminder = Reminder.fromFirestore(doc);
              reminders.add(
            SizedBox(
  height: 120,
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    color: Colors.white,
    child: ListTile(
      leading: Image.asset(
        reminder.imagePath,
        height: 80,
        width: 80,
      ),
      title: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reminder.medicineName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              Row(
  children: [
    Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Icon(
        Icons.access_time,
        color: Colors.grey,
        size: 18.0,
      ),
    ),
    SizedBox(width: 5.0),
    Padding(
      padding: const EdgeInsets.only(top:10.0),
      child: Text(
        reminder.reminderTime.hour.toString().padLeft(2, '0') +
            ':' +
            reminder.reminderTime.minute.toString().padLeft(2, '0'),
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.5,
        ),
      ),
    ),
  ],
),
            ],
          ),
          SizedBox(height: 14,),
          Row(
        // mainAxisAlignment: MainAxisAlignment.,
        children: [
          InkWell(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(43, 52, 103, 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                translation(context).edit,
                style: TextStyle(
                  color: Color.fromRGBO(43, 52, 103, 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _modifyReminder(reminder);
            },
          ),
          SizedBox(width: 5),
          InkWell(
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                translation(context).delete,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              _deleteReminder(reminder.id);
            },
          ),
        ],
      ),
        ],
      ),
      
    ),
  ),
)




              );
            });
      
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: reminders,
                  ),
                ),
                MaterialButton(
                  height: 50,
                  minWidth: 150,
                  color:  Color.fromRGBO(43, 52, 103, 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    translation(context).addRem,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                   showDialog(
  context: context,
  builder: (BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        title:  Text(translation(context).schedRem),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 250.0,
                width: 250.0,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    for (final icon in medicineIcons)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMedicineIcon = icon;
                             _selectedIconPath = 'assets/icons/med${medicineIcons.indexOf(icon) + 1}.png';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            border: Border.all(
                              color: _selectedMedicineIcon == icon ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: icon,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                              // controller: nameController,
                              decoration: InputDecoration(
                              // prefixIcon: Icon(Icons.person_outline_outlined),
                              labelText: translation(context).medField,
                              hintText: translation(context).enterMedName,
                              border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _medicineName = value;
                              },
                              keyboardType: TextInputType.name,
                            ),
              const SizedBox(height: 30),
              MaterialButton(
                height: 50,
                minWidth: 150,
                color: Color.fromRGBO(43, 52, 103, 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  translation(context).openTimePick,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _timeOfDay,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeOfDay = pickedTime;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              _createReminder();
              // _scheduleNotification();
              Navigator.pop(context);
            },
            child:  Text(translation(context).sched),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child:  Text(translation(context).cancel),
          ),
        ],
      );
    },
  );
},
);
                  },
                ),
              ],
            );
          },
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
      SizedBox(width: 300,),
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
Future<void> selectTime() async {
    TimeOfDay? _picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );
    if (_picked != null) {
      setState(() {
        _timeOfDay = _picked;
      });
    }
  }
}
class Reminder {
  final String id;
  final String medicineName;
  final DateTime reminderTime;
  final String imagePath;

  Reminder({
    required this.id,
    required this.medicineName,
    required this.reminderTime,
    required this.imagePath,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    // Map<String, dynamic> data = doc.data()!;
    Map<String, dynamic> data = (doc.data()! as Map).cast<String, dynamic>();

    return Reminder(
      id: doc.id,
      medicineName: data['medicineName'],
      reminderTime: (data['reminderTime'] as Timestamp).toDate(),
      imagePath: data['imagePath'] ?? '',
    );
  }
}