import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/license_model.dart';
import 'package:makaiapp/screens/messages/view_image.dart';
import 'package:makaiapp/screens/vessels/licenses/edit_license.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class ViewLicense extends StatefulWidget {
  final License license;

  ViewLicense({required this.license});

  @override
  State<ViewLicense> createState() => _ViewLicenseState();
}

class _ViewLicenseState extends State<ViewLicense> {
  final GlobalKey<FormState> step4Key = GlobalKey<FormState>();

  RxList licenses = [].obs;
  final TextEditingController documentNumberTEC = TextEditingController();
  final TextEditingController countryCodeTEC = TextEditingController();
  final TextEditingController referenceNumberTEC = TextEditingController();
  final TextEditingController fullNameTEC = TextEditingController();
  final TextEditingController addressTEC = TextEditingController();
  final TextEditingController citizenshipTEC = TextEditingController();
  final TextEditingController dobTEC = TextEditingController();
  final TextEditingController buildDateTEC = TextEditingController();
  final TextEditingController expiryDateTEC = TextEditingController();
  Rx<String> certificateType = 'Six-pack or Charter Boat License'.obs;
  late Timestamp issueDate, buildDate, expiryDate;
  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();
  final storageService = Get.find<StorageService>();
  RxList imageURLs = [].obs;

  @override
  void initState() {
    imageURLs.value = widget.license.licenses!;
    documentNumberTEC.text = widget.license.documentNumber!;
    certificateType.value = widget.license.licenseType!;
    countryCodeTEC.text = widget.license.countryCode!;
    referenceNumberTEC.text = widget.license.referenceNumber!;
    fullNameTEC.text = widget.license.fullName!;
    addressTEC.text = widget.license.address!;
    citizenshipTEC.text = widget.license.citizenship!;
    dobTEC.text = DateFormat('MMMM dd, yyyy').format(widget.license.issueDate!.toDate());
    buildDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.license.dob!.toDate());
    expiryDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.license.expiryDate!.toDate());
    issueDate = widget.license.issueDate!;
    buildDate = widget.license.dob!;
    expiryDate = widget.license.expiryDate!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VIEW CAPTAIN\'S LICENSE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: step4Key,
          child: Column(
            children: [
              Text('License Images', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 25),
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.license.licenses!.length,
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () => Get.to(() => ViewImages(index: i, images: widget.license.licenses!)),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CachedImage(height: 80, roundedCorners: true, url: widget.license.licenses![i]),
                      ),
                    );
                  },
                ),
              ),
              CustomTextField(controller: fullNameTEC, label: 'Full Name of the Captain *', hint: 'Enter name', validate: true, enabled: false),
              CustomTextField(controller: documentNumberTEC, label: 'Document Number *', hint: 'Enter number', validate: true, enabled: false),
              CustomTextField(controller: TextEditingController(text: certificateType.value), label: 'License Type *', enabled: false),
              CustomTextField(controller: countryCodeTEC, label: 'Country Code *', hint: 'Enter code', validate: true, enabled: false),
              CustomTextField(controller: addressTEC, label: 'Present Address *', hint: 'Enter address', validate: true, enabled: false),
              CustomTextField(controller: citizenshipTEC, label: 'Citizenship *', hint: 'Enter citizenship', validate: true, enabled: false),
              CustomTextField(controller: referenceNumberTEC, label: 'Reference Number *', hint: 'Enter number', validate: true, enabled: false),
              CustomTextField(controller: dobTEC, label: 'Date of Birth *', hint: 'Select date', validate: true, enabled: false),
              CustomTextField(controller: buildDateTEC, label: 'Date of Issue *', hint: 'Select date', validate: true, enabled: false),
              CustomTextField(controller: expiryDateTEC, label: 'Date of Expiry *', hint: 'Select date', validate: true, enabled: false),
              SizedBox(height: 20),
              if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
                CustomButton(
                  text: 'Modify License',
                  function: () => Get.off(() => EditLicense(license: widget.license)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  update() async {
    dialogService.showLoading();
    List finalLicenses = [];
    for (int i = 0; i < licenses.length; i++) {
      finalLicenses.add(await storageService.uploadPhoto(licenses[i], 'licenses'));
    }
    await vesselService.editLicense(
      License(
        licenses: finalLicenses,
        userID: userController.currentUser.value.userID,
        vesselID: widget.license.vesselID,
        issueDate: issueDate,
        dob: buildDate,
        expiryDate: expiryDate,
        documentNumber: documentNumberTEC.text,
        licenseType: certificateType.value,
        countryCode: countryCodeTEC.text,
        referenceNumber: referenceNumberTEC.text,
        fullName: fullNameTEC.text,
        address: addressTEC.text,
        citizenship: citizenshipTEC.text,
      ),
    );
  }

  addImageButton() {
    return InkWell(
      onTap: () async {
        File file = await storageService.pickImage();
        licenses.add(file);
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

  dropDown(List items) {
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
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(1950), maxTime: DateTime(2100), onChanged: (date) {}, onConfirm: (date) {
      if (type == 1) {
        dobTEC.text = DateFormat('MMMM dd, yyyy').format(date);
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
