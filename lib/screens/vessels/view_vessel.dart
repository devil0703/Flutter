import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/forum_model.dart';
import 'package:makaiapp/models/review_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/auth/login.dart';
import 'package:makaiapp/screens/bookings/book_now.dart';
import 'package:makaiapp/screens/messages/chats.dart';
import 'package:makaiapp/screens/messages/view_image.dart';
import 'package:makaiapp/screens/vessels/write_post.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/post_item.dart';
import 'package:makaiapp/widgets/review_item.dart';
import 'package:makaiapp/widgets/saved_button.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ViewVessel extends StatefulWidget {
  final String vesselID;
  final bool showFullAddress;

  ViewVessel(this.showFullAddress, {required this.vesselID});

  @override
  State<ViewVessel> createState() => _ViewVesselState();
}

class _ViewVesselState extends State<ViewVessel> {
  final userService = Get.find<UserService>();

  final messageService = Get.find<MessageService>();

  final vesselService = Get.find<VesselService>();

  final bookingService = Get.find<BookingService>();

  final userController = Get.find<UserController>();

  final dialogService = Get.find<DialogService>();

  final formatCurrency = new NumberFormat.simpleCurrency();

  RxBool checkIfBooked = false.obs;

  @override
  void initState() {
    check();
    super.initState();
  }

  check() async {
    checkIfBooked.value = await bookingService.checkIfIBooked(widget.vesselID);
    print('VALUE CHEKED== ' + checkIfBooked.value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('VESSEL DETAILS'),
          actions: [
            if (u.FirebaseAuth.instance.currentUser != null) SavedButton(vesselID: widget.vesselID),
          ],
        ),
        body: StreamBuilder(
            stream: vesselService.getVesselForVesselIDStream(widget.vesselID),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                Vessel vessel = Vessel.fromDocument(snapshot.data as DocumentSnapshot<Map<String, dynamic>>);
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Row(
                            children: [
                              Expanded(child: Text(vessel.vesselName!, textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold))),
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(vessel.rating!.toStringAsFixed(1), textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                decoration: BoxDecoration(color: Colors.deepOrangeAccent, borderRadius: BorderRadius.circular(5)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            //color: Colors.grey.shade400,
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
                              Tab(text: 'Details'),
                              Tab(text: 'Features'),
                              Tab(text: 'Reviews'),
                              Tab(text: 'Forum'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              buildDetails(context, vessel),
                              buildFeatures(vessel),
                              buildReviews(context, vessel),
                              buildForum(context, vessel),
                            ],
                          ),
                        ),
                        if (MY_ROLE == VESSEL_USER)
                          Row(
                            children: [
                              if (vessel.userID != userController.currentUser.value.userID)
                                Expanded(
                                  child: CustomButton(
                                    text: 'MESSAGE',
                                    color: Colors.green,
                                    function: () async {
                                      if (u.FirebaseAuth.instance.currentUser == null)
                                        Get.offAll(() => Login());
                                      else {
                                        dialogService.showLoading();
                                        QuerySnapshot querySnapshot = await vesselService.getVesselReceptionistForChat(vessel.vesselID!);
                                        User? user = querySnapshot.docs.isEmpty ? null : User.fromDocument(querySnapshot.docs[0]);
                                        String? userID = user == null ? vessel.vesselChatUserID : user.userID;
                                        String chatRoomID = await messageService.checkIfVesselChatRoomExists(userID!, vessel.vesselID!, true, false);
                                        DocumentSnapshot doc = await userService.getUser(userID);
                                        User chatUser = User.fromDocument(doc);
                                        Get.back();
                                        Get.to(() => Chats(user: chatUser, chatRoomID: chatRoomID, vessel: vessel));
                                      }
                                    },
                                  ),
                                ),
                              if (vessel.userID != userController.currentUser.value.userID) SizedBox(width: 15),
                              Expanded(
                                child: CustomButton(
                                  text: 'BOOK',
                                  function: () {
                                    if (u.FirebaseAuth.instance.currentUser == null)
                                      Get.offAll(() => Login());
                                    else
                                      Get.to(() => BookNow(vessel: vessel));
                                    // else {
                                    //   DateTime bookingDate;
                                    //   TextEditingController guestCountTEC = TextEditingController();
                                    //   TextEditingController dateTEC = TextEditingController();
                                    //   Get.defaultDialog(
                                    //     titlePadding: const EdgeInsets.only(top: 10),
                                    //     contentPadding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                                    //     title: 'Book',
                                    //     titleStyle: TextStyle(fontWeight: FontWeight.bold),
                                    //     content: Column(
                                    //       children: [
                                    //         CustomTextField(
                                    //           label: 'Number of seats',
                                    //           hint: 'Enter count',
                                    //           controller: guestCountTEC,
                                    //           textInputType: TextInputType.numberWithOptions(decimal: false, signed: false),
                                    //           validate: true,
                                    //         ),
                                    //         InkWell(
                                    //             onTap: () {
                                    //               DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2000), maxTime: DateTime(2100), onChanged: (date) {}, onConfirm: (date) {
                                    //                 dateTEC.text = DateFormat('MMMM dd, yyyy').format(date);
                                    //                 bookingDate = date;
                                    //               }, currentTime: DateTime.now(), locale: LocaleType.en);
                                    //             },
                                    //             child: CustomTextField(controller: dateTEC, label: 'Select Date *', hint: 'Select date', validate: true, enabled: false)),
                                    //       ],
                                    //     ),
                                    //     cancel: ElevatedButton(
                                    //         onPressed: () {
                                    //           if (dateTEC.text.isNotEmpty && guestCountTEC.text.isNotEmpty) {
                                    //             Get.back();
                                    //             Get.to(() => Checkout(vessel: vessel, guestCount: int.parse(guestCountTEC.text), date: bookingDate));
                                    //           } else
                                    //             showRedAlert('Please enter all details');
                                    //         },
                                    //         child: Text('Book')),
                                    //     confirm: Padding(
                                    //       padding: const EdgeInsets.only(bottom: 10),
                                    //       child: ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(redColor)), onPressed: () => Get.back(), child: Text('Cancel')),
                                    //     ),
                                    //   );
                                    // }
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              } else
                return LoadingData();
            }));
  }

  buildDetails(context, Vessel vessel) {
    final PageController reviewController = PageController();

    return ListView(
      padding: const EdgeInsets.only(top: 15),
      children: [
        SizedBox(
          height: Get.width - 40,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: reviewController,
                  itemCount: vessel.images!.length,
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () => Get.to(() => ViewImages(images: vessel.images!, index: i)),
                      child: CachedImage(
                        url: vessel.images![i],
                        height: 100,
                        roundedCorners: true,
                        circular: false,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 40,
                child: SmoothPageIndicator(
                  controller: reviewController, // PageController
                  count: vessel.images!.length,
                  effect: WormEffect(activeDotColor: primaryColor, radius: 5, dotHeight: 10, dotWidth: 10),
                  onDotClicked: (index) {},
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Text('Vessel Category: ' + vessel.vesselType!, textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold)),
        if (vessel.vesselType == 'Yacht')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('Vessel Type: ' + vessel.yachtType!, textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        SizedBox(height: 30),
        Text('Description', textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Text(vessel.description!),
        SizedBox(height: 20),
        Text('Details', textScaleFactor: 1.1, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        CustomListTile(
          onTap: () => widget.showFullAddress ? openMap(vessel.geoPoint!.latitude, vessel.geoPoint!.longitude) : showNoticeAlert('Full address will be shown once your booking is confirmed'),
          leading: Icon(Icons.location_on_outlined, color: secondaryColor),
          title: Text(widget.showFullAddress 
  ? (vessel.address ?? 'Default Address') 
  : (vessel.shortAddress ?? 'Short Address'), style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)),
          trailing: Icon(Icons.directions_outlined, color: secondaryColor),
        ),
        CustomListTile(
          leading: Icon(Icons.event_seat_outlined),
          title: Text('Passenger Capacity'),
          trailing: Text(vessel.passengerCapacity.toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.only(right: 15),
            title: Row(
              children: [
                Expanded(child: Icon(Icons.attach_money)),
                Expanded(flex: 3, child: Text('Pricing')),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: vessel.durations!.length,
                        itemBuilder: (context, index) => fishingFeatures('Cost for ${vessel.durations![index].toString()} hours', formatCurrency.format(vessel.prices![index]).toString()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (vessel.vesselType == 'Fishing')
          Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.only(right: 15),
              title: Row(
                children: [
                  Expanded(child: Icon(FontAwesomeIcons.fish)),
                  Expanded(flex: 3, child: Text('Fishing Features')),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fishingFeatures('Fishing Type', vessel.fishingType!),
                      fishingFeatures('Vessel Type', vessel.fishingVesselType!),
                      fishingFeatures('Fishing Techniques', ''),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: vessel.fishingTechniques!.length,
                          itemBuilder: (context, index) => Text(
                            "- ${vessel.fishingTechniques![index]}",
                          ),
                        ),
                      ),
                      fishingFeatures('Fishing Species', ''),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: vessel.fishingSpecies!.length,
                          itemBuilder: (context, index) => Text(
                            "- ${vessel.fishingSpecies![index]}",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.only(right: 15),
            title: Row(
              children: [
                Expanded(child: Icon(Icons.info_outline)),
                Expanded(flex: 3, child: Text('Cancellation Policy')),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vessel.cancellationPolicy!, textScaleFactor: 1.25, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Text(getCancellationPolicyText(vessel)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  fishingFeatures(String title, String feature) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(feature),
      ],
    );
  }

  getCancellationPolicyText(Vessel vessel) {
    if (vessel.cancellationPolicy == 'Flexible') return 'Free cancellations until 24 hrs before the start date.\n\nCancellations within 24 hours of booking are non-refundable.';
    if (vessel.cancellationPolicy == 'Moderate') return 'Free cancellations until 7 days before the start date.\n\n50% refund on cancellations between 2 and 7 days before booking start date.\n\nCancellations within 2 days of booking are non-refundable.';
    if (vessel.cancellationPolicy == 'Strict') return 'Free cancellations until 30 days before the start date.\n\n50% refund on cancellations between 14 and 30 days before booking start date.\n\nCancellations within 14 days of booking are non-refundable.';
    return '';
  }

  buildFeatures(Vessel vessel) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children: [
        CustomListTile(
          leading: Icon(FontAwesomeIcons.rulerHorizontal),
          title: Text('Length'),
          trailing: Text((vessel.length! * 3.28084).toString() + 'm', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        CustomListTile(
          leading: Icon(FontAwesomeIcons.personBooth),
          title: Text('Cabins'),
          trailing: Text(vessel.cabins.toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        CustomListTile(
          leading: Icon(FontAwesomeIcons.restroom),
          title: Text('Bathrooms'),
          trailing: Text(vessel.bathrooms.toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        CustomListTile(
          leading: Icon(Icons.group),
          title: Text('Crew Size'),
          trailing: Text(vessel.crewSize.toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        CustomListTile(
          leading: Icon(FontAwesomeIcons.gaugeHigh),
          title: Text('Top Speed'),
          trailing: Text((vessel.speed! * 1.150779).toString() + ' mph', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.only(right: 15),
            title: Row(
              children: [
                Expanded(child: Icon(Icons.view_list)),
                Expanded(flex: 3, child: Text('Amenities')),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 60),
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: vessel.features!.length,
                  itemBuilder: (context, index) => Text(
                    "- ${vessel.features![index]}",
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.only(right: 15),
            title: Row(
              children: [
                Expanded(child: Icon(Icons.pets)),
                Expanded(flex: 3, child: Text('Things Allowed Onboard')),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 60),
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: vessel.thingsAllowed!.length,
                  itemBuilder: (context, index) => Text(
                    "- ${vessel.thingsAllowed![index]}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buildReviews(context, Vessel vessel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Reviews (${vessel.ratingCount.toString()})', style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() {
                if (checkIfBooked.isTrue)
                  return TextButton(
                      onPressed: () {
                        if (u.FirebaseAuth.instance.currentUser == null)
                          Get.offAll(() => Login());
                        else
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return RatingDialog(
                                  starColor: Colors.deepOrangeAccent,
                                  image: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CachedImage(roundedCorners: true, circular: false, height: 75, url: vessel.images![0]),
                                    ],
                                  ),
                                  title: Text("Rate ${vessel.vesselName}"),
                                  initialRating: 0,
                                  force: true,
                                  message: Text("Tap a star to set your rating and press submit"),
                                  commentHint: 'Tell us what you think...',
                                  submitButtonText: "SUBMIT",
                                  onSubmitted: (response) async {
                                    if (response.comment.isNotEmpty && response.rating > 0) {
                                      Get.back();
                                      Review review = Review(
                                        userID: userController.currentUser.value.userID,
                                        flagged: false,
                                        comment: response.comment,
                                        rating: response.rating.toDouble(),
                                        reviewID: Uuid().v1(),
                                        vesselID: vessel.vesselID,
                                      );
                                      await vesselService.addReview(review, vessel);
                                    } else
                                      showRedAlert('Please tap a star and enter a comment');
                                  },
                                  //onAlternativePressed: () => openLink('tel:${venue.venuePhoneNumber}'),
                                );
                              });
                      },
                      child: Text('Write a review', style: TextStyle(decoration: TextDecoration.underline)));
                else
                  return Container();
              }),
            ],
          ),
        ),
        Expanded(
          child: PaginateFirestore(
            key: GlobalKey(),
            shrinkWrap: true,
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (context, documentSnapshot, i) {
              Review review = Review.fromDocument(documentSnapshot[i]);
              return ReviewItem(review: review);
            },
            query: vesselService.getVesselReviews(vessel.vesselID!, 5000),
            onEmpty: Padding(
              padding: EdgeInsets.only(bottom: Get.height / 2 - 100),
              child: EmptyBox(text: 'Book this vessel to review'),
            ),
            itemsPerPage: 10,
            bottomLoader: LoadingData(),
            initialLoader: LoadingData(),
          ),
        )
      ],
    );
  }

  buildForum(context, Vessel vessel) {
    return Column(
      children: [
        Obx(() {
          if (checkIfBooked.isTrue)
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        if (u.FirebaseAuth.instance.currentUser == null)
                          Get.offAll(() => Login());
                        else
                          Get.to(() => WritePost(vessel: vessel, forum: null as Forum,));
                      },
                      child: Text('Write a Post', style: TextStyle(decoration: TextDecoration.underline))),
                ],
              ),
            );
          else
            return Container();
        }),
        Expanded(
          child: PaginateFirestore(
            isLive: true,
            key: GlobalKey(),
            shrinkWrap: true,
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (context, documentSnapshot, i) {
              Forum forum = Forum.fromDocument(documentSnapshot[i]);
              return PostItem(forum: forum, vessel: vessel);
            },
            query: vesselService.getVesselForumPosts(vessel.vesselID!, 5000),
            onEmpty: Padding(
              padding: EdgeInsets.only(bottom: Get.height / 2 - 100),
              child: EmptyBox(text: 'Book this vessel to post'),
            ),
            itemsPerPage: 10,
            bottomLoader: LoadingData(),
            initialLoader: LoadingData(),
          ),
        ),
      ],
    );
  }

  openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
