import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/license_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/vessels/licenses/add_license.dart';
import 'package:makaiapp/screens/vessels/licenses/view_license.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/vessel_item.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class MyLicenses extends StatelessWidget {
  final String vesselID;

  MyLicenses({required this.vesselID});

  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('CAPTAIN\'S LICENSES')),
        body: Column(
          children: [
            if (MY_ROLE == VESSEL_OWNER)
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: CustomListTile(
                  marginBottom: 0,
                  leading: Icon(Icons.add),
                  title: Text('Add a New License'),
                  onTap: () async {
                    QuerySnapshot docs = await vesselService.getVesselCaptains(vesselID);
                    if (docs.docs.isEmpty)
                      showRedAlert('Please add a captain to the vessel before adding a license');
                    else
                      Get.to(() => AddLicense(vesselID: vesselID));
                  },
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
                  License certificate = License.fromDocument(documentSnapshot[i]);
                  return CustomListTile(
                    onTap: () => Get.to(() => ViewLicense(license: certificate)),
                    title: Text(certificate.licenseType!),
                    leading: Icon(Icons.verified_user_outlined),
                    trailing: Icon(Icons.keyboard_arrow_right_rounded),
                  );
                },
                query: vesselService.getVesselLicenses(vesselID, 5000),
                onEmpty: EmptyBox(text: 'No licenses to show'),
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
