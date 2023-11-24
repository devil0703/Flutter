import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/models/premade_trip_model.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class PreMadeTrips extends StatefulWidget {
  final String vesselID;

  PreMadeTrips({required this.vesselID});

  @override
  State<PreMadeTrips> createState() => _PreMadeTripsState();
}

class _PreMadeTripsState extends State<PreMadeTrips> {
  String dayOfTheWeek = 'Monday';

  String bookingType = 'Per Passenger';

  late Timestamp issueDate;

  final TextEditingController tripDateTEC = TextEditingController();

  final TextEditingController priceTEC = TextEditingController();

  final TextEditingController durationTEC = TextEditingController();

  final GlobalKey<FormState> step4Key = GlobalKey<FormState>();

  final vesselService = Get.find<VesselService>();

  final dialogService = Get.find<DialogService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PRE-MADE TRIPS')),
      body: Form(
        key: step4Key,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              //CustomTextField(dropdown: dropDown(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'], 1), label: 'Day of the week *'),
              CustomTextField(dropdown: dropDown(['Per Passenger', 'Whole Boat'], 2), label: 'Booking Type *'),
              CustomTextField(controller: priceTEC, hint: 'Enter Price', label: 'Price', textInputType: TextInputType.numberWithOptions(signed: false)),
              CustomTextField(controller: durationTEC, hint: 'Enter duration', label: 'Duration', textInputType: TextInputType.numberWithOptions(signed: false, decimal: false)),
              InkWell(onTap: () => showDatePicker(1, context), child: CustomTextField(controller: tripDateTEC, label: 'Date of Trip *', hint: 'Select date', validate: true, enabled: false)),
              SizedBox(height: 25),
              CustomButton(
                text: 'Add Trip',
                function: () async {
                  if (!step4Key.currentState!.validate()) {
                    showRedAlert('Please fill the necessary details');
                  } else {
                    final dialogService = Get.find<DialogService>();
                    dialogService.showLoading();
                    await vesselService.addTrip(
                      PreMadeTrip(
                        type: bookingType,
                        vesselID: widget.vesselID,
                        price: int.parse(priceTEC.text),
                        tripDate: issueDate,
                        duration: int.parse(durationTEC.text),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 25),
              Text('Pre-Made Trips', textScaleFactor: 1.2),
              showPage(),
            ],
          ),
        ),
      ),
    );
  }

  showPage() {
    return PaginateFirestore(
      isLive: true,
      padding: const EdgeInsets.only(top: 25),
      key: GlobalKey(),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshot, i) {
        PreMadeTrip booking = PreMadeTrip.fromDocument(documentSnapshot[i]);
        return Card(
          child: ListTile(
            title: Text(DateFormat('dd MMM yyyy - hh:mm aa ').format(booking.tripDate!.toDate()) + '(${durationTEC.text} hrs)'),
            subtitle: Text('\$' + booking.price.toString() + ' - ' + booking.type!),
            trailing: IconButton(
                onPressed: () {
                  dialogService.showConfirmationDialog(
                    title: 'Delete Trip?',
                    contentText: 'Are you sure you want to delete the trip?',
                    confirm: () async {
                      Get.back();
                      dialogService.showLoading();
                      await vesselService.removeTrip(booking.tripID!);
                    },
                  );
                },
                icon: Icon(Icons.delete_forever, color: redColor)),
          ),
        );
      },
      query: vesselService.viewTripsForVessel(widget.vesselID),
      onEmpty: Padding(
        padding: const EdgeInsets.all(8.0),
        child: EmptyBox(text: 'No pre made trips to show'),
      ),
      itemsPerPage: 10,
      bottomLoader: LoadingData(),
      initialLoader: LoadingData(),
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
      case 1:
        return dayOfTheWeek;
      case 2:
        return bookingType;
    }
  }

  setValue(int i, String value) {
    switch (i) {
      case 1:
        return dayOfTheWeek = value;
      case 2:
        return bookingType = value;
    }
  }

  showDatePicker(int type, context) {
    DatePicker.showDateTimePicker(context, showTitleActions: true, minTime: DateTime(2000), maxTime: DateTime(2100), onChanged: (date) {}, onConfirm: (date) {
      if (type == 1) {
        tripDateTEC.text = DateFormat('MMMM dd, yyyy - hh:mm a').format(date);
        issueDate = Timestamp.fromDate(date);
      }
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }
}
