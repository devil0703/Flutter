import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/users_model.dart' as u;
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/home/map_view.dart';
import 'package:makaiapp/screens/home/search_results.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:makaiapp/widgets/notification_icon.dart';
import 'package:makaiapp/widgets/vessel_item.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();

  initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // executes after build
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onLongPress: () {
            if (FirebaseAuth.instance.currentUser!.email == 'ujwalchordiya@gmail.com') adminControls(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Image.asset('assets/images/makai.png', width: MediaQuery.of(context).size.width * 0.3),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () => Get.to(() => MapView()), icon: Icon(Icons.map, color: Colors.white)),
          // IconButton(
          //     // onPressed: () async {
          //     //
          //     //   await BuyService().getCards();
          //     //   //await cloudFunction(functionName: 'listCards', parameters: {'customer_id': 'cus_KPu2njrClX8F4N'}, action: () {});
          //     // },
          //     onPressed: () => Get.to(() => Notifications()),
          //     icon: Icon(Icons.notifications_none_outlined, color: Colors.white)),
          NotificationIcon(),
          SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    onTap: () => Get.to(() => SearchResults(searchQuery: '')),
                    decoration: InputDecoration(
                      hintText: 'Search Vessels...',
                      hintStyle: TextStyle(color: primaryColor),
                      suffixIcon: Icon(Icons.search, color: primaryColor),
                    ),
                    onFieldSubmitted: (val) {
                      FocusScope.of(context).unfocus();
                      if (val != '') Get.to(() => SearchResults(searchQuery: val));
                    },
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: Colors.grey.shade300, width: 1)),
                  child: IconButton(
                    onPressed: () => showFilters(context),
                    icon: Icon(Icons.filter_alt_outlined),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: showPage(),
            ),
          ],
        ),
      ),
    );
  }

  showPage() {
    return PaginateFirestore(
      isLive: true,
      key: GlobalKey(),
      padding: const EdgeInsets.only(bottom: 25),
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshot, i) {
        Vessel vessel = Vessel.fromDocument(documentSnapshot[i] as DocumentSnapshot<Map<String, dynamic>>);
        if (vessel.licensed! && vessel.captainLicensed!)
          return VesselItem(vessel: vessel);
        else
          return Container();
      },
      query: getQuery(),
      onEmpty: EmptyBox(text: 'No vessels to show'),
      itemsPerPage: 10,
      bottomLoader: LoadingData(),
      initialLoader: LoadingData(),
    );
  }

  getQuery() {
    switch (sortBy) {
      case 'popular':
        return vesselService.getPopularVessels();
      case 'ratings':
        return vesselService.getRatedVessels();
      case 'priceH':
        return vesselService.getVesselsPriceHigh();
      case 'priceL':
        return vesselService.getVesselsPriceLow();
    }
  }

  String sortBy = 'popular';

  void showFilters(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  insetPadding: EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Sort By", textScaleFactor: 1.25),
                        Divider(color: Colors.grey.shade400, height: 20, thickness: 1),
                        RadioListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          groupValue: sortBy,
                          title: Text('Popularity', textScaleFactor: 1.1),
                          value: 'popular',
                          onChanged: (val) => setState(() => sortBy = val as String),
                        ),
                        RadioListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          groupValue: sortBy,
                          title: Text('Ratings', textScaleFactor: 1.1),
                          value: 'ratings',
                          onChanged: (val) => setState(() => sortBy = val as String),
                        ),
                        RadioListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          groupValue: sortBy,
                          title: Text('Price: High to Low', textScaleFactor: 1.1),
                          value: 'priceH',
                          onChanged: (val) => setState(() => sortBy = val as String),
                        ),
                        RadioListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          groupValue: sortBy,
                          title: Text('Price: Low to High', textScaleFactor: 1.1),
                          value: 'priceL',
                          onChanged: (val) => setState(() => sortBy = val as String),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                              setState(() {});
                            },
                            child: Text('Apply')),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result) {
      setState(() {});
    }
  }

  adminControls(BuildContext context) async {
    TextEditingController staffTEC = TextEditingController();
    Get.defaultDialog(
      title: 'Login As',
      content: CustomTextField(label: 'Enter Email', hint: 'Enter email', controller: staffTEC, maxLines: 1, validate: true, isEmail: false, textInputType: TextInputType.emailAddress),
      actions: [
        ElevatedButton(
            onPressed: () async {
              Get.back();
              showGreenAlert('Please wait...');
              String mobile = staffTEC.text.trim();
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: mobile).get();
              if (querySnapshot.docs.isNotEmpty) {
                userController.currentUser.value = u.User.fromDocument(querySnapshot.docs[0]);
                await Preferences.setUser(userController.currentUser.value.userID!);
                await userService.getCurrentUser();
                Get.back();
                showGreenAlert('You are now logged in as ' + userController.currentUser.value.fullName!);
              } else {
                Get.back();
                showRedAlert('User does not exist. Please check the mobile number');
              }
            },
            child: Text('Login', textScaleFactor: 1)),
        TextButton(onPressed: () => Get.back(), child: Text('Cancel', textScaleFactor: 1)),
      ],
    );
  }
}
