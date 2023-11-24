import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? userID;
  final String? paymentID;
  final String? stripeCustomerID;
  final String? stripeCustomerEphemeralKey;
  final String? fullName;
  final String? email;
  final String? photoURL;
  final String? token;
  final String? status;
  final String? tripStatus;
  final List<dynamic>? owners; // User is an owner of these vessels
  final List<dynamic>? captains; // User is a captain of these vessels
  final List<dynamic>? crew; // User is a crew member of these vessels
  //final List<dynamic>? receptionists; // User is a receptionist of these vessels
  bool? unreadNotifications;
  bool? unreadMessages;
  String? verification;
  bool? bookingNotifications;
  bool? messageNotifications;
  bool? generalNotifications;
  bool? transactionNotifications;

  User({
    this.userID,
    this.paymentID,
    this.stripeCustomerID,
    this.stripeCustomerEphemeralKey,
    this.fullName,
    this.email,
    this.photoURL,
    this.token,
    this.status,
    this.tripStatus,
    this.owners,
    this.captains,
    this.crew,
    //this.receptionists,
    this.unreadNotifications,
    this.unreadMessages,
    this.verification,
    this.bookingNotifications,
    this.messageNotifications,
    this.generalNotifications,
    this.transactionNotifications,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      print('DocumentSnapshot.data() is null');
      throw Exception('Document data is null');
    }

    return User(
      userID: data['userID'] as String?,
      paymentID: data['paymentID'] as String?,
      stripeCustomerID: data['stripeCustomerID'] as String?,
      stripeCustomerEphemeralKey: data['stripeCustomerEphemeralKey'] as String?,
      fullName: data['fullName'] as String?,
      email: data['email'] as String?,
      photoURL: data['photoURL'] as String? ?? 'default_profile_picture.png',
      token: data['token'] as String?,
      status: data['status'] as String?,
      tripStatus: data['tripStatus'] as String? ?? 'STOP',
      owners: data['owners'] as List<dynamic>?,
      captains: data['captains'] as List<dynamic>?,
      crew: data['crew'] as List<dynamic>?,
      //receptionists: data['receptionists'] as List<dynamic>?,
      unreadNotifications: data['unreadNotifications'] as bool? ?? false,
      unreadMessages: data['unreadMessages'] as bool? ?? false,
      verification: data['verification'] as String?,
      bookingNotifications: data['bookingNotifications'] as bool? ?? true,
      messageNotifications: data['messageNotifications'] as bool? ?? true,
      generalNotifications: data['generalNotifications'] as bool? ?? true,
      transactionNotifications: data['transactionNotifications'] as bool? ?? true,
    );
  }
}
