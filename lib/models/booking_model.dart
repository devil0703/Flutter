import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? userID;
  final String? bookingID;
  final String? paymentMethodID; //This is the payment method ID
  final String? paymentIntentID;
  final String? bookingRef;
  final String? vesselID;
  final num? seatCost;
  final bool? paid;
  final bool? isPreMadeTrip;
  final String? status;
  final String? bookingAgreement;
  final num? guestCount;
  final num? tipAmount;
  final num? totalCost;
  final num? duration;
  final Timestamp? travelDate;
  final Timestamp? creationDate;

  Booking({
    this.userID,
    this.bookingID,
    this.paymentMethodID,
    this.paymentIntentID,
    this.bookingRef,
    this.vesselID,
    this.seatCost,
    this.paid,
    this.isPreMadeTrip,
    this.status,
    this.bookingAgreement,
    this.guestCount,
    this.tipAmount,
    this.totalCost,
    this.duration,
    this.creationDate,
    this.travelDate,
  });

  factory Booking.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> snapshot = doc.data() as Map<String, dynamic>? ?? {};

    DateTime defaultDate = DateTime(2021);
    return Booking(
      userID: snapshot['userID'] ?? '',
      bookingID: snapshot['bookingID'] ?? '',
      paymentMethodID: snapshot['paymentMethodID'] ?? '',
      paymentIntentID: snapshot['paymentIntentID'] ?? '',
      bookingRef: snapshot['bookingRef'] ?? '',
      vesselID: snapshot['vesselID'] ?? '',
      seatCost: snapshot['seatCost']?.toDouble() ?? 0,
      paid: snapshot['paid'] ?? false,
      isPreMadeTrip: snapshot['isPreMadeTrip'] ?? false,
      status: snapshot['status'] ?? '',
      bookingAgreement: snapshot['bookingAgreement'] ?? '',
      guestCount: snapshot['guestCount']?.toInt() ?? 0,
      tipAmount: snapshot['tipAmount']?.toDouble() ?? 0,
      totalCost: snapshot['totalCost']?.toDouble() ?? 0,
      duration: snapshot['duration']?.toDouble() ?? 0,
      creationDate: snapshot['creationDate'] as Timestamp? ?? Timestamp.fromDate(defaultDate),
      travelDate: snapshot['travelDate'] as Timestamp? ?? Timestamp.fromDate(defaultDate),
    );
  }
}
