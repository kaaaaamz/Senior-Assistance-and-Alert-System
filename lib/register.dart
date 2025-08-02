// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'package:authtest/assistant.dart';
import 'package:authtest/doctor.dart';
import 'package:authtest/elder.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/langpage.dart';
import 'package:authtest/otp_screen.dart';
import 'package:authtest/roles.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
// import 'model.dart';

class Register extends StatefulWidget {
  @override
  final String? roleName; // make roleName optional

  Register({this.roleName});
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
final TextEditingController deviceIdController = TextEditingController();

  bool isvalid = true;
  // String ermsg = 'id doesnt exist';
  bool exists = false;
  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;


  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmpassController =
      new TextEditingController();
      
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  // final TextEditingController mobile = new TextEditingController();
  final _deviceIDController = TextEditingController();
  final _bpmController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  final _deviceIDFocusNode = FocusNode();
  final ref = FirebaseDatabase.instance.ref('devices');
    EmailOTP myauth = EmailOTP();
  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  Future<bool>? _isNodeExists;
  var options = [
    'elder',
    'assistant',
    'doctor',
  ];
  var _currentItemSelected = "elder";
  var rool = ""; // modify this line
  Future<bool> isNodeExists(String id) async {
    bool exists = true;
    var result = await _dbRef.child('devices').child('$id').once();
    exists = result.snapshot.value != null;
    return exists;
  }
  
  @override
  void initState() {
    super.initState();
    rool = widget.roleName ?? ""; // add this line
  }
  // final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body:
      Stack(children: [SingleChildScrollView(
        
        child: Container(
          // color: Colors.white,
          // padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   color: Color.fromARGB(255, 182, 182, 230),
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height,
              //   child: SingleChildScrollView(
              //     child: Container(
              //       margin: EdgeInsets.all(12),
                    // child: 
                Center(child:Container(
                  child: Image.asset(   
                    'assets/images/signup_img.jpg',
                      height: 250,
                      width: 310,
                    )
                ),),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Text(
                              translation(context).headTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              translation(context).headDiscp,
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                color: Color.fromARGB(230, 0, 0, 0),
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_outlined),
                              labelText: translation(context).nameField,
                              hintText: translation(context).nameField,
                              border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translation(context).emptyName;
                                }
                                return null;
                              },
                              onChanged: (value) {},
                              keyboardType: TextInputType.name,
                            ),
                            
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              labelText: translation(context).emailField,
                              hintText: translation(context).emailField,
                              border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value!.length == 0) {
                                  return translation(context).emptyEmail;
                                }
                                if (!RegExp(
                                        "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                    .hasMatch(value)) {
                                  return translation(context).validEmail;
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {},
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              obscureText: _isObscure,
                              controller: passwordController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(_isObscure
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    }),
                                prefixIcon: Icon(Icons.fingerprint),
                                labelText: translation(context).passField,
                                hintText: translation(context).passField,
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                RegExp regex = new RegExp(r'^.{6,}$');
                                if (value!.isEmpty) {
                                  return translation(context).emtyPass;
                                }
                                if (!regex.hasMatch(value)) {
                                  return translation(context).shortPass;
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {},
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              obscureText: _isObscure2,
                              controller: confirmpassController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(_isObscure2
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure2 = !_isObscure2;
                                      });
                                    }),
                                prefixIcon: Icon(Icons.fingerprint),
                                labelText: translation(context).passConField,
                                hintText: translation(context).passConField,
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (confirmpassController.text !=
                                    passwordController.text) {
                                  return translation(context).matchinPass;
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {},
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                              if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      showProgress = true;
                                    });
                          // signUp(emailController.text, passwordController.text, rool, nameController.text,_deviceIDController.text);
                                     myauth.setConfig(
                              appEmail: "otp@email.com",
                              appName: translation(context).emailotp,
                              userEmail: emailController.text,
                              otpLength: 4,
                              otpType: OTPType.digitsOnly);
                          if (await myauth.sendOTP() == true) {
                            print("email : ${emailController.text}");
                            ScaffoldMessenger.of(context)
                                .showSnackBar( SnackBar(
                              content: Text(translation(context).otpsent),
                            ));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>   OtpScreen(email:emailController.text,password: passwordController.text, role :rool,name: nameController.text,id:_deviceIDController.text,myauth: myauth,)));
                          } 
                          else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar( SnackBar(
                              content: Text(translation(context).otpfail),
                            ));
                                  }
                          ;};},
                                child: Text(translation(context).signUp),

                              ),
                            ),
                            Column(
      children: [

        SizedBox(height: 20,),
        Container(
          padding: EdgeInsets.only(left: 140),
          child: TextButton(
            onPressed: () {
              // CircularProgressIndicator();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: translation(context).alreadyHaveAcc,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              TextSpan(text: translation(context).login,style: TextStyle(color: Color.fromRGBO(0, 62, 168, 1)),)
            ])),
          ),
        )
      ],
    ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
       Positioned(
  top: 33,
  // left: 0,
  child: Row(
    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    // crossAxisAlignment: CrossAxisAlignment.baseline,
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: (){
          Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoleSelectionPage(),
                ),
              );
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