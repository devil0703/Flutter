import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/certificate_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/vessels/certificates/add_certificate.dart';
import 'package:makaiapp/screens/vessels/certificates/view_certificate.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/vessel_item.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class MyCertificates extends StatelessWidget {
  final String vesselID;

  MyCertificates({required this.vesselID});

  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('VESSEL CERTIFICATES')),
        body: Column(
          children: [
            if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: CustomListTile(
                  marginBottom: 0,
                  leading: Icon(Icons.add),
                  title: Text('Add a New Certificate'),
                  onTap: () => Get.to(() => AddCertificate(vesselID: '',)),
                ),
              ),
            SizedBox(height: 15),
            Expanded(
              child: PaginateFirestore(
                isLive: true,
                key: GlobalKey(),
                padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, documentSnapshot, i) {
                  Certificate certificate = Certificate.fromDocument(documentSnapshot[i]);
                  return CustomListTile(
                    onTap: () => Get.to(() => ViewCertificate(certificate: certificate)),
                    title: Text(certificate.certificateType!),
                    leading: Icon(Icons.verified_user_outlined),
                    trailing: Icon(Icons.keyboard_arrow_right_rounded),
                  );
                },
                query: vesselService.getVesselCertificates(vesselID, 5000),
                onEmpty: EmptyBox(text: 'No certificates to show'),
                itemsPerPage: 10,
                bottomLoader: LoadingData(),
                initialLoader: LoadingData(),
              ),
            ),
          ],
        ));
  }

  buildList(List vessels, int userType) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      itemCount: vessels.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        return StreamBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Vessel vessel = Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
              return VesselItem(vessel: vessel);
            } else
              return Container();
          },
          stream: vesselService.getVesselForVesselIDStream(vessels[i]),
        );
      },
    );
  }
}
