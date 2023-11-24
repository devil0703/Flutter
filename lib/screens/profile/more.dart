import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/services/misc_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/loading.dart';

class More extends StatelessWidget {
  final Vessel vessel;

  More({required this.vessel});

  final userController = Get.find<UserController>();
  final vesselService = Get.find<VesselService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MORE')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: FutureBuilder<DocumentSnapshot>(
            future: vesselService.getConstants(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                String privacy = snapshot.data!['privacy'];
                String cancellation = snapshot.data!['cancellation'];
                String faq = snapshot.data!['faq'];
                String service = snapshot.data!['service'];
                String houseRules = snapshot.data!['houseRules'];

                return Column(
                  children: [
                    customLink('Privacy Policy', privacy),
                    customLink('Cancellation Policy', cancellation),
                    customLink('House Rules', houseRules),
                    customLink('Terms of Service', service),
                    customLink('F.A.Q.', faq),
                  ],
                );
              } else
                return LoadingData();
            }),
      ),
    );
  }

  customLink(String title, String link) {
    final miscService = Get.find<MiscService>();
    return CustomListTile(
      leading: Icon(FontAwesomeIcons.link, color: primaryColor, size: 20),
      title: Text(title),
      onTap: () => miscService.openLink(link),
      trailing: Icon(Icons.arrow_right_alt, color: primaryColor, size: 20),
    );
  }
}
