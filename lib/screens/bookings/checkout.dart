import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/models/discount_model.dart';
import 'package:makaiapp/models/fees_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/bookings/my_bookings.dart';
import 'package:makaiapp/screens/profile/list_cards.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/cloud_function.dart';
import 'package:makaiapp/services/misc_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/vessel_item.dart';
import 'package:nanoid/async.dart';
import 'package:uuid/uuid.dart';

class Checkout extends StatefulWidget {
  final Vessel vessel;
  final int guestCount;
  final DateTime date;
  final bool isPreMadeTrip;
  final num duration;
  final num price;

  Checkout({required this.vessel, required this.guestCount, required this.date, required this.isPreMadeTrip, required this.duration, required this.price});

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Rx<bool> checkedPrivacy = true.obs;
  Rx<bool> checkedTnC = true.obs;
  final buyService = Get.find<BookingService>();
  final formatCurrency = new NumberFormat.simpleCurrency();
  num tipAmount = 0;
  final userController = Get.find<UserController>();
  num myDiscount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CHECKOUT')),
      body: FutureBuilder(
          future: buyService.getFees(widget.price),
          builder: (context, AsyncSnapshot<FeesModel> snapshot) {
            if (snapshot.hasData) {
              FeesModel? feesModel = snapshot.data;
              num total = ((widget.price) - myDiscount + num.parse(feesModel!.fees!.total!.feesTotal!)) + tipAmount;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    IgnorePointer(ignoring: true, child: VesselItem(vessel: widget.vessel)),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Booking Date'),
                                Text(DateFormat('MMMM dd, yyyy - hh:mm aa').format(widget.date)),
                              ],
                            ),
                            Divider(color: Colors.transparent),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Seat Price (' + widget.duration.toString() + ' hrs)'),
                                Text(formatCurrency.format(widget.price).toString()),
                              ],
                            ),
                            Divider(color: Colors.transparent),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Guests', style: TextStyle(color: primaryColor)),
                                Text(widget.guestCount.toString(), style: TextStyle(color: primaryColor)),
                              ],
                            ),
                            Divider(color: Colors.transparent),
                            InkWell(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Discount', style: TextStyle(color: primaryColor)),
                                  Row(
                                    children: [
                                      Text('Apply Coupon', style: TextStyle(color: primaryColor, decoration: TextDecoration.underline)),
                                      Text('    -\$' + myDiscount.toStringAsFixed(2), style: TextStyle(color: primaryColor)),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: addCoupon,
                            ),
                            Divider(color: Colors.transparent),
                            Text('Additional fee(s)', style: TextStyle(fontWeight: FontWeight.bold)),
                            Divider(color: Colors.transparent),
                            InkWell(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tip Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      Text('Edit', style: TextStyle(color: primaryColor, decoration: TextDecoration.underline)),
                                      Text('    \$' + tipAmount.toStringAsFixed(2), style: TextStyle(color: primaryColor)),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: addTip,
                            ),
                            Divider(color: Colors.transparent),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: feesModel.fees!.types!.length,
                              itemBuilder: (context, i) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(feesModel.fees!.summary![i].name??"NUN", style: TextStyle(color: primaryColor)),
                                        Text(formatCurrency.format(double.parse(feesModel.fees!.summary![i].total ?? "NONE")), style: TextStyle(color: primaryColor)),
                                      ],
                                    ),
                                    Divider(color: Colors.transparent),
                                  ],
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Amount to Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(formatCurrency.format(total), style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Obx(() {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: InkWell(
                          onTap: () => Get.to(() => ListCards()),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: userController.currentUser.value.paymentID == ''
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('SET A PAYMENT METHOD', style: TextStyle(fontWeight: FontWeight.bold, color: redColor)),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Default Card >', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                    Row(
                      children: [
                        Obx(() {
                          return Checkbox(
                              value: checkedTnC.value,
                              focusColor: primaryColor,
                              activeColor: primaryColor,
                              onChanged: (newValue) {
                                checkedTnC.value = !checkedTnC.value;
                              });
                        }),
                        Expanded(
                          flex: 8,
                          child: InkWell(
                            child: Text(
                              'I accept the app purchase terms and conditions',
                              textScaleFactor: 0.9,
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() {
                          return Checkbox(
                              value: checkedPrivacy.value,
                              focusColor: primaryColor,
                              activeColor: primaryColor,
                              onChanged: ( newValue) {
                                checkedPrivacy.value = !checkedPrivacy.value;
                              });
                        }),
                        Expanded(
                          flex: 8,
                          child: InkWell(
                            child: Text(
                              'I agree to the Privacy Policy',
                              textScaleFactor: 0.9,
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomButton(
                        function: () async {
                          if (checkedPrivacy.value && checkedTnC.value) {
                            if (userController.currentUser.value.paymentID != '') {
                              final miscService = Get.find<MiscService>();
                              final userService = Get.find<UserService>();
                              dialogService.showLoading();
                              User vesselOwner = User.fromDocument(await userService.getUser(widget.vessel.userID));
                              String bookingID = Uuid().v1();
                              String bookingRef = await customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 6);
                              final bookingService = Get.find<BookingService>();
                              final data = await bookingService.createPaymentIntent(total - myDiscount);
                              String paymentIntentID = data['paymentIntent']['id'];
                              print(paymentIntentID);
                              String bookingAgreement = miscService.getBookingAgreement(
                                vesselID: widget.vessel.vesselID!,
                                address: widget.vessel.address!,
                                amount: total - myDiscount,
                                discount: myDiscount,
                                startDateTime: DateFormat('MMMM dd, yyyy, hh:mm aa').format(widget.date),
                                endDateTime: DateFormat('MMMM dd, yyyy, hh:mm aa').format(widget.date.add(Duration(hours: widget.duration as int),
                              )));                              
                              Get.back();
                              Get.defaultDialog(
                                title: 'Booking Agreement',
                                content: Container(height: 250, child: Scrollbar(thumbVisibility: true, child: SingleChildScrollView(child: Text(bookingAgreement)))),
                                confirm: CustomButton(function: () => Get.back(), text: 'Cancel', color: Colors.grey),
                                cancel: CustomButton(
                                  text: widget.isPreMadeTrip ? 'Agree and Confirm Booking' : 'Agree & Send Booking Request',
                                  function: () async {
                                    dialogService.showLoading();
                                    await buyService.sendBookingRequest(Booking(
                                      vesselID: widget.vessel.vesselID!,
                                      guestCount: widget.guestCount,
                                      seatCost: widget.vessel.prices![0] * widget.vessel.durations![0],
                                      totalCost: total - myDiscount,
                                      travelDate: Timestamp.fromDate(widget.date),
                                      tipAmount: tipAmount,
                                      duration: widget.duration,
                                      bookingID: bookingID,
                                      bookingAgreement: bookingAgreement,
                                      bookingRef: bookingRef,
                                      paymentMethodID: userController.currentUser.value.paymentID ?? "",
                                      paymentIntentID: paymentIntentID,
                                      isPreMadeTrip: widget.isPreMadeTrip, userID: '', paid: true, status: '', creationDate: widget.duration as Timestamp,
                                    ));
                                    Get.back();
                                    Get.back();
                                    Get.off(() => MyBookings());
                                  },
                                ),
                              );
                            } else
                              showRedAlert('Please set a payment method to proceed');
                          } else
                            showRedAlert('Please agree to the Privacy Policy and Terms and Conditions to proceed');
                        },
                        text: 'Proceed',
                      ),
                    ),
                  ],
                ),
              );
            } else
              return LoadingData();
          }),
    );
  }

  addTip() {
    Rx<TextEditingController> tipAmountTEC = TextEditingController().obs;
    Get.defaultDialog(
      titlePadding: EdgeInsets.all(15),
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      title: 'Enter Tip Amount',
      content: Obx(() {
        return Column(
          children: [
            CustomTextField(
              label: '',
              hint: 'Enter amount',
              controller: tipAmountTEC.value,
              maxLines: 1,
              validate: true,
              textInputType: TextInputType.numberWithOptions(signed: false),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(onTap: () => tipAmountTEC.value.text = (widget.price * 0.05).toString(), child: Container(decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(5), child: Text('5%'))),
                InkWell(onTap: () => tipAmountTEC.value.text = (widget.price * 0.10).toString(), child: Container(decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(5), child: Text('10%'))),
                InkWell(onTap: () => tipAmountTEC.value.text = (widget.price * 0.15).toString(), child: Container(decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(5), child: Text('15%'))),
                InkWell(onTap: () => tipAmountTEC.value.text = (widget.price * 0.20).toString(), child: Container(decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(5), child: Text('20%'))),
              ],
            ),
          ],
        );
      }),
      actions: [
        ElevatedButton(
            onPressed: () async {
              Get.back();
              if (tipAmountTEC.value.text.isEmpty) {
                showRedAlert('Please enter a valid tip amount');
                return;
              }
              tipAmount = num.parse(tipAmountTEC.value.text);
              setState(() {});
            },
            child: Text('Add', textScaleFactor: 1)),
        TextButton(onPressed: () => Get.back(), child: Text('Cancel', textScaleFactor: 1)),
      ],
    );
  }

  addCoupon() {
    Rx<TextEditingController> couponCodeTEC = TextEditingController().obs;
    Get.defaultDialog(
      titlePadding: EdgeInsets.all(15),
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      title: 'Enter Coupon Code',
      content: Obx(() {
        return Column(
          children: [
            CustomTextField(
              label: '',
              hint: 'Enter here',
              controller: couponCodeTEC.value,
              maxLines: 1,
              validate: true,
            ),
            SizedBox(height: 15),
          ],
        );
      }),
      actions: [
        ElevatedButton(
            onPressed: () async {
              Get.back();
              FocusScope.of(context).unfocus();
              myDiscount = 0;
              if (couponCodeTEC.value.text.isNotEmpty) {
                num amount = widget.isPreMadeTrip ? widget.price : getFeesForDuration(widget.duration * widget.guestCount);
                final bookingService = Get.find<BookingService>();
                Discount? discount = await bookingService.calculateCouponDiscount(amount, couponCodeTEC.value.text);
                if (discount == null)
                  showRedAlert('Invalid Coupon code');
                else {
                  myDiscount = discount.coupon!.discount!;
                  showGreenAlert('Coupon applied');
                  setState(() {});
                }
              } else {
                showRedAlert('Enter Number of guests and coupon code');
              }
            },
            child: Text('Add', textScaleFactor: 1)),
        TextButton(onPressed: () => Get.back(), child: Text('Cancel', textScaleFactor: 1)),
      ],
    );
  }

  getFeesForDuration(num duration) {
    for (int i = 0; i < widget.vessel.durations!.length; i++) if (widget.vessel.durations![i] == duration) return widget.vessel.prices![i];
  }
}
