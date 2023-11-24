import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/models/transaction_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class Reports extends StatelessWidget {
  final String vesselID;

  Reports({required this.vesselID});

  final bookingService = Get.find<BookingService>();
  final userService = Get.put(UserService());
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('REPORTS')),
        body: PaginateFirestore(
          isLive: true,
          padding: const EdgeInsets.all(15),
          key: GlobalKey(),
          shrinkWrap: true,
          itemBuilderType: PaginateBuilderType.listView,
          itemBuilder: (context, documentSnapshot, i) {
            TransactionModel transaction = TransactionModel.fromDocument(documentSnapshot[i]);
            return FutureBuilder(
              future: userService.getUser(transaction.userID),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  User user = User.fromDocument(snapshot.data!);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: ExpansionTile(
                      expandedAlignment: Alignment.centerLeft,
                      childrenPadding: const EdgeInsets.all(25),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 15),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      leading: CachedImage(url: user.photoURL!, height: 40, roundedCorners: false, circular: true),
                      title: Text(user.fullName!),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMMM dd, yyyy').format(transaction.creationDate!.toDate()), style: TextStyle(color: Colors.grey)),
                          Text(formatCurrency.format(transaction.amount).toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      children: [
                        item('Total Amount', formatCurrency.format(transaction.amount).toString(), Colors.green),
                        item('Tip Amount', formatCurrency.format(transaction.tipAmount).toString(), secondaryColor),
                        item('Type', transaction.type!, primaryColor),
                        item('Payment Method', transaction.paymentMethod!, primaryColor),
                        //item('Transaction ID', transaction.transactionID, primaryColor),
                        //item('Stripe Customer ID', transaction.stripeCustomerID, primaryColor),
                        //item('Stripe Payment ID', transaction.stripePaymentID, primaryColor),
                      ],
                    ),
                  );
                } else
                  return Container();
              },
            );
          },
          query: bookingService.getVesselTransactions(vesselID),
          onEmpty: EmptyBox(text: 'No transactions to show'),
          itemsPerPage: 10,
          bottomLoader: LoadingData(),
          initialLoader: LoadingData(),
        ));
  }

  item(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 20),
      ],
    );
  }
}
