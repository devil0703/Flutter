import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final bool? archived;
  final String? notificationID;
  final String? type;
  final String? receiverUserID;
  final String? senderUserID;
  final String? bookingID;
  final String? vesselID;
  final String? chatRoomID;
  final String? messageText;
  final Timestamp? creationDate;

  NotificationModel({
    this.archived,
    this.notificationID,
    this.type,
    this.receiverUserID,
    this.senderUserID,
    this.bookingID,
    this.vesselID,
    this.chatRoomID,
    this.messageText,
    this.creationDate,
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    try {
      var snapshot = doc.data() as Map<String, dynamic>; // Assuming data() returns a non-null Map<String, dynamic>

      return NotificationModel(
        archived: snapshot['archived'] ?? false,
        notificationID: snapshot['notificationID'] ?? '',
        type: snapshot['type'] ?? '',
        receiverUserID: snapshot['receiverUserID'] ?? '',
        senderUserID: snapshot['senderUserID'] ?? '',
        bookingID: snapshot['bookingID'] ?? '',
        vesselID: snapshot['vesselID'] ?? '',
        chatRoomID: snapshot['chatRoomID'] ?? '',
        messageText: snapshot['messageText'] ?? '',
        creationDate: snapshot['creationDate'] as Timestamp? ?? Timestamp.fromDate(DateTime(2021)),
      );
    } catch (e) {
      print('****** NOTIFICATION MODEL ******');
      print(e);
      throw Exception('Failed to create NotificationModel from DocumentSnapshot');
    }
  }
}
