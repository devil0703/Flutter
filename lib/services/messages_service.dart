import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/utils/constants.dart';

class MessageService {
  final userController = Get.find<UserController>();

  Future<DocumentSnapshot> getUser(id) async {
    return ref.collection('users').doc(id).get();
  }

  Stream<DocumentSnapshot> getUserStream(id) {
    return ref.collection('users').doc(id).snapshots();
  }

  Stream<DocumentSnapshot> getVesselStream(id) {
    return ref.collection('vessels').doc(id).snapshots();
  }

  Stream<QuerySnapshot> getConversations(bool userInitiated) {
    return ref.collection("chats").where('users', arrayContains: userController.currentUser.value.userID).where('userInitiated', isEqualTo: userInitiated).orderBy('lastMessageTime', descending: true).snapshots();
  }

  getAllConversations() {
    return ref.collection("chats").where('users', arrayContains: userController.currentUser.value.userID).orderBy('lastMessageTime', descending: true);
  }

  Stream<QuerySnapshot> getMessages(String chatRoomID) {
    return ref.collection("chats").doc(chatRoomID).collection('messages').orderBy('time').snapshots();
  }

  addMessage(String chatRoomID, chatMessageData) {
    ref.collection("chats").doc(chatRoomID).collection('messages').add(chatMessageData);
    ref.collection("chats").doc(chatRoomID).update({
      'lastMessage': chatMessageData['message'],
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  deleteMessage(String docID) {
    ref.collection("chats").doc(docID).update({
      'message': 'This message was deleted',
    });
  }

  checkIfVesselChatRoomExists(String userID, String vesselID, bool userToAdmin, bool adminToUser) async {
    try {
      bool chatRoomExists = false;
      QuerySnapshot querySnapshot = await ref.collection("chats").where('users', arrayContains: userController.currentUser.value.userID).get();
      if (querySnapshot.docs.isNotEmpty) {
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          if (querySnapshot.docs[i].id.contains(userID)) {
            print('RETURNING CHATROOM ID : ' + querySnapshot.docs[i].id);
            chatRoomExists = true;
            return querySnapshot.docs[i].id;
          }
        }
        if (!chatRoomExists) return createVesselChatRoom(userID, vesselID, userToAdmin, adminToUser);
      } else {
        print('CREATING CHATROOM');
        return createVesselChatRoom(userID, vesselID, userToAdmin, adminToUser);
      }
    } catch (e) {
      print(e);
    }
  }

  createVesselChatRoom(String userID, String vesselID, bool userToAdmin, bool adminToUser) async {
    String chatRoomID = userController.currentUser.value.userID! + "|" + userID;
    ref.collection("chats").doc(chatRoomID).set({
      'chatRoomID': chatRoomID,
      'vesselID': vesselID,
      'lastMessage': '',
      //'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      'users': [userController.currentUser.value.userID, userID],
      'userInitiated': MY_ROLE == VESSEL_USER,
      'userToAdmin': userToAdmin,
      'adminToUser': adminToUser,
    }).catchError((e) {
      print(e);
      showRedAlert('Something went wrong');
    });

    return userController.currentUser.value.userID! + "|" + userID;
  }

  checkIfChatRoomExists(String userID) async {
    try {
      bool chatRoomExists = false;
      QuerySnapshot querySnapshot = await ref.collection("chats").where('users', arrayContains: userController.currentUser.value.userID).get();
      if (querySnapshot.docs.isNotEmpty) {
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          if (querySnapshot.docs[i].id.contains(userID)) {
            print('RETURNING CHATROOM ID : ' + querySnapshot.docs[i].id);
            chatRoomExists = true;
            return querySnapshot.docs[i].id;
          }
        }
        if (!chatRoomExists) return createChatRoom(userID);
      } else {
        print('CREATING CHATROOM');
        return createChatRoom(userID);
      }
    } catch (e) {
      print(e);
    }
  }

  createChatRoom(String userID) async {
    String chatRoomID = userController.currentUser.value.userID! + "|" + userID;
    ref.collection("chats").doc(chatRoomID).set({
      'chatRoomID': chatRoomID,
      'lastMessage': '',
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      'users': [userController.currentUser.value.userID, userID],
    }).catchError((e) {
      print(e);
      showRedAlert('Something went wrong');
    });

    return userController.currentUser.value.userID! + "|" + userID;
  }
}
