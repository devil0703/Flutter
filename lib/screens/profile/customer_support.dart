import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/services/cloud_function.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';

class CustomerSupport extends StatefulWidget {
  @override
  State<CustomerSupport> createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport> {
  final TextEditingController nameTEC = TextEditingController();
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController mobileTEC = TextEditingController();
  final TextEditingController tripDateTEC = TextEditingController();
  final TextEditingController confirmationTEC = TextEditingController();
  final TextEditingController detailsTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();
  late DateTime tripDate;

  @override
  void initState() {
    nameTEC.text = userController.currentUser.value.fullName!;
    emailTEC.text = userController.currentUser.value.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CUSTOMER SUPPORT')),
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
                  CustomTextField(controller: mobileTEC, label: 'Mobile Number *', hint: 'Enter mobile', validate: true, textInputType: TextInputType.phone),
                  InkWell(
                    onTap: () {
                      DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2000), maxTime: DateTime(2100), onChanged: (date) {}, onConfirm: (date) {
                        tripDateTEC.text = DateFormat('MMMM dd, yyyy').format(date);
                        tripDate = date;
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                    child: CustomTextField(controller: tripDateTEC, label: 'Trip Date *', hint: 'Select date', validate: true, enabled: false),
                  ),
                  CustomTextField(controller: confirmationTEC, label: 'Confirmation Number *', hint: 'Enter confirmation no.', validate: true),
                  CustomTextField(controller: detailsTEC, label: 'More details *', hint: 'Enter details', validate: true, maxLines: 5),
                ],
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(onPressed: () => sendMail(), child: Text('RAISE QUERY')),
          ],
        ),
      ),
    );
  }

  sendMail() async {
    if (!formKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    } else {
      String subject = 'Customer support';
      String text = ""
          "Name: ${nameTEC.text}\n"
          "Email: ${emailTEC.text}\n"
          "Mobile: ${mobileTEC.text}\n"
          "Trip Date: ${tripDateTEC.text}\n"
          "Confirmation No: ${confirmationTEC.text}\n"
          "Details: ${detailsTEC.text}\n";
      await cloudFunction(functionName: 'genericEmail', parameters: {'subject': subject, 'text': text}, action: () {});
    }
  }
}
