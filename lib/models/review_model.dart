import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? userID;
  final String? reviewID;
  final String? vesselID;
  final String? comment;
  final bool? flagged;
  final num? rating;
  final Timestamp? creationDate;

  Review({
    this.userID,
    this.reviewID,
    this.vesselID,
    this.comment,
    this.flagged,
    this.rating,
    this.creationDate,
  });

  factory Review.fromDocument(DocumentSnapshot doc) {
    try {
      // Casting with null safety
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      // Provide defaults or allow null for each field
      return Review(
        userID: data?['userID'] as String?,
        reviewID: data?['reviewID'] as String?,
        vesselID: data?['vesselID'] as String?,
        comment: data?['comment'] as String?,
        flagged: data?['flagged'] as bool?,
        rating: data?['rating'] as num?,
        creationDate: data?['creationDate'] as Timestamp?,
      );
    } catch (e) {
      print('****** REVIEW MODEL ******');
      print(e);
      // Use rethrow to throw the exception again instead of returning null.
      rethrow;
    }
  }
}
