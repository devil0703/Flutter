import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/messages/chats.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';

class UserTile extends StatelessWidget {
  final userID;
  final bool? showMessage;

  UserTile({this.userID, this.showMessage});

  final userService = Get.put(UserService());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userService.getUser(userID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          User user = User.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            onTap: () async {
              if (showMessage!) {
                final dialogService = Get.find<DialogService>();
                final messageService = Get.find<MessageService>();
                dialogService.showLoading();
                String chatRoomID = await messageService.checkIfChatRoomExists(userID);
                DocumentSnapshot doc = await userService.getUser(userID);
                User chatUser = User.fromDocument(doc);
                Get.back();
                // ignore: cast_from_null_always_fails
                Get.to(() => Chats(user: chatUser, chatRoomID: chatRoomID));
              }
            },
            leading: CachedImage(url: user.photoURL, height: 40, roundedCorners: false, circular: true),
            title: Text(user.fullName!, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            subtitle: showMessage ?? true ? Text('Click to send a message') : null,
          );
        } else
          return Container(height: 56);
      },
    );
  }
}
