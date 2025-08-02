import 'package:authtest/langconsts.dart';
import 'package:authtest/langpage.dart';
import 'package:authtest/login.dart';
import 'package:authtest/register.dart';
import 'package:authtest/roles.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  Stack(children: [SingleChildScrollView(
        
        child:Container(
        padding: const EdgeInsets.fromLTRB(8, 100, 8, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //  SizedBox(height: 10,),
                Center(child:Container(
                  child: Image.asset(   
                    'assets/images/welcome.jpg',
                      height: 400,
                      width: 400,
                    )
                ),),
            Center(
  child: Column(
    // mainAxisAlignment: MainAxisAlignment.center,
    // crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(height: 40),
      Text(
        translation(context).welcheadtxt,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 27,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 1), // Add some spacing between the lines
      Padding(
        padding: const EdgeInsets.fromLTRB(17, 5, 17, 0),
        child: Text(
          translation(context).welcdiscptxt,
          style: TextStyle(
            color: Color.fromARGB(255, 110, 110, 110),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Row(
                
                children: [
                  // SizedBox(height: 200,),
            
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                     Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
                  },
                  style: ButtonStyle(
                    // Change text color
                    foregroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(43, 52, 103, 0.8)),
                    // Change outline color
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Color.fromRGBO(43, 52, 103, 0.8)),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(150, 50))
                  ),
                  child: Text(translation(context).login),
                ),
              ),
            
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoleSelectionPage(),
                ),
              );
                      },
                      style: ButtonStyle(
                    // Change text color
            
                    minimumSize: MaterialStateProperty.all<Size>(Size(150, 50))
                  ),
                      child: Text( translation(context).signUp),
                    ),
                  ),
                ],
              ),
            )
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
                  builder: (context) => LanguagePage(),
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