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
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: FutureBuilder(
        future: bookingService.getBookingForBookingID(bookingID!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Booking booking = Booking.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
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
                  Divider(height: 10),
                  item('Total Guests', booking.guestCount.toString(), primaryColor),
                  item('Total Amount', formatCurrency.format(booking.totalCost).toString(), primaryColor),
                  item('Booking Status', getStatus(booking.status!), getColor(booking.status!)),
                  item('Payment status', booking.paid! ? 'Paid' : 'Not Paid', booking.paid! ? Colors.green : Colors.red),
                  SizedBox(height: 10),
                  if (MY_ROLE == VESSEL_USER)
                    if (booking.travelDate!.toDate().isAfter(DateTime.now())) messageAndPayButtons(booking, context, Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>)),
                  if (MY_ROLE == VESSEL_OWNER)
                    if (booking.travelDate!.toDate().isAfter(DateTime.now()))
                      if (booking.status == null) approveAndDisapproveButtons(booking),
                ],
              );
          } else
            return Container();
        },
      ),
    );
  }

  expansionTile(Booking booking, context) {
    return FutureBuilder(
      future: vesselService.getVesselForVesselID(booking.vesselID!),
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Container()
            : ListTile(
                title: Text(Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>).vesselName!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('MMMM dd, yyyy hh:mm aa').format(booking.travelDate!.toDate()), style: TextStyle(color: primaryColor)),
                leading: CachedImage(url: snapshot.hasData ? Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>).images![0] : '', height: 50, roundedCorners: true),
              );
      },
    );
  }

  messageAndPayButtons(Booking booking, context, Vessel vessel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'MESSAGE',
                color: Colors.green,
                function: () async {
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
            // SizedBox(width: 10),
            // Expanded(
            //   child: CustomButton(
            //     text: 'PAY NOW',
            //     color: booking.paid
            //         ? Colors.grey
            //         : getStatus(booking.status) == 'Accepted'
            //             ? primaryColor
            //             : Colors.grey,
            //     function: () async {
            //       if (booking.paid)
            //         showRedAlert('You have already paid for this booking');
            //       else {
            //         if (getStatus(booking.status) == 'Accepted') {
            //           final buyService = Get.find<BookingService>();
            //           await buyService.processPayment(
            //               tipAmount: booking.tipAmount,
            //               context: context,
            //               bookingID: booking.bookingID,
            //               vesselID: booking.vesselID,
            //               total: booking.totalCost,
            //               guestCount: booking.guestCount,
            //               date: booking.travelDate.toDate(),
            //               setState: () {
            //                 //setState(() {});
            //               });
            //           Get.back();
            //           Get.back();
            //           Get.back();
            //         } else {
            //           showRedAlert('Your booking is not approved yet');
            //         }
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
        if (booking.status == null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CustomButton(
              text: 'CANCEL BOOKING',
              color: redColor,
              function: () async {
                dialogService.showLoading();
                print(booking.status);
                num refundAmount = booking.status == null ? booking.totalCost : await bookingService.getCancellationAmount(bookingID!);
                Get.back();
                dialogService.showConfirmationDialog(
                  title: 'Cancel Booking',
                  contentText: 'Are you sure you want to cancel the booking?\nYou will receive \$$refundAmount as a refund.',
                  confirm: () async {
                    Get.back();
                    dialogService.showLoading();
                    var response = await bookingService.cancelBooking(bookingID!, '');
                    if (response['success']) {
                      await bookingService.updateBookingRequest(booking, 'cancelled');
                      Get.back();
                      showGreenAlert(response['message']);
                    } else {
                      Get.back();
                      showRedAlert(response['message']);
                    }
                  },
                );
              },
            ),
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
                  child: Scrollbar(thumbVisibility: true, child: SingleChildScrollView(child: Text(booking!.bookingAgreement!))),
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
                          var response = await bookingService.confirmPayment(booking.paymentIntentID!);
                          if (response['success']) {
                            await bookingService.updateBookingRequest(booking, 'accepted');
                            Get.back();
                            showGreenAlert(response['message']);
                          } else {
                            Get.back();
                            showRedAlert(response['message']);
                          }
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
        Text(title),
        SizedBox(height: 30),
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
