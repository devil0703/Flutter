import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart' as u;
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/screens/auth/splash_screen.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();
  final dialogService = Get.find<DialogService>();

  signOut() async {
    await Preferences.setBiometricStatus(false);
    await Preferences.setUser('');
    await Preferences.setUserRole(VESSEL_USER);
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    await GoogleSignIn().signOut();
  }

  signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userService.setCurrentUser(email);
      await saveCredentials(email, password);
      Get.offAll(() => SplashScreen());
      return;
    } on FirebaseAuthException catch (e) {
      Get.back();
      print(e.code);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        showRedAlert('No user found for this email');
        return;
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showRedAlert('Incorrect password');
        return;
      }
    } catch (e) {
      Get.back();
      showRedAlert(e.toString());
      print(e);
      return;
    }
  }

  signUp(u.User user, String password) async {
    try {
      if (await checkIfEmailExists(user.email!)) {
        showRedAlert('User exists with this email. Please login.');
        await signOut();
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: user.email!, password: password);
        await userService.addUser(user);
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      showRedAlert(e.message!);
    } catch (e) {
      print(e);
      Get.back();
      showRedAlert('Something went wrong');
    }
  }

  void changePassword(String password) async {
    //Create an instance of the current user.
    User user = FirebaseAuth.instance.currentUser!;

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_) {
      Get.back();
      showGreenAlert('Password changed');
    }).catchError((error) {
      Get.back();
      showRedAlert('Something went wrong. Please login again and try again');
      print(error);
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  resetPassword(String email) async {
    dialogService.showLoading();
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    Get.back();
    Get.offAll(() => Login());
    showGreenAlert('Password reset instructions sent to your email');
  }

  signInWithGoogle(bool isLoggingIn) async {
    dialogService.showLoading();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    if (googleAuth == null) {
      print(e);
      await signOut();
      Get.back();
      showRedAlert('Cancelled');
      return;
    }
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
      await check(isLoggingIn, value.user!.email!, u.User(fullName: value.user!.displayName, email: value.user!.email, photoURL: value.user!.photoURL));
    }).catchError((e) async {
      print(e);
      await signOut();
      Get.back();
      showRedAlert('Something went wrong');
    });
  }

  signInWithFacebook(bool isLoggingIn) async {
    // dialogService.showLoading();
    // // Trigger the sign-in flow
    // final LoginResult loginResult = await FacebookAuth.instance.login();
    //
    // if (loginResult == null || loginResult?.accessToken == null) {
    //   print(e);
    //   await signOut();
    //   Get.back();
    //   showRedAlert('Cancelled');
    //   return;
    // }
    // // Create a credential from the access token
    // final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken.token);
    //
    // // Once signed in, return the UserCredential
    // return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential).then((value) async {
    //   await check(isLoggingIn, value.user.email, u.User(fullName: value.user.displayName, email: value.user.email, photoURL: value.user.photoURL));
    // }).catchError((e) async {
    //   print(e);
    //   await signOut();
    //   Get.back();
    //   showRedAlert('Something went wrong');
    // });
  }

  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple(bool isLoggingIn) async {
    dialogService.showLoading();
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    ).catchError((e) async {
      print(e);
      await signOut();
      Get.back();
      showRedAlert('Cancelled');
    });

    if (appleCredential == null) {
      print(e);
      await signOut();
      Get.back();
      showRedAlert('Cancelled');
      return;
    }
    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    await FirebaseAuth.instance.signInWithCredential(oauthCredential).then((value) async {
      await check(isLoggingIn, value.user!.email!, u.User(fullName: value.user!.displayName, email: value.user!.email, photoURL: value.user!.photoURL!));
    }).catchError((e) async {
      await signOut();
      print(e);
      Get.back();
      showRedAlert('Something went wrong');
    });
  }

  checkIfEmailExists(String email) async {
    QuerySnapshot docs = await ref.collection('users').where('email', isEqualTo: email).get();
    if (docs.docs.isEmpty)
      return false;
    else
      return true;
  }

  check(bool isLoggingIn, String email, u.User user) async {
    bool emailExists = await checkIfEmailExists(email);
    Get.back();
    if (isLoggingIn) {
      if (emailExists) {
        await userService.setCurrentUser(user.email!);
        Get.off(() => SplashScreen());
      } else {
        await signOut();
        showRedAlert('No user with this email. Please sign up.');
      }
    } else {
      if (emailExists) {
        await signOut();
        showRedAlert('User exists with this email. Please login.');
      } else {
        await userService.addUser(user);
        await userService.setCurrentUser(user.email!);
        Get.off(() => SplashScreen());
      }
    }
  }

  Future<DocumentSnapshot> getSlideImages() async {
    return await ref.collection('constants').doc('slides').get();
  }

  saveCredentials(String username, String password) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: username, value: password);
  }

  final _auth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
        // authMessages: AndroidAuthMessages(
        //   signInTitle: 'Authentication required',
        // ),
        localizedReason: 'Authenticate to proceed',
      );
    } on PlatformException {
      return false;
    }
  }
}
