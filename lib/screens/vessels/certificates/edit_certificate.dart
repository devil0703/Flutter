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

class EditCertificate extends StatefulWidget {
  final Certificate certificate;

  EditCertificate({required this.certificate});

  @override
  State<EditCertificate> createState() => _EditCertificateState();
}

class _EditCertificateState extends State<EditCertificate> {
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

  late Timestamp issueDate, buildDate, expiryDate;
  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();
  final storageService = Get.find<StorageService>();
  RxList imageURLs = [].obs;

  @override
  void initState() {
    imageURLs.value = widget.certificate.certificates!;

    certificateAuthTEC.text = widget.certificate.certificateAuthority!;
    certificateType.value = widget.certificate.certificateType!;
    cNumberTEC.text = widget.certificate.cNumber!;
    vdNumberTEC.text = widget.certificate.vDNumber!;
    moNumberTEC.text = widget.certificate.mONumber!;
    portTEC.text = widget.certificate.port!;
    tonnageTEC.text = widget.certificate.tonnage!;
    issueDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.certificate.issueDate!.toDate());
    buildDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.certificate.buildDate!.toDate());
    expiryDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.certificate.expiryDate!.toDate());
    issueDate = widget.certificate.issueDate!;
    buildDate = widget.certificate.buildDate!;
    expiryDate = widget.certificate.expiryDate!;
    issuePlaceTEC.text = widget.certificate.issuePlace!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EDIT CERTIFICATE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: step4Key,
          child: Column(
            children: [
              Text('Certificates', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 25),
                height: 80,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageURLs.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => imageURLs.remove(imageURLs[i]),
                          child: Stack(
                            children: [
                              CachedImage(height: 80, roundedCorners: true, url: imageURLs[i]),
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
                          itemCount: certificates.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () => certificates.remove(certificates[i]),
                                child: Stack(
                                  children: [
                                    CachedImage(height: 80, roundedCorners: true, imageFile: certificates[i]),
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
              CustomTextField(controller: certificateAuthTEC, label: 'Certificate Authority *', hint: 'Enter authority name', validate: true),
              CustomTextField(dropdown: dropDown(certificateTypes, 4), label: 'Certificate Type *'),
              CustomTextField(controller: cNumberTEC, label: 'Certificate Number *', hint: 'Enter number', validate: true),
              CustomTextField(controller: vdNumberTEC, label: 'Vessel Distinctive Number *', hint: 'Enter number', validate: true),
              CustomTextField(controller: moNumberTEC, label: 'MO Number *', hint: 'Enter number', validate: true),
              CustomTextField(controller: portTEC, label: 'Port of Registry *', hint: 'Enter port name', validate: true),
              CustomTextField(controller: tonnageTEC, label: 'Gross Tonnage *', hint: 'Enter value', validate: true),
              InkWell(onTap: () => showDatePicker(1, context), child: CustomTextField(controller: issueDateTEC, label: 'Date of Issue *', hint: 'Select date', validate: true, enabled: false)),
              InkWell(onTap: () => showDatePicker(2, context), child: CustomTextField(controller: buildDateTEC, label: 'Date of Build *', hint: 'Select date', validate: true, enabled: false)),
              InkWell(onTap: () => showDatePicker(3, context), child: CustomTextField(controller: expiryDateTEC, label: 'Date of Expiry *', hint: 'Select date', validate: true, enabled: false)),
              CustomTextField(controller: issuePlaceTEC, label: 'Place of Issue *', hint: 'Enter place', validate: true),
              SizedBox(height: 20),
              CustomButton(
                text: 'Edit Certificate',
                function: () async {
                  if (!step4Key.currentState!.validate()) {
                    showRedAlert('Please fill the necessary details');
                  } else if (imageURLs.isEmpty && certificates.isEmpty) {
                    showRedAlert('Please add at least one certificate image');
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
    List finalCertificates = widget.certificate.certificates!;
    for (int i = 0; i < certificates.length; i++) {
      finalCertificates.add(await storageService.uploadPhoto(certificates[i], 'certificates'));
    }
    await vesselService.editCertificate(
      Certificate(
        certificateID: widget.certificate.certificateID,
        certificates: finalCertificates,
        certificateAuthority: certificateAuthTEC.text,
        certificateType: certificateType.value,
        cNumber: cNumberTEC.text,
        vDNumber: vdNumberTEC.text,
        mONumber: moNumberTEC.text,
        port: portTEC.text,
        tonnage: tonnageTEC.text,
        issueDate: issueDate,
        buildDate: buildDate,
        expiryDate: expiryDate,
        issuePlace: issuePlaceTEC.text,
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
