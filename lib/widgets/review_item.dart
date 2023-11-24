import 'package:flutter/material.dart';
import 'package:makaiapp/models/review_model.dart';
import 'package:makaiapp/widgets/user_tile.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewItem extends StatelessWidget {
  final Review? review;

  ReviewItem({this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserTile(userID: review!.userID, showMessage: false),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmoothStarRating(
                starCount: 5,
                rating: review!.rating!.toDouble(),
                size: 20.0,
                color: Colors.amber,
                borderColor: Colors.amber,
                spacing: 0.0,
              ),
              Text(
                timeago.format(review!.creationDate!.toDate()),
                style: TextStyle(color: Colors.grey),
                textScaleFactor: 0.9,
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            review!.comment!,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
