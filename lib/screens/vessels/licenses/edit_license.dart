import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/license_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/screens/vessels/vessel_constants.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';

class EditLicense extends StatefulWidget {
  final License license;

  EditLicense({required this.license});

  @override
  State<EditLicense> createState() => _EditLicenseState();
}

class _EditLicenseState extends State<EditLicense> {
  final GlobalKey<FormState> step4Key = GlobalKey<FormState>();

  RxList licenses = [].obs;
  final TextEditingController documentNumberTEC = TextEditingController();
  final TextEditingController countryCodeTEC = TextEditingController();
  final TextEditingController referenceNumberTEC = TextEditingController();
  final Rx<TextEditingController> fullNameTEC = TextEditingController().obs;
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
    fullNameTEC.value.text = widget.license.fullName!;
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
      appBar: AppBar(title: Text('EDIT CAPTAIN\'S LICENSE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: step4Key,
          child: Column(
            children: [
              Text('License Images', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 15),
                height: 80,
                child: Row(
                  children: [
                    addImageButton(),
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: licenses.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () => licenses.remove(licenses[i]),
                                child: Stack(
                                  children: [
                                    CachedImage(height: 80, roundedCorners: true, imageFile: licenses[i]),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 55),
                                      child: Icon(Icons.remove_circle, color: Colors.red, size: 25),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () {
                  return InkWell(
                    onTap: () {
                      Get.defaultDialog(
                        title: 'Select the Captain',
                        content: Container(
                          height: 100,
                          width: Get.width,
                          child: StreamBuilder(
                              stream: vesselService.getVesselCaptainsStream(widget.license.vesselID!),
                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData)
                                  return snapshot.data!.docs.length > 0
                                      ? ListView.builder(
                                          padding: const EdgeInsets.all(15),
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, i) {
                                            DocumentSnapshot doc = snapshot.data!.docs[i];
                                            User user = User.fromDocument(doc);
                                            return ListTile(
                                              title: Text(user.fullName!),
                                              trailing: Text('SELECT', textScaleFactor: 0.9, style: TextStyle(color: Colors.green)),
                                              onTap: () {
                                                fullNameTEC.value.text = user.fullName!;
                                                Get.back();
                                              },
                                            );
                                          },
                                        )
                                      : EmptyBox(text: 'Please add a captain before adding a license');
                                else
                                  return LoadingData();
                              }),
                        ),
                      );
                    },
                    child: CustomTextField(controller: fullNameTEC.value, label: 'Full Name of the Captain *', hint: 'Enter name', validate: true, enabled: false),
                  );
                },
              ),
              CustomTextField(controller: documentNumberTEC, label: 'Document Number *', hint: 'Enter number', validate: true),
              CustomTextField(dropdown: dropDown(licenseTypes), label: 'License Type *'),
              CustomTextField(controller: countryCodeTEC, label: 'Country Code *', hint: 'Enter code', validate: true),
              CustomTextField(controller: addressTEC, label: 'Present Address *', hint: 'Enter address', validate: true),
              CustomTextField(controller: citizenshipTEC, label: 'Citizenship *', hint: 'Enter citizenship', validate: true),
              CustomTextField(controller: referenceNumberTEC, label: 'Reference Number *', hint: 'Enter number', validate: true),
              InkWell(onTap: () => showDatePicker(1, context), child: CustomTextField(controller: dobTEC, label: 'Date of Birth *', hint: 'Select date', validate: true, enabled: false)),
              InkWell(onTap: () => showDatePicker(2, context), child: CustomTextField(controller: buildDateTEC, label: 'Date of Issue *', hint: 'Select date', validate: true, enabled: false)),
              InkWell(onTap: () => showDatePicker(3, context), child: CustomTextField(controller: expiryDateTEC, label: 'Date of Expiry *', hint: 'Select date', validate: true, enabled: false)),
              SizedBox(height: 20),
              CustomButton(
                text: 'Edit License',
                function: () async {
                  if (!step4Key.currentState!.validate()) {
                    showRedAlert('Please fill the necessary details');
                  } else if (imageURLs.isEmpty && licenses.isEmpty) {
                    showRedAlert('Please add at least one license image');
                    return;
                  } else {
                    await update();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  update() async {
    dialogService.showLoading();
    List finalLicenses = widget.license.licenses!;
    for (int i = 0; i < licenses.length; i++) {
      finalLicenses.add(await storageService.uploadPhoto(licenses[i], 'licenses'));
    }
    await vesselService.editLicense(
      License(
        licenseID: widget.license.licenseID,
        licenses: finalLicenses,
        userID: userController.currentUser.value.userID!,
        vesselID: widget.license.vesselID,
        issueDate: issueDate,
        dob: buildDate,
        expiryDate: expiryDate,
        documentNumber: documentNumberTEC.text,
        licenseType: certificateType.value,
        countryCode: countryCodeTEC.text,
        referenceNumber: referenceNumberTEC.text,
        fullName: fullNameTEC.value.text,
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
