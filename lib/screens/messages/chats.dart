import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/vessels/view_vessel.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/notification_service.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/message_box.dart';

class Chats extends StatefulWidget {
  final User user;
  final chatRoomID;
  final Vessel? vessel;

  Chats({this.chatRoomID,required this.user, this.vessel});

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  Rx<TextEditingController> messageTEC = TextEditingController().obs;
  final messageService = Get.find<MessageService>();
  final vesselService = Get.find<VesselService>();
  final notificationService = Get.find<NotificationService>();
  final userController = Get.find<UserController>();
  final storageService = Get.find<StorageService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.fullName!, textScaleFactor: 1.15, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            selectedTileColor: Colors.grey.shade300,
            selected: true,
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            leading: CachedImage(url: widget.vessel!.images![0], roundedCorners: true, height: 50),
            onTap: () => Get.to(() => ViewVessel(false, vesselID: widget.vessel!.vesselID!)),
            title: Text(MY_ROLE == VESSEL_USER ? 'You are chatting with the owner of ${widget.vessel!.vesselName} - ${widget.user.fullName}' : 'This conversation is related to ${widget.vessel!.vesselName}', textScaleFactor: 1.1, style: TextStyle(color: secondaryColor)),
            subtitle: Text('Click to view vessel'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: messageService.getMessages(widget.chatRoomID),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return snapshot.hasData
                    ? snapshot.data!.docs.isNotEmpty
                        ? ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              index = snapshot.data!.docs.length - 1 - index;
                              Map<String, dynamic> doc = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              return MessageBox(
                                docID: snapshot.data!.docs[index].id,
                                time: doc['time'],
                                message: doc["message"],
                                imageURL: doc["imageURL"],
                                isSent: userController.currentUser.value.userID == doc["sentBy"],
                              );
                            })
                        : EmptyBox(text: 'Start a conversation')
                    : LoadingData();
              },
            ),
          ),
          Obx(() {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                maxLines: null,
                controller: messageTEC.value,
                style: TextStyle(color: primaryColor),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.attach_file, color: primaryColor),
                    onPressed: () async {
                      File image = await storageService.pickImage();
                      showYellowAlert('Uploading image');
                      String profilePhotoURL = await storageService.uploadPhoto(image, 'messages');
                      await addImageMsg(profilePhotoURL);
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: primaryColor),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      addMsg();
                    },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  addMsg() async {
    print(widget.chatRoomID);
    print(userController.currentUser.value.userID);
    if (messageTEC.value.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'chatRoomID': widget.chatRoomID,
        "sentBy": userController.currentUser.value.userID,
        "message": messageTEC.value.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      messageService.addMessage(widget.chatRoomID, chatMessageMap);
      notificationService.sendNotification(
        parameters: {
          'chatRoomID': widget.chatRoomID,
        },
        body: messageTEC.value.text,
        receiverUserID: widget.user.userID!,
        type: 'message',
      );

      messageTEC.value.clear();
    }
  }

  addImageMsg(photoURL) async {
    Map<String, dynamic> chatMessageMap = {
      'chatRoomID': widget.chatRoomID,
      "sentBy": userController.currentUser.value.userID,
      "message": '▶ Photo',
      'imageURL': photoURL,
      'time': DateTime.now().millisecondsSinceEpoch,
    };

    messageService.addMessage(widget.chatRoomID, chatMessageMap);
    notificationService.sendNotification(
      parameters: {
        'chatRoomID': widget.chatRoomID,
      },
      body: '▶ Photo',
      receiverUserID: widget.user.userID!,
      type: 'message',
    );
  }
}
