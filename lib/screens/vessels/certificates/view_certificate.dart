import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/certificate_model.dart';
import 'package:makaiapp/screens/messages/view_image.dart';
import 'package:makaiapp/screens/vessels/certificates/edit_certificate.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class ViewCertificate extends StatefulWidget {
  final Certificate certificate;

  ViewCertificate({required this.certificate});

  @override
  State<ViewCertificate> createState() => _ViewCertificateState();
}

class _ViewCertificateState extends State<ViewCertificate> {
  final TextEditingController certificateAuthTEC = TextEditingController();
  final TextEditingController certificateTypeTEC = TextEditingController();
  final TextEditingController cNumberTEC = TextEditingController();
  final TextEditingController moNumberTEC = TextEditingController();
  final TextEditingController vdNumberTEC = TextEditingController();
  final TextEditingController portTEC = TextEditingController();
  final TextEditingController tonnageTEC = TextEditingController();
  final TextEditingController issueDateTEC = TextEditingController();
  final TextEditingController buildDateTEC = TextEditingController();
  final TextEditingController expiryDateTEC = TextEditingController();
  final TextEditingController issuePlaceTEC = TextEditingController();
  final userController = Get.find<UserController>();

  @override
  void initState() {
    certificateAuthTEC.text = widget.certificate.certificateAuthority!;
    certificateTypeTEC.text = widget.certificate.certificateType!;
    cNumberTEC.text = widget.certificate.cNumber!;
    vdNumberTEC.text = widget.certificate.vDNumber!;
    moNumberTEC.text = widget.certificate.mONumber!;
    portTEC.text = widget.certificate.port!;
    tonnageTEC.text = widget.certificate.tonnage!;
    issueDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.certificate.issueDate!.toDate());
    buildDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.certificate.buildDate!.toDate());
    expiryDateTEC.text = DateFormat('MMMM dd, yyyy').format(widget.certificate.expiryDate!.toDate());
    issuePlaceTEC.text = widget.certificate.issuePlace!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CERTIFICATE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text('Certificates', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 25),
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.certificate.certificates!.length,
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () => Get.to(() => ViewImages(index: i, images: widget.certificate.certificates!)),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CachedImage(height: 80, roundedCorners: true, url: widget.certificate.certificates![i]),
                    ),
                  );
                },
              ),
            ),
            CustomTextField(controller: certificateAuthTEC, label: 'Certificate Authority *', hint: 'Enter authority name', validate: true, enabled: false),
            CustomTextField(controller: certificateTypeTEC, label: 'Certificate Type *', hint: 'Enter certificate type', validate: true, enabled: false),
            CustomTextField(controller: cNumberTEC, label: 'Certificate Number *', hint: 'Enter number', validate: true, enabled: false),
            CustomTextField(controller: vdNumberTEC, label: 'Vessel Distinctive Number *', hint: 'Enter number', validate: true, enabled: false),
            CustomTextField(controller: moNumberTEC, label: 'MO Number *', hint: 'Enter number', validate: true, enabled: false),
            CustomTextField(controller: portTEC, label: 'Port of Registry *', hint: 'Enter port name', validate: true, enabled: false),
            CustomTextField(controller: tonnageTEC, label: 'Gross Tonnage *', hint: 'Enter value', validate: true, enabled: false),
            CustomTextField(controller: issueDateTEC, label: 'Date of Issue *', hint: 'Select date', validate: true, enabled: false),
            CustomTextField(controller: buildDateTEC, label: 'Date of Build *', hint: 'Select date', validate: true, enabled: false),
            CustomTextField(controller: expiryDateTEC, label: 'Date of Expiry *', hint: 'Select date', validate: true, enabled: false),
            CustomTextField(controller: issuePlaceTEC, label: 'Place of Issue *', hint: 'Enter place', validate: true, enabled: false),
            SizedBox(height: 25),
            if (MY_ROLE == VESSEL_CAPTAIN || MY_ROLE == VESSEL_OWNER)
              CustomButton(
                text: 'Modify Certificate',
                function: () => Get.off(() => EditCertificate(certificate: widget.certificate)),
              ),
          ],
        ),
      ),
    );
  }
}
