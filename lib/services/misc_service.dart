import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MiscService {
  openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch URL';
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  getPinColor(String venueImpactStatus) {
    switch (venueImpactStatus) {
      case 'none':
        return 'assets/images/pin.png';
      case 'gold':
        return 'assets/images/gold_pin.png';
      case 'silver':
        return 'assets/images/silver_pin.png';
      case 'bronze':
        return 'assets/images/bronze_pin.png';
      default:
        return 'assets/images/pin.png';
    }
  }

  getBookingAgreement({String? vesselID, String? vesselOwner, String? vesselName, String? model, String? bookingRef, num? discount, num? amount, String? startDateTime, String? endDateTime, String? address}) {
    final userController = Get.find<UserController>();
    String agreement = "This agreement is between $vesselOwner of $address (“Owner”), owner of $model identified by Makai as BOAT $vesselID, and ${userController.currentUser.value.fullName} of  (\"Renter\") for Booking $bookingRef (\"$vesselName\")."
        "\n\n1. In consideration of the promises herein, the Owner agrees to let and the Renter agrees to hire the Boat from $startDateTime to $endDateTime via Makai for the sum of \$$amount USD exclusive of service fees and taxes, (the “Rental Fees”) which amount has been paid via the Makai system subject to the terms and conditions to which Owner and Renter have individually agreed with Makai, which in this instance includes a discount of \$$discount USD off the full price of \$$amount USD which does not affect the Owner’s payment."
        "\n\n2. The Owner agrees to charter the Boat at $address with captain on $startDateTime, in full commission and in proper working order with captain, all associated fees, documents and full equipment as stated in the Makai listing, inclusive of that required by law."
        "\n\n3. In accordance with the Makai policies and agreement to which the Owner is subject, Owner agrees to maintain marine hull liability insurance on the Boat which covers this Charter; such policy to be held by Owner as partial protection beyond the security deposit of \$$amount USD, for any deductible and loss or damage that may occur to, or caused by, the Boat during the charter period; and in case of any accident or disaster the Renter shall give the Owner or his representative prompt notice of same, and fill out a Makai in app damage or cleaning request provided loss notice no later than 48 hours following an incident."
        "\n\n4. The Renter agrees to passengers and to accept the Boat delivered as provided herein, and to participate in a “Pre-Rental & Post Rental” inspection of the Boat. Renter agrees that a failure to complete this document or not providing adequate, time-stamped photos or video documentation in lieu of a Pre-Rental or Post Rental Inspection documents makes you responsible for ALL damages, and not just the deductible and/or security deposit. In the case of a discrepancy, each party agrees to note the document if it does not agree to any particular damage on the Pre-Rental or Post Rental Inspection document and sign the same."
        "\n\n5. Renter agrees to pay Rental Fees as set forth above at the time of booking. Agreed Rental Fees are inclusive of all expenses including fuel and water, pump out and consumable stores, docking and mooring fees, port charges, and marina fees. Fees for damages (in excess of the Security Deposit), incidents, and cleaning, or as associated with a change to the route of the vessel as requested by Renter may be charged in addition to the agreed Rental Fee."
        "\n\n6. The Renter agrees to be responsible for and to replace or make good any injury to the Boat, her equipment or furnishings, caused personally by itself or any of its party, and not otherwise collectible under the Owner’s insurance, ordinary wear and tear excepted. Renter shall indemnify and hold Owner harmless for any loss or injury suffered by Renter or any member of his party resulting from events within Renter’s control."
        "\n\n7. The Renter agrees to surrender the Boat at the expiration of this charter at the same location the Boat was originally received (unless otherwise specified by the owner prior to rental period), free and clear of any indebtedness that may have been incurred for his account during the term of charter, and in as good condition as when delivery was taken, ordinary wear and tear and any loss or damage that he shall not be liable to make good excepted. In the event of any damage or loss to the Boat or its equipment, Renter shall fully advise Owner thereof not later than the termination of the charter using the Pre- Rental or Post Rental Inspection document as described elsewhere in this agreement."
        "\n\n8. The Renter agrees that the Boat shall be used exclusively as a pleasure vessel for the sole and proper use of Renter, its family and guests during the term of this charter and Renter shall at all times during the term of this charter obey the lawful commands of the Captain, abide by the Revenue Laws of the United States, and shall comply with state and federal law in all other respects."
        "\n\n9. The Renter agrees not to assign this Agreement or subcharter the Boat, and Renter agrees that only the Makai authorized Owner/Captain may operate the vessel, pre-approved by the Owner’s own commercial charter policy has approved the Captain."
        "\n\n10. It is further agreed by the parties hereto that Renter agrees to allow Makai to charge the Renter’s credit card three (3) days prior to the Charter term beginning the security deposit amount of $amount. Makai will release the hold 72 hours after the Charter term concludes unless a claim or incident is reported. If a claim is filed, Makai will hold the security deposit until the Insurance Company underwriting the coverage renders a decision. Any uncovered or excess damage and/or the deductible, administrative fee or other deduction allowed for under the terms hereof or by the Renter’s agreement with Makai will be deducted from the security deposit and the balance remaining will be refunded. In the instance where balance due exceeds the security deposit, the renter agrees to allow Makai to charge the credit card used to make the purchase for the amount. In the case the credit card is not able to complete a transaction, the Renter will be required to submit an alternate payment method."
        "\n\n11. Should the Owner and Renter be unable to reconcile any differences that may arise with respect to this Agreement, such dispute shall be referred to a sole arbitrator to be named by Makai. The decision in writing signed by the arbitrator shall be final and binding upon both Owner and Renter and may be binding in any court of competent jurisdiction. The expense and fees in connection with such arbitration shall be equally divided between the parties unless the arbitrator decides otherwise. All disputes or disagreements to be settled in Palm Beach County, Florida applying the law of Florida to the extent it is not preempted by general maritime law."
        "\n\n12. The Owner’s and Renter’s, electronic assent and signatures need not be affixed to the same copy of this Charter Booking Agreement, and Makai may transmit the Charter Booking Agreement by any electronic means."
        "\n\n13. Renter will use its utmost good faith and due diligence to abide by the Makai Code of Conduct at all times"
        "\n\n14. Renter accepts that any changes or modifications to the Charter Booking as to date, time, price or any similar logistical change made after the original booking will be confirmed by email to Owner and Renter, which once sent; shall be incorporated into this Agreement as if originally set forth."
        "\n\nIN WITNESS WHEREOF, the parties hereto set their hands the day and year first above written.";
    return agreement;
  }
}
