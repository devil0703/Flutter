import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String? chatRoomID;
  final String? vesselID;
  final List? users;
  final String? lastMessage;
  final int? lastMessageTime;

  // Assuming all fields are required and must be non-null. 
  // If any of them can be null, you should mark them as nullable with a '?'.
  Conversation({
    this.users,
    this.lastMessage,
    this.lastMessageTime,
    this.chatRoomID,
    this.vesselID,
  });

  factory Conversation.fromDocument(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> doc = documentSnapshot.data() as Map<String, dynamic>;
    // It's safe to assume 'data' is non-null within 'fromDocument' if you are sure the snapshot exists.
    // If 'data' could be null, then you need to handle that case appropriately.
    return Conversation(
      chatRoomID: doc['chatRoomID'] as String,
      vesselID: doc['vesselID'] as String,
      users: doc['users'] as List,
      lastMessage: doc['lastMessage'] as String,
      lastMessageTime: doc['lastMessageTime'] as int,
    );
  }
}
