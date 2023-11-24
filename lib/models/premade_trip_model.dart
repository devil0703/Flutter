import 'package:cloud_firestore/cloud_firestore.dart';

class PreMadeTrip {
  final String? userID;
  final String? tripID;
  final String? vesselID;
  final String? type;
  final num? price;
  final num? duration;
  final Timestamp? tripDate;

  PreMadeTrip({
    this.userID,
    this.tripID,
    this.vesselID,
    this.type,
    this.price,
    this.duration,
    this.tripDate,
  });

  factory PreMadeTrip.fromDocument(DocumentSnapshot doc) {
    try {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      // Provide defaults for each field or handle potential null cases.
      return PreMadeTrip(
        userID: data?['userID'] as String?,
        tripID: data?['tripID'] as String?,
        vesselID: data?['vesselID'] as String?,
        type: data?['type'] as String?,
        price: data?['price'] as num?,
        duration: data?['duration'] as num?,
        tripDate: data?['tripDate'] as Timestamp?,
      );
    } catch (e) {
      print('****** PRE MADE TRIP MODEL ******');
      print(e);
      rethrow; // Rather than returning null, it is better to rethrow the exception.
    }
  }
}
