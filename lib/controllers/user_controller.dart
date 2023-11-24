import 'package:get/get.dart';
import 'package:makaiapp/models/users_model.dart';

class UserController extends GetxController {
  Rx<User> currentUser = User(unreadNotifications: true, unreadMessages: true, bookingNotifications: true, messageNotifications: true, generalNotifications: true, transactionNotifications: true).obs;

  double myLatitude = 51.509865;
  double myLongitude = -0.118092;
}
