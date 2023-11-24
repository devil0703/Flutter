import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/screens/vessels/view_vessel.dart';
import 'package:makaiapp/widgets/cached_image.dart';

class DisplaySearchResult extends StatelessWidget {
  final String? vesselID;
  final String? vesselName;
  final List? images;

  DisplaySearchResult({ this.vesselName, this.vesselID, this.images});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => ViewVessel(false, vesselID: vesselID!)),
      child: Row(children: <Widget>[
        CachedImage(url: images![0], height: 50, circular: true),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            vesselName ?? "",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ]),
    );
  }
}
