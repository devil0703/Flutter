import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/conversation_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/messages/chats.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationItem extends StatelessWidget {
  final Conversation? conversation;

  ConversationItem({this.conversation});

  final messageService = Get.find<MessageService>();
  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    List users = conversation!.users!;
    users.remove(userController.currentUser.value.userID);
    String userID = users[0];
    print(userID);
    return conversation!.lastMessage != ''
        ? StreamBuilder(
            stream: messageService.getUserStream(userID),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                User user = User.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
                return FutureBuilder(
                  future: vesselService.getVesselForVesselID(conversation!.vesselID!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Vessel vessel = Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
                      if (MY_ROLE == VESSEL_USER)
                        return item(vessel.vesselName! + ' (' + user.fullName! + ')', vessel.images![0], user, vessel);
                      else
                        return item(user.fullName!, user.photoURL!, user, vessel);
                    } else
                      return item(user.fullName!, user.photoURL!, user, true as Vessel);
                  },
                );
              } else
                return Text('');
            },
          )
        : Text('');
  }

  item(String name, String image, User user, Vessel vessel) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => Get.to(() => Chats(user: user, vessel: vessel, chatRoomID: conversation!.chatRoomID)),
      leading: CachedImage(url: image, height: 60, roundedCorners: true, circular: null,),
      title: Text(name, textScaleFactor: 1.15, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Expanded(child: Text(conversation!.lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey), textScaleFactor: 0.95)),
          SizedBox(width: 5),
          Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(conversation!.lastMessageTime!)), style: TextStyle(color: Colors.grey), textScaleFactor: 0.8),
        ],
      ),
    );
  }
}
