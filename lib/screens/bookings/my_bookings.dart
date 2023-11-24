import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/booking_item.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class MyBookings extends StatelessWidget {
  final buyService = Get.find<BookingService>();
  final vesselService = Get.find<VesselService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MY BOOKINGS')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade400,
                ),
                child: TabBar(
                  labelPadding: EdgeInsets.zero,
                  labelColor: Colors.white,
                  indicatorColor: primaryColor,
                  indicator: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  unselectedLabelColor: primaryColor,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  // labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    showPage(false),
                    showPage(true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showPage(bool isPast) {
    return PaginateFirestore(
      isLive: true,
      padding: const EdgeInsets.only(top: 15),
      key: GlobalKey(),
      shrinkWrap: true,
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshot, i) {
        Booking booking = Booking.fromDocument(documentSnapshot[i]);
        return BookingItem(booking: booking);
      },
      query: buyService.getMyBookings(10, isPast),
      onEmpty: Padding(
        padding: EdgeInsets.only(bottom: Get.height / 2 - 200),
        child: EmptyBox(text: 'No booking to show'),
      ),
      itemsPerPage: 10,
      bottomLoader: LoadingData(),
      initialLoader: LoadingData(),
    );
  }
}
