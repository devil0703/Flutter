import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/models/premade_trip_model.dart';
import 'package:makaiapp/models/vessel_model.dart';
import 'package:makaiapp/screens/bookings/checkout.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/custom_text_field.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:makaiapp/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class BookNow extends StatefulWidget {
  final Vessel vessel;

  BookNow({required this.vessel});

  @override
  State<BookNow> createState() => _BookNowState();
}

class _BookNowState extends State<BookNow> {
  final GlobalKey<FormState> step1Key = GlobalKey<FormState>();
  late DateTime bookingDate;
  final TextEditingController dateTEC = TextEditingController();
  final TextEditingController timeTEC = TextEditingController();
  final vesselService = Get.find<VesselService>();
  late String slot;
  int seatsAvailable = 0;
  Rx<String> duration = '1'.obs;
  Rx<String> seats = '1'.obs;
  Rx<String> noOfSeats = '1'.obs;
  List seatsList = ['1'];

  @override
  void initState() {
    duration.value = widget.vessel.durations![0].toString();
    seatsList.clear();
    for (int i = 0; i < widget.vessel.passengerCapacity!; i++) seatsList.add('${i + 1}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ENTER DETAILS')),
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
                    Tab(text: 'Custom Trip'),
                    Tab(text: 'Pre-made Trips'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    customTrip(),
                    preMadeTrip(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  customTrip() {
    return Form(
      key: step1Key,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            CustomTextField(dropdown: dropDown(seatsList, 9), label: 'Number of seats *'),
            InkWell(
              onTap: () {
                DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime.now().add(Duration(days: 1)), maxTime: DateTime(2100), onChanged: (date) {}, onConfirm: (date) {
                  dateTEC.text = DateFormat('MMMM dd, yyyy').format(date);
                  bookingDate = date;
                  setState(() {});
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: CustomTextField(controller: dateTEC, label: 'Select Date *', hint: 'Select date', validate: true, enabled: false),
            ),
            if (dateTEC.text.isNotEmpty)
              CustomTextField(
                controller: timeTEC,
                label: 'Select time *',
                hint: '',
                dropdown: dropdown('Select time'),
                validate: true,
                enabled: false,
              ),
            CustomTextField(dropdown: dropDown(widget.vessel.durations!, 8), label: 'Hours *'),
            SizedBox(height: 15),
            if (seatsAvailable == -1) LoadingData(),
            if (seatsAvailable > 0) Text('Seats available: $seatsAvailable', style: TextStyle(color: Colors.green)),
            SizedBox(height: 15),
            ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(seatsAvailable > 0 ? primaryColor : Colors.grey)),
                onPressed: () async {
                  if (seatsAvailable > 0) {
                    if (!step1Key.currentState!.validate()) {
                      showRedAlert('Please fill the necessary details');
                    } else {
                      Get.off(() => Checkout(
                            price: getFeesForDuration(num.parse(duration.value)),
                            duration: num.parse(duration.value),
                            vessel: widget.vessel,
                            guestCount: int.parse(seats.value),
                            date: bookingDate,
                            isPreMadeTrip: false,
                          ));
                    }
                  }
                },
                child: Text('PROCEED')),
          ],
        ),
      ),
    );
  }

  preMadeTrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(dropdown: dropDown(seatsList, 10), label: 'Select Number of seats *'),
        SizedBox(height: 35),
        Text('Select one of the following Pre Made Trips to proceed'),
        Expanded(
          child: PaginateFirestore(
            isLive: true,
            padding: const EdgeInsets.only(top: 15),
            key: GlobalKey(),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (context, documentSnapshot, i) {
              PreMadeTrip preMadeTrip = PreMadeTrip.fromDocument(documentSnapshot[i]);
              return Card(
                margin: EdgeInsets.only(bottom: 15),
                child: ListTile(
                  onTap: () => Get.off(() => Checkout(
                        price: preMadeTrip.type == 'Per Passenger' ? int.parse(noOfSeats.value) * preMadeTrip.price! : preMadeTrip.price!,
                        duration: preMadeTrip.duration!,
                        vessel: widget.vessel,
                        guestCount: int.parse(noOfSeats.value),
                        date: preMadeTrip.tripDate!.toDate(),
                        isPreMadeTrip: true,
                      )),
                  title: Text(DateFormat('dd MMM yyyy - hh:mm aa ').format(preMadeTrip.tripDate!.toDate()) + '(${preMadeTrip.duration} hrs)'),
                  subtitle: Text('\$' + preMadeTrip.price.toString() + ' - ' + preMadeTrip.type!),
                  trailing: Text('BOOK', textScaleFactor: 0.95, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              );
            },
            query: vesselService.viewTripsForVessel(widget.vessel.vesselID!),
            onEmpty: Padding(
              padding: const EdgeInsets.all(8.0),
              child: EmptyBox(text: 'No pre made trips to show'),
            ),
            itemsPerPage: 10,
            bottomLoader: LoadingData(),
            initialLoader: LoadingData(),
          ),
        ),
      ],
    );
  }

  dropdown(String hint) {
    List items = [];
    DateTime dateTime = bookingDate;
    switch (dateTime.weekday) {
      case 1:
        items = widget.vessel.monday!;
        break;
      case 2:
        items = widget.vessel.tuesday!;
        break;
      case 3:
        items = widget.vessel.wednesday!;
        break;
      case 4:
        items = widget.vessel.thursday!;
        break;
      case 5:
        items = widget.vessel.friday!;
        break;
      case 6:
        items = widget.vessel.saturday!;
        break;
      case 7:
        items = widget.vessel.sunday!;
        break;
    }

    List<String> newItems = List<String>.from(items);
    timeTEC.text = newItems[0];
    return DropdownSearch<String>(
      dropdownDecoratorProps: DropDownDecoratorProps(dropdownSearchDecoration: InputDecoration(hintText: hint)),
      dropdownButtonProps: DropdownButtonProps(),
      items: newItems,
      selectedItem: slot,
      onChanged: (value) async {
        setState(() {
          seatsAvailable = -1;
        });
        final bookingService = Get.find<BookingService>();
        print(slot);
        timeTEC.text = value!;
        bookingDate = DateTime(bookingDate.year, bookingDate.month, bookingDate.day, int.parse(timeTEC.text.substring(0, 2)), int.parse(timeTEC.text.substring(3, 5)));
        //dateTime = dateTime.toUtc().add(Duration(hours: 5, minutes: 30));
        print(DateFormat('dd MM yyyy hh:mm').format(bookingDate));
        seatsAvailable = await bookingService.checkSeatAvailability(widget.vessel.vesselID!, (bookingDate.toUtc().millisecondsSinceEpoch ~/ 1000).toInt().toString());
        setState(() {
          slot = value;
        });
      },
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
      value: i == 9
          ? seats.value
          : i == 10
              ? noOfSeats.value
              : duration.value,
      items: items.map((value) {
        return DropdownMenuItem<String>(value: value.toString(), child: Text(value.toString(), textScaleFactor: 1, style: TextStyle(color: Colors.black)));
      }).toList(),
      onChanged: (value) => i == 9
          ? seats.value = value!
          : i == 10
              ? noOfSeats.value = value!
              : duration.value = value!,
    );
  }

  getFeesForDuration(num duration) {
    for (int i = 0; i < widget.vessel.durations!.length; i++) if (widget.vessel.durations![i] == duration) return widget.vessel.prices![i];
  }
}
