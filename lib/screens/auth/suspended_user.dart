import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/services/authentication_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';

class SuspendedUser extends StatelessWidget {
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  final authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Image.asset('assets/images/makai.png', width: MediaQuery.of(context).size.width * 0.3),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your account has been ${userController.currentUser.value.status}. \n\nPlease contact us to know more.', textScaleFactor: 1.25, textAlign: TextAlign.center),
            SizedBox(height: 25),
            CustomListTile(
              backgroundColor: Colors.white,
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
          ],
        ),
      ),
    );
  }
}
