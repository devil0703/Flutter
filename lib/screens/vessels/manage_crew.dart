import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/crew_item.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';

class ManageCrew extends StatelessWidget {
  final Vessel vessel;

  ManageCrew({required this.vessel});

  final vesselsService = Get.find<VesselService>();
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CREW MEMBERS')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TabBar(
                      indicatorColor: primaryColor,
                      isScrollable: false,
                      tabs: [
                        Tab(text: VESSEL_CAPTAIN),
                        Tab(text: VESSEL_CREW),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        viewMembers(VESSEL_CAPTAIN),
                        viewMembers(VESSEL_CREW),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: CustomButton(
                color: primaryColor,
                text: 'Add a Crew Member',
                function: () => addMember(context),
              ),
            ),
        ],
      ),
    );
  }

  viewMembers(String type) {
    return StreamBuilder(
      stream: getQuery(type),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData)
          return snapshot.data!.docs.length > 0
              ? ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    DocumentSnapshot doc = snapshot.data!.docs[i];
                    User user = User.fromDocument(doc);
                    return CrewItem(user: user, vesselID: vessel.vesselID!);
                  },
                )
              : EmptyBox(text: 'No one added yet');
        else
          return LoadingData();
      },
    );
  }

  getQuery(String type) {
    switch (type) {
      case 'Captain':
        return vesselsService.getVesselCaptainsStream(vessel.vesselID!);
      case 'Crew':
        return vesselsService.getVesselCrew(vessel.vesselID!);
    }
  }

  addMember(context) async {
    bool check = true; //await vesselsService.checkIfVesselHasCertificates(vessel.vesselID);
    if (check) {
      String? staffType = 'Crew';
      TextEditingController staffTEC = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add a Crew Member', textScaleFactor: 1.25),
                    CustomTextField(
                      label: 'Email address',
                      hint: 'Enter email address',
                      labelColor: primaryColor,
                      controller: staffTEC,
                      validate: true,
                      isEmail: true,
                      textInputType: TextInputType.emailAddress,
                    ),
                    ExpansionTile(
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      childrenPadding: const EdgeInsets.only(bottom: 20, left: 25),
                      expandedAlignment: Alignment.centerLeft,
                      leading: Radio(
                        value: 'Captain',
                        groupValue: staffType,
                        onChanged: (value) {
                          setState(() {
                            staffType = value as String?;
                          });
                        },
                      ),
                      title: Text('Captain'),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        Text('- Manage vessel details', textScaleFactor: 0.85, style: TextStyle(color: Colors.grey)),
                        Text('- Manage reservations', textScaleFactor: 0.85, style: TextStyle(color: Colors.grey)),
                        Text('- Manage Crew', textScaleFactor: 0.85, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    ExpansionTile(
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      childrenPadding: const EdgeInsets.only(bottom: 20, left: 25),
                      expandedAlignment: Alignment.centerLeft,
                      leading: Radio(
                        value: 'Crew',
                        groupValue: staffType,
                        onChanged: (value) {
                          setState(() {
                            staffType = value as String;
                          });
                        },
                      ),
                      title: Text('Crew'),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        Text('- View vessel details', textScaleFactor: 0.85, style: TextStyle(color: Colors.grey)),
                        Text('- View reservations', textScaleFactor: 0.85, style: TextStyle(color: Colors.grey)),
                        Text('- View Crew', textScaleFactor: 0.85, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(child: ElevatedButton(onPressed: () => Get.back(), child: Text('Cancel'))),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () async {
                                dialogService.showLoading();
                                String mobile = staffTEC.text.trim();
                                if (staffType == 'Crew') await vesselsService.addCrew(mobile, vessel.vesselID!);
                                if (staffType == 'Captain') await vesselsService.addCaptains(mobile, vessel.vesselID!);
                              },
                              child: Text('Add')),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        },
      );
    } else
      showRedAlert('You need to add certificate/license to add crew/captain to the vessel');
  }
}
