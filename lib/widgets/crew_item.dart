import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';

class CrewItem extends StatelessWidget {
  final User? user;
  final String? vesselID;
  final String? crewType;

  CrewItem({this.user, this.vesselID, this.crewType});

  final vesselsService = Get.find<VesselService>();
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      leading: Icon(Icons.person_outline_outlined, color: primaryColor),
      title: Text(user!.fullName!, style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: userController.currentUser.value.userID != user!.userID! && (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
          ? IconButton(
              icon: Icon(Icons.remove_circle, color: redColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context1) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      title: Text('Remove Member?', textScaleFactor: 1),
                      content: Text('Are you sure you want to remove ${user!.fullName}?', textScaleFactor: 1),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: Text('Cancel', textScaleFactor: 1)),
                        TextButton(
                            onPressed: () async {
                              dialogService.showLoading();
                              if (crewType == 'Crew') await vesselsService.removeCrew(user!.userID!, vesselID!);
                              if (crewType == 'Captain') await vesselsService.removeCaptain(user!.userID!, vesselID!);
                              if (crewType == 'Receptionist') await vesselsService.removeReceptionist(user!.userID!, vesselID!);
                            },
                            child: Text('Remove', textScaleFactor: 1, style: TextStyle(color: redColor))),
                      ],
                    );
                  },
                );
              },
            )
          : SizedBox(height: 10, width: 10),
    );
  }
}
