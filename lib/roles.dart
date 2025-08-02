import 'package:authtest/langconsts.dart';
import 'package:authtest/langpage.dart';
import 'package:authtest/register.dart';
import 'package:authtest/welcome.dart';
import 'package:flutter/material.dart';
class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRoleCard(
              context,
              translation(context).assistant,
              translation(context).assistantDiscp,
              AssetImage('assets/icons/assistant.png'),
              Color.fromRGBO(169, 205, 241, 1),
            ),
            _buildRoleCard(
              context,
              translation(context).doctor,
              translation(context).doctorDiscp,
              AssetImage('assets/icons/doctor.png'),
              Color.fromRGBO(91, 142, 190, 1),
            ),
            _buildRoleCard(
              context,
              translation(context).elderly,
              translation(context).elderlyDiscp,
              AssetImage('assets/icons/elderly.png'),
              Color.fromRGBO(34, 73, 116, 1),
            ),
          ],
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

  Widget _buildRoleCard(BuildContext context, String roleName,
      String description, ImageProvider  icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _navigateToRegistrationPage(context, roleName),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Image(
              image: icon,
              color: Colors.white.withOpacity(0.7),
              height: 48.0,
              width: 48.0,
            ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      roleName,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _navigateToRegistrationPage(BuildContext context, String roleName) {
    if (roleName == 'elderly') {
      roleName = 'elder';
    }
    if (roleName == 'caregiver') {
      roleName = 'assistant';
    }
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Register(roleName: roleName),
      ),
    );
  }
}
