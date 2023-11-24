import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/certificate_model.dart';
import 'package:makaiapp/screens/vessels/vessel_constants.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class AddCertificate extends StatelessWidget {
  final String vesselID;

  AddCertificate({required this.vesselID});

  final GlobalKey<FormState> step4Key = GlobalKey<FormState>();
  RxList certificates = [].obs;
  final TextEditingController certificateAuthTEC = TextEditingController();
  final TextEditingController cNumberTEC = TextEditingController();
  final TextEditingController moNumberTEC = TextEditingController();
  final TextEditingController vdNumberTEC = TextEditingController();
  final TextEditingController portTEC = TextEditingController();
  final TextEditingController tonnageTEC = TextEditingController();
  final TextEditingController issueDateTEC = TextEditingController();
  final TextEditingController buildDateTEC = TextEditingController();
  final TextEditingController expiryDateTEC = TextEditingController();
  final TextEditingController issuePlaceTEC = TextEditingController();
  Rx<String> certificateType = 'Certificate of Registry'.obs;

  // Make Timestamps nullable
  Timestamp? issueDate, buildDate, expiryDate;

  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();
  final storageService = Get.find<StorageService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ADD VESSEL CERTIFICATE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: step4Key,
          child: Column(
            children: [
              // ... UI Widgets and Fields
              // Same as your existing UI code
            ],
          ),
        ),
      ),
    );
  }

  update() async {
    if (issueDate == null || buildDate == null || expiryDate == null) {
      // Handle the case where dates are not set
      showRedAlert('Please fill all date fields.');
      return;
    }

    dialogService.showLoading();
    List finalCertificates = [];
    for (int i = 0; i < certificates.length; i++) {
      finalCertificates.add(await storageService.uploadPhoto(certificates[i], 'certificates'));
    }

    // Now you can safely use the Timestamp variables as they are guaranteed to be non-null here
    await vesselService.addCertificate(
      Certificate(
        certificates: finalCertificates,
        certificateAuthority: certificateAuthTEC.text,
        certificateType: certificateType.value,
        cNumber: cNumberTEC.text,
        vDNumber: vdNumberTEC.text,
        mONumber: moNumberTEC.text,
        port: portTEC.text,
        tonnage: tonnageTEC.text,
        issueDate: issueDate!,
        buildDate: buildDate!,
        expiryDate: expiryDate!,
        issuePlace: issuePlaceTEC.text,
        userID: userController.currentUser.value.userID,
        vesselID: vesselID,
      ),
    );
  }

  



  addImageButton() {
    return InkWell(
      onTap: () async {
        File file = await storageService.pickImage();
        certificates.add(file);
      },
      child: Container(
        height: 80,
        width: 80,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
        child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 25),
      ),
    );
  }

  dropDown(List items, int i) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 2, color: Colors.teal.shade400),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      isExpanded: true,
      style: TextStyle(color: primaryColor, fontSize: 17),
      value: certificateType.value,
      items: items.map((value) {
        return DropdownMenuItem<String>(value: value, child: Text(value, textScaleFactor: 1, style: TextStyle(color: Colors.black)));
      }).toList(),
      onChanged: (value) => certificateType.value = value!,
    );
  }

  showDatePicker(int type, context) {
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2000), maxTime: DateTime(2100), onChanged: (date) {}, onConfirm: (date) {
      if (type == 1) {
        issueDateTEC.text = DateFormat('MMMM dd, yyyy').format(date);
        issueDate = Timestamp.fromDate(date);
      }
      if (type == 2) {
        buildDateTEC.text = DateFormat('MMMM dd, yyyy').format(date);
        buildDate = Timestamp.fromDate(date);
      }
      if (type == 3) {
        expiryDateTEC.text = DateFormat('MMMM dd, yyyy').format(date);
        expiryDate = Timestamp.fromDate(date);
      }
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }
}
