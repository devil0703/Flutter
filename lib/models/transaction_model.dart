import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? userID;
  final String? transactionID;
  final String? vesselID;
  final String? stripeCustomerID;
  final String? stripeChargeID;
  final String? stripePaymentID;
  final String? stripeRefundID;
  final String? notes;
  final String? paymentMethod;
  final String? receiptID;
  final String? type;
  final num? tipAmount;
  final num? amount;
  final Timestamp? creationDate;

  TransactionModel({
    this.userID,
    this.transactionID,
    this.vesselID,
    this.stripeCustomerID,
    this.stripeChargeID,
    this.stripePaymentID,
    this.stripeRefundID,
    this.notes,
    this.paymentMethod,
    this.receiptID,
    this.type,
    this.tipAmount,
    this.amount,
    this.creationDate,
  });

  factory TransactionModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> snapshot = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      userID: snapshot['userID'] as String?,
      transactionID: snapshot['transactionID'] as String?,
      vesselID: snapshot['vesselID'] as String?,
      stripeCustomerID: snapshot['stripeCustomerID'] as String?,
      stripeChargeID: snapshot['stripeChargeID'] as String?,
      stripePaymentID: snapshot['stripePaymentID'] as String?,
      stripeRefundID: snapshot['stripeRefundID'] as String?,
      notes: snapshot['notes'] as String?,
      paymentMethod: snapshot['paymentMethod'] as String? ?? 'card',
      receiptID: snapshot['receiptID'] as String?,
      type: snapshot['type'] as String? ?? 'payment',
      tipAmount: snapshot['tipAmount'] as num? ?? 0,
      amount: snapshot['amount'] as num? ?? 0,
      creationDate: snapshot['creationDate'] as Timestamp?,
    );
  }
}
