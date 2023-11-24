import 'package:cloud_firestore/cloud_firestore.dart';

class Certificate {
  final String? certificateID;
  final String? userID;
  final String? vesselID;
  final List<dynamic>? certificates;
  final String? certificateAuthority;
  final String? certificateType;
  final String? cNumber;
  final String? vDNumber;
  final String? mONumber;
  final String? port;
  final String? tonnage;
  final Timestamp? buildDate;
  final Timestamp? issueDate;
  final Timestamp? expiryDate;
  final String? issuePlace;

  Certificate({
    this.certificateID,
    this.userID,
    this.vesselID,
    this.certificates,
    this.certificateAuthority,
    this.certificateType,
    this.cNumber,
    this.vDNumber,
    this.mONumber,
    this.port,
    this.tonnage,
    this.buildDate,
    this.issueDate,
    this.expiryDate,
    this.issuePlace,
  });

  factory Certificate.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> snapshot = doc.data() as Map<String, dynamic>? ?? {};

    return Certificate(
      certificateID: snapshot['certificateID'] as String?,
      userID: snapshot['userID'] as String?,
      vesselID: snapshot['vesselID'] as String?,
      certificateAuthority: snapshot['certificateAuthority'] as String?,
      certificates: snapshot['certificates'] as List<dynamic>?,
      certificateType: snapshot['certificateType'] as String?,
      cNumber: snapshot['cNumber'] as String?,
      vDNumber: snapshot['vDNumber'] as String?,
      mONumber: snapshot['mONumber'] as String?,
      port: snapshot['port'] as String?,
      tonnage: snapshot['tonnage'] as String?,
      buildDate: snapshot['buildDate'] as Timestamp?,
      issueDate: snapshot['issueDate'] as Timestamp?,
      expiryDate: snapshot['expiryDate'] as Timestamp?,
      issuePlace: snapshot['issuePlace'] as String?,
    );
  }
}
