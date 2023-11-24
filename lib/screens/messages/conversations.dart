import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/conversation_model.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/conversation_item.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class Conversations extends StatefulWidget {
  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  TextEditingController searchTEC = new TextEditingController();
  bool isSearching = false;
  final messageService = Get.find<MessageService>();
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();

  @override
  void initState() {
    searchTEC.addListener(() {
      if (searchTEC.text.length > 2)
        isSearching = true;
      else
        isSearching = false;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MESSAGES')),
      body: Column(
        children: [
          if (MY_ROLE != VESSEL_USER) Container(color: Colors.white, padding: const EdgeInsets.all(15), width: double.infinity, alignment: Alignment.center, child: Text('Logged in as - $MY_ROLE', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold))),
          Expanded(
            child: showPage(),
          ),
        ],
      ),
    );
  }

  showPage() {
    return PaginateFirestore(
      isLive: true,
      padding: const EdgeInsets.all(15),
      key: GlobalKey(),
      shrinkWrap: true,
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshot, i) {
        Conversation conversation = Conversation.fromDocument(documentSnapshot[i]);
        if (MY_ROLE != VESSEL_USER) {
          if (conversation.users![0] != userController.currentUser.value.userID)
            return ConversationItem(conversation: conversation);
          else
            return Container();
        } else {
          if (conversation.users![0] == userController.currentUser.value.userID)
            return ConversationItem(conversation: conversation);
          else
            return Container();
        }
      },
      query: messageService.getAllConversations(),
      onEmpty: EmptyBox(text: 'No messages to show'),
      itemsPerPage: 10,
      bottomLoader: LoadingData(),
      initialLoader: LoadingData(),
    );
  }
}
