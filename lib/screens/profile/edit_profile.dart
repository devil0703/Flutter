import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/services/authentication_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/validator_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class EditProfile extends StatefulWidget {
  final User user;

  EditProfile({required this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  final TextEditingController confirmTEC = TextEditingController();
  final TextEditingController emailTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordKey = GlobalKey<FormState>();
  final validatorService = Get.find<ValidatorService>();
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  final authService = Get.find<AuthService>();
  final dialogService = Get.find<DialogService>();

  @override
  void initState() {
    nameTEC.text = userController.currentUser.value.fullName!;
    emailTEC.text = userController.currentUser.value.email!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EDIT PROFILE'.toUpperCase())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(controller: nameTEC, label: 'Full name *', hint: 'Enter full name', validate: true),
                  CustomTextField(controller: emailTEC, label: 'Email Address *', hint: 'Enter email address', validate: true, isEmail: true, textInputType: TextInputType.emailAddress),
                ],
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(onPressed: () => update(), child: Text('UPDATE PROFILE')),
            SizedBox(height: 15),
            Form(
              key: passwordKey,
              child: Column(
                children: [
                  CustomTextField(controller: passwordTEC, label: 'Password *', hint: 'Enter password', validate: true, isPassword: true, textInputType: TextInputType.text),
                  CustomTextField(controller: confirmTEC, label: 'Confirm password *', hint: 'Re-enter password', validate: true, isPassword: true, textInputType: TextInputType.text),
                ],
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(onPressed: () => changePassword(), child: Text('CHANGE PASSWORD')),
          ],
        ),
      ),
    );
  }

  update() async {
    if (!formKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }
    dialogService.showLoading();
    await userService.editUser(User(email: emailTEC.text, fullName: nameTEC.text, unreadNotifications: true, unreadMessages: true, bookingNotifications: true, messageNotifications: true, generalNotifications: true, transactionNotifications: true));
  }

  changePassword() async {
    if (!passwordKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }
    if (passwordTEC.text != confirmTEC.text) {
      showRedAlert('Passwords do not match');
      return;
    }
    dialogService.showLoading();
    authService.changePassword(passwordTEC.text.trim());
  }
}
