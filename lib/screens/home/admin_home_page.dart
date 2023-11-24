import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart' as u;
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/home/all_bookings.dart';
import 'package:makaiapp/screens/home/notifications.dart';
import 'package:makaiapp/screens/vessels/add_vessel.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/vessel_item.dart';
import 'package:passbase_flutter/passbase_flutter.dart';

class AdminHomePage extends StatelessWidget {
  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: InkWell(
            onLongPress: () {
              if (FirebaseAuth.instance.currentUser!.email == 'ujwalchordiya@gmail.com') adminControls(context);
            },
            child: Text('MY VESSELS'),
          ),
          actions: [
            Obx(
              () => IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Stack(
                    children: [
                      Center(child: Icon(Icons.notifications_none_outlined)),
                      if (userController.currentUser.value.unreadNotifications ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Align(alignment: Alignment.topCenter, child: CircleAvatar(radius: 5, backgroundColor: redColor)),
                        ),
                    ],
                  ),
                  onPressed: () async {
                    Get.to(() => Notifications());
                    userController.currentUser.value.unreadNotifications = false;
                    await userService.updateUser({'unreadNotifications': false});
                  }),
            ),
            SizedBox(width: 15),
          ],
        ),
        body: Column(
          children: [
            Container(margin: const EdgeInsets.only(bottom: 15), color: Colors.white, padding: const EdgeInsets.all(15), width: double.infinity, alignment: Alignment.center, child: Text('Logged in as - $MY_ROLE', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold))),
            if (MY_ROLE == VESSEL_OWNER && userController.currentUser.value.verification == 'approved')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomListTile(
                  marginBottom: 15,
                  backgroundColor: Colors.white,
                  leading: Icon(Icons.add, color: primaryColor),
                  title: Text('Add your vessel'),
                  onTap: () => Get.to(() => AddVessel()),
                ),
              ),
            if (userController.currentUser.value.verification != 'approved')
              Column(
                children: [
                  Text('Want to add your own vessel? \nComplete your verification now and start adding.', textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  PassbaseButton(
                    onStart: () {
                      debugPrint('VERIFICATION STARTED');
                      Get.back();
                    },
                    onFinish: (String identityAccessKey) async {
                      debugPrint('VERIFICATION FINISHED');
                      debugPrint(identityAccessKey);
                      await userService.updateUser({'identityAccessKey': identityAccessKey, 'verification': 'pending'});
                      showYellowAlert('Profile submitted for verification. You will be notified when you are approved.');
                    },
                    onSubmitted: (String identityAccessKey) async {
                      debugPrint('VERIFICATION SUBMITTED');
                      debugPrint(identityAccessKey);
                      await userService.updateUser({'identityAccessKey': identityAccessKey, 'verification': 'pending'});
                      showYellowAlert('Profile submitted for verification. You will be notified when you are approved.');
                    },
                    onError: (errorCode) async {
                      debugPrint('VERIFICATION ERROR');
                      debugPrint(errorCode);
                      print(errorCode);
                      await userService.updateUser({'identityAccessKey': errorCode});
                    },
                    width: Get.width - 20,
                    height: 50,
                  ),
                  Divider(height: 50),
                ],
              ),
            Expanded(
              child: FutureBuilder(
                builder: (context, snapshot) {
                  return buildList(snapshot.data as String);
                },
                future: Preferences.getUserRole(),
              ),
            ),
          ],
        ));
  }

  buildList(String userType) {
    List<dynamic> vessels = [];
    switch (MY_ROLE) {
      case VESSEL_OWNER:
        vessels = userController.currentUser.value.owners!;
        break;
      case VESSEL_CAPTAIN:
        vessels = userController.currentUser.value.captains!;
        break;
      case VESSEL_CREW:
        vessels = userController.currentUser.value.crew!;
        break;
    }
    
    return vessels.isEmpty
        ? EmptyBox(text: 'No vessels to show')
        : SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomListTile(
                    marginBottom: 15,
                    leading: Icon(Icons.directions_boat_outlined),
                    title: Text('Manage Bookings'),
                    onTap: () => Get.to(() => AllBookings()),
                  ),
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
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
                ),
              ],
            ),
          );
  }

  adminControls(BuildContext context) async {
    TextEditingController staffTEC = TextEditingController();
    Get.defaultDialog(
      title: 'Login As',
      content: CustomTextField(label: 'Enter Email', hint: 'Enter email', controller: staffTEC, maxLines: 1, validate: true, isEmail: false, textInputType: TextInputType.emailAddress),
      actions: [
        ElevatedButton(
            onPressed: () async {
              final userService = Get.find<UserService>();

              Get.back();
              showGreenAlert('Please wait...');
              String mobile = staffTEC.text.trim();
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: mobile).get();
              if (querySnapshot.docs.isNotEmpty) {
                userController.currentUser.value = u.User.fromDocument(querySnapshot.docs[0]);
                await Preferences.setUser(userController.currentUser.value.userID ?? "");
                await userService.getCurrentUser();
                Get.back();
                showGreenAlert('You are now logged in as ' + userController.currentUser.value.fullName!);
              } else {
                Get.back();
                showRedAlert('User does not exist. Please check the mobile number');
              }
            },
            child: Text('Login', textScaleFactor: 1)),
        TextButton(onPressed: () => Get.back(), child: Text('Cancel', textScaleFactor: 1)),
      ],
    );
  }
}
