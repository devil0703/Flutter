// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/models/makai_fee_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/vessels/select_features.dart';
import 'package:makaiapp/screens/vessels/select_fishing_features.dart';
import 'package:makaiapp/screens/vessels/select_journey_timings.dart';
import 'package:makaiapp/screens/vessels/select_things_allowed.dart';
import 'package:makaiapp/screens/vessels/vessel_constants.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/cached_image.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_list_tile.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:place_picker/place_picker.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:uuid/uuid.dart';

class AddVessel extends StatefulWidget {
  @override
  _AddVesselState createState() => _AddVesselState();
}

class _AddVesselState extends State<AddVessel> {
  final TextEditingController vesselLengthTEC = TextEditingController();
  final TextEditingController vesselNameTEC = TextEditingController();
  final TextEditingController vesselDescriptionTEC = TextEditingController();
  final TextEditingController costPerHourTEC = TextEditingController();
  final TextEditingController passengerCapacityTEC = TextEditingController();
  final TextEditingController thingsAllowedTEC = TextEditingController();
  final TextEditingController cabinsTEC = TextEditingController();
  final TextEditingController bathroomsTEC = TextEditingController();
  final TextEditingController speedTEC = TextEditingController();
  final TextEditingController crewSizeTEC = TextEditingController();
  final TextEditingController featuresTEC = TextEditingController();
  final TextEditingController speciesTEC = TextEditingController();
  final TextEditingController techniquesTEC = TextEditingController();
  final TextEditingController feeTEC = TextEditingController();
  final Rx<TextEditingController> locationTEC = TextEditingController().obs;
  final GlobalKey<FormState> step1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> step2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> step3Key = GlobalKey<FormState>();
  final GlobalKey<FormState> step4Key = GlobalKey<FormState>();

  final vesselService = Get.find<VesselService>();
  final userController = Get.find<UserController>();
  final dialogService = Get.find<DialogService>();
  final storageService = Get.find<StorageService>();
  RxList images = [].obs;
  RxList durations = [].obs;
  RxList prices = [].obs;

  late Timestamp issueDate, buildDate, expiryDate;
  late LatLng latLng;
  Rx<String> vesselType = 'Fishing'.obs;
  Rx<String> bookingTime = 'Hourly'.obs;
  Rx<String> yachtBuilder = 'Any'.obs;
  String yachtType = 'Motor';
  String fishingVesselType = 'Air';
  String fishingType = 'Backcountry';
  RxList features = [].obs;
  RxList species = [].obs;
  RxList techniques = [].obs;
  RxList thingsAllowed = [].obs;
  int currentStep = 1;
  Rx<String> cancellationPolicy = 'Flexible'.obs;
  Rx<String> duration = '1'.obs;
  String makaiFee = '0.00';
  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  void initState() {
    costPerHourTEC.addListener(() {
      getMakaiFees();
    });

    super.initState();
  }

  getMakaiFees() async {
    MakaiFee makaiFees = await vesselService.getMakaiFees(num.parse(costPerHourTEC.text));
    makaiFee = makaiFees.fee.total;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.defaultDialog(
          title: 'You will lose progress',
          content: Text('Did you want to go back?'),
          confirm: CustomButton(
            text: 'No',
            color: Colors.grey,
            function: () => Get.back(),
          ),
          cancel: CustomButton(
            text: 'Yes',
            function: () {
              Get.back();
              Get.back();
            },
          ),
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text('ADD YOUR VESSEL')),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressIndicator(
                totalSteps: 4,
                currentStep: currentStep,
                size: 40,
                selectedColor: Colors.black,
                unselectedColor: Colors.grey[400]!,
                customStep: (index, color, _) {
                  if (currentStep > index + 1)
                    return InkWell(
                      onTap: () => setState(() => currentStep = index + 1),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.green.shade700,
                        ),
                        child: Text('${index + 1}', style: TextStyle(color: Colors.white), textScaleFactor: 1.25),
                      ),
                    );
                  if (currentStep - 1 == index) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 2,
                            color: Colors.green.shade700,
                          )),
                      child: Text('${index + 1}', style: TextStyle(color: Colors.green.shade700), textScaleFactor: 1.25),
                    );
                  } else
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 2,
                            color: Colors.grey.shade400,
                          )),
                      child: Text('${index + 1}', style: TextStyle(color: Colors.grey), textScaleFactor: 1.25),
                    );
                },
              ),
              SizedBox(height: 40),
              if (currentStep == 1) step1(),
              if (currentStep == 2) step2(),
              if (currentStep == 3) step3(),
              if (currentStep == 4) step4(),
              CustomButton(
                text: currentStep == 4 ? 'Add Vessel' : 'Proceed',
                function: () async {
                  switch (currentStep) {
                    case 1:
                      if (!step1Key.currentState!.validate()) {
                        showRedAlert('Please fill the necessary details');
                      } else if (images.isEmpty) {
                        showRedAlert('Please add at least one vessel image');
                        return;
                      } else {
                        setState(() => currentStep++);
                      }
                      return;
                    case 2:
                      if (!step2Key.currentState!.validate()) {
                        showRedAlert('Please fill the necessary details');
                        return;
                      }
                      if (durations.isEmpty) {
                        showRedAlert('Please add the journey durations');
                        return;
                      } else {
                        setState(() => currentStep++);
                      }
                      return;
                    case 3:
                      if (!step3Key.currentState!.validate()) {
                        showRedAlert('Please fill the necessary details');
                      } else {
                        setState(() => currentStep++);
                      }
                      return;
                    case 4:
                      await update();
                      return;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  dropDown(List items, int i) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 2, color: Colors.teal.shade400),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      isExpanded: true,
      style: TextStyle(color: primaryColor, fontSize: 17),
      value: getValue(i),
      items: items.map((value) {
        return DropdownMenuItem<String>(value: value, child: Text(value, textScaleFactor: 1, style: TextStyle(color: Colors.black)));
      }).toList(),
      onChanged: (value) => setValue(i, value!),
    );
  }

  getValue(int i) {
    switch (i) {
      case 0:
        return vesselType.value;
      case 1:
        return yachtType;
      case 2:
        return bookingTime.value;
      case 3:
        return yachtBuilder.value;
      case 5:
        return fishingVesselType;
      case 6:
        return fishingType;
      case 7:
        return cancellationPolicy.value;
      case 8:
        return duration.value;
    }
  }

  setValue(int i, String value) {
    switch (i) {
      case 0:
        return vesselType.value = value;
      case 1:
        return yachtType = value;
      case 2:
        return bookingTime.value = value;
      case 3:
        return yachtBuilder.value = value;
      case 5:
        return fishingVesselType = value;
      case 6:
        return fishingType = value;
      case 7:
        return cancellationPolicy.value = value;
      case 8:
        return duration.value = value;
    }
  }

  addImageButton() {
    return InkWell(
      onTap: () async {
        File file = await storageService.pickImage();
        images.add(file);
      },
      child: Container(
        height: 80,
        width: 80,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
        child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 25),
      ),
    );
  }

  update() async {
    dialogService.showLoading();
    List imageURLs = [];
    for (int i = 0; i < images.length; i++) {
      imageURLs.add(await storageService.uploadPhoto(images[i], 'vessels'));
    }
    await vesselService.addVessel(
      Vessel(
        approved: false,
        images: imageURLs,
        vesselType: vesselType.value,
        yachtType: yachtType,
        fishingVesselType: fishingVesselType,
        fishingType: fishingType,
        vesselName: vesselNameTEC.text,
        description: vesselDescriptionTEC.text,
        prices: prices.value,
        geoPoint: GeoPoint(latLng.latitude, latLng.longitude),
        address: locationTEC.value.text,
        shortAddress: shortAddress,
        durations: durations.value,
        thingsAllowed: thingsAllowed.value,
        length: num.parse(vesselLengthTEC.text),
        passengerCapacity: num.parse(passengerCapacityTEC.text),
        cabins: num.parse(cabinsTEC.text),
        bathrooms: num.parse(bathroomsTEC.text),
        crewSize: num.parse(crewSizeTEC.text),
        speed: num.parse(speedTEC.text),
        builder: yachtBuilder.value,
        features: features.value,
        fishingSpecies: species.value,
        fishingTechniques: techniques.value,
        cancellationPolicy: cancellationPolicy.value,
        rating: 0,
        ratingCount: 0,
        userID: userController.currentUser.value.userID,
        vesselID: Uuid().v1(),
        disabledByAdmin: false,
      ),
    );
  }

  void showPlacePicker() async {
    LocationResult result = await Get.to(() => PlacePicker(GOOGLE_MAP_KEY, displayLocation: LatLng(myLatitude, myLongitude)));
    locationTEC.value.text = result.formattedAddress!;
    shortAddress = result.city!.name! + ', ' + result.country!.name!;
    latLng = result.latLng!;
  }

  String shortAddress = '';

  step1() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: step1Key,
          child: Column(
            children: [
              Text('Vessel Details', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 25),
                height: 80,
                child: Row(
                  children: [
                    addImageButton(),
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () => images.remove(images[i]),
                                child: Stack(
                                  children: [
                                    CachedImage(height: 80, roundedCorners: true, imageFile: images[i]),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 55),
                                      child: Icon(Icons.circle, color: Colors.white, size: 25),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 55),
                                      child: Icon(Icons.remove_circle, color: redColor, size: 25),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomTextField(dropdown: dropDown(vesselTypes, 0), label: 'Vessel Category *'),
              Obx(
                () {
                  if (vesselType.value != 'Fishing')
                    return CustomTextField(dropdown: dropDown(yachtTypes, 1), label: 'Vessel Type *');
                  else
                    return Column(
                      children: [
                        CustomTextField(dropdown: dropDown(fishingVesselTypes, 5), label: 'Vessel Type *'),
                        CustomTextField(dropdown: dropDown(fishingTypes, 6), label: 'Fishing Type *'),
                        InkWell(
                            onTap: () async {
                              species.value = await Get.to(() => SelectFishingFeatures(features: species.value, featureType: 'species'));
                              speciesTEC.text = species.length.toString() + ' species selected';
                              setState(() {});
                            },
                            child: CustomTextField(enabled: false, controller: speciesTEC, label: 'Fishing Species *', hint: 'Select Species')),
                        InkWell(
                            onTap: () async {
                              techniques.value = await Get.to(() => SelectFishingFeatures(features: techniques.value, featureType: 'techniques'));
                              techniquesTEC.text = techniques.length.toString() + ' techniques selected';
                              setState(() {});
                            },
                            child: CustomTextField(enabled: false, controller: techniquesTEC, label: 'Fishing Techniques *', hint: 'Select Techniques')),
                      ],
                    );
                },
              ),
              CustomTextField(controller: vesselNameTEC, label: 'Vessel Name *', hint: 'Enter vessel name', validate: true),
              CustomTextField(controller: vesselDescriptionTEC, maxLength: 1000, label: 'Vessel Description *', hint: 'Enter vessel description', validate: true, maxLines: 4),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  step2() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: step2Key,
          child: Column(
            children: [
              Text('Journey Details', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              Obx(
                () => InkWell(
                  onTap: () => showPlacePicker(),
                  child: CustomTextField(controller: locationTEC.value, label: 'Vessel Location *', hint: 'Select vessel location', validate: true, enabled: false),
                ),
              ),
              InkWell(
                  onTap: () async {
                    thingsAllowed.value = await Get.to(() => SelectThingsAllowed(thingsAllowed: thingsAllowed.value));
                    thingsAllowedTEC.text = thingsAllowed.length.toString() + ' items selected';
                    setState(() {});
                  },
                  child: CustomTextField(enabled: false, controller: thingsAllowedTEC, label: 'Things Allowed Onboard *', hint: 'Select items')),
              InkWell(
                onTap: () => Get.to(() => SelectJourneyTiming()),
                child: CustomTextField(enabled: false, controller: TextEditingController(text: 'Tap to modify timings'), label: 'Journey Timings (Pre-Selected) *', hint: 'Select timings'),
              ),
              Divider(height: 50),
              Text('Journey Durations', textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: CustomTextField(dropdown: dropDown(vesselDurations, 8), label: 'Hours *')),
                  SizedBox(width: 5),
                  Expanded(child: CustomTextField(controller: costPerHourTEC, prefix: Text('\$ ', style: TextStyle(color: Colors.black)), label: 'Cost *', hint: 'Cost', textInputType: TextInputType.numberWithOptions(signed: false, decimal: true))),
                  SizedBox(width: 5),
                  Expanded(
                    child: FutureBuilder(
                      future: vesselService.getMakaiFees(costPerHourTEC.text.isEmpty ? 0 : num.parse(costPerHourTEC.text)),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          MakaiFee makaiFees = snapshot.data as MakaiFee;
                          // ignore: unnecessary_null_comparison
                          if (makaiFees.fee == null)
                            makaiFee = '0.00';
                          else
                            makaiFee = makaiFees.fee.total;
                        }
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 15),
                              child: Text('Makai Fee', style: TextStyle(color: primaryColor)),
                            ),
                            TextField(
                              controller: TextEditingController(text: makaiFee),
                              decoration: InputDecoration(
                                hintText: 'Fees',
                                prefix: Text('\$ ', style: TextStyle(color: Colors.black)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                                fillColor: Colors.grey.shade300,
                                enabled: false,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  durations.add(num.parse(duration.value));
                  prices.add(num.parse(costPerHourTEC.text));
                },
                child: Text('+Add'),
              ),
              Obx(() {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemBuilder: (context, i) {
                    if (i == 0)
                      return Column(
                        children: [
                          Text('Added Durations', textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          CustomListTile(
                            marginBottom: 15,
                            leading: Icon(Icons.timer_outlined),
                            title: Text(durations[i].toString() + ' hours', style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text(formatCurrency.format(prices[i]).toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );

                    return CustomListTile(
                      marginBottom: 15,
                      leading: Icon(Icons.timer_outlined),
                      title: Text(durations[i].toString() + ' hours', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(formatCurrency.format(prices[i]).toString(), style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    );
                  },
                  itemCount: durations.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  step3() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: step3Key,
          child: Column(
            children: [
              Text('Features', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              CustomTextField(controller: vesselLengthTEC, label: 'Vessel Length (in feet)*', hint: 'Enter vessel length', validate: true, textInputType: TextInputType.numberWithOptions(signed: false, decimal: true)),
              CustomTextField(controller: passengerCapacityTEC, label: 'Guests Capacity (excluding Crew) *', hint: 'Enter guests capacity', validate: true, textInputType: TextInputType.numberWithOptions(signed: false, decimal: false)),
              CustomTextField(controller: cabinsTEC, label: 'Vessel Cabins *', hint: 'Enter vessel cabins', validate: true, textInputType: TextInputType.numberWithOptions(signed: false, decimal: false)),
              CustomTextField(controller: bathroomsTEC, label: 'Number of Bathrooms *', hint: 'Enter bathrooms count', validate: true, textInputType: TextInputType.numberWithOptions(signed: false, decimal: false)),
              CustomTextField(controller: crewSizeTEC, label: 'Crew Size *', hint: 'Enter crew size', validate: true, textInputType: TextInputType.numberWithOptions(signed: false, decimal: false)),
              CustomTextField(controller: speedTEC, label: 'Vessel top speed (in knots)*', hint: 'Enter vessel speed', validate: true, textInputType: TextInputType.numberWithOptions(signed: false, decimal: false)),
              CustomTextField(dropdown: dropDown(yachtBuilders, 3), label: 'Yacht Builder *'),
              InkWell(
                  onTap: () async {
                    features.value = await Get.to(() => SelectFeatures(features: features.value, vesselType: vesselType.value));
                    featuresTEC.text = features.length.toString() + ' features selected';
                    setState(() {});
                  },
                  child: CustomTextField(enabled: false, controller: featuresTEC, label: 'Yacht Features *', hint: 'Select Features')),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  step4() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: step3Key,
          child: Column(
            children: [
              Text('Cancellation Policy', textScaleFactor: 1.5, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              CustomTextField(dropdown: dropDown(cancellationPolicies, 7), label: 'Select Policy *'),
              Obx(
                () => Container(
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cancellationPolicy.value, textScaleFactor: 1.25, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text(getCancellationPolicyText()),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  getCancellationPolicyText() {
    if (cancellationPolicy.value == 'Flexible') return 'Free cancellations until 24 hrs before the start date.\n\nCancellations within 24 hours of booking are non-refundable.';
    if (cancellationPolicy.value == 'Moderate') return 'Free cancellations until 7 days before the start date.\n\n50% refund on cancellations between 2 and 7 days before booking start date.\n\nCancellations within 2 days of booking are non-refundable.';
    if (cancellationPolicy.value == 'Strict') return 'Free cancellations until 30 days before the start date.\n\n50% refund on cancellations between 14 and 30 days before booking start date.\n\nCancellations within 14 days of booking are non-refundable.';
    return '';
  }
}
