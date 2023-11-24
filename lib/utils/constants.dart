import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final Color primaryColor = Color(0xff193a69);
final Color secondaryColor = Color(0xff00B5BB);
final Color redColor = Colors.red.shade600;
final ref = FirebaseFirestore.instance;
const String GOOGLE_MAP_KEY = "AIzaSyAt99JFvfU_GgGqt7V06lv54F61xhYzmec";
const String VESSEL_OWNER = "Owner";
const String VESSEL_CAPTAIN = 'Captain';
const String VESSEL_CREW = 'Crew';
const String VESSEL_USER = 'User';
String MY_ROLE = 'User';
double myLatitude = 0.0;
double myLongitude = 0.0;

showRedAlert(String text) {
  return Get.snackbar('Error', text, backgroundColor: redColor, colorText: Colors.white, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
}

showGreenAlert(String text) {
  return Get.snackbar('Success', text, backgroundColor: Colors.green, colorText: Colors.white, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
}

showYellowAlert(String text) {
  Get.snackbar('Please wait', text, backgroundColor: Colors.amber, colorText: Colors.black, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
}

showNoticeAlert(String text) {
  Get.snackbar('Notice', text, backgroundColor: Colors.amber, colorText: Colors.black, margin: const EdgeInsets.all(15), animationDuration: const Duration(milliseconds: 500));
}
