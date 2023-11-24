import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/vessel_item.dart';

class Saved extends StatelessWidget {
  final vesselService = Get.find<VesselService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SAVED')),
      body: StreamBuilder(
        stream: vesselService.getSavedVessels(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.docs.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(15),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, i) {
                      return FutureBuilder(
                        future: vesselService.getVesselForVesselID(snapshot.data!.docs[i].get('vesselID')),
                        builder: (context, vesselData) {
                          if (vesselData.hasData)
                            return VesselItem(vessel: Vessel.fromDocument(vesselData.data as DocumentSnapshot<Map<String, dynamic>>));
                          else
                            return Container();
                        },
                      );
                    },
                  )
                : EmptyBox(text: 'No vessels to show');
          } else
            return LoadingData();
        },
      ),
    );
  }
}
