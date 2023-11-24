import 'package:cloud_firestore/cloud_firestore.dart';

class License {
  final String? licenseID;
  final String? userID;
  final String? vesselID;
  final List? licenses;
  final String? documentNumber;
  final String? licenseType;
  final String? countryCode;
  final String? referenceNumber;
  final String? fullName;
  final String? address;
  final String? citizenship;
  final Timestamp? dob;
  final Timestamp? issueDate;
  final Timestamp? expiryDate;

  License({
    this.licenseID,
    this.userID,
    this.vesselID,
    this.licenses,
    this.documentNumber,
    this.licenseType,
    this.countryCode,
    this.referenceNumber,
    this.fullName,
    this.address,
    this.citizenship,
    this.dob,
    this.issueDate,
    this.expiryDate,
  });

  factory License.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic>? snapshot = doc.data() as Map<String, dynamic>?;
    if (snapshot == null) {
      // Handle the case where the snapshot is null
      // Perhaps by logging the error and returning a default License instance
      // Or by throwing an appropriate exception
    }
    return License(
      licenseID: snapshot?['licenseID'] as String? ?? '',
      userID: snapshot?['userID'] as String? ?? '',
      vesselID: snapshot?['vesselID'] as String? ?? '',
      licenses: snapshot?['licenses'] as List<dynamic>? ?? [],
      documentNumber: snapshot?['documentNumber'] as String? ?? '',
      licenseType: snapshot?['licenseType'] as String? ?? '',
      countryCode: snapshot?['countryCode'] as String? ?? '',
      referenceNumber: snapshot?['referenceNumber'] as String? ?? '',
      fullName: snapshot?['fullName'] as String? ?? '',
      address: snapshot?['address'] as String? ?? '',
      citizenship: snapshot?['citizenship'] as String? ?? '',
      dob: snapshot?['dob'] as Timestamp? ?? Timestamp.fromDate(DateTime.now()),
      issueDate: snapshot?['issueDate'] as Timestamp? ?? Timestamp.fromDate(DateTime.now()),
      expiryDate: snapshot?['expiryDate'] as Timestamp? ?? Timestamp.fromDate(DateTime(2100)),
    );
  }
}
