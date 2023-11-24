import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/vessels/view_vessel.dart';
import 'package:makaiapp/services/location_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/loading.dart';

class MapView extends StatefulWidget {
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  final Completer<GoogleMapController> controller = Completer();
  final vesselService = Get.find<VesselService>();
  LatLng center = LatLng(25.7, -80.18);

  final Set<Marker> markers = new Set();

  Future getMarkers() async {
    QuerySnapshot vesselDocs = await vesselService.getVesselsOnMap();
    for (int j = 0; j < vesselDocs.docs.length; j++) {
      Vessel vessel = Vessel.fromDocument(vesselDocs.docs[j] as DocumentSnapshot<Map<String, dynamic>>);
      if (vessel.licensed! && vessel.captainLicensed!)
        markers.add(
          new Marker(
            visible: true,
            markerId: MarkerId((vesselDocs.docs.length + j).toString()),
            position: LatLng(vessel.geoPoint!.latitude, vessel.geoPoint!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(200),
            infoWindow: InfoWindow(
              onTap: () => Get.to(() => ViewVessel(false, vesselID: vessel.vesselID!)),
              title: vessel.vesselName,
              snippet: vessel.address,
            ),
          ),
        );
    }

    return true;
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        setState(() {});
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MAP VIEW', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder(
          future: LocationService().determinePosition(),
          builder: (context, AsyncSnapshot<Position> locSnapshot) {
            if (locSnapshot.hasData) {
              myLatitude = locSnapshot.data!.latitude;
              myLongitude = locSnapshot.data!.longitude;
              center = LatLng(myLatitude, myLongitude);
              return FutureBuilder(
                future: getMarkers(),
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(target: center, zoom: 10.0),
                      onMapCreated: (controller1) => controller.complete(controller1),
                      onCameraMove: (position) => null,
                      markers: markers,
                      myLocationEnabled: true,
                    );
                  else
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingData(),
                        Text('Loading...'),
                      ],
                    );
                },
              );
            }
            if (locSnapshot.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(locSnapshot.error.toString(), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      text: buttonText(locSnapshot),
                      function: () async {
                        if (locSnapshot.error == 'Location services are disabled.') await Geolocator.openLocationSettings();
                        if (locSnapshot.error == 'Location permissions are denied') await LocationService().determinePosition();
                        if (locSnapshot.error == 'Location permissions are permanently denied, we cannot request permissions.') await Geolocator.openAppSettings();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              );
            } else
              return GoogleMap(
                initialCameraPosition: CameraPosition(target: center, zoom: 10.0),
                onMapCreated: (controller1) => controller.complete(controller1),
                onCameraMove: (position) => null,
                markers: markers,
                myLocationEnabled: true,
                //myLocationEnabled: true,
              );
          }),
    );
  }

  buttonText(snapshot) {
    if (snapshot.error == 'Location services are disabled.') return 'Enable';
    if (snapshot.error == 'Location permissions are denied') return 'Request Again';
    if (snapshot.error == 'Location permissions are permanently denied, we cannot request permissions.') return 'Open Settings';
  }
}
