import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/booking_item.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class AllBookings extends StatefulWidget {
  @override
  State<AllBookings> createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  final userController = Get.find<UserController>();
  final bookingService = Get.find<BookingService>();
  final vesselService = Get.find<VesselService>();
  RxBool showLoading = true.obs;
  RxString selectedVesselID = ''.obs;
  Rx<Vessel> vessel = Vessel().obs;
  List<Vessel> myVessels = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    List<dynamic> vessels = [];
    switch (MY_ROLE) {
      case VESSEL_OWNER:
        vessels = userController.currentUser.value.owners!;
        break;
      case VESSEL_CAPTAIN:
        vessels = userController.currentUser.value.captains!;
        break;
      case VESSEL_CREW:
        vessels = userController.currentUser.value.crew!;
        break;
    }
    for (int i = 0; i < vessels.length ; i++) {
      myVessels.add(Vessel.fromDocument(await vesselService.getVesselForVesselID(vessels[i])));
    }
    selectedVesselID.value = vessels.isNotEmpty ? vessels[0] : '';
    vessel.value = (myVessels.isNotEmpty ? myVessels[0] : null)!;
    showLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MANAGE ALL BOOKINGS')),
      body: Obx(
        () => showLoading.value
            ? CircularProgressIndicator()
            : vessel.value == null
                ? EmptyBox(text: 'Nothing to show')
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: CustomListTile(
                            marginBottom: 0,
                            leading: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 45, child: CachedImage(url: vessel.value.images![0], height: 45, circular: true)),
                              ],
                            ),
                            title: Text(vessel.value.vesselName!),
                            trailing: Icon(Icons.keyboard_arrow_down),
                            onTap: () => Get.defaultDialog(
                              title: 'Select a Vessel',
                              content: Container(
                                height: (myVessels.length * 60).toDouble(),
                                width: 400,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: myVessels.length,
                                  itemBuilder: (context, i) {
                                    return ListTile(
                                      leading: Container(width: 45, child: CachedImage(url: myVessels[i].images![0], height: 45, circular: true)),
                                      title: Text(myVessels[i].vesselName!),
                                      trailing: Text('SELECT', textScaleFactor: 0.9, style: TextStyle(color: Colors.blue)),
                                      onTap: () {
                                        Get.back();
                                        vessel.value = myVessels[i];
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 45,
                          margin: const EdgeInsets.all(15),
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
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                            child: TabBarView(
                              children: [
                                showPage(false),
                                showPage(true),
                              ],
                            ),
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
      key: GlobalKey(),
      shrinkWrap: true,
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshot, i) {
        Booking booking = Booking.fromDocument(documentSnapshot[i]);
        return BookingItem(booking: booking);
      },
      query: bookingService.getVesselBookings(vessel.value.vesselID!, 10, isPast),
      onEmpty: EmptyBox(text: 'No bookings to show'),
      itemsPerPage: 10,
      bottomLoader: LoadingData(),
      initialLoader: LoadingData(),
    );
  }
}
