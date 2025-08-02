
import 'package:authtest/langconsts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentLoc extends StatefulWidget {
  const CurrentLoc({super.key});

  @override
  State<CurrentLoc> createState() => _CurrentLocState();
}
class _CurrentLocState extends State<CurrentLoc> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late GoogleMapController googleMapController;

  Set<Marker> markers = {};
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> userStream;
   String mapLanguage = "ar";
  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

void _setInitialLocation() async {
  Position position = await _determinePosition();
  final User? user = _auth.currentUser;
  googleMapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14,
      ),
    ),
  );

  markers.add(
    Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(position.latitude, position.longitude),
    ),
  );

  // Update the user's location in Firestore
  firestore.collection('users').doc(user!.uid).update({
    'location': GeoPoint(position.latitude, position.longitude),
  });

  // Listen for updates to the user's location in Firestore
  userStream = firestore.collection('users').doc(user.uid).snapshots();
  userStream.listen((documentSnapshot) {
    if (documentSnapshot.exists) {
      GeoPoint? location = documentSnapshot.data()?['location'];
      if (location != null) {
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(location.latitude, location.longitude),
          ),
        );
        setState(() {});
      }
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text("User current location"),
      //   centerTitle: true,
      // ),
      body: Stack(children: [Container(
    // padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 90),
      decoration: BoxDecoration(borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    )
    ),
    
    child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child:GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        markers: markers,        
        zoomControlsEnabled: true, 
        // myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        // language:mapLanguage,
        initialCameraPosition: initialCameraPosition,
      ),
      
      ),
  ),
      Positioned(
        top: 33,
        left: 0,
        child: IconButton(
          icon: Icon(Icons.arrow_back,color:  Color.fromRGBO(43, 52, 103, 0.8),),
          onPressed: () {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Do nothing and keep the current page open.
    }
  },
        ),
      ),
  ]
  )
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error(translation(context).locservdis);
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error(translation(context).locperden);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(translation(context).locperdenperma);
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}