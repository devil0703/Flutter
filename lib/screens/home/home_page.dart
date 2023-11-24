import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/screens/bookings/my_bookings.dart';
import 'package:makaiapp/screens/home/admin_home_page.dart';
import 'package:makaiapp/screens/home/home.dart';
import 'package:makaiapp/screens/home/saved.dart';
import 'package:makaiapp/screens/messages/conversations.dart';
import 'package:makaiapp/screens/profile/profile.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';

class HomeController extends GetxController {
  var tabIndex = 0;
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();

  changeTabIndex(index) async {
    tabIndex = index;
    if (MY_ROLE == VESSEL_USER) {
      if (index == 3) {
        userController.currentUser.value.unreadMessages = false;
        userService.updateUser({'unreadMessages': false});
      }
    } else {
      if (index == 2) {
        userController.currentUser.value.unreadMessages = false;
        userService.updateUser({'unreadMessages': false});
      }
    }
    update();
  }
}

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (HomeController controller) {
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home_outlined, size: 20)),
              if (MY_ROLE == VESSEL_USER) BottomNavigationBarItem(label: 'Bookings', icon: Icon(Icons.calendar_today, size: 20)),
              if (MY_ROLE == VESSEL_USER) BottomNavigationBarItem(label: 'Saved', icon: Icon(FontAwesomeIcons.heart, size: 20)),
              if (MY_ROLE != VESSEL_CREW)
                BottomNavigationBarItem(
                  label: 'Messages',
                  icon: Stack(
                    children: [
                      if (FirebaseAuth.instance.currentUser != null)
                        Obx(() {
                          if (userController.currentUser.value.unreadMessages!)
                            return Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: CircleAvatar(radius: 5, backgroundColor: redColor),
                                ));
                          else
                            return Container();
                        }),
                      Center(child: Icon(FontAwesomeIcons.comment, size: 20)),
                    ],
                  ),
                ),
              // BottomNavigationBarItem(
              //   label: 'Messages',
              //   icon: Obx(
              //     () => Stack(
              //       //mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Center(child: Icon(Icons.messenger_outline, size: 20)),
              //         // if (userController.currentUser.value.unreadMessages)
              //         //   Align(
              //         //       alignment: Alignment.topRight,
              //         //       child: Padding(
              //         //         padding: const EdgeInsets.only(right: 12),
              //         //         child: CircleAvatar(radius: 5, backgroundColor: redColor),
              //         //       )),
              //       ],
              //     ),
              //   ),
              // ),
              BottomNavigationBarItem(label: 'Account', icon: Icon(Icons.person_outline, size: 20)),
            ],
            currentIndex: controller.tabIndex,
            onTap: (demo) {
              if (FirebaseAuth.instance.currentUser == null)
                Get.offAll(() => Login());
              else
                controller.changeTabIndex(demo);
            },
          ),
          body: IndexedStack(
            children: [
              MY_ROLE == VESSEL_USER ? Home() : AdminHomePage(),
              if (MY_ROLE == VESSEL_USER) MyBookings(),
              if (MY_ROLE == VESSEL_USER) Saved(),
              if (MY_ROLE != VESSEL_CREW) Conversations(),
              Profile(),
            ],
            index: controller.tabIndex,
          ),
        );
      },
    );
  }
}
