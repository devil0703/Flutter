import 'package:flutter/material.dart' hide Card;
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_button.dart';

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  final userController = Get.find<UserController>();
  final bookingService = Get.find<BookingService>();
  final dialogService = Get.find<DialogService>();
  final userService = Get.find<UserService>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late CreditCardModel creditCardModel;
  bool isDefaultCard = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CARDS')),
      body: Column(
        children: <Widget>[
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            obscureCardNumber: true,
            obscureCardCvv: true,
            isHolderNameVisible: true,
            cardBgColor: primaryColor,
            isSwipeGestureEnabled: true,
            onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CreditCardForm(
                    formKey: formKey,
                    obscureCvv: true,
                    obscureNumber: true,
                    cardNumber: cardNumber,
                    cvvCode: cvvCode,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    cardHolderName: cardHolderName,
                    expiryDate: expiryDate,
                   
                    onCreditCardModelChange: onCreditCardModelChange,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CheckboxListTile(value: isDefaultCard, onChanged: (val) => setState(() => isDefaultCard = val!), title: Text('Set this card as your default payment method')),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: CustomButton(
                      text: 'Add Card',
                      function: () async {
                        if (formKey.currentState!.validate()) {
                          Map params = {
                            'number': creditCardModel.cardNumber,
                            'exp_month': creditCardModel.expiryDate.substring(0, 2),
                            'exp_year': creditCardModel.expiryDate.substring(3, 5),
                            'cvc': creditCardModel.cvvCode,
                            'customer_id': userController.currentUser.value.stripeCustomerID,
                          };
                          dialogService.showLoading();
                          var response = await bookingService.addCard(params);
                          Get.back();
                          if (response['success']) {
                            showGreenAlert(response['message']);
                            if (isDefaultCard) await userService.updateUser({'paymentID': response['data']['id']});
                          } else {
                            showRedAlert(response['message']);
                          }
                          Get.back();
                          Get.back();
                        } else {
                          print('invalid!');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCard) {
    setState(() {
      creditCardModel = creditCard;
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
