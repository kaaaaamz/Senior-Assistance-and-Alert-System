import 'package:authtest/langconsts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
class ElderLocationPage extends StatefulWidget {
  final GeoPoint location;

  ElderLocationPage({required this.location});

  @override
  State<ElderLocationPage> createState() => _ElderLocationPageState();
}

class _ElderLocationPageState extends State<ElderLocationPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late LatLng _currentLocation;
  // List polyLineCoordinates = [];

   String googleAPiKey = "AIzaSyCElE4fajhl-2VsH2lfw_9XNMGNZexbBiY";
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // getPoly(); 
  }
  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('elder-location'),
          position: LatLng(widget.location.latitude, widget.location.longitude),
        ),
      );
    });
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId('user-location'),
          position: _currentLocation,
        ),
      );
      _polylines.add(
        Polyline(
          polylineId: PolylineId('doctor-to-elder'),
          color: Colors.blue,
          width: 5,
          points: [
            LatLng(position.latitude, position.longitude),
            LatLng(widget.location.latitude, widget.location.longitude),
          ],
        ),
      );
    });

    // Zoom to fit both markers and polyline on the map
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(position.latitude, position.longitude),
      northeast: LatLng(widget.location.latitude, widget.location.longitude),
    );
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
  List<LatLng> polyLineCoordinates = [];

  // void getPoly() async{
  //   PolylinePoints polylinepoints= PolylinePoints();
  //   PolylineResult result = await polylinepoints.getRouteBetweenCoordinates(
  //     googleAPiKey,
  //     PointLatLng(_currentLocation.latitude,_currentLocation.longitude), 
  //     PointLatLng(widget.location.latitude, widget.location.longitude),
  //   );

  //   if(result.points.isNotEmpty){
  //     result.points.forEach((PointLatLng point) => polyLineCoordinates.add(LatLng(point.latitude, point.longitude))); 
  //     setState(() {
  //     _polylines.add(
  //       Polyline(
  //         polylineId: PolylineId('doctor-to-elder'),
  //         color: Colors.blue,
  //         width: 5,
  //         points: polyLineCoordinates,
  //       ),
  //     );
  //   });                      
  //   }
  // }
  @override
 Widget build(BuildContext context) {
  return Scaffold(
    // appBar: AppBar(
    //   title: Text('Elder Location'),
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
        child: GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.location.latitude, widget.location.longitude),
        zoom: 15,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    ),
          ),
  ),
      Positioned(
        top: 33,
        left: 0,
        child: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
  ]
  ),
    floatingActionButton: Container(
      
      margin: EdgeInsets.only(right: 130),
      child: FloatingActionButton.extended(
        backgroundColor: Color.fromRGBO(43, 52, 103, 1),
        onPressed: () async{
          final Uri url = Uri(
            scheme:'tel' ,
            path:"16"
          );
          if(await canLaunchUrl(url)){
            await launchUrl(url);
          } else{
            print('cannot launch');
          }
        },
        label: Text(translation(context).callamb),
      ),
    ),
  );
}
}
