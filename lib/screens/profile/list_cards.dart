import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/payment_method_model.dart' as card;
import 'package:makaiapp/screens/profile/add_card.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/cloud_function.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';

class ListCards extends StatelessWidget {
  final userController = Get.find<UserController>();
  final buyService = Get.find<BookingService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CARDS')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: buyService.getCards(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    card.PaymentMethodsList payments = snapshot.data as card.PaymentMethodsList;
                    return payments.paymentMethods!.data!.isNotEmpty
                        ? ListView.builder(
                            itemBuilder: (context, i) {
                              return Column(
                                children: [
                                  CreditCardWidget(
                                    cardNumber: '0000 0000 0000 ' + payments.paymentMethods!.data![i].card!.last4,
                                    expiryDate: payments.paymentMethods!.data[i].card!.expMonth.toString() + '/' + payments.paymentMethods!.data[i].card!.expYear.toString(),
                                    cardHolderName: userController.currentUser.value.fullName!,
                                    cardType: getCardType(payments.paymentMethods!.data[i].card!.brand),
                                    cvvCode: '***',
                                    showBackView: false,
                                    obscureCardNumber: true,
                                    obscureCardCvv: true,
                                    isHolderNameVisible: true,
                                    cardBgColor: primaryColor,
                                    isSwipeGestureEnabled: false,
                                    onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Obx(() {
                                        return InkWell(
                                          onTap: () async {
                                            if (userController.currentUser.value.paymentID != payments.paymentMethods!.data![i].id) {
                                              final userService = Get.find<UserService>();
                                              dialogService.showLoading();
                                              await userService.updateUser({'paymentID': payments.paymentMethods!.data![i].id});
                                              Get.back();
                                              showGreenAlert('Default Card set successfully');
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(15, 0, 25, 20),
                                            child: Text(userController.currentUser.value.paymentID == payments.paymentMethods!.data![i].id ? 'DEFAULT CARD' : 'SET AS DEFAULT CARD', style: TextStyle(color: userController.currentUser.value.paymentID == payments.paymentMethods!.data![i].id ? Colors.green : redColor)),
                                          ),
                                        );
                                      }),
                                      InkWell(
                                        onTap: () => dialogService.showConfirmationDialog(
                                          title: 'Delete Card?',
                                          contentText: 'Are you sure you want to delete this card?',
                                          confirm: () async {
                                            Get.back();
                                            dialogService.showLoading();
                                            var response = await buyService.removeCard({'payment_method_id': payments.paymentMethods!.data![i].id});
                                            Get.back();
                                            Get.back();
                                            if (response['success']) {
                                              showGreenAlert(response['message']);
                                            } else {
                                              showRedAlert(response['message']);
                                            }
                                          },
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(15, 0, 25, 20),
                                          child: Text('DELETE', style: TextStyle(color: redColor)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],
                              );
                            },
                            itemCount: payments.paymentMethods!.data!.length,
                          )
                        : EmptyBox(text: 'No cards added yet.');
                  } else
                    return LoadingData();
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: CustomButton(text: 'Add a new Card', function: () => Get.off(() => AddCard())),
          ),
        ],
      ),
    );
  }

  getCardType(String brand) {
    if (brand == 'visa') return CardType.visa;
    if (brand == 'americanExpress') return CardType.americanExpress;
    if (brand == 'discover') return CardType.discover;
    if (brand == 'mastercard') return CardType.mastercard;
    return CardType.otherBrand;
  }
}
