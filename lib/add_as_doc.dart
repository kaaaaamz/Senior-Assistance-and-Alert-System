import 'package:authtest/elderinfo.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/langpage.dart';
import 'package:authtest/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssistantAndDoctorsPage extends StatefulWidget {
  @override
  _AssistantAndDoctorsPageState createState() => _AssistantAndDoctorsPageState();
}

class _AssistantAndDoctorsPageState extends State<AssistantAndDoctorsPage> {
  String _languageCode = '';

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  String _selectedTab =  "";
  late Stream<QuerySnapshot<Map<String, dynamic>>> _assistantsStream;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _doctorsStream;

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
    getLocale().then((locale) {
    setState(() {
      _languageCode = locale.languageCode;
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
      SizedBox(
  width: MediaQuery.of(context).size.width - 40, // subtracting the padding from the container
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      
      Container(
        // width: MediaQuery.of(context).size.width / 2 - 20,
        
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
           borderRadius: _languageCode == 'ar'
          ? BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )
          : BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          border: Border.all(
      color: Colors.black,
      width: 1,
    ),
          color: _selectedTab == translation(context).assistants
              ? Color.fromRGBO(43, 52, 103, 0.8)
              : Colors.transparent,
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = translation(context).assistants;
            });
          },
          child: Center(
            child: Text(
              translation(context).assistants,
              style: TextStyle(
                fontSize: 16,
                fontWeight: _selectedTab == translation(context).assistants
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedTab == translation(context).assistants
                    ? Colors.white
                    : Color.fromRGBO(43, 52, 103, 0.8),

              ),
            ),
          ),
        ),
      ),
      Container(
        // width: MediaQuery.of(context).size.width / 2 - 20,
        padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
        decoration: BoxDecoration(
          borderRadius: _languageCode == 'ar'
          ? BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            )
          : BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          border: Border.all(
      color: Colors.black,
      width: 1,
    ),
            color: _selectedTab == translation(context).doctors
              ? Color.fromRGBO(43, 52, 103, 0.8)
              : Colors.transparent,
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = translation(context).doctors;
            });
          },
          child: Center(
            child: Text(
              translation(context).doctors,
              style: TextStyle(
                fontSize: 16,
                fontWeight: _selectedTab == translation(context).doctors
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedTab == translation(context).doctors
                    ? Colors.white
                    : Color.fromRGBO(43, 52, 103, 0.8),

              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
            SizedBox(height: 20,),
            Expanded(
  child: _selectedTab == translation(context).assistants
      ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _assistantsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // return CircularProgressIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var assistant = snapshot.data!.docs[index];
                return Card(
                   shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Color.fromRGBO(43, 52, 103, 0.8),
                    width: 1.0,
                  ),
                ),
                  child: ListTile(
                    title: Text(assistant['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    subtitle: Text(assistant['email'],style: TextStyle(fontSize: 15),),
                  ),
                );
              },
            );
          },
        )
      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _doctorsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doctor = snapshot.data!.docs[index];
                return Card(
                   shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Color.fromRGBO(43, 52, 103, 0.8),
                    width: 1.0,
                  ),
                ),
                  child: ListTile(
                    title: Text(doctor['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    subtitle: Text(doctor['email'],style: TextStyle(fontSize: 15),),
                  ),
                );
              },
            );
          },
        ),
),

            // Container(
            //   padding: EdgeInsets.all(10),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: 
            //           TextFormField(
            //             controller: _emailController,
            //             decoration:  InputDecoration(
            //                           // prefixIcon: Icon(Icons.person_outline_outlined),
            //                           labelText: translation(context).entDocAsEm,
            //                           hintText: translation(context).emailField,
            //                           border: OutlineInputBorder(),
            //                           ),
            //           ),
            //         // TextFormField(
            //         //   controller: _emailController,
            //         //   decoration: InputDecoration(
            //         //     labelText: "Enter Assistant's or Doctor's Email",
            //         //     border: OutlineInputBorder(),
            //         //   ),
            //         // ),
            //       ),
            //       IconButton(
            //         onPressed: () {
            //           addAssistant();
            //         },
            //         icon: Icon(Icons.add),
            //       ),
            //     ],
            //   ),
            // ),
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
        onPressed: () {
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

//     Future<void> addAssistant() async {
//   String email = _emailController.text.trim();
//   var userSnapshot = await _db.collection('users').where('email', isEqualTo: email).where('rool', whereIn: ['assistant', 'doctor']).get();
//   if (userSnapshot.docs.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(translation(context).noAsDocEmFound),
//       ),
//     );
//   } else {
//     var userDoc = userSnapshot.docs.first;
//     var userRef = userDoc.reference;
//     var elderRef = _db.collection('users').doc(_auth.currentUser!.uid);

//     if (userDoc['rool'] == 'assistant') {
//     elderRef.collection('assistants').doc(userRef.id).set({
//       'name': userDoc['name'],
//       'email': userDoc['email'],
//       'role': userDoc['rool'],
//     });

//   }else if(userDoc['rool'] == 'doctor') {
//     // Add elder to doctor's list of elders
//   elderRef.collection('doctors').doc(userRef.id).set({
//       'name': userDoc['name'],
//       'email': userDoc['email'],
//       'role': userDoc['rool'],
//     });
//   }
//     var currentUserRef = _db.collection('users').doc(_auth.currentUser!.uid);
//     var currentUserDoc = await currentUserRef.get();

//     // Update the elder's list of added assistant with current user
//     await userRef.collection('elders').doc(currentUserRef.id).set({
//       'name': currentUserDoc['name'],
//       'email': currentUserDoc['email'],
//       'deviceId':currentUserDoc['deviceId']
//     });


//     _emailController.clear();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Assistant added successfully'),
//       ),
//     );
//   }
// }
}