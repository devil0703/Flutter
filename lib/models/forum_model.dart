import 'package:cloud_firestore/cloud_firestore.dart';

class Forum {
  final String? userID;
  final String? postID;
  final String? vesselID;
  final String? comment;
  final bool? flagged;
  final List<dynamic>? images;
  final Timestamp? creationDate;

  Forum({
    this.userID,
    this.postID,
    this.vesselID,
    this.comment,
    this.flagged,
    this.images,
    this.creationDate,
  });

  factory Forum.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic>? snapshot = doc.data() as Map<String, dynamic>?;
    if (snapshot == null) {
      // Handle null snapshot by returning a default Forum instance
      return Forum(
        userID: '',
        postID: '',
        vesselID: '',
        comment: '',
        flagged: false,
        images: [],
        creationDate: Timestamp.fromDate(DateTime(2021)),
      );
    }
    return Forum(
      userID: snapshot['userID'] as String? ?? '',
      postID: snapshot['postID'] as String? ?? '',
      vesselID: snapshot['vesselID'] as String? ?? '',
      comment: snapshot['comment'] as String? ?? '',
      flagged: snapshot['flagged'] as bool? ?? false,
      images: snapshot['images'] as List<dynamic>? ?? [],
      creationDate: snapshot['creationDate'] as Timestamp? ?? Timestamp.fromDate(DateTime.now()),
    );
  }
}
