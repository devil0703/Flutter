import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/screens/home/notifications.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';

import '../models/users_model.dart';

class NotificationIcon extends StatefulWidget {
  NotificationIcon(); //check this and compare if get error

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();

  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // executes after build
    });
  }

  @override
  Widget build(BuildContext context) {
    if (auth.FirebaseAuth.instance.currentUser == null) {
      return IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: const Center(child: Icon(Icons.notifications_none_outlined)),
        onPressed: () => Get.offAll(() => Login()),
      );
    } else {
      return StreamBuilder(
        stream: userService.getUserStream(userController.currentUser.value.userID),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          User user = userController.currentUser.value;
          if (snapshot.hasData) {
            //userController.currentUser.value = User.fromDocument(snapshot.data);
            user = User.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
          }
          return IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: Stack(
              children: [
                const Center(child: Icon(Icons.notifications_none_outlined)),
                if (user.unreadNotifications ?? false)
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
            },
          );
        },
      );
    }
  }
}
