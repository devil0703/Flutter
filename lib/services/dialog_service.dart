import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/loading.dart';

class DialogService {
  final userService = Get.find<UserService>();

  showLoading() {
    Get.defaultDialog(
      titlePadding: EdgeInsets.all(10),
      contentPadding: EdgeInsets.all(10),
      barrierDismissible: false,
      title: 'Please wait...',
      content: LoadingData(),
    );
  }

  showInfoDialog(String title, String description, bool closeScreen) {
    Get.defaultDialog(
      titlePadding: EdgeInsets.all(15),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      barrierDismissible: false,
      title: title,
      content: Text(description),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
              if (closeScreen) Get.back();
            },
            child: Text('Ok'))
      ],
    );
  }

  logout() {
    Get.defaultDialog(
      title: 'Logout',
      content: Text('Are you sure you want to logout?', textScaleFactor: 1),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel', textScaleFactor: 1)),
        TextButton(
            onPressed: () async {
              final u.FirebaseAuth auth = u.FirebaseAuth.instance;
              await auth.signOut();
              Get.back();

              Get.off(Login());
            },
            child: Text('Logout', textScaleFactor: 1)),
      ],
    );
  }

  showConfirmationDialog({String? title, String? contentText, String? confirmText, String? cancelText, Function? cancel, Function? confirm}) {
    Get.defaultDialog(
      title: title!,
      content: Text(contentText!),
      actions: [
        CustomButton(
            text: confirmText ?? 'Yes',
            color: primaryColor,
            function: () {
              if (confirm == null)
                Get.back();
              else
                confirm();
            }),
        CustomButton(
            text: cancelText ?? 'No',
            color: Colors.grey,
            function: () {
              if (cancel == null)
                Get.back();
              else
                cancel();
            }),
      ],
    );
  }
}
