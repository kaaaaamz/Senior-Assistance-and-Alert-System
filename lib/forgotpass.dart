import 'package:authtest/langconsts.dart';
import 'package:authtest/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String _errorMessage = "";

  void _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
                                                 Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LoginPage(),
                                          ),);
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message ?? translation(context).erroc;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Forgot Password"),
      // ),
      body:  Stack(children: [Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80,),
                Center(child:Container(
                  child: Image.asset(   
                    'assets/images/forgot_pass.jpg',
                      height: 300,
                      width: 300,
                    )
                ),),
              TextFormField(
                controller: _emailController,
                decoration:  InputDecoration(
                               prefixIcon: Icon(Icons.person_outline_outlined),
                              labelText: translation(context).emailField,
                              hintText: translation(context).emailField,
                              border: OutlineInputBorder(),
                              ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return translation(context).emptyEmail;
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendResetEmail,
                child: Text(translation(context).sendresem),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
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
}
