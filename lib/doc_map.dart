import 'package:authtest/langconsts.dart';
import 'package:authtest/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DocMap extends StatefulWidget {
  const DocMap({super.key});

  @override
  State<DocMap> createState() => _DocMapState();
}

class _DocMapState extends State<DocMap> {
  late GoogleMapController googleMapController;
  
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> markers = {};

  // final List<Elder> eldersList = [
  //   Elder(name: "John", latitude: 36.7328, longitude: 3.0534),
  //   Elder(name: "Sarah", latitude: 36.7315, longitude: 3.1733),
  //   Elder(name: "Tom", latitude: 36.7656, longitude: 3.4701),
  // ];

    @override
  void initState() {
    super.initState();

    _addMarkers();
  }
Future<List<Elder>> getEldersListFromFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  final uid = user!.uid;

  final eldersRef = FirebaseFirestore.instance.collection('users').doc(uid).collection('elders');
  final eldersSnapshot = await eldersRef.get();

  List<Elder> eldersList = [];
  for (final doc in eldersSnapshot.docs) {
    final elderId = doc.id;
    final elderRef = FirebaseFirestore.instance.collection('users').doc(elderId);
    final elderDoc = await elderRef.get();
    final elder = Elder(
      name: doc.data()['name'],
      location: elderDoc.data()?['location'],
    );
    eldersList.add(elder);
  }

  return eldersList;
}
 Future<void> _addMarkers() async {
    Position position = await _determinePosition();

    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 14)));

    markers.clear();

    // markers.add(Marker(
    //     markerId: const MarkerId('currentLocation'),
    //     position: LatLng(position.latitude, position.longitude)));

    List<Elder> eldersList = await getEldersListFromFirestore();
    for (Elder elder in eldersList) {
      markers.add(
        Marker(
          markerId: MarkerId(elder.name),
          position: LatLng(elder.location.latitude, elder.location.longitude),
          infoWindow: InfoWindow(title: elder.name),
        ),
      );
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          zoomControlsEnabled: true, 
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
          },
        ),
      ),
  ),
      Positioned(
        top: 33,
        left: 0,
        child: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black),
          onPressed: ()  {
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
class Elder {
  final String name;
  final GeoPoint location;

  Elder({required this.name, required this.location});

  factory Elder.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Elder(
      name: data['name'],
      location: data['location'],
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