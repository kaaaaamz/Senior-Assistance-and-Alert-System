import 'package:authtest/device_id.dart';
import 'package:authtest/doctor.dart';
import 'package:authtest/forgotpass.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'elder.dart';
import 'assistant.dart';
import 'register.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController forgetPasswordController = new TextEditingController();
  final _auth = FirebaseAuth.instance;
  var isLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Stack(children: [SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const Image(
                image: AssetImage("assets/images/login_img.jpg")
                ),
              // Container(
              //   color:  Colors.white,
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height * 0.70,
              //   child: Center(
              //     child: Container(
              //       margin: EdgeInsets.all(12),
              //       child: 
                    Container(
                      color:  Colors.white,
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              translation(context).headTitLogin,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 35,
                              ),
                            ),
                            Text(
                              translation(context).headDiscpLogin,
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                color: Color.fromARGB(230, 0, 0, 0),
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                               prefixIcon: Icon(Icons.person_outline_outlined),
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
                              onSaved: (value) {
                                emailController.text = value!;
                              },
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _isObscure3,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: Icon(_isObscure3
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure3 = !_isObscure3;
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
                              onSaved: (value) {
                                passwordController.text = value!;
                              },
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: () async {
                                    // var forgotEmail = forgetPasswordController.text.trim();
                                    // try{
                                    //   await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text).then((value) => {
                                    //     print("email sent"),
                                         Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ForgotPasswordPage(),
                                          ),
                                        );

                                    //   });
                                    // }on FirebaseAuthException catch (e){
                                    //   print("Error $e");
                                    // }                                  
                                    }, 
                                  child: Text(translation(context).forgotPass,style: TextStyle(color: Color.fromRGBO(0, 62, 168, 1)),)),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                setState(() {
                                  visible = true;
                                });
                                signIn(
                                    emailController.text, passwordController.text);
                              },
                                child: Text(translation(context).login),
                              ),
                            ),
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                const SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.only(left: 140),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Register(),
                                        ),
                                      );
                                    },
                                   child: Text.rich(TextSpan(children: [
                                    TextSpan(
                                      text: translation(context).dontHaveAcc,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),
                                    TextSpan(text: translation(context).signUp,style: TextStyle(color: Color.fromRGBO(0, 62, 168, 1)),)
                                  ]))
                                  ),
                                ),
                              ],
                            ),

                            
                          ],
                        ),
                      ),
                    ),
            
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
        onPressed: () {
                    Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomePage(),
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

  void route() {
  User? user = FirebaseAuth.instance.currentUser;
  var kk = FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      if (documentSnapshot.get('rool') == "assistant") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AssistantPage(),
          ),
        );
      } else if (documentSnapshot.get('rool') == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorPage(),
          ),
        );
      } else if (documentSnapshot.get('deviceId') != "" &&
          documentSnapshot.get('rool') == "elder") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ElderPage(),
          ),
        );
      } else if (documentSnapshot.get('deviceId') == "" &&
          documentSnapshot.get('rool') == "elder") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceId(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translation(context).documnotfound),
        ),
      );
    }
  });
}

void signIn(String email, String password) async {
  if (_formkey.currentState!.validate()) {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      route();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translation(context).nouserfound),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translation(context).wrongpass),
          ),
        );
      }
    }
  }
}

}
