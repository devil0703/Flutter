import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/bookings/manage_bookings.dart';
import 'package:makaiapp/screens/home/home_page.dart';
import 'package:makaiapp/screens/profile/reports.dart';
import 'package:makaiapp/screens/vessels/certificates/my_certificates.dart';
import 'package:makaiapp/screens/vessels/edit_vessel.dart';
import 'package:makaiapp/screens/vessels/licenses/my_licenses.dart';
import 'package:makaiapp/screens/vessels/manage_crew.dart';
import 'package:makaiapp/screens/vessels/premade_trips.dart';
import 'package:makaiapp/services/cloud_function.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class ManageVessels extends StatelessWidget {
  final Vessel vessel;

  ManageVessels({required this.vessel});

  final userController = Get.find<UserController>();
  final vesselService = Get.find<VesselService>();
  final userService = Get.find<UserService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MANAGE VESSEL')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          children: [
            if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
              CustomListTile(
                leading: Icon(FontAwesomeIcons.penToSquare, color: primaryColor, size: 20),
                title: Text('Edit Vessel'),
                onTap: () => Get.to(() => EditVessel(vessel: vessel)),
              ),
            if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
              CustomListTile(
                leading: Icon(Icons.calendar_today, color: primaryColor),
                title: Text('Pre-made Trips'),
                onTap: () => Get.to(() => PreMadeTrips(vesselID: vessel.vesselID!)),
              ),
            CustomListTile(
              leading: Icon(Icons.directions_boat_outlined, color: primaryColor),
              title: Text('Bookings'),
              onTap: () => Get.to(() => ManageBookings(vessel: vessel)),
            ),
            if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
              CustomListTile(
                leading: Icon(Icons.sticky_note_2_outlined, color: primaryColor),
                title: Text('Reports'),
                onTap: () => Get.to(() => Reports(vesselID: vessel.vesselID!)),
              ),
            CustomListTile(
              leading: Icon(Icons.account_box_outlined, color: primaryColor),
              title: Text('Crew Members'),
              onTap: () => Get.to(() => ManageCrew(vessel: vessel)),
            ),
            CustomListTile(
              leading: Icon(Icons.account_balance_wallet_outlined, color: primaryColor),
              title: Text('Certificates'),
              onTap: () => Get.to(() => MyCertificates(vesselID: vessel.vesselID!)),
            ),
            CustomListTile(
              leading: Icon(Icons.credit_card, color: primaryColor),
              title: Text('Licenses'),
              onTap: () => Get.to(() => MyLicenses(vesselID: vessel.vesselID!)),
            ),
            if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
              vessel.disabledUntil == null
                  ? CustomListTile(
                      leading: Icon(Icons.delete_forever, color: redColor),
                      title: Text('Disable Vessel', style: TextStyle(color: redColor)),
                      onTap: () {
                        Get.defaultDialog(
                          titlePadding: const EdgeInsets.only(top: 10),
                          contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                          title: 'Disable',
                          content: Column(
                            children: [
                              Text('Are you sure you want to disable this vessel?'),
                              SizedBox(height: 15),
                              ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    DatePicker.showDatePicker(
                                      context,
                                      showTitleActions: true,
                                      minTime: DateTime(2000),
                                      maxTime: DateTime(2100),
                                      onChanged: (date) {},
                                      onConfirm: (date) async {
                                        dialogService.showLoading();
                                        await vesselService.disableVessel(vessel.vesselID!, Timestamp.fromDate(date));
                                        Get.back();
                                        Get.back();
                                        showGreenAlert('Vessel disabled');
                                      },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en,
                                    );
                                  },
                                  child: Text('Disable until..')),
                              SizedBox(height: 10),
                              ElevatedButton(
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(redColor)),
                                  onPressed: () async {
                                    Get.back();
                                    dialogService.showLoading();
                                    await vesselService.disableVessel(vessel.vesselID!, Timestamp.fromDate(DateTime(2100)));
                                    Get.back();
                                    Get.back();
                                    showGreenAlert('Vessel disabled permanently');
                                  },
                                  child: Text('Disable Permanently')),
                              SizedBox(height: 10),
                              ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueGrey)), onPressed: () => Get.back(), child: Text('Cancel')),
                            ],
                          ),
                        );
                      },
                    )
                  : CustomListTile(
                      leading: Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
                      title: Text('Enable Vessel', style: TextStyle(color: Colors.green)),
                      onTap: () async {
                        dialogService.showLoading();
                        await vesselService.enableVessel(vessel.vesselID!);
                        Get.back();
                        Get.back();
                        showGreenAlert('Vessel enabled');
                      },
                    ),
            StreamBuilder(
                stream: userService.getUserStream(vessel.vesselChatUserID),
                builder: (context, snapshot) {
                  print(vessel.vesselChatUserID);
                  if (snapshot.hasData) {
                    User user = User.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
                    return ListTile(
                      onTap: () async {
                        TextEditingController emailTEC = TextEditingController();
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
                                      Text('Add a Contact Person', textScaleFactor: 1.25),
                                      CustomTextField(
                                        label: 'Email address',
                                        hint: 'Enter email address',
                                        labelColor: primaryColor,
                                        controller: emailTEC,
                                        validate: true,
                                        isEmail: true,
                                        textInputType: TextInputType.emailAddress,
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
                                                  String email = emailTEC.text.trim();
                                                  User? user = await userService.getUserFromEmail(email);
                                                  if (user == null) {
                                                    Get.back();
                                                    showRedAlert('User with this email does not exist');
                                                  } else {
                                                    Vessel updatedVessel = vessel;
                                                    updatedVessel.vesselChatUserID = user.userID;
                                                    await vesselService.editVessel(vessel);
                                                    Get.offAll(() => HomePage());
                                                  }
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
                      },
                      dense: true,
                      leading: Icon(Icons.lightbulb, color: Colors.amber),
                      title: RichText(
                        text: TextSpan(
                          text: 'All the messages from the users for this vessel are received by:  ',
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: user.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      //  title: Text('${user.fullName}.', textScaleFactor: 1.1),
                      subtitle: Text('Click to change the contact person', textScaleFactor: 1.2),
                    );
                  } else
                    return Container();
                })
          ],
        ),
      ),
    );
  }
}
