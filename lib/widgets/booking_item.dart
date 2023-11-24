// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/models/confirm_payment_model.dart' as c;
import 'package:makaiapp/models/notification_model.dart';
import 'package:makaiapp/models/transaction_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/messages/chats.dart';
import 'package:makaiapp/screens/vessels/view_vessel.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/notification_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class BookingItem extends StatelessWidget {
  final Booking? booking;
  final NotificationModel? notification;

  BookingItem({this.booking, this.notification});

  final bookingService = Get.find<BookingService>();
  final vesselService = Get.find<VesselService>();
  final userService = Get.find<UserService>();
  final dialogService = Get.find<DialogService>();
  final userController = Get.find<UserController>();
  final formatCurrency = new NumberFormat.simpleCurrency();
  final notificationService = Get.find<NotificationService>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                notification!.type == 'vesselBookingResponse' ? getMessage(booking!.status!) : 'You have received a booking request',
                style: TextStyle(color: getColor(booking!.status!)),
              ),
            ),
            getVessel(),
            Divider(height: 10),
            item('Travel Date', DateFormat('MMMM dd, yyyy hh:mm aa').format(booking!.travelDate!.toDate()), primaryColor),
            item('Duration', booking!.duration.toString() + ' hrs', primaryColor),
            item('Total Guests', booking!.guestCount.toString(), primaryColor),
            item('Total Amount', formatCurrency.format(booking!.totalCost).toString(), primaryColor),
            item('Booking Status', getStatus(booking!.status!), getColor(booking!.status!)),
            if (MY_ROLE != VESSEL_USER) getUser(),
            item('Booking Date', DateFormat('MMMM dd, yyyy').format(booking!.creationDate!.toDate()), primaryColor),

            //item('Payment status', booking.paid ? 'Paid' : 'Not Paid', booking.paid ? Colors.green : Colors.red),

            Divider(height: 10),
            if (MY_ROLE == VESSEL_USER)
              if (booking!.travelDate!.toDate().isAfter(DateTime.now())) messageAndCancelButtons(),
            if (MY_ROLE == VESSEL_OWNER)
              if (booking!.travelDate!.toDate().isAfter(DateTime.now()))
                if (booking!.status == null) approveAndDisapproveButtons(booking!),
          ],
        ),
      ),
    );
  }

  getVessel() {
    return FutureBuilder(
      future: vesselService.getVesselForVesselID(booking!.vesselID!),
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Container()
            : ListTile(
                onTap: () => Get.to(() => ViewVessel(true, vesselID: booking!.vesselID!)),
                contentPadding: EdgeInsets.zero,
                title: Text(Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>).vesselName!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Click to view vessel', style: TextStyle(color: Colors.grey)),
                leading: CachedImage(url: snapshot.hasData ? Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>).images![0] : '', height: 50, roundedCorners: true, circular: true, imageFile: fileOption as File),
                trailing: userController.currentUser.value.userID == Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>).vesselChatUserID
                    ? SizedBox(width: 10)
                    : TextButton.icon(
                        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                        onPressed: () async {
                          final userService = Get.find<UserService>();
                          final messageService = Get.find<MessageService>();
                          dialogService.showLoading();
                          QuerySnapshot querySnapshot = await vesselService.getVesselReceptionistForChat(booking!.vesselID!);
                          User? user = querySnapshot.docs.isEmpty ? null : User.fromDocument(querySnapshot.docs[0]);
                          String? userID = user == null ? booking!.userID : user.userID;
                          String chatRoomID = await messageService.checkIfVesselChatRoomExists(userID!, booking!.vesselID!, true, false);
                          DocumentSnapshot doc = await userService.getUser(userID);
                          User chatUser = User.fromDocument(doc);
                          Get.back();
                          Get.to(Chats(user: chatUser, chatRoomID: chatRoomID, vessel: Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>)));
                        },
                        icon: Icon(FontAwesomeIcons.comment, color: secondaryColor, size: 18),
                        label: Text('Chat', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)),
                      ),
              );
      },
    );
  }

  getUser() {
    return FutureBuilder(
      future: userService.getUser(booking!.userID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          User user = User.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
          return item('Booked by', user.fullName!, primaryColor);
        } else
          return Container(height: 56);
      },
    );
  }

  messageAndCancelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (booking!.status != 'cancelled')
          TextButton.icon(
            onPressed: () async {
              dialogService.showConfirmationDialog(
                title: 'Cancel Booking',
                contentText: 'Are you sure you want to cancel the booking?',
                confirm: () async {
                  Get.back();
                  dialogService.showLoading();
                  QuerySnapshot docs = await bookingService.getTransactionFromPaymentID(booking!.paymentIntentID!);
                  TransactionModel transaction = TransactionModel.fromDocument(docs.docs[0]);

                  var response;
                  if (booking!.status == null)
                    response = await bookingService.cancelBooking(booking!.paymentIntentID!, 'requested_by_customer');
                  else
                    response = await bookingService.refundPayment(transaction.stripeChargeID!, booking!.totalCost! * 100, 'requested_by_customer');
                  if (response['success']) {
                    await bookingService.updateBookingRequest(booking!, 'cancelled');
                    Get.back();
                    showGreenAlert(response['message']);
                  } else {
                    Get.back();
                    showRedAlert(response['message']);
                  }
                },
              );
            },
            icon: Icon(FontAwesomeIcons.xmark, color: redColor),
            label: Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold, color: redColor)),
          ),
      ],
    );
  }

  approveAndDisapproveButtons(Booking booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () async {
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
                        c.ConfirmPaymentModel confirmPaymentModel = await bookingService.confirmPayment(booking.paymentIntentID!);
                        if (confirmPaymentModel.success) {
                          await bookingService.updateBookingRequest(booking, 'accepted');
                          TransactionModel transaction = TransactionModel(
                            userID: booking.userID,
                            transactionID: Uuid().v1(),
                            vesselID: booking.vesselID,
                            stripeCustomerID: userController.currentUser.value.stripeCustomerID,
                            stripePaymentID: booking.paymentIntentID,
                            stripeRefundID: '',
                            notes: '',
                            stripeChargeID: confirmPaymentModel.data.charges.data[0].id,
                            receiptID: '',
                            paymentMethod: 'card',
                            type: 'payment',
                            tipAmount: booking.tipAmount,
                            amount: booking.totalCost,
                            creationDate: Timestamp.now(),
                          );
                          await bookingService.storeTransaction(transaction);
                          Get.back();
                          showGreenAlert(confirmPaymentModel.message);
                        } else {
                          Get.back();
                          showRedAlert(confirmPaymentModel.message);
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
          icon: Icon(FontAwesomeIcons.check, color: Colors.green),
          label: Text('Approve Booking', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ),
        TextButton.icon(
          onPressed: () async {
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
          icon: Icon(FontAwesomeIcons.xmark, color: redColor),
          label: Text('Deny Booking', style: TextStyle(fontWeight: FontWeight.bold, color: redColor)),
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
