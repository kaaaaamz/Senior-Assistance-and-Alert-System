
import 'package:authtest/langconsts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:authtest/elder.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class DeviceId extends StatefulWidget {
  @override
  _DeviceIdState createState() => _DeviceIdState();
}

class _DeviceIdState extends State<DeviceId> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _idController = TextEditingController();
  Future<bool>? _isNodeExists;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(children: [ Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _idController,
              decoration:  InputDecoration(
              labelText: translation(context).deviceid,
              hintText: translation(context).deviceid,
              border: OutlineInputBorder(),
                ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isNodeExists = isNodeExists(_idController.text);
                });
              },
              child: Text(translation(context).submit),
            ),
            SizedBox(height: 16),
            FutureBuilder<bool>(
              future: _isNodeExists,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text(translation(context).err('${snapshot.error}'));
                }
                if (snapshot.data == true) {
                  route();
                }
                return Text(translation(context).devicednex);
              },
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
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ),
),
      ]
      ),
    );
  }

Future<bool> isNodeExists(String id) async {
  bool exists = true;
  var result = await _dbRef.child('devices').child('$id').once();
  exists = result.snapshot.value != null;

  if (exists) {
    var userRef = _db.collection('users').doc(_auth.currentUser!.uid);
    await userRef.update({
      'deviceId': id
    });
  }

  return exists;
}
void route() {
           Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>  ElderPage(),
          )
           );
  }
}
