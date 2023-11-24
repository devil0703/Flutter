import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/screens/auth/splash_screen.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final userController = Get.find<UserController>();

  registerFirebase() async {
    if (Platform.isIOS) {
      await messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);
    }
    String? firebaseToken = await messaging.getToken();
    await updateUser({
      'token': firebaseToken,
      'updatedDate': Timestamp.now(),
    });
  }

  setCurrentUser(String email) async {
    QuerySnapshot querySnapshot = await ref.collection('users').where('email', isEqualTo: email).get();
    DocumentSnapshot doc = querySnapshot.docs[0];
    userController.currentUser.value = User.fromDocument(doc);
    await Preferences.setUser(userController.currentUser.value.userID!);
    await getCurrentUser();
  }

  getCurrentUser() async {
    try {
      String userID = await Preferences.getUser();
      print('USER ID $userID');
      DocumentSnapshot doc = await ref.collection('users').doc(userID).get();
      userController.currentUser.value = User.fromDocument(doc);
      return;
    } catch (e) {
      print(e);
      userController.currentUser.value = User as User;
      return;
    }
  }

  Future<bool> checkIfUserExists(String email) async {
    QuerySnapshot querySnapshot = await ref.collection('users').where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  addUser(User user) async {
    final bookingService = Get.put(BookingService());
    String userID = Uuid().v1();
    await Preferences.setUser(userID);
    await ref.collection('users').doc(userID).set({
      'userID': userID,
      'fullName': user.fullName,
      'email': user.email,
      'bookingNotifications': true,
      'messageNotifications': true,
      'generalNotifications': true,
      'transactionNotifications': true,
      'creationDate': Timestamp.now(),
      'updatedDate': Timestamp.now(),
      'status': 'Active',
      'stripeCustomerID': await bookingService.createCustomer(user.email!, user.fullName!),
    });
    userController.currentUser.value = user;
    Get.offAll(() => SplashScreen());
  }

  editUser(User user) async {
    await ref.collection('users').doc(userController.currentUser.value.userID).update({
      'fullName': user.fullName,
      'email': user.email,
      'updatedDate': Timestamp.now(),
    }).then((value) {
      Get.back();
      showGreenAlert('Profile updated');
    }).catchError((e) {
      Get.back();
      showRedAlert('Something went wrong');
    });
    await getCurrentUser();
  }

  updateUser(data) async {
    await ref.collection('users').doc(userController.currentUser.value.userID).update(data);
    await getCurrentUser();
  }

  updateOtherUser(String userID, data) async {
    await ref.collection('users').doc(userID).update(data);
  }

  Future<DocumentSnapshot> getUser(id) async {
    return ref.collection('users').doc(id).get();
  }

  Stream<DocumentSnapshot> getUserStream(id) {
    return ref.collection('users').doc(id).snapshots();
  }

  Future<User?> getUserFromEmail(String email) async {
    QuerySnapshot querySnapshot = await ref.collection('users').where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isEmpty) {
      return null;
    } else
      return User.fromDocument(querySnapshot.docs[0]);
  }

  addBanking(Map bank) async {
    await ref.collection('banking').doc(userController.currentUser.value.userID).set(bank as Map<String, dynamic>);
  }

  updateBanking(Map bank) async {
    await ref.collection('banking').doc(userController.currentUser.value.userID).update(bank as Map<String, dynamic>);
  }

  getBankingDetails() async {
    return await ref.collection('banking').doc(userController.currentUser.value.userID).get();
  }
}
