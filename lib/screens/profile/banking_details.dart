import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/banking_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/loading.dart';

class BankingDetails extends StatefulWidget {
  final User user;

  BankingDetails({required this.user});

  @override
  _BankingDetailsState createState() => _BankingDetailsState();
}

class _BankingDetailsState extends State<BankingDetails> {
  final TextEditingController bankNameTEC = TextEditingController();
  final TextEditingController accountNameTEC = TextEditingController();
  final TextEditingController routingTEC = TextEditingController();
  final TextEditingController accountNoTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();
  late Banking banking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EDIT BANKING DETAILS'.toUpperCase())),
      body: FutureBuilder(
        future: userService.getBankingDetails(),
        builder: (context, snapshot) {
          print('USER ID:' + userController.currentUser.value.userID!);
          if (snapshot.hasData) {
            banking = Banking.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
            accountNameTEC.text = banking.accountName ?? "";
            bankNameTEC.text = banking.bankName ?? "";
            accountNoTEC.text = banking.accountNo ?? "";
            routingTEC.text = banking.routingNo ?? "";
            selectedCountry.value = banking.country ?? "";
                      return bankForm();
          } else
            return LoadingData();
        },
      ),
    );
  }

  bankForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(dropdown: dropDown(countries), label: 'Select Country *'),
                CustomTextField(controller: accountNameTEC, label: 'Account Holder Name *', hint: 'Enter full name', validate: true),
                CustomTextField(controller: bankNameTEC, label: 'Bank Name *', hint: 'Enter bank name', validate: true),
                CustomTextField(controller: accountNoTEC, label: 'Account Number *', hint: 'Enter number', validate: true),
                CustomTextField(controller: routingTEC, label: 'Routing Number *', hint: 'Enter number', validate: true),
              ],
            ),
          ),
          SizedBox(height: 25),
          ElevatedButton(onPressed: () => update(), child: Text('SAVE')),
        ],
      ),
    );
  }

  Rx<String> selectedCountry = 'United States'.obs;
  List countries = ['United States', 'Canada'];

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
      value: selectedCountry.value,
      items: items.map((value) {
        return DropdownMenuItem<String>(value: value, child: Text(value, textScaleFactor: 1, style: TextStyle(color: Colors.black)));
      }).toList(),
      onChanged: (value) => selectedCountry.value = value!,
    );
  }

  update() async {
    if (!formKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }
    dialogService.showLoading();
    Map<String, dynamic> bank = {
      'userID': userController.currentUser.value.userID,
      'accountName': accountNameTEC.text.trim(),
      'bankName': bankNameTEC.text.trim(),
      'accountNo': accountNoTEC.text.trim(),
      'routingNo': routingTEC.text.trim(),
      'accountType': selectedCountry.value,
      'updatedDate': Timestamp.now(),
    };

    if (banking == null)
      userService.addBanking(bank);
    else
      userService.updateBanking(bank);
    Get.back();
    showGreenAlert('Updated Successfully');
  }
}
