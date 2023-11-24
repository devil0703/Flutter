import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/vessels/manage_vessels.dart';
import 'package:makaiapp/screens/vessels/view_vessel.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';

class VesselItem extends StatelessWidget {
  final Vessel? vessel;

  VesselItem({this.vessel});
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => ViewVessel(false, vesselID: vessel!.vesselID!)),
      child: Container(
        height: MY_ROLE != VESSEL_USER ? 320 : 250,
        margin: const EdgeInsets.only(bottom: 20),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: vessel!.disabledByAdmin! ? Colors.grey : Colors.transparent,
          backgroundBlendMode: BlendMode.saturation,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          //border: Border.all(width: 2, color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, spreadRadius: 1)],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    child: CachedImage(url: vessel!.images![0], height: double.infinity, roundedCorners: false),
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.solidStar, size: 10, color: Colors.white),
                        SizedBox(width: 5),
                        Text(vessel!.rating!.toStringAsFixed(1), textScaleFactor: 0.9, style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(color: Colors.deepOrangeAccent, borderRadius: BorderRadius.circular(5)),
                  ),
                  if (vessel!.disabledUntil != null)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          color: redColor,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(vessel!.disabledUntil!.toDate().isBefore(DateTime(2100)) ? 'Disabled Until: ' + DateFormat('dd MMM yyyy').format(vessel!.disabledUntil!.toDate()) : 'Disabled permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          )),
                    )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(child: Text(vessel!.vesselName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
                            Text('From ' + formatCurrency.format(vessel!.prices![0]).toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (MY_ROLE != VESSEL_USER && !vessel!.licensed! || !vessel!.captainLicensed!)
              Container(
                color: redColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Add a certificate and a license to the vessel to accept bookings', textScaleFactor: 0.8, style: TextStyle(color: Colors.white))],
                ),
              ),
            if (MY_ROLE != VESSEL_USER)
              Column(
                children: [
                  Divider(height: 1, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(icon: Icon(Icons.remove_red_eye, color: Colors.green, size: 20), onPressed: () => Get.to(() => ViewVessel(true, vesselID: vessel!.vesselID!)), label: Text('View', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      TextButton.icon(icon: Icon(Icons.settings, color: secondaryColor, size: 20), onPressed: () => Get.to(() => ManageVessels(vessel: vessel!)), label: Text('Manage', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
