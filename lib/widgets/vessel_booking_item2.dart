import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/models/notification_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/messages/chats.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/notification_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';

class VesselBookingItem extends StatelessWidget {
  final String? bookingID;
  final NotificationModel? notification;

  VesselBookingItem({this.bookingID, this.notification});

  final bookingService = Get.find<BookingService>();
  final vesselService = Get.find<VesselService>();
  final dialogService = Get.find<DialogService>();
  final userController = Get.find<UserController>();
  final notificationService = Get.find<NotificationService>();
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: FutureBuilder(
          future: bookingService.getBookingForBookingID(bookingID!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Booking booking = Booking.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
              if (notification == null)
                return expansionTile(booking, context);
              else
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        notification!.type == 'vesselBookingResponse' ? getMessage(booking.status!) : 'You have received a booking request',
                        style: TextStyle(color: getColor(booking.status!)),
                      ),
                    ),
                    expansionTile(booking, context),
                  ],
                );
            } else
              return Container();
          },
        ),
      ),
    );
  }

  expansionTile(Booking booking, context) {
    return FutureBuilder(
        future: vesselService.getVesselForVesselID(booking.vesselID!),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Container()
              : Column(
                  children: [
                    ListTile(
                      leading: CachedImage(url: snapshot.hasData ? Vessel.fromDocument(snapshot.data  as DocumentSnapshot<Map<String, dynamic>>).images![0] : '', height: 50, roundedCorners: true),
                      title: Text(Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>).vesselName!, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('MMMM dd, yyyy, hh:mm aa').format(booking.travelDate!.toDate()), style: TextStyle(color: primaryColor)),
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 0,
                      style: ListTileStyle.list,
                    ),
                    item('Total Guests', booking.guestCount.toString(), Colors.grey.shade600),
                    item('Total Amount', formatCurrency.format(booking.totalCost).toString(), Colors.grey.shade600),
                    item('Booking Status', getStatus(booking.status!), getColor(booking.status!)),
                    item('Payment status', booking.paid! ? 'Paid' : 'Not Paid', booking.paid! ? Colors.green : Colors.red),
                    Divider(height: 10),
                    SizedBox(height: 5),
                    if (MY_ROLE == VESSEL_USER)
                      if (booking.travelDate!.toDate().isAfter(DateTime.now())) messageAndPayButtons(booking, context, Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>)),
                    if (MY_ROLE == VESSEL_OWNER)
                      if (booking.travelDate!.toDate().isAfter(DateTime.now()))
                        if (booking.status == null) approveAndDisapproveButtons(booking),
                  ],
                );
        });
  }

  messageAndPayButtons(Booking booking, context, Vessel vessel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                //style: ButtonStyle(visualDensity: VisualDensity.compact, padding: MaterialStateProperty.all(EdgeInsets.zero)),
                child: Text('MESSAGE', textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final userService = Get.find<UserService>();
                  final messageService = Get.find<MessageService>();
                  dialogService.showLoading();
                  QuerySnapshot querySnapshot = await vesselService.getVesselReceptionistForChat(booking.vesselID!);
                  User? user = querySnapshot.docs.isEmpty ? null : User.fromDocument(querySnapshot.docs[0]);
                  String? userID = user == null ? booking.userID : user.userID;
                  String chatRoomID = await messageService.checkIfVesselChatRoomExists(userID!, booking.vesselID!, true, false);
                  DocumentSnapshot doc = await userService.getUser(userID);
                  User chatUser = User.fromDocument(doc);
                  Get.back();
                  Get.to(Chats(user: chatUser, chatRoomID: chatRoomID, vessel: vessel));
                },
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: InkWell(
                //style: ButtonStyle(visualDensity: VisualDensity.compact, padding: MaterialStateProperty.all(EdgeInsets.zero)),
                child: Text('PAY NOW', textAlign: TextAlign.center, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                onTap: () async {
                  if (booking.paid!)
                    showRedAlert('You have already paid for this booking');
                  else {
                    if (getStatus(booking.status!) == 'Accepted') {
                      final buyService = Get.find<BookingService>();
                      await buyService.processPayment(
                          tipAmount: booking.tipAmount!,
                          context: context,
                          bookingID: booking.bookingID!,
                          vesselID: booking.vesselID!,
                          total: booking.totalCost!,
                          guestCount: booking.guestCount!,
                          date: booking.travelDate!.toDate(),
                          setState: () {
                            //setState(() {});
                          });
                      Get.back();
                      Get.back();
                      Get.back();
                    } else {
                      showRedAlert('Your booking is not approved yet');
                    }
                  }
                },
              ),
            ),
            SizedBox(width: 15),
            if (booking.status == null)
              Expanded(
                child: InkWell(
                  //style: ButtonStyle(visualDensity: VisualDensity.compact, padding: MaterialStateProperty.all(EdgeInsets.zero)),
                  child: Text('CANCEL', textAlign: TextAlign.center, style: TextStyle(color: redColor, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    dialogService.showLoading();
                    num refundAmount = await bookingService.getCancellationAmount(bookingID!);
                    Get.back();
                    dialogService.showConfirmationDialog(
                        title: 'Cancel Booking',
                        contentText: 'Are you sure you want to cancel the booking?\n\nYou will receive \$$refundAmount as a refund.',
                        confirm: () async {
                          Get.back();
                          dialogService.showLoading();
                          await bookingService.updateBookingRequest(booking, 'cancelled');
                          await bookingService.cancelBooking(bookingID!, '');
                          Get.back();
                          showGreenAlert('Booking Cancelled');
                        });
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  approveAndDisapproveButtons(Booking booking) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Approve',
            color: primaryColor,
            function: () async {
              Get.defaultDialog(
                title: 'Booking Agreement',
                content: Container(
                  height: 250,
                  child: Scrollbar(thumbVisibility: true, child: SingleChildScrollView(child: Text(booking.bookingAgreement!))),
                ),
                confirm: CustomButton(function: () => Get.back(), text: 'Cancel', color: Colors.grey),
                cancel: CustomButton(
                  text: 'Agree',
                  function: () async {
                    Get.back();
                    dialogService.showConfirmationDialog(
                        title: 'Approve Booking',
                        contentText: 'Are you sure you want to approve the booking?',
                        confirm: () async {
                          Get.back();
                          dialogService.showLoading();
                          await bookingService.updateBookingRequest(booking, 'accepted');
                          await notificationService.sendNotification(
                            parameters: {
                              'receptionistID': userController.currentUser.value.userID,
                              'vesselID': booking.vesselID,
                              'bookingID': booking.bookingID,
                            },
                            body: 'Congrats! Your vessel booking request has been approved',
                            type: 'vesselBookingResponse',
                            receiverUserID: booking.userID,
                          );
                          Get.back();
                          showGreenAlert('Accepted booking');
                        });
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            color: redColor,
            text: 'Deny',
            function: () async {
              dialogService.showConfirmationDialog(
                  title: 'Reject Booking',
                  contentText: 'Are you sure you want to reject the booking?',
                  confirm: () async {
                    Get.back();
                    dialogService.showLoading();
                    await bookingService.updateBookingRequest(booking, 'rejected');
                    await notificationService.sendNotification(
                      parameters: {
                        'receptionistID': userController.currentUser.value.userID,
                        'vesselID': booking.vesselID,
                        'bookingID': booking.bookingID,
                      },
                      body: 'Sorry. Your vessel booking request has been denied',
                      type: 'vesselBookingResponse',
                      receiverUserID: booking.userID,
                    );
                    Get.back();
                    showGreenAlert('Rejected booking');
                  });
            },
          ),
        ),
      ],
    );
  }

  item(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600)),
        SizedBox(height: 20),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  getStatus(String status) {
    if (status == null) return 'Requested';
    if (status == 'accepted') return 'Accepted';
    if (status == 'rejected') return 'Rejected';
    if (status == 'cancelled') return 'Cancelled';
  }

  getColor(String status) {
    if (status == null) return Colors.amber;
    if (status == 'accepted') return Colors.green;
    if (status == 'rejected') return redColor;
    if (status == 'cancelled') return redColor;
  }

  getMessage(String status) {
    if (status == null) return '';
    if (status == 'accepted') return 'Congrats! Your vessel booking request has been approved';
    if (status == 'rejected') return 'Sorry. Your vessel booking request has been denied.';
    if (status == 'cancelled') return 'Your vessel booking request has been cancelled';
  }
}
