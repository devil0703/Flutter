import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  getLocation() async {
    bool checkIfGranted = await requestLocationPermission();
    if (checkIfGranted) {
      await getLocation();
    } else {
      showPermissionSettingsDialog('This app needs Location access to show your nearby venues');
    }
  }

  getUserLocation() async {
    double lat = 51.509865;
    double long = -0.118092;
    var location = new loc.Location();
    bool enabled = await location.serviceEnabled();
    if (enabled) {
      try {
        loc.LocationData locationData = await location.getLocation();
        lat = locationData.latitude!;
        long = locationData.longitude!;
      } catch (e) {
        print(e);
      }
    } else {
      bool gotEnabled = await location.requestService();
      if (gotEnabled) {
        await getLocation();
      } else {
        getLocation();
      }
    }
  }

  requestLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isDenied) status = await Permission.camera.request();
    return status.isGranted;
  }

  showPermissionSettingsDialog(String description) {
    Get.defaultDialog(
      title: 'Permission required',
      content: Text(description),
      actions: <Widget>[
        TextButton(
          child: Text('Deny'),
          onPressed: () => Get.back(),
        ),
        TextButton(
          child: Text('Settings'),
          onPressed: () {
            Get.back();
            openAppSettings();
          },
        ),
      ],
    );
  }
}
