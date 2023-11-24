import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final String serverToken = 'AAAACUCrSkk:APA91bGvaSEGD-c_ygf7yg_fk0qGwt46_DO_8Unv9Jv290IksYzzmg9hIa0ZfTJjcKRJ991mIu234BeNESlmjGoXqK8D7lGQaOIcp7MryAk1DVfHfuMkP50otH_j-GDj_0Mcp2eP7OJl';
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();

  getNotifications(int limit, bool archived) {
    return ref.collection("notifications").where('receiverUserID', isEqualTo: userController.currentUser.value.userID).where('archived', isEqualTo: archived).orderBy('creationDate', descending: true).limit(limit);
  }

  archiveNotification(String notificationID) async {
    await ref.collection('notifications').doc(notificationID).update({'archived': true});
    return;
  }

  sendNotification({Map<String, dynamic>? parameters, String? receiverUserID, String? body, String ? type}) async {
    //GET RECEIVER USER FOR TOKEN
    DocumentSnapshot doc = await userService.getUser(receiverUserID);
    User receiverUser = User.fromDocument(doc);

    //ADD MANDATORY PARAMETERS FOR NOTIFICATION
    parameters!['creationDate'] = Timestamp.now();
    parameters['receiverUserID'] = receiverUserID;
    parameters['notificationID'] = Uuid().v1();
    parameters['senderUserID'] = userController.currentUser.value.userID;
    parameters['type'] = type;
    parameters['archived'] = false;

    //DEPENDING ON THE TYPE STORE NOTIFICATION DETAILS AND FLAGS
    if (type != 'message') {
      await ref.collection('notifications').doc(parameters['notificationID']).set(parameters!);
      await userService.updateOtherUser(receiverUserID!, {'unreadNotifications': true});
    } else
      await userService.updateOtherUser(receiverUserID!, {'unreadMessages': true});

    print(receiverUser.token);

    //SEND NOTIFICATIONS
    return await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'key=$serverToken'},
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'title': body, 'body': 'From: ' + userController.currentUser.value.fullName!},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'sound': 'default',
            'id': '1',
            'status': 'done',
            'type': type,
            'title': userController.currentUser.value.fullName,
            'body': body,
          },
          'to': receiverUser.token,
        },
      ),
    );
  }
}
