import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/booking_item.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ManageBookings extends StatelessWidget {
  final Vessel vessel;

  ManageBookings({required this.vessel});

  final buyService = Get.find<BookingService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MANAGE BOOKINGS')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              height: 45,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade400,
              ),
              child: TabBar(
                labelPadding: EdgeInsets.zero,
                labelColor: Colors.white,
                indicatorColor: primaryColor,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                unselectedLabelColor: primaryColor,
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                // labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TabBarView(
                  children: [
                    showPage(false),
                    showPage(true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showPage(bool isPast) {
    return PaginateFirestore(
      isLive: true,
      //padding: const EdgeInsets.only(top: 25),
      key: GlobalKey(),
      shrinkWrap: true,
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshot, i) {
        Booking booking = Booking.fromDocument(documentSnapshot[i]);
        if (isPast)
          return BookingItem(booking: booking);
        else {
          if (i == 0)
            return Column(
              children: [
                startStopButtons(),
                SizedBox(height: 10),
                BookingItem(booking: booking),
              ],
            );
          else
            return BookingItem(booking: booking);
        }
      },
      query: buyService.getVesselBookings(vessel.vesselID!, 10, isPast),
      onEmpty: EmptyBox(text: 'No booking to show'),
      itemsPerPage: 10,
      bottomLoader: LoadingData(),
      initialLoader: LoadingData(),
    );
  }

  startStopButtons() {
    final userController = Get.find<UserController>();
    final utilService = Get.find<DialogService>();
    final userService = Get.find<UserService>();
    if (MY_ROLE == VESSEL_CAPTAIN)
      return Obx(() {
        return CustomButton(
          text: userController.currentUser.value.tripStatus == 'START' ? 'STOP TRIP' : 'START TRIP',
          color: userController.currentUser.value.tripStatus == 'START' ? redColor : Colors.green,
          function: () {
            utilService.showConfirmationDialog(
              title: userController.currentUser.value.tripStatus == 'START' ? 'STOP TRIP' : 'START TRIP',
              contentText: userController.currentUser.value.tripStatus == 'START' ? 'Would you like to stop this trip?' : 'Would you like to start this trip?',
              confirm: () async {
                Get.back();
                await userService.updateUser({'tripStatus': userController.currentUser.value.tripStatus == 'START' ? 'STOP' : 'START'});
              },
            );
          },
        );
      });
    else
      return Container();
  }
}
