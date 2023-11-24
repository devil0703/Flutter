import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/certificate_model.dart';
import 'package:makaiapp/models/forum_model.dart';
import 'package:makaiapp/models/license_model.dart';
import 'package:makaiapp/models/makai_fee_model.dart';
import 'package:makaiapp/models/premade_trip_model.dart';
import 'package:makaiapp/models/review_model.dart';
import 'package:makaiapp/models/users_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/home/home_page.dart';
import 'package:makaiapp/screens/vessels/select_journey_timings.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/notification_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:uuid/uuid.dart';

class VesselService {
  final userService = Get.find<UserService>();
  final dialogService = Get.find<DialogService>();
  final userController = Get.find<UserController>();

  getVesselForVesselID(String vesselID) async {
    return await ref.collection('vessels').doc(vesselID).get();
  }

  Stream<DocumentSnapshot> getVesselForVesselIDStream(String vesselID) {
    return ref.collection('vessels').doc(vesselID).snapshots();
  }

  getRatedVessels() {
    return ref.collection('vessels').where('approved', isEqualTo: true).where('disabledByAdmin', isEqualTo: false).orderBy('rating', descending: true);
  }

  getPopularVessels() {
    return ref.collection('vessels').where('approved', isEqualTo: true).where('disabledByAdmin', isEqualTo: false).orderBy('ratingCount', descending: true);
  }

  getVesselsOnMap() {
    return ref.collection('vessels').where('approved', isEqualTo: true).where('disabledByAdmin', isEqualTo: false).get();
  }

  getVesselsPriceHigh() {
    return ref.collection('vessels').where('approved', isEqualTo: true).where('disabledByAdmin', isEqualTo: false).orderBy('costPerHour', descending: true);
  }

  getVesselsPriceLow() {
    return ref.collection('vessels').where('approved', isEqualTo: true).where('disabledByAdmin', isEqualTo: false).orderBy('costPerHour', descending: false);
  }

  getMyVessels() {
    return ref.collection('vessels').where('userID', isEqualTo: userController.currentUser.value.userID);
  }

  addVessel(Vessel vessel) async {
    return await ref.collection('vessels').doc(vessel.vesselID).set({
      'userID': userController.currentUser.value.userID,
      'vesselID': vessel.vesselID,
      'owners': [userController.currentUser.value.userID],
      'images': vessel.images,
      'vesselType': vessel.vesselType,
      'yachtType': vessel.yachtType,
      'fishingVesselType': vessel.fishingVesselType,
      'fishingType': vessel.fishingType,
      'fishingTechniques': vessel.fishingTechniques,
      'fishingSpecies': vessel.fishingSpecies,
      'vesselName': vessel.vesselName,
      'description': vessel.description,
      'prices': vessel.prices,
      'costPerHour': vessel.prices!.reduce((curr, next) => curr < next ? curr : next),
      'rating': vessel.rating,
      'ratingCount': vessel.ratingCount,
      'geoPoint': vessel.geoPoint,
      'address': vessel.address,
      'shortAddress': vessel.shortAddress,
      'durations': vessel.durations,
      'thingsAllowed': vessel.thingsAllowed,
      'length': vessel.length,
      'passengerCapacity': vessel.passengerCapacity,
      'cabins': vessel.cabins,
      'bathrooms': vessel.bathrooms,
      'crewSize': vessel.crewSize,
      'speed': vessel.speed,
      'builder': vessel.builder,
      'features': vessel.features,
      'approved': vessel.approved,
      'cancellationPolicy': vessel.cancellationPolicy,
      'monday': SelectJourneyTiming.selectedMondayTimings,
      'tuesday': SelectJourneyTiming.selectedTuesdayTimings,
      'wednesday': SelectJourneyTiming.selectedWednesdayTimings,
      'thursday': SelectJourneyTiming.selectedThursdayTimings,
      'friday': SelectJourneyTiming.selectedFridayTimings,
      'saturday': SelectJourneyTiming.selectedSaturdayTimings,
      'sunday': SelectJourneyTiming.selectedSundayTimings,
      //'nameSearch': generateCaseSearch(vessel.vesselName.toLowerCase().trim()),
      'disabledByAdmin': vessel.disabledByAdmin,
      'vesselChatUserID': userController.currentUser.value.userID,
    }).then((value) async {
      await userService.updateUser({
        'owners': FieldValue.arrayUnion([vessel.vesselID]),
        'receptionists': FieldValue.arrayUnion([vessel.vesselID]),
      });
      //Get.back();
      //Get.back();
      Get.offAll(() => HomePage());
      showGreenAlert('Vessel added successfully');
    }).catchError((e) {
      Get.back();
      showRedAlert(e.toString());
    });
  }

  editVessel(Vessel vessel) async {
    // List nameSearch = generateCaseSearch(vessel.vesselName.toLowerCase().trim());
    // nameSearch.add(vessel.vesselType.toLowerCase());
    // nameSearch.add(vessel.yachtType.toLowerCase());
    // nameSearch.add(vessel.fishingVesselType.toLowerCase());
    // nameSearch.add(vessel.fishingType.toLowerCase());
    // nameSearch = nameSearch + vessel.fishingSpecies.map((term) => term.toLowerCase()).toList();
    // nameSearch = nameSearch + vessel.fishingTechniques.map((term) => term.toLowerCase()).toList();
    // nameSearch = nameSearch + vessel.thingsAllowed.map((term) => term.toLowerCase()).toList();

    return await ref.collection('vessels').doc(vessel.vesselID).update({
      'vesselType': vessel.vesselType,
      'yachtType': vessel.yachtType,
      'fishingVesselType': vessel.fishingVesselType,
      'fishingType': vessel.fishingType,
      'fishingTechniques': vessel.fishingTechniques,
      'fishingSpecies': vessel.fishingSpecies,
      'vesselName': vessel.vesselName,
      'description': vessel.description,
      'prices': vessel.prices,
      'costPerHour': vessel.prices!.reduce((curr, next) => curr < next ? curr : next),
      'geoPoint': vessel.geoPoint,
      'address': vessel.address,
      'shortAddress': vessel.shortAddress,
      'durations': vessel.durations,
      'thingsAllowed': vessel.thingsAllowed,
      'length': vessel.length,
      'passengerCapacity': vessel.passengerCapacity,
      'cabins': vessel.cabins,
      'bathrooms': vessel.bathrooms,
      'crewSize': vessel.crewSize,
      'speed': vessel.speed,
      'builder': vessel.builder,
      'features': vessel.features,
      'cancellationPolicy': vessel.cancellationPolicy,
      'monday': SelectJourneyTiming.selectedMondayTimings,
      'tuesday': SelectJourneyTiming.selectedTuesdayTimings,
      'wednesday': SelectJourneyTiming.selectedWednesdayTimings,
      'thursday': SelectJourneyTiming.selectedThursdayTimings,
      'friday': SelectJourneyTiming.selectedFridayTimings,
      'saturday': SelectJourneyTiming.selectedSaturdayTimings,
      'sunday': SelectJourneyTiming.selectedSundayTimings,
      'vesselChatUserID': vessel.vesselChatUserID,
      'licensed': vessel.licensed,
      'captainLicensed': vessel.captainLicensed,
    }).then((value) async {
      Get.back();
      Get.back();
      showGreenAlert('Vessel updated successfully');
    }).catchError((e) {
      Get.back();
      showRedAlert(e.toString());
    });
  }

  addCertificate(Certificate certificate) async {
    String certificateID = Uuid().v1();
    return await ref.collection('certificates').doc(certificateID).set({
      'certificateID': certificateID,
      'userID': certificate.userID,
      'vesselID': certificate.vesselID,
      'certificates': certificate.certificates,
      'certificateAuthority': certificate.certificateAuthority,
      'certificateType': certificate.certificateType,
      'cNumber': certificate.cNumber,
      'vDNumber': certificate.vDNumber,
      'mONumber': certificate.mONumber,
      'port': certificate.port,
      'tonnage': certificate.tonnage,
      'issueDate': certificate.issueDate,
      'buildDate': certificate.buildDate,
      'expiryDate': certificate.expiryDate,
      'issuePlace': certificate.issuePlace,
    }).then((value) async {
      DocumentSnapshot doc = await getVesselForVesselID(certificate.vesselID!);
      Vessel vessel = Vessel.fromDocument(doc as DocumentSnapshot<Map<String, dynamic>>);
      vessel.licensed = true;
      await editVessel(vessel);
      Get.back();
      Get.back();
      showGreenAlert('Certificate added successfully');
    }).catchError((e) {
      Get.back();
      showRedAlert(e.toString());
    });
  }

  editCertificate(Certificate certificate) async {
    return await ref.collection('certificates').doc(certificate.certificateID).update({
      'certificates': certificate.certificates,
      'certificateAuthority': certificate.certificateAuthority,
      'certificateType': certificate.certificateType,
      'cNumber': certificate.cNumber,
      'vDNumber': certificate.vDNumber,
      'mONumber': certificate.mONumber,
      'port': certificate.port,
      'tonnage': certificate.tonnage,
      'issueDate': certificate.issueDate,
      'buildDate': certificate.buildDate,
      'expiryDate': certificate.expiryDate,
      'issuePlace': certificate.issuePlace,
    }).then((value) async {
      Get.back();
      Get.back();
      showGreenAlert('Certificate updated successfully');
    }).catchError((e) {
      Get.back();
      showRedAlert(e.toString());
    });
  }

  addLicense(License license) async {
    String certificateID = Uuid().v1();
    return await ref.collection('licenses').doc(certificateID).set({
      'licenseID': certificateID,
      'userID': license.userID,
      'vesselID': license.vesselID,
      'licenses': license.licenses,
      'documentNumber': license.documentNumber,
      'licenseType': license.licenseType,
      'countryCode': license.countryCode,
      'referenceNumber': license.referenceNumber,
      'fullName': license.fullName,
      'address': license.address,
      'citizenship': license.citizenship,
      'dob': license.dob,
      'issueDate': license.issueDate,
      'expiryDate': license.expiryDate,
    }).then((value) async {
      DocumentSnapshot doc = await getVesselForVesselID(license.vesselID!);
      Vessel vessel = Vessel.fromDocument(doc as DocumentSnapshot<Map<String, dynamic>>);
      vessel.captainLicensed = true;
      await editVessel(vessel);
      Get.back();
      Get.back();
      showGreenAlert('License added successfully');
    }).catchError((e) {
      Get.back();
      showRedAlert(e.toString());
    });
  }

  editLicense(License license) async {
    return await ref.collection('licenses').doc(license.licenseID).update({
      'licenses': license.licenses,
      'documentNumber': license.documentNumber,
      'licenseType': license.licenseType,
      'countryCode': license.countryCode,
      'referenceNumber': license.referenceNumber,
      'fullName': license.fullName,
      'address': license.address,
      'citizenship': license.citizenship,
      'dob': license.dob,
      'issueDate': license.issueDate,
      'expiryDate': license.expiryDate,
    }).then((value) async {
      Get.back();
      Get.back();
      showGreenAlert('License updated successfully');
    }).catchError((e) {
      Get.back();
      showRedAlert(e.toString());
    });
  }

  disableVessel(String vesselID, Timestamp timestamp) async {
    await ref.collection('vessels').doc(vesselID).update({'approved': false, 'disabledUntil': timestamp});
  }

  enableVessel(String vesselID) async {
    await ref.collection('vessels').doc(vesselID).update({'approved': true, 'disabledUntil': null});
  }

  generateCaseSearch(String query) {
    List keywords = query.split(" ").toList();
    List caseSearch = [];

    for (int i = 0; i < keywords.length; i++)
      for (int j = 0; j < keywords[i].length; j++) {
        caseSearch.add(keywords[i].substring(0, j + 1));
      }

    for (int i = keywords[0].length; i < query.length; i++) {
      caseSearch.add(query.substring(0, i + 1));
    }
    return caseSearch;
  }

  getSavedVessels() {
    return ref.collection('saved').where('userID', isEqualTo: userController.currentUser.value.userID).snapshots();
  }

  getVesselSavedStatus(String vesselID) {
    return ref.collection('saved').doc(userController.currentUser.value.userID! + '|' + vesselID).snapshots();
  }

  saveVessel(String vesselID) async {
    return await ref.collection('saved').doc(userController.currentUser.value.userID! + '|' + vesselID).set({
      'userID': userController.currentUser.value.userID,
      'vesselID': vesselID,
    });
  }

  unSaveVessel(String vesselID) async {
    return await ref.collection('saved').doc(userController.currentUser.value.userID! + '|' + vesselID).delete();
  }

  Future<QuerySnapshot> searchVessel(String searchQuery) async {
    return ref.collection('vessels').where('nameSearch', arrayContains: searchQuery).where('approved', isEqualTo: true).orderBy('rating', descending: true).get();
  }

  getVesselReviews(String vesselID, int limit) {
    return ref.collection("reviews").where('vesselID', isEqualTo: vesselID).orderBy('creationDate', descending: true).limit(limit);
  }

  addReview(Review review, Vessel vessel) async {
    num averageRating = ((vessel.rating! * vessel.ratingCount!) + review.rating!) / (vessel.ratingCount! + 1);
    return await ref.collection('reviews').doc(review.reviewID).set({
      'userID': review.userID,
      'reviewID': review.reviewID,
      'vesselID': review.vesselID,
      'flagged': false,
      'comment': review.comment,
      'rating': review.rating,
      'creationDate': Timestamp.now(),
    }).then((value) async {
      await ref.collection('vessels').doc(review.vesselID).update({
        'rating': averageRating,
        'ratingCount': FieldValue.increment(1),
      });
      showGreenAlert('Submitted review successfully');
    }).catchError((e) {
      showRedAlert('Something went wrong\n$e');
    });
  }

  getUpcomingBookings() {
    return ref.collection('bookings');
  }

  addCaptains(String email, String vesselID) async {
    User? user = await userService.getUserFromEmail(email);
    if (user == null) {
      Get.back();
      showRedAlert('User with this email does not exist');
    } else {
      if (!checkIfUserRoleExists(user, vesselID))
        await ref.collection('users').doc(user.userID).update({
          'captains': FieldValue.arrayUnion([vesselID]),
        }).then((value) async {
          final notificationService = Get.find<NotificationService>();
          notificationService.sendNotification(
            parameters: {
              'vesselID': vesselID,
            },
            body: 'You are now listed as a Captain for a Vessel',
            receiverUserID: user.userID,
            type: 'addCaptain',
          );
          Get.back();
          Get.back();
          showGreenAlert('Added successfully');
        });
    }
  }

  removeCaptain(String userID, String vesselID) async {
    await ref.collection('users').doc(userID).update({
      'captains': FieldValue.arrayRemove([vesselID]),
    }).then((value) {
      Get.back();
      Get.back();
      showGreenAlert('Removed successfully');
    });
  }

  addReceptionist(String email, String vesselID) async {
    User? user = await userService.getUserFromEmail(email);
    if (user == null) {
      Get.back();
      showRedAlert('User with this email does not exist');
    } else {
      await ref.collection('users').doc(user.userID).update({
        'receptionists': FieldValue.arrayUnion([vesselID]),
      }).then((value) {
        Get.back();
        Get.back();
        showGreenAlert('Added successfully');
      });
    }
  }

  removeReceptionist(String userID, String vesselID) async {
    await ref.collection('users').doc(userID).update({
      'receptionists': FieldValue.arrayRemove([vesselID]),
    }).then((value) {
      Get.back();
      Get.back();
      showGreenAlert('Removed successfully');
    });
  }

  addCrew(String email, String vesselID) async {
    User? user = await userService.getUserFromEmail(email);
    if (user == null) {
      Get.back();
      showRedAlert('User with this email does not exist');
    } else {
      if (!checkIfUserRoleExists(user, vesselID))
        await ref.collection('users').doc(user.userID).update({
          'crew': FieldValue.arrayUnion([vesselID]),
        }).then((value) async {
          final notificationService = Get.find<NotificationService>();
          notificationService.sendNotification(
            parameters: {
              'vesselID': vesselID,
            },
            body: 'You are now listed as a Crew member for a Vessel',
            receiverUserID: user.userID,
            type: 'addCrew',
          );
          Get.back();
          Get.back();
          showGreenAlert('Added successfully');
        });
    }
  }

  removeCrew(String userID, String vesselID) async {
    await ref.collection('users').doc(userID).update({
      'crew': FieldValue.arrayRemove([vesselID]),
    }).then((value) {
      Get.back();
      Get.back();
      showGreenAlert('Removed successfully');
    });
  }

  checkIfUserRoleExists(User user, String vesselID) {
    // if (user.owners.contains(vesselID)) {
    //   Get.back();
    //   Get.back();
    //   showRedAlert('${user.fullName} is already an owner of this vessel');
    //   return true;
    // }
    if (user.captains!.contains(vesselID)) {
      Get.back();
      Get.back();
      showRedAlert('${user.fullName} is already a captain of this vessel');
      return true;
    }
    if (user.crew!.contains(vesselID)) {
      Get.back();
      Get.back();
      showRedAlert('${user.fullName} is already a crew member of this vessel');
      return true;
    }
    return false;
  }

  getVesselCrew(String vesselID) {
    return ref.collection('users').where('crew', arrayContains: vesselID).snapshots();
  }

  getVesselCaptainsStream(String vesselID) {
    return ref.collection('users').where('captains', arrayContains: vesselID).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getVesselCaptains(String vesselID) {
    return ref.collection('users').where('captains', arrayContains: vesselID).get();
  }

  getVesselReceptionists(String vesselID) {
    return ref.collection('users').where('receptionists', arrayContains: vesselID).snapshots();
  }

  getVesselReceptionistForChat(String vesselID) {
    return ref.collection('users').where('owners', arrayContains: vesselID).get();
  }

  getVesselForumPosts(String vesselID, int limit) {
    return ref.collection("forum").where('vesselID', isEqualTo: vesselID).orderBy('creationDate', descending: true).limit(limit);
  }

  addPost(Forum forum) async {
    String postID = Uuid().v1();
    return await ref.collection('forum').doc(postID).set({
      'userID': userController.currentUser.value.userID,
      'postID': postID,
      'vesselID': forum.vesselID,
      'flagged': false,
      'comment': forum.comment,
      'images': forum.images,
      'creationDate': Timestamp.now(),
    }).then((value) async {
      Get.back();
      Get.back();
      showGreenAlert('Added successfully');
    });
  }

  updatePost(Forum forum) async {
    return await ref.collection('forum').doc(forum.postID).update({
      'comment': forum.comment,
      'images': forum.images,
      'creationDate': Timestamp.now(),
    }).then((value) async {
      Get.back();
      Get.back();
      showGreenAlert('Post edited successfully');
    });
  }

  getVesselCertificates(String vesselID, int limit) {
    return ref.collection("certificates").where('vesselID', isEqualTo: vesselID).orderBy('issueDate', descending: true).limit(limit);
  }

  getVesselLicenses(String vesselID, int limit) {
    return ref.collection("licenses").where('vesselID', isEqualTo: vesselID).orderBy('issueDate', descending: true).limit(limit);
  }

  checkIfVesselHasCertificates(String vesselID) async {
    return (await ref.collection("certificates").where('vesselID', isEqualTo: vesselID).get()).docs.isNotEmpty;
  }

  addTrip(PreMadeTrip preMadeTrip) async {
    String tripID = Uuid().v1();
    return await ref.collection('pre_made_trips').doc(tripID).set({
      'userID': userController.currentUser.value.userID,
      'tripID': tripID,
      'vesselID': preMadeTrip.vesselID,
      'type': preMadeTrip.type,
      'price': preMadeTrip.price,
      'duration': preMadeTrip.duration,
      'tripDate': preMadeTrip.tripDate,
    }).then((value) async {
      Get.back();
      showGreenAlert('Added successfully');
    });
  }

  removeTrip(String tripID) async {
    await ref.collection('pre_made_trips').doc(tripID).delete().then((value) async {
      Get.back();
      showGreenAlert('Removed successfully');
    });
  }

  viewTripsForVessel(String vesselID) {
    return ref.collection('pre_made_trips').where('vesselID', isEqualTo: vesselID);
  }

  Future<MakaiFee> getMakaiFees(num amount) async {
    String url = 'https://us-central1-makai-65aae.cloudfunctions.net/calculateMakaiFees?amount=$amount';
    var response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    print(response.body);
    return MakaiFee.fromJson(data);
  }

  Future<DocumentSnapshot> getConstants() async {
    return await ref.collection('constants').doc('policy').get();
  }
}
