import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/review_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/review_item.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:uuid/uuid.dart';

class VesselReviews extends StatefulWidget {
  final Vessel vessel;

  VesselReviews({required this.vessel});

  @override
  _VesselReviewsState createState() => _VesselReviewsState();
}

class _VesselReviewsState extends State<VesselReviews> {
  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VESSEL REVIEWS')),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15.0),
            alignment: Alignment.center,
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                CachedImage(
                  height: 120,
                  url: widget.vessel.images![0],
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(widget.vessel.vesselName!, textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     SmoothStarRating(
                //       onRated: (v) {},
                //       starCount: 5,
                //       rating: widget.vessel.rating.toDouble(),
                //       size: 15.0,
                //       isReadOnly: true,
                //       color: Colors.deepOrangeAccent,
                //       borderColor: Colors.deepOrangeAccent,
                //       spacing: 7.0,
                //     ),
                //     SizedBox(width: 15),
                //     Text('(${widget.vessel.ratingCount.toString()})', textScaleFactor: 0.9),
                //   ],
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text('All Reviews'),
          ),
          Expanded(
            child: showPage(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              text: 'Write a review',
              function: () {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return RatingDialog(
                        starColor: Colors.deepOrangeAccent,
                        image: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedImage(roundedCorners: true, circular: false, height: 75, url: widget.vessel.images![0]),
                          ],
                        ),
                        title: Text("Rate ${widget.vessel.vesselName}"),
                        initialRating: 0,
                        force: true,
                        message: Text("Tap a star to set your rating and press submit"),
                        commentHint: 'Tell us what you think...',
                        submitButtonText: "SUBMIT",
                        // alternativeButton: "Contact us instead?",
                        // // optional
                        // positiveComment: "Great news!",
                        // // optional
                        // negativeComment: "Oh dear!",
                        // // optional
                        // accentColor: Colors.red,
                        // optional
                        onSubmitted: (response) async {
                          if (response.comment.isNotEmpty && response.rating > 0) {
                            Get.back();
                            Review review = Review(
                              userID: userController.currentUser.value.userID,
                              flagged: false,
                              comment: response.comment,
                              rating: response.rating.toDouble(),
                              reviewID: Uuid().v1(),
                              vesselID: widget.vessel.vesselID,
                            );
                            await vesselService.addReview(review, widget.vessel);
                          } else
                            showRedAlert('Please tap a star and enter a comment');
                        },
                        //onAlternativePressed: () => openLink('tel:${venue.venuePhoneNumber}'),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  showPage() {
    return PaginateFirestore(
      key: GlobalKey(),
      padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25),
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshot, i) {
        Review review = Review.fromDocument(documentSnapshot[i]);
        return ReviewItem(review: review);
      },
      query: vesselService.getVesselReviews(widget.vessel.vesselID!, 5000),
      onEmpty: EmptyBox(text: 'Be the first one to review'),
      itemsPerPage: 10,
      bottomLoader: LoadingData(),
      initialLoader: LoadingData(),
    );
  }
}
