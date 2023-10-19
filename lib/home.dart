import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> marker = {};
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription!.cancel();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS'),
        centerTitle: true,
      ),
      body: locationData == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.hybrid,
              markers: marker,
              onTap: (argument) {
                marker
                    .add(Marker(markerId: MarkerId("New"), position: argument));
                setState(() {});
              },
              initialCameraPosition: currentLocation,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }

  Future<void> updateMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            zoom: 18,
            target:
                LatLng(locationData!.latitude!, locationData!.longitude!))));
  }

  Location location = Location();
  PermissionStatus? permissionStatus;
  bool isServiceEnable = false;
  LocationData? locationData;
  StreamSubscription<LocationData>? subscription;
  CameraPosition currentLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void getCurrentLocation() async {
    bool permission = await isPermissionGranted();
    if (!permission) {
      return;
    }
    bool service = await isServiceEnabled();
    if (!service) {
      return;
    }

    locationData = await location.getLocation();
    marker.add(Marker(
        markerId: MarkerId("my location"),
        position: LatLng(locationData!.latitude!, locationData!.longitude!)));
    currentLocation = CameraPosition(
      target: LatLng(locationData!.latitude!, locationData!.longitude!),
      zoom: 18.4746,
    );
    subscription = location.onLocationChanged.listen((event) {
      locationData = event;
      marker.add(Marker(
          markerId: MarkerId("my location"),
          position: LatLng(event.latitude!, event.longitude!)));
      setState(() {});
      updateMyLocation();

      print("lat:${locationData!.latitude},long:${locationData!.longitude}");
    });
    location.changeSettings(accuracy: LocationAccuracy.high);
    setState(() {});
  }

  Future<bool> isServiceEnabled() async {
    isServiceEnable = await location.serviceEnabled();
    if (!isServiceEnable) {
      isServiceEnable = await location.requestService();
    }
    return isServiceEnable;
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    }
    return permissionStatus == PermissionStatus.granted;
  }

//AIzaSyA8rOV72gGSV3tcPGjO12hbVGiWkCqELfo
}
