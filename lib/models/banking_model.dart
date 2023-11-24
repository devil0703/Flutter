import 'package:cloud_firestore/cloud_firestore.dart';

class Banking {
  final String? userID;
  final String? bankName;
  final String? accountName;
  final String? accountNo;
  final String? routingNo;
  final String? country;

  Banking({
    this.userID,
    this.bankName,
    this.accountName,
    this.accountNo,
    this.routingNo,
    this.country,
  });

  factory Banking.fromDocument(DocumentSnapshot doc) {
    // Assuming that 'data()' returns a non-null map.
    // If it can return null, you should handle that case as well.
    Map<String, dynamic> snapshot = doc.data() as Map<String, dynamic>;

    return Banking(
      userID: snapshot['userID'] ?? '', // The '??' operator gives a default value if 'null'
      bankName: snapshot['bankName'] ?? '',
      accountName: snapshot['accountName'] ?? '',
      accountNo: snapshot['accountNo'] ?? '',
      routingNo: snapshot['routingNo'] ?? '',
      country: snapshot['country'] ?? 'United States', // Providing a default value
    );
  }
}
