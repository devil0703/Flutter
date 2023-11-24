import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';

class SavedButton extends StatelessWidget {
  final String? vesselID;

  SavedButton({this.vesselID});

  final vesselService = Get.find<VesselService>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: vesselService.getVesselSavedStatus(vesselID!),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData)
          return IconButton(
            onPressed: () async {
              snapshot.data!.exists ? await vesselService.unSaveVessel(vesselID!) : await vesselService.saveVessel(vesselID!);
            },
            icon: Icon(
              snapshot.data!.exists ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: !snapshot.data!.exists ? Colors.white54 : redColor,
              size: 20,
            ),
          );
        else
          return Container();
      },
    );
  }
}
