import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/models/confirm_payment_model.dart';
import 'package:makaiapp/models/notification_model.dart';
import 'package:makaiapp/screens/home/notification_settings.dart';
import 'package:makaiapp/screens/profile/reports.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/misc_service.dart';
import 'package:makaiapp/services/notification_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/booking_item.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class Notifications extends StatelessWidget {
  final vesselService = Get.find<VesselService>();
  final dialogService = Get.find<DialogService>();
  final bookingService = Get.find<BookingService>();
  final notificationService = Get.find<NotificationService>();
  final RxBool showArchived = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NOTIFICATIONS'),
        actions: [IconButton(onPressed: () => Get.to(() => NotificationSettings()), icon: Icon(Icons.settings))],
      ),
      body: Obx(() => showPage()),
    );
  }

  showPage() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: SwitchListTile(
            activeColor: primaryColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 25),
            value: showArchived.value,
            onChanged: (val) => showArchived.value = val,
            title: Text('Show archived notifications'),
            subtitle: Text('(Swipe to dismiss notifications)', textScaleFactor: 0.9),
          ),
        ),
        Divider(height: 1),
        Expanded(
          child: PaginateFirestore(
            isLive: true,
            padding: const EdgeInsets.all(15),
            key: GlobalKey(),
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (context, documentSnapshot, i) {
              NotificationModel notification = NotificationModel.fromDocument(documentSnapshot[i]);
              print(notification.notificationID);
              if (notification.type == 'vesselBookingRequest' && MY_ROLE != VESSEL_USER) {
                return Dismissible(
                  key: Key(notification.notificationID ?? ""),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('  dd MMM yyyy, hh:mm a').format(notification.creationDate!.toDate()), style: TextStyle(color: Colors.grey), textScaleFactor: 0.9),
                      SizedBox(height: 5),
                      FutureBuilder(
                          future: bookingService.getBookingForBookingID(notification.bookingID ?? ""),
                          builder: (context, snapshot) {
                            return snapshot.hasData ? BookingItem(notification: notification, booking: Booking.fromDocument(snapshot.data as DocumentSnapshot<Object?>)) : Container();
                          }),
                    ],
                  ),
                  onDismissed: (direction) async {
                    await notificationService.archiveNotification(notification.notificationID ?? "");
                  },
                );
              } else if (notification.type == 'vesselBookingResponse' && MY_ROLE == VESSEL_USER) {
                return Dismissible(
                  key: Key(notification.notificationID ?? ""),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('  dd MMM yyyy, hh:mm a').format(notification.creationDate!.toDate()), style: TextStyle(color: Colors.grey), textScaleFactor: 0.9),
                      SizedBox(height: 5),
                      FutureBuilder(
                          future: bookingService.getBookingForBookingID(notification.bookingID ?? ""),
                          builder: (context, snapshot) {
                            return snapshot.hasData ? BookingItem(notification: notification, booking: Booking.fromDocument(snapshot.data as DocumentSnapshot<Object?>)) : Container();
                          }),
                    ],
                  ),
                  onDismissed: (direction) async {
                    await notificationService.archiveNotification(notification.notificationID ?? "");
                  },
                );
              } else if (notification.type == 'general') {
                return Dismissible(
                  key: Key(notification.notificationID ?? ""),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('  dd MMM yyyy, hh:mm a').format(notification.creationDate!.toDate()), style: TextStyle(color: Colors.grey), textScaleFactor: 0.9),
                      SizedBox(height: 5),
                      Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Linkify(
                          text: notification.messageText ?? "",
                          onOpen: (element) {
                            print(element.url);
                            MiscService().openLink(element.url);
                          },
                        ),
                      ),
                    ],
                  ),
                  onDismissed: (direction) async {
                    await notificationService.archiveNotification(notification.notificationID ?? "");
                  },
                );
              } else if (notification.type == 'transaction') {
                return Dismissible(
                  key: Key(notification.notificationID ?? ""),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('  dd MMM yyyy, hh:mm a').format(notification.creationDate!.toDate()), style: TextStyle(color: Colors.grey), textScaleFactor: 0.9),
                      SizedBox(height: 5),
                      CustomListTile(
                        onTap: () => Get.to(() => Reports(vesselID: notification.vesselID ?? "")),
                        title: Text(notification.messageText ?? "", style: TextStyle(color: Colors.green)),
                        leading: Icon(Icons.monetization_on, color: Colors.green),
                        trailing: Icon(Icons.keyboard_arrow_right_rounded, color: Colors.green),
                      ),
                    ],
                  ),
                  onDismissed: (direction) async {
                    await notificationService.archiveNotification(notification.notificationID ?? "");
                  },
                );
              } else
                return Container();
            },
            query: notificationService.getNotifications(10, showArchived.value),
            onEmpty: Center(child: EmptyBox(text: 'You are all caught up!')),
            itemsPerPage: 10,
            bottomLoader: LoadingData(),
            initialLoader: LoadingData(),
          ),
        ),
      ],
    );
  }
}
