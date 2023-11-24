import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/screens/auth/forgot_password.dart';
import 'package:makaiapp/screens/home/home_page.dart';
import 'package:makaiapp/services/authentication_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/misc_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/validator_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final validatorService = Get.find<ValidatorService>();
  final userService = Get.find<UserService>();
  final dialogService = Get.find<DialogService>();
  final authService = Get.find<AuthService>();
  final miscService = Get.find<MiscService>();
  final TextEditingController nameTEC = TextEditingController();
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  String userType = 'User';
  RxBool signIn = true.obs;

  @override
  void initState() {
    MY_ROLE = userType;

    init();

    super.initState();
  }

  init() async {
    final storage = new FlutterSecureStorage();
    emailTEC.text = (await storage.read(key: 'email'))!;
    passwordTEC.text = (await storage.read(key: 'password'))!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(systemOverlayStyle: SystemUiOverlayStyle.dark, backgroundColor: Colors.transparent),
      body: Obx(
        () => Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              //  padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Image.asset('assets/images/s1.png', height: Get.width, fit: BoxFit.contain),
                  // Container(
                  //   height: Get.width,
                  //   margin: const EdgeInsets.only(bottom: 10),
                  //   child: FutureBuilder(
                  //       future: authService.getSlideImages(),
                  //       builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  //         if (!snapshot.hasData)
                  //           return LoadingData();
                  //         else {
                  //           ConstantsModel constantsModel = ConstantsModel.fromDocument(snapshot.data);
                  //           return Swiper(
                  //             controller: SwiperController(),
                  //             loop: true,
                  //             itemBuilder: (context, i) {
                  //               return Padding(
                  //                 padding: const EdgeInsets.only(bottom: 20),
                  //                 //child: Image.asset("assets/images/s${i + 1}.png", fit: BoxFit.fitWidth),
                  //                 child: CachedImage(height: double.infinity, url: constantsModel.images[i], roundedCorners: true),
                  //               );
                  //             },
                  //             itemCount: 5,
                  //             autoplay: true,
                  //             pagination: new SwiperPagination(
                  //               margin: EdgeInsets.only(top: 25),
                  //               builder: SwiperCustomPagination(
                  //                 builder: (BuildContext context, SwiperPluginConfig config) {
                  //                   return DotSwiperPaginationBuilder(color: Colors.grey, activeColor: primaryColor, size: 8, activeSize: 8).build(context, config);
                  //                 },
                  //               ),
                  //             ),
                  //           );
                  //         }
                  //       }),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          if (signIn.isFalse) CustomTextField(controller: nameTEC, label: '', hint: 'Enter full name', validate: true, autofillHints: AutofillHints.name),
                          SizedBox(height: 20),
                          CustomTextField(controller: emailTEC, label: '', hint: 'Enter email address', validate: true, isEmail: true, textInputType: TextInputType.emailAddress, autofillHints: AutofillHints.email),
                          SizedBox(height: 20),
                          CustomTextField(controller: passwordTEC, label: '', hint: 'Enter password', validate: true, isPassword: true, textInputType: TextInputType.text, autofillHints: AutofillHints.password),
                          SizedBox(height: 20),
                          CustomButton(function: () => signIn.isTrue ? login() : signUp(), text: signIn.isTrue ? 'Sign In' : 'Sign Up'),
                          FutureBuilder(
                              future: Preferences.getBiometricStatus(),
                              builder: (context, snapshot) {
                                Object biometric = snapshot.data ?? false;
                                RxBool? value = biometric.obs as RxBool?;
                                return Obx(() {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Use FaceID/Fingerprint to authenticate'),
                                      Checkbox(
                                        value: value!.value,
                                        onChanged: (val) async {
                                          await Preferences.setBiometricStatus(val!);
                                          value.toggle();
                                        },
                                      ),
                                    ],
                                  );
                                });
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(onPressed: () => Get.to(() => ForgotPassword()), child: Text('Forgot Password?')),
                              SizedBox(height: 40),
                              TextButton(onPressed: () => signIn.toggle(), child: Text(signIn.isTrue ? 'Create Account?' : 'Sign In')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(signIn.isTrue ? 'Or sign in using' : 'Or sign up using'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          await Preferences.setUserRole(userType);
                          authService.signInWithGoogle(signIn.isTrue);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: Icon(FontAwesomeIcons.googlePlusG, color: Colors.white, size: 22),
                            radius: 22,
                            backgroundColor: redColor,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await Preferences.setUserRole(userType);
                          authService.signInWithFacebook(signIn.isTrue);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: Icon(FontAwesomeIcons.facebookF, color: Colors.white, size: 22),
                            radius: 22,
                            backgroundColor: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      if (Platform.isIOS)
                        InkWell(
                          onTap: () async {
                            await Preferences.setUserRole(userType);
                            authService.signInWithApple(signIn.isTrue);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              child: Icon(FontAwesomeIcons.apple, color: Colors.white, size: 22),
                              radius: 22,
                              backgroundColor: Colors.grey.shade900,
                            ),
                          ),
                        ),
                    ],
                  ),

                  TextButton(onPressed: () => Get.offAll(() => HomePage()), child: Text('SKIP >>', style: TextStyle(color: Colors.grey.shade600))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  login() async {
    if (!formKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }

    dialogService.showLoading();
    await Preferences.setUserRole(userType);
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'email', value: emailTEC.text.toLowerCase());
    await storage.write(key: 'password', value: passwordTEC.text);
    await authService.signIn(emailTEC.text.toLowerCase(), passwordTEC.text);
    //Get.back();
  }

  signUp() async {
    if (!formKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }

    Get.defaultDialog(
      titlePadding: const EdgeInsets.only(top: 10),
      contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
      title: 'Create Account',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By signing up, you accept the Terms & Conditions of use of this app.'),
          InkWell(
            onTap: () => miscService.openLink('https://makaiapp.com'),
            child: Text(
              'Know more',
              textScaleFactor: 0.95,
              maxLines: 2,
              style: TextStyle(color: secondaryColor, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
      confirm: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(redColor)), onPressed: () => Get.back(), child: Text('Cancel')),
      ),
      cancel: ElevatedButton(
          onPressed: () async {
            dialogService.showLoading();
            final storage = new FlutterSecureStorage();
            await storage.write(key: 'email', value: emailTEC.text.toLowerCase());
            await storage.write(key: 'password', value: passwordTEC.text);
            authService.signUp(User(email: emailTEC.text.toLowerCase(), fullName: nameTEC.text, unreadNotifications: true, unreadMessages: true, bookingNotifications: true, messageNotifications: true, generalNotifications: true, transactionNotifications: true), passwordTEC.text);
          },
          child: Text('Sign Up')),
    );
  }
}

// Set user role for all screens - login, sign up, Owner login
// set common function for role
// remove constants
// use preferences everywhere
