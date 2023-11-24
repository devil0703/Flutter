import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/models/confirm_payment_model.dart';
import 'package:makaiapp/models/discount_model.dart';
import 'package:makaiapp/models/fees_model.dart';
import 'package:makaiapp/models/payment_method_model.dart';
import 'package:makaiapp/models/seat_model.dart';
import 'package:makaiapp/models/transaction_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/services/cloud_function.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/notification_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final ref = FirebaseFirestore.instance;
  final dialogService = Get.find<DialogService>();
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  late Map<String, dynamic> paymentIntentData;
  String stripeCustomerID = '';
  String stripeCustomerEphemeralKey = '';

  getMyBookings(int limit, bool isPast) {
    if (isPast)
      return ref.collection("bookings").where('userID', isEqualTo: userController.currentUser.value.userID).where('travelDate', isLessThanOrEqualTo: Timestamp.now()).orderBy('travelDate', descending: true).limit(limit);
    else
      return ref.collection("bookings").where('userID', isEqualTo: userController.currentUser.value.userID).where('travelDate', isGreaterThanOrEqualTo: Timestamp.now()).orderBy('travelDate', descending: true).limit(limit);
  }

  checkIfIBooked(String vesselID) async {
    return (await ref.collection('bookings').where('vesselID', isEqualTo: vesselID).where('userID', isEqualTo: userController.currentUser.value.userID).get()).docs.isNotEmpty;
  }

  getVesselTransactions(String vesselID) {
    return ref.collection("transactions").where('vesselID', isEqualTo: vesselID).orderBy('creationDate', descending: true).limit(10);
  }

  getVesselBookings(String vesselID, int limit, bool isPast) {
    if (isPast)
      return ref.collection("bookings").where('vesselID', isEqualTo: vesselID).where('travelDate', isLessThanOrEqualTo: Timestamp.now()).orderBy('travelDate').limit(limit);
    else
      return ref.collection("bookings").where('vesselID', isEqualTo: vesselID).where('travelDate', isGreaterThanOrEqualTo: Timestamp.now()).orderBy('travelDate').limit(limit);
  }

  getBookingForBookingID(String bookingID) async {
    return await ref.collection('bookings').doc(bookingID).get();
  }

  getBookingRequests(String vesselID, int limit) {
    return ref.collection("bookings").where('vesselID', isEqualTo: userController.currentUser.value.userID).where('status', isNull: true).orderBy('creationDate', descending: true).limit(limit);
  }

  getUpcomingBookings(int limit, bool isPaid) {
    return ref.collection("bookings").where('userID', isEqualTo: userController.currentUser.value.userID).where('paid', isEqualTo: isPaid).where('travelDate', isGreaterThanOrEqualTo: Timestamp.now()).orderBy('travelDate', descending: true).limit(limit);
  }

  getAllUpcomingBookings(int limit) {
    return ref.collection("bookings").where('userID', isEqualTo: userController.currentUser.value.userID).where('travelDate', isGreaterThanOrEqualTo: Timestamp.now()).orderBy('travelDate', descending: true).limit(limit);
  }

  Future<QuerySnapshot> getBookingsBetween(Timestamp startDate, Timestamp endDate) {
    return ref.collection("bookings").where('userID', isEqualTo: userController.currentUser.value.userID).where('travelDate', isGreaterThanOrEqualTo: startDate).where('travelDate', isLessThanOrEqualTo: endDate).orderBy('travelDate', descending: true).get();
  }

  getBookingsForDate(Timestamp date) {
    return ref.collection("bookings").where('userID', isEqualTo: userController.currentUser.value.userID).where('travelDate', isEqualTo: date).limit(500);
  }

  sendBookingRequest(Booking booking) async {
    String? bookingID = booking.bookingID;
    ref.collection('bookings').doc(bookingID).set({
      'bookingID': bookingID,
      'bookingRef': booking.bookingRef,
      'userID': userController.currentUser.value.userID,
      'vesselID': booking.vesselID,
      'guestCount': booking.guestCount,
      'seatCost': booking.seatCost,
      'totalCost': booking.totalCost,
      'tipAmount': booking.tipAmount,
      'travelDate': booking.travelDate!.toDate().toUtc(),
      'duration': booking.duration,
      'creationDate': Timestamp.now().toDate().toUtc(),
      'status': booking.isPreMadeTrip! ? 'accepted' : null,
      'bookingAgreement': booking.bookingAgreement,
      'paymentMethodID': userController.currentUser.value.paymentID,
      'paymentIntentID': booking.paymentIntentID,
      'isPreMadeTrip': booking.isPreMadeTrip,
    });
    if (!booking.isPreMadeTrip!) {
      final vesselService = Get.find<VesselService>();
      QuerySnapshot querySnapshot = await vesselService.getVesselReceptionistForChat(booking.vesselID!);
      User? receiver = querySnapshot.docs.isEmpty ? null : User.fromDocument(querySnapshot.docs[0]);
      final notificationService = Get.find<NotificationService>();
      await notificationService.sendNotification(
        parameters: {'vesselID': booking.vesselID, 'bookingID': bookingID},
        receiverUserID: receiver!.userID!,
        type: 'vesselBookingRequest',
        body: 'You have a new vessel booking request',
      );
    } else {
      ConfirmPaymentModel confirmPaymentModel = await confirmPayment(booking.paymentIntentID!);
      TransactionModel transaction = TransactionModel(
        userID: userController.currentUser.value.userID,
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
      await storeTransaction(transaction);
    }
  }

  updateBookingRequest(Booking booking, String status) async {
    return await ref.collection('bookings').doc(booking.bookingID).update({
      'status': status,
    });
  }

  makePayment(String bookingID) async {
    await ref.collection('bookings').doc(bookingID).update({
      'paid': true,
    });
  }

  storeTransaction(TransactionModel transaction) async {
    await ref.collection('transactions').doc(transaction.transactionID).set({
      'userID': transaction.userID,
      'transactionID': transaction.transactionID,
      'vesselID': transaction.vesselID,
      'stripeCustomerID': transaction.stripeCustomerID,
      'stripeChargeID': transaction.stripeChargeID,
      'stripePaymentID': transaction.stripePaymentID,
      'stripeRefundID': transaction.stripeRefundID,
      'notes': transaction.notes,
      'paymentMethod': transaction.paymentMethod,
      'receiptID': transaction.receiptID,
      'type': transaction.type,
      'tipAmount': transaction.tipAmount,
      'amount': transaction.amount,
      'creationDate': transaction.creationDate,
    });
  }

  getTransactionFromPaymentID(String paymentIntentID) async {
    return ref.collection('transactions').where('stripePaymentID', isEqualTo: paymentIntentID).get();
  }

  getCards() async {
    stripeCustomerID = userController.currentUser.value.stripeCustomerID!;
    var response = await getMethod('makai/list-cards?customer_id=$stripeCustomerID', {});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(data);
    return PaymentMethodsList.fromJson(data);
  }

  checkSeatAvailability(String vesselID, String timeSlot) async {
    var response = await getMethod('makai/seat-availability?vessel_id=$vesselID&time_slot=$timeSlot', {});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(response.body.toString());
    SeatAvailabilityModel seatAvailabilityModel = SeatAvailabilityModel.fromJson(data);
    print(seatAvailabilityModel.vessel!.availableSeats!);
    return seatAvailabilityModel.vessel!.availableSeats;
  }

  Future<FeesModel> getFees(num amount) async {
    var response = await getMethod('makai/service-fees?amount=$amount', {});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(response.body);
    return FeesModel.fromJson(data);
  }

  createCustomer(String email, String name) async {
    var response = await postMethod('makai/create-stripe-customer', {'full_name': name, 'email': email});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(response.body.toString());
    return data['stripe_customer_id'];
    // if (data['stripe_customer_id'] != null) await userService.updateUser({'stripeCustomerID': data['stripe_customer_id']});
  }

  createPaymentIntent(num amount) async {
    var response = await postMethod('makai/stripePI', {
      'amount': amount * 100,
      'customer_id': userController.currentUser.value.stripeCustomerID,
      'email': userController.currentUser.value.email,
    });
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(data.toString());
    return data;
  }

  addCard(Map parameters) async {
    var response = await postMethod('makai/stripe-add-card', parameters);
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(data.toString());
    return data;
  }

  removeCard(Map parameters) async {
    var response = await postMethod('makai/stripe-remove-card', parameters);
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(data.toString());
    return data;
  }

  cancelBooking(String bookingID, String reason) async {
    var response = await postMethod('makai/cancel-booking', {'payment_intent_id': bookingID, 'cancellation_reason': reason});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    return data;
  }

  refundPayment(String chargeID, num amount, String reason) async {
    var response = await postMethod('makai/refund-payment', {'charge_id': chargeID, 'amount': amount, 'reason': reason});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    return data;
  }

  confirmPayment(String paymentIntentID) async {
    var response = await postMethod('/makai/stripe-confirm-payment', {'payment_intent_id': paymentIntentID, 'email': userController.currentUser.value.email});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^ Confirm Payment ^^^^^^^^^^^^^^^^');
    printWrapped(data.toString());
    return ConfirmPaymentModel.fromJson(data);
  }

  getCancellationAmount(String bookingID) async {
    var response = await postMethod('makai/cancellation-amount', {'booking_id': bookingID});
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    return data['amount'];
  }

  Future<Discount?> calculateCouponDiscount(num amount, String couponCode) async {
    try {
      var response = await getMethod('makai/coupon-discount?amount=$amount&couponCode=$couponCode', {});
      final data = json.decode(response.body);
      print('^^^^^^^^^^^^^ COUPON DISCOUNT ^^^^^^^^^^^^^^^^');
      print(response.body);
      if (response.body.toString().contains('"error"')) return null;
      return Discount.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  late TransactionModel transaction;

  processPayment({required BuildContext context, required String vesselID, required String bookingID, required num total, required num tipAmount, required num guestCount, required DateTime date, required Function setState}) async {
    try {
      Map data;
      var response;
      dialogService.showLoading();

      //Step 1 : Get Publishable Key
      response = await getMethod('makai/stripe-pubkey', {});
      data = json.decode(response.body);
      Stripe.publishableKey = data['publishable_key'];

      //Step 2 : Get Customer ID
      if (userController.currentUser.value.stripeCustomerID == '') {
        response = await postMethod('makai/create-stripe-customer', {'full_name': userController.currentUser.value.fullName, 'email': userController.currentUser.value.email});
        data = json.decode(response.body);
        stripeCustomerID = data['stripe_customer_id'];
        await userService.updateUser({'stripeCustomerID': stripeCustomerID});
      } else
        stripeCustomerID = userController.currentUser.value.stripeCustomerID!;

      //Step 3 : Get Payment Intent
      stripeCustomerEphemeralKey = userController.currentUser.value.stripeCustomerEphemeralKey!;
      response = await postMethod('makai/stripePI', {'amount': (total * 100).toInt(), 'customer_id': stripeCustomerID, 'email': userController.currentUser.value.email});
      data = json.decode(response.body);
      paymentIntentData = data['paymentIntent'];
      stripeCustomerEphemeralKey = data['ephemeralKey'];

      //Step 4 :Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'MAKAI',
          customerId: stripeCustomerID,
          customerEphemeralKeySecret: stripeCustomerEphemeralKey,
        ),
      );
      setState();

      // Step 5 : Display Payment Sheet
      bool success = await displayPaymentSheet(setState, vesselID, total, tipAmount);

      // Step 6 : Store booking data and transaction
      if (success) {
        await makePayment(bookingID);
        await storeTransaction(transaction);
      }

      // Step 7 : Send notification
      if (success) {
        final formatCurrency = new NumberFormat.simpleCurrency();
        final vesselService = Get.find<VesselService>();
        QuerySnapshot querySnapshot = await vesselService.getVesselReceptionistForChat(vesselID);
        User? receiver = querySnapshot.docs.isEmpty ? null : User.fromDocument(querySnapshot.docs[0]);
        final notificationService = Get.find<NotificationService>();
        await notificationService.sendNotification(
          parameters: {
            'vesselID': vesselID,
            'bookingID': bookingID,
            'messageText': '${userController.currentUser.value.fullName} made a payment of ${formatCurrency.format(total)} for a booking.',
          },
          receiverUserID: receiver!.userID!,
          type: 'transaction',
          body: '${userController.currentUser.value.fullName} made a payment of ${formatCurrency.format(total)} for a booking.',
        );
        Get.back();
      }
    } catch (e) {
      Get.back();
      showRedAlert('Something went wrong. Please try again.');
      print('@@@@@@@@@@@@@@@@ ERROR @@@@@@@@@@@@@@@@@@@@@');
      print(e);
      return false;
    }
  }

  Future<bool> displayPaymentSheet(setState, String vesselID, num total, num tipAmount) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      final postPaymentIntent = await Stripe.instance.retrievePaymentIntent(paymentIntentData['client_secret']);
      paymentIntentData = null as Map<String, dynamic>;
      setState();
      if (postPaymentIntent.status == PaymentIntentsStatus.Succeeded) {
        transaction = TransactionModel(
          userID: userController.currentUser.value.userID,
          transactionID: Uuid().v1(),
          vesselID: vesselID,
          stripeCustomerID: stripeCustomerID,
          stripePaymentID: postPaymentIntent.id,
          stripeRefundID: '',
          notes: '',
          stripeChargeID: '',
          receiptID: '',
          paymentMethod: 'card',
          type: 'payment',
          tipAmount: tipAmount,
          amount: total,
          creationDate: Timestamp.now(),
        );
        Get.back();
        showGreenAlert('Payment successful');
        return true;
      } else {
        return false;
      }
    } on StripeException catch (e) {
      print('@@@@@@@@@@@@@@@@@ Stripe @@@@@@@@@@@@@@@@@@@@');
      print(e);
      showRedAlert(e.toString());
      return false;
    }
  }
}
