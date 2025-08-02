import 'package:authtest/chart.dart';
import 'package:authtest/chart2.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/login.dart';
import 'package:authtest/services/notifi_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ElderInformationPage extends StatefulWidget {
  final String elderId;

  const ElderInformationPage({Key? key, required this.elderId}) : super(key: key);

  @override
  _ElderInformationPageState createState() => _ElderInformationPageState();
}

class _ElderInformationPageState extends State<ElderInformationPage> {

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

  @override
  void initState() {
    super.initState();
    _startRealTimeData(widget.elderId);
    _elderStream = FirebaseFirestore.instance.collection('users').doc(widget.elderId).snapshots();
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
Widget build(BuildContext context) {
  // debugPrint('ElderInformationPage - elderId: $widget.elderId');
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
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LiveChartPage(elderId: widget.elderId,)),
      );
    },
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
          child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LiveChartSpo2Page(elderId: widget.elderId,)),
      );
    },
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
    ),
  ]
),

               Card(
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Color.fromRGBO(43, 52, 103, 0.8),
                    width: 1.0,
                  ),
                ),
                margin: EdgeInsets.all(8),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          translation(context).thresh1,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${elder['threshold'][0]} - ${elder['threshold'][1]}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.orange),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 15, 5),
                            child: 
                            TextButton(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.withOpacity(0.3)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.orange),
  ),
   onPressed: () async {
                                final newThreshold = await showDialog<List<int>>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              int lowerBound = elder['threshold'][0];
                                              int upperBound = elder['threshold'][1];
                                          
                                              return AlertDialog(
                                                title: Text(translation(context).setNewThresh),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                            TextFormField(
                              initialValue: lowerBound.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: translation(context).lowerBnd,
                                hintText: translation(context).entLowbnd,
                              ),
                              onChanged: (value) {
                                lowerBound = int.tryParse(value) ?? lowerBound;
                              },
                            ),
                            TextFormField(
                              initialValue: upperBound.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: translation(context).upperBnd,
                                hintText: translation(context).entUpBnd,
                              ),
                              onChanged: (value) {
                                upperBound = int.tryParse(value) ?? upperBound;
                              },
                            ),
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                            child: Text(translation(context).cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                                                  ),
                                                  ElevatedButton(
                            child: Text(translation(context).save),
                            onPressed: () {
                              Navigator.of(context).pop([lowerBound, upperBound]);
                            },
                                                  ),
                                                ],
                                              );
                                            },
                                );
                                          
                                if (newThreshold != null &&
                                              (newThreshold[0] != elder['threshold'][0] ||
                                                  newThreshold[1] != elder['threshold'][1])) {
                                            setState(() {
                                              elder['threshold'] = newThreshold;
                                            });
                                          
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(widget.elderId)
                                                .set({
                                              'threshold': newThreshold,
                                            }, SetOptions(merge: true));
                                }
                              },
  child: Text(translation(context).edit),
),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
),

            Card(
               shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color:Color.fromRGBO(43, 52, 103, 0.8),
                    width: 1.0,
                  ),
                ),
                margin: EdgeInsets.all(8),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          translation(context).thresh2,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${elder['threshold1'][0]} - ${elder['threshold1'][1]}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.red),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 15, 5),
                            child: 
                            TextButton(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.red.withOpacity(0.3)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
  ),
   onPressed: () async {
                                final newThreshold = await showDialog<List<int>>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              int lowerBound = elder['threshold1'][0];
                                              int upperBound = elder['threshold1'][1];
                                          
                                              return AlertDialog(
                                                title: Text(translation(context).setNewThresh),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                            TextFormField(
                              initialValue: lowerBound.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: translation(context).lowerBnd,
                                hintText: translation(context).entLowbnd,
                              ),
                              onChanged: (value) {
                                lowerBound = int.tryParse(value) ?? lowerBound;
                              },
                            ),
                            TextFormField(
                              initialValue: upperBound.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: translation(context).upperBnd,
                                hintText: translation(context).entUpBnd,
                              ),
                              onChanged: (value) {
                                upperBound = int.tryParse(value) ?? upperBound;
                              },
                            ),
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                            child: Text(translation(context).cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                                                  ),
                                                  ElevatedButton(
                            child: Text(translation(context).save),
                            onPressed: () {
                              Navigator.of(context).pop([lowerBound, upperBound]);
                            },
                                                  ),
                                                ],
                                              );
                                            },
                                );
                                          
                                if (newThreshold != null &&
                                              (newThreshold[0] != elder['threshold1'][0] ||
                                                  newThreshold[1] != elder['threshold1'][1])) {
                                            setState(() {
                                              elder['threshold1'] = newThreshold;
                                            });
                                          
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(widget.elderId)
                                                .set({
                                              'threshold1': newThreshold,
                                            }, SetOptions(merge: true));
                                }
                              },
  child: Text(translation(context).edit),
),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
),
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
    side: BorderSide(
      color: Color.fromRGBO(43, 52, 103, 0.8),
      width: 1.0,
    ),
  ),
  margin: EdgeInsets.all(8),
  child: Container(
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            translation(context).spo2thresh,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${elder['limitspo2']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 15, 5),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red.withOpacity(0.3)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () async {
                  final newLimitspo2 = await showDialog<int>(
                    context: context,
                    builder: (BuildContext context) {
                      int limitspo2 = elder['limitspo2'];

                      return AlertDialog(
                        title: Text(translation(context).setNewThresh),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              initialValue: limitspo2.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: translation(context).threshspo2,
                                hintText: translation(context).threshspo2,
                              ),
                              onChanged: (value) {
                                limitspo2 = int.tryParse(value) ?? limitspo2;
                              },
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(translation(context).cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: Text(translation(context).save),
                            onPressed: () {
                              Navigator.of(context).pop(limitspo2);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (newLimitspo2 != null && newLimitspo2 != elder['limitspo2']) {
                    setState(() {
                      elder['limitspo2'] = newLimitspo2;
                    });

                    FirebaseFirestore.instance.collection('users').doc(widget.elderId).set(
                      {
                        'limitspo2': newLimitspo2,
                      },
                      SetOptions(merge: true),
                    );
                  }
                },
                child: Text(translation(context).edit),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
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