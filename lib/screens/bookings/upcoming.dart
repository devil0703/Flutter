import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makaiapp/models/booking_model.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/widgets/vessel_booking_item.dart';
import 'package:table_calendar/table_calendar.dart';

class Upcoming extends StatefulWidget {
  @override
  State<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  final vesselService = Get.find<VesselService>();
  final bookingService = Get.find<BookingService>();
  Timestamp startDate = Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, 1));
  Timestamp endDate = Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  Timestamp focusDate = Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, 1));
  List<Booking> allBookings = [];
  List<Booking> selectedDateBookings = [];
  List<String> bookingDates = [];
  Timestamp selectedDate = Timestamp.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UPCOMING BOOKINGS')),
      body: FutureBuilder(
        future: bookingService.getBookingsBetween(startDate, endDate),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            allBookings.clear();
            bookingDates.clear();
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              allBookings.add(Booking.fromDocument(snapshot.data!.docs[i]));
              String travelDate = DateFormat('dd MMM yyyy').format(Booking.fromDocument(snapshot.data!.docs[i]).travelDate!.toDate());
              bookingDates.add(travelDate);
            }
            print(allBookings.length.toString());
          }
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: TableCalendar(
                  availableGestures: AvailableGestures.none,
                  firstDay: DateTime.utc(2021, 1, 1),
                  lastDay: DateTime.utc(2030, 1, 1),
                  focusedDay: focusDate.toDate(),
                  selectedDayPredicate: (date) => selectedDate == Timestamp.fromDate(date),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(shape: BoxShape.circle, color: secondaryColor),
                    todayDecoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor)),
                    todayTextStyle: TextStyle(color: primaryColor),

                    // isTodayHighlighted: false,
                  ),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  daysOfWeekHeight: 40,
                  daysOfWeekStyle: DaysOfWeekStyle(weekdayStyle: TextStyle(color: primaryColor), weekendStyle: TextStyle(color: redColor)),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    selectedDateBookings.clear();
                    for (int i = 0; i < allBookings.length; i++) {
                      print('&&&&&&&&&&&&&&&&');
                      print(DateFormat().format(allBookings[i].travelDate!.toDate()));
                      print(DateFormat().format(selectedDay));
                      if (DateFormat('dd MMM yyyy').format(allBookings[i].travelDate!.toDate()) == DateFormat('dd MMM yyyy').format(selectedDay)) selectedDateBookings.add(allBookings[i]);
                    }
                    setState(() {
                      selectedDate = Timestamp.fromDate(selectedDay.toUtc());
                      focusDate = selectedDate;
                    });
                    print('*********************************');
                    print(DateFormat().format(selectedDate.toDate()));
                    print(DateFormat().format(selectedDay.toUtc()));
                  },
                  onFormatChanged: (cal) {},
                  eventLoader: (day) {
                    // print(DateFormat().format(day));
                    // print(allBookings.length.toString());
                    if (bookingDates.contains(DateFormat('dd MMM yyyy').format(day)))
                      return [
                        DateFormat('dd MMM yyyy').format(day),
                      ];
                    return [];
                  },
                  onPageChanged: (date) {
                    startDate = Timestamp.fromDate(date);
                    endDate = Timestamp.fromDate(DateTime(date.year, date.month + 1, 1));
                    focusDate = startDate;
                    print(DateFormat('dd MMM yyyy').format(endDate.toDate()));
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, i) {
                    return VesselBookingItem();
                  },
                  itemCount: selectedDateBookings.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
