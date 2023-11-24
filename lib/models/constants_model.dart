import 'package:cloud_firestore/cloud_firestore.dart';

class ConstantsModel {
  final List? images; // Make images nullable if it can be absent.

  ConstantsModel({this.images});

  // You can also decide to make the images non-nullable and provide a default empty list
  // final List images;
  // ConstantsModel({this.images = const []});

  factory ConstantsModel.fromDocument(DocumentSnapshot documentSnapshot) {
    try {
      Map<String, dynamic>? snapshot = documentSnapshot.data() as Map<String, dynamic>?;
      // Make sure to check if snapshot is not null before trying to access its data
      if (snapshot != null) {
        return ConstantsModel(
          // Use the null-aware operator to provide a default value in case 'images' is null
          images: snapshot['images'] as List? ?? [],
        );
      } else {
        // Handle the case where the snapshot is null
        // You could throw an exception or return a ConstantsModel with default values
        throw Exception('DocumentSnapshot data is null');
      }
    } catch (e) {
      print('******************* CONSTANTS MODEL *****************');
      print(e);
      // If you're handling exceptions by printing, rethrow the exception here
      rethrow;
    }
  }
}
