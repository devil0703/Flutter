import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/screens/auth/suspended_user.dart';
import 'package:makaiapp/screens/home/home_page.dart';
import 'package:makaiapp/services/authentication_service.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  final authService = Get.find<AuthService>();
  final bookingService = Get.find<BookingService>();

  void handleTimeout() async {
    // authService.signOut();
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await Preferences.setUserRole(VESSEL_USER);
        Get.offAll(() => HomePage());
      } else {
        MY_ROLE = await Preferences.getUserRole();
        await userService.getCurrentUser();
        await userService.registerFirebase();
        if (userController.currentUser.value.stripeCustomerID == '')
          await userService.updateUser(
            {
              'stripeCustomerID': await bookingService.createCustomer(
                userController.currentUser.value.email?? "blank",
                userController.currentUser.value.fullName ?? "blank",
              ),
            },
          );
        if (userController.currentUser.value.status == 'Active')
          Get.offAll(() => HomePage());
        else
          Get.offAll(() => SuspendedUser());
      }
    } catch (e) {
      authService.signOut();
    }
  }

  startTimeout() async {
    var duration = const Duration(seconds: 1);
    return new Timer(duration, handleTimeout);
  }

  @override
  void initState() {
    super.initState();
    startTimeout();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, systemOverlayStyle: SystemUiOverlayStyle.dark),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(50),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 75),
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/makailogo.png',
                height: MediaQuery.of(context).size.height * 0.2,
              ),
            ),
            LinearProgressIndicator(color: primaryColor),
          ],
        ),
      ),
    );
  }
}
