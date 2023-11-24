import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/services/authentication_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/validator_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class ForgotPassword extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final validatorService = Get.find<ValidatorService>();
  final userService = Get.find<UserService>();
  final dialogService = Get.find<DialogService>();
  final authService = Get.find<AuthService>();
  final TextEditingController emailTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/makailogo.png',
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                    ),
                  ),
                  CustomTextField(controller: emailTEC, label: 'Email Address *', hint: 'Enter email address', validate: true, isEmail: true, textInputType: TextInputType.emailAddress),
                  SizedBox(height: 25),
                  ElevatedButton(
                      onPressed: () async {
                        if (emailTEC.text.isNotEmpty) {
                          await authService.resetPassword(emailTEC.text.trim());
                        } else
                          showRedAlert('Please enter your email');
                      },
                      child: Text('Send password reset link', textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(height: 15),
                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueGrey.shade400)), onPressed: () => Get.offAll(() => Login()), child: Text('Go Back', textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
