import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';

class NotificationSettings extends StatefulWidget {
  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  RxBool bookingNotifications = true.obs;
  RxBool messageNotifications = true.obs;
  RxBool generalNotifications = true.obs;
  RxBool transactionNotifications = true.obs;

  final userController = Get.find<UserController>();

  @override
  void initState() {
    bookingNotifications.value = userController.currentUser.value.bookingNotifications!;
    messageNotifications.value = userController.currentUser.value.messageNotifications!;
    generalNotifications.value = userController.currentUser.value.generalNotifications!;
    transactionNotifications.value = userController.currentUser.value.transactionNotifications!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NOTIFICATION SETTINGS')),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              CustomListTile(
                leading: Icon(Icons.help_outline),
                title: Text('General'),
                trailing: Switch(value: generalNotifications.value, onChanged: (value) => generalNotifications.value = value, activeColor: primaryColor),
              ),
              CustomListTile(
                leading: Icon(FontAwesomeIcons.comment, size: 20),
                title: Text('Messages'),
                trailing: Switch(value: messageNotifications.value, onChanged: (value) => messageNotifications.value = value, activeColor: primaryColor),
              ),
              CustomListTile(
                leading: Icon(Icons.sticky_note_2_outlined),
                title: Text('Booking Status'),
                trailing: Switch(value: bookingNotifications.value, onChanged: (value) => bookingNotifications.value = value, activeColor: primaryColor),
              ),
              CustomListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Transactions'),
                trailing: Switch(value: transactionNotifications.value, onChanged: (value) => transactionNotifications.value = value, activeColor: primaryColor),
              ),
              Spacer(),
              CustomButton(
                text: 'SAVE SETTINGS',
                function: () async {
                  final userService = Get.find<UserService>();
                  final dialogService = Get.find<DialogService>();
                  dialogService.showLoading();
                  await userService.updateUser({
                    'bookingNotifications': bookingNotifications.value,
                    'messageNotifications': messageNotifications.value,
                    'generalNotifications': generalNotifications.value,
                    'transactionNotifications': transactionNotifications.value,
                  });
                  Get.back();
                  Get.back();
                  showGreenAlert('Updated successfully');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
