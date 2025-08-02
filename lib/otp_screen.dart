
import 'package:authtest/assistant.dart';
import 'package:authtest/doctor.dart';
import 'package:authtest/elder.dart';
import 'package:authtest/elder_home.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:emailotp/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class Otp extends StatelessWidget {
  const Otp({Key? key,required this.otpController, }) : super(key: key);
  final TextEditingController otpController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        controller: otpController,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: const InputDecoration(
          hintText: ('0'),
        ),
        onSaved: (value) {},
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
//  final TextEditingController otpController;
  final String email;
  final String password;
  final String role;
  final String name;
  final String id;
  final EmailOTP myauth ;
  const OtpScreen({
    Key? key,
    // required this.otpController,
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    required this.id,
    required this.myauth,
  }) : super(key: key);
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
   final _formkey = GlobalKey<FormState>();
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();

   final _auth = FirebaseAuth.instance;
  String otpController = "1234";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   leading: IconButton(
      //     onPressed: () {},
      //     icon: const Icon(Icons.arrow_back_ios_new),
      //   ),
      //   actions: [
      //     IconButton(
      //       onPressed: () {},
      //       icon: const Icon(Icons.info),
      //     ),
      //   ],
      // ),
      body:  Stack(children: [Form(
         key: _formkey,
        child: Column(
          children: [
            const SizedBox(
              height: 120,
            ),
             Center(child:Container(
                  child: Image.asset(   
                    'assets/images/verify.jpg',
                      height: 300,
                      width: 300,
                    )
                ),),
            // const Icon(Icons.dialpad_rounded, size: 50),
            const SizedBox(
              height: 40,
            ),
            // const Text(
            //   "Enter Mary's PIN",
            //   style: TextStyle(fontSize: 40),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Otp(
                  otpController: otp1Controller,
                ),
                Otp(
                  otpController: otp2Controller,
                ),
                Otp(
                  otpController: otp3Controller,
                ),
                Otp(
                  otpController: otp4Controller,
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            // const Text(
            //   "Rider can't find a pin",
            //   style: TextStyle(fontSize: 20),
            // ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
              if (await widget.myauth.verifyOTP(otp: otp1Controller.text +
                      otp2Controller.text +
                      otp3Controller.text +
                      otp4Controller.text) == true) {
                        signUp(widget.email,widget.password , widget.role, widget.name,widget.id);

                  ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                    content: Text(translation(context).otpver),
                  ));
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>  LoginPage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(translation(context).otpinval),
                  ));
                }
              },
              child: Text(
                translation(context).confirm,
                style: TextStyle(fontSize: 20),
              ),
            )
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
      )
    );
  }

 void signUp(String email, String password, String rool, String name, String id) async {
  if (_formkey.currentState!.validate()) {
    print('signUp method called'); 
    await _auth
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((value) => {
        postDetailsToFirestore(email, rool, [], [], name, id, [], [0,0], [0,0]),
      })
      .catchError((e) {
         print('Error during sign up: $e');
         return Future.error(e);
      });
  }
}
postDetailsToFirestore(String email, String rool, List<dynamic> assistants, List<dynamic> doctors, String name, String id,List<dynamic> reminders,  List<dynamic> threshold ,  List<dynamic> threshold1) async {
      print('post method called'); 
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  var user = _auth.currentUser;
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  if (rool == 'elder') {
    ref.doc(user!.uid).set({
      'name':name,
      'email': email,
      'rool': rool,
      'assistants': assistants,
      'doctors':doctors,
      'deviceId':id,
      'reminders':reminders,
      'threshold':threshold,
      'threshold1':threshold1,
      'limitspo2':0
    }, SetOptions(merge: true));
  } else if (rool == 'assistant') {
    ref.doc(user!.uid).set({
      'name':name,
      'email': email,
      'rool': rool,
      'elders': assistants,
    }, SetOptions(merge: true));
  }  else if (rool == 'doctor') {
    ref.doc(user!.uid).set({
      'name':name,
      'email': email,
      'rool': rool,
      'elders': assistants,
  }, SetOptions(merge: true));}
  Navigator.pushReplacement(
    context, 
    MaterialPageRoute(builder: (context) => LoginPage())
  );
}
}



