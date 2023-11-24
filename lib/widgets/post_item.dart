import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/forum_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/messages/view_image.dart';
import 'package:makaiapp/screens/vessels/write_post.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItem extends StatelessWidget {
  final Forum? forum;
  final Vessel? vessel;

  PostItem({this.forum, this.vessel});

  final userController = Get.find<UserController>();
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
          if (forum!.images!.isNotEmpty)
            GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: forum!.images!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () => Get.to(() => ViewImages(images: forum!.images!, index: i)),
                  child: CachedImage(
                    url: forum!.images![i],
                    height: 100,
                    roundedCorners: true,
                    circular: false,
                  ),
                );
              },
            ),
          Text(
            forum!.comment!,
            textAlign: TextAlign.justify,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeago.format(forum!.creationDate!.toDate()),
                style: TextStyle(color: Colors.grey),
                textScaleFactor: 0.9,
              ),
              if (forum!.userID == userController.currentUser.value.userID) InkWell(onTap: () => Get.to(() => WritePost(vessel: vessel!, forum: forum!)), child: Text('Edit')),
            ],
          ),
        ],
      ),
    );
  }
}
