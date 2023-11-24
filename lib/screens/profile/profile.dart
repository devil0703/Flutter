import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/seat_model.dart';
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/screens/bookings/my_bookings.dart';
import 'package:makaiapp/screens/home/home_page.dart';
import 'package:makaiapp/screens/home/notification_settings.dart';
import 'package:makaiapp/screens/home/notifications.dart';
import 'package:makaiapp/screens/profile/banking_details.dart';
import 'package:makaiapp/screens/profile/customer_support.dart';
import 'package:makaiapp/screens/profile/edit_profile.dart';
import 'package:makaiapp/screens/profile/list_cards.dart';
import 'package:makaiapp/screens/profile/more.dart';
import 'package:makaiapp/screens/vessels/add_vessel.dart';
import 'package:makaiapp/services/authentication_service.dart';
import 'package:makaiapp/services/cloud_function.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:passbase_flutter/passbase_flutter.dart';
import 'package:share/share.dart';
import 'package:store_launcher_nullsafe/store_launcher_nullsafe.dart';

class Profile extends StatelessWidget {
  final userController = Get.find<UserController>();
  final authService = Get.find<AuthService>();
  final userService = Get.find<UserService>();
  final storageService = Get.find<StorageService>();

  //String userType = 'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PROFILE'),
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
                  if (FirebaseAuth.instance.currentUser == null)
                    Get.offAll(() => Login());
                  else {
                    Get.to(() => Notifications());
                    userController.currentUser.value.unreadNotifications = false;
                    await userService.updateUser({'unreadNotifications': false});
                  }
                }),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          if (MY_ROLE != VESSEL_USER) Container(color: Colors.white, padding: const EdgeInsets.all(15), width: double.infinity, alignment: Alignment.center, child: Text('Logged in as - $MY_ROLE', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold))),
          Expanded(
            child: Obx(
              () {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            CachedImage(
                              roundedCorners: true,
                              url: userController.currentUser.value.photoURL ?? '',
                              height: MediaQuery.of(context).size.height * 0.15,
                              circular: false,
                            ),
                            InkWell(
                              onTap: () async {
                                File image = await storageService.pickImage();
                                showYellowAlert('Uploading image');
                                String url = await storageService.uploadPhoto(image, 'profile');
                                await userService.updateUser({
                                  'photoURL': url,
                                  'updatedDate': Timestamp.now(),
                                });
                                                            },
                              child: Container(
                                width: MediaQuery.of(context).size.height * 0.15,
                                height: MediaQuery.of(context).size.height * 0.15,
                                padding: const EdgeInsets.all(5),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(Icons.camera_alt, color: primaryColor, size: 20),
                                  ),
                                ),
                              ),
                            ),
                            if (userController.currentUser.value.photoURL != 'profile')
                              InkWell(
                                onTap: () {
                                  Get.defaultDialog(
                                    title: 'Remove Photo?',
                                    content: Text('Do you want to remove your profile photo?'),
                                    confirm: Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: ElevatedButton(onPressed: () => Get.back(), child: Text('Cancel')),
                                    ),
                                    cancel: ElevatedButton(
                                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(redColor)),
                                        onPressed: () async {
                                          await userService.updateUser({
                                            'photoURL': 'profile',
                                          });
                                          Get.back();
                                        },
                                        child: Text('Remove')),
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.height * 0.15,
                                  height: MediaQuery.of(context).size.height * 0.15,
                                  padding: const EdgeInsets.all(2),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 10,
                                      child: Icon(Icons.close, color: Colors.white, size: 15),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(userController.currentUser.value.fullName ?? '', textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          if (userController.currentUser.value.verification == 'approved') Icon(Icons.verified, color: Colors.green, size: 20),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(userController.currentUser.value.email ?? '', textScaleFactor: 0.9),
                      Divider(height: 50),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, bottom: 15),
                            child: Text('Logged in as :'),
                          )
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                        isExpanded: true,
                        style: TextStyle(color: primaryColor, fontSize: 17),
                        value: MY_ROLE,
                        items: [VESSEL_OWNER, VESSEL_CAPTAIN, VESSEL_CREW, VESSEL_USER].map((value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value, textScaleFactor: 1, style: TextStyle(color: Colors.black)));
                        }).toList(),
                        onChanged: (value) async {
                          MY_ROLE = value!;
                          await Preferences.setUserRole(MY_ROLE);
                          Get.offAll(() => HomePage());
                        },
                      ),
                      SizedBox(height: 15),
                      FutureBuilder(
                          future: Preferences.getBiometricStatus(),
                          builder: (context, snapshot) {
                            bool biometric = snapshot.data as bool;
                            RxBool value = biometric.obs;
                            return Obx(() {
                              return CustomListTile(
                                backgroundColor: Colors.white,
                                leading: Icon(Icons.lock_outline, color: primaryColor),
                                trailing: Switch(
                                  activeColor: primaryColor,
                                  value: value.value,
                                  onChanged: (val) async {
                                    await Preferences.setBiometricStatus(val);
                                    value.toggle();
                                  },
                                ),
                                title: Text('FaceID/Fingerprint'),
                              );
                            });
                          }),
                      // CustomListTile(
                      //   leading: Icon(Icons.person_outline, color: primaryColor),
                      //   title: Text('Edit Profile'),
                      //   onTap: () => Get.to(() => EditProfile(user: null,)),
                      // ),
                      if (MY_ROLE == VESSEL_USER)
                        CustomListTile(
                          leading: Icon(Icons.sticky_note_2_outlined, color: primaryColor),
                          title: Text('My Bookings'),
                          onTap: () => Get.to(() => MyBookings()),
                        ),
                      CustomListTile(
                        leading: Icon(Icons.notifications_none_outlined, color: primaryColor),
                        title: Text('Notification Settings'),
                        onTap: () => Get.to(() => NotificationSettings()),
                      ),
                      if (MY_ROLE == VESSEL_OWNER)
                        CustomListTile(
                          leading: Icon(Icons.credit_card, color: primaryColor),
                          title: Text('Banking Details'),
                          onTap: () => Get.to(() => BankingDetails(user: userController.currentUser.value)),
                        ),
                      if (MY_ROLE == VESSEL_USER)
                        CustomListTile(
                          leading: Icon(Icons.credit_card, color: primaryColor),
                          title: Text('Cards'),
                          onTap: () => Get.to(() => ListCards()),
                        ),
                      // CustomListTile(
                      //   leading: Icon(Icons.credit_card, color: primaryColor),
                      //   title: Text('Verify'),
                      //   onTap: () async => await NotificationService().sendNotification(parameters: {'userID': userController.currentUser.value.userID}, type: 'verification', receiverUserID: userController.currentUser.value.userID, body: 'Test'),
                      // ),
                      if (userController.currentUser.value.verification == 'approved')
                        CustomListTile(
                          leading: Icon(Icons.add, color: primaryColor),
                          title: Text('Add your vessel'),
                          onTap: () {
                            PassbaseSDK.initialize(publishableApiKey: "cmKroKAccXWHuGIe4SlJ7OHz66TdIk5WBt0b309I8y98uNg5Sgi7ZoW9Qg6stCgK", customerPayload: '');
                            PassbaseSDK.prefillUserEmail = userController.currentUser.value.email;
                            if (userController.currentUser.value.verification == 'declined') return showRedAlert('Your verification has been declined. Please contact customer support');
                            if (userController.currentUser.value.verification == 'pending') return showYellowAlert('Your profile has been submitted for verification. You will be notified when you are approved.');
                            if (userController.currentUser.value.verification == 'approved') {
                              if (MY_ROLE == VESSEL_OWNER)
                                Get.to(() => AddVessel());
                              else
                                Get.snackbar('Owner login required', 'Must be logged in as Owner to add vessels', backgroundColor: Colors.amber, colorText: Colors.black, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
                            } else
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        title: Text('Verification required'),
                                        content: Text('You will have to verify your profile to add a vessel. Do you want to continue?'),
                                        actions: [
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
                                            // onSubmitted: (String identityAccessKey) async {
                                            //   debugPrint('VERIFICATION SUBMITTED');
                                            //   debugPrint(identityAccessKey);
                                            //   await userService.updateUser({'identityAccessKey': identityAccessKey, 'verification': 'pending'});
                                            //   showYellowAlert('Profile submitted for verification. You will be notified when you are approved.');
                                            // },
                                            onError: (errorCode) async {
                                              debugPrint('VERIFICATION ERROR');
                                              debugPrint(errorCode);
                                              print(errorCode);
                                              await userService.updateUser({'identityAccessKey': errorCode});
                                            },
                                            width: 300,
                                            height: 50,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: OutlinedButton(onPressed: () => Get.back(), child: Text('Cancel')),
                                            ),
                                          ),
                                        ],
                                      ));
                          },
                        ),
                      CustomListTile(
                        leading: Icon(Icons.rate_review_outlined, color: primaryColor),
                        title: Text('Rate Makai'),
                        onTap: () async => await StoreLauncher.openWithStore('com.makaiapp'),
                      ),
                      CustomListTile(
                        leading: Icon(Icons.share, color: primaryColor),
                        title: Text('Share Makai'),
                        onTap: () => Share.share('Download Makai from Play Store and App Store.'),
                      ),
                      CustomListTile(
                        leading: Icon(Icons.help_outline, color: primaryColor),
                        title: Text('Customer Support'),
                        onTap: () => Get.to(() => CustomerSupport()),
                      ),
                      // CustomListTile(
                      //   leading: Icon(Icons.list, color: primaryColor),
                      //   title: Text('More'),
                      //   onTap: () => Get.to(() => More(vessel: null,)),
                      //   marginBottom: 0,
                      // ),
                      Divider(height: 50),

                      if (userController.currentUser.value.verification != 'approved' && userController.currentUser.value.verification != 'pending')
                        Column(
                          children: [
                            Text(
                              userController.currentUser.value.verification == 'rejected' ? 'Your verification was rejected.\nWould you like to submit another verification?' : 'Want to add your own vessel? \nComplete your verification now and start adding.',
                              textAlign: TextAlign.center,
                            ),
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
                              width: double.infinity,
                              height: 50,
                            ),
                            Divider(height: 50),
                          ],
                        ),
                      if (userController.currentUser.value.verification == 'pending')
                        Column(
                          children: [
                            Text('Your verification is under process.', textScaleFactor: 1.25, style: TextStyle(color: Colors.orange)),
                            Divider(height: 50),
                          ],
                        ),
                      CustomListTile(
                        leading: Icon(Icons.login_outlined, color: redColor),
                        title: Text('Logout', style: TextStyle(color: redColor)),
                        onTap: () async {
                          Get.defaultDialog(
                            titlePadding: const EdgeInsets.only(top: 10),
                            contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
                            title: 'Logout',
                            content: Text('Are you sure you want to logout?'),
                            confirm: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ElevatedButton(onPressed: () => Get.back(), child: Text('Cancel')),
                            ),
                            cancel: ElevatedButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(redColor)),
                                onPressed: () async {
                                  MY_ROLE = 'User';
                                  dialogService.showLoading();
                                  await userService.updateUser({'token': ''});
                                  await Preferences.setUser('');
                                  await Preferences.setUserRole('User');
                                  await authService.signOut();
                                  Get.back();
                                  Get.offAll(Login());
                                },
                                child: Text('Logout')),
                          );
                        },
                      ),
                      CustomListTile(
                        leading: Icon(Icons.delete_forever, color: redColor),
                        title: Text('Delete Account', style: TextStyle(color: redColor)),
                        onTap: () async {
                          Get.defaultDialog(
                            titlePadding: const EdgeInsets.only(top: 10),
                            contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
                            title: 'Delete Account',
                            content: Text('Deleting your account will delete your profile data, bookings, saved vessels and your messages. You cannot undo this action.\n\nAre you sure you want to Delete your Account?'),
                            confirm: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ElevatedButton(onPressed: () => Get.back(), child: Text('Cancel')),
                            ),
                            cancel: ElevatedButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(redColor)),
                                onPressed: () async {
                                  await userService.updateUser({'token': '', 'status': 'Deleted', 'fullName': 'Deleted user :${userController.currentUser.value.fullName}'});
                                  await Preferences.setUser('');
                                  await Preferences.setUserRole(VESSEL_USER);
                                  await authService.signOut();
                                  Get.back();
                                  Get.offAll(() => Login());
                                },
                                child: Text('Delete Account')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
