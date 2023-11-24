import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/widgets/custom_button.dart';

class SelectJourneyTiming extends StatefulWidget {
  static List selectedMondayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
  static List selectedTuesdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
  static List selectedWednesdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
  static List selectedThursdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
  static List selectedFridayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
  static List selectedSaturdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
  static List selectedSundayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];

  static resetTimings() {
    selectedMondayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
    selectedTuesdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
    selectedWednesdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
    selectedThursdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
    selectedFridayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
    selectedSaturdayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
    selectedSundayTimings = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00"];
  }

  @override
  _SelectJourneyTimingState createState() => _SelectJourneyTimingState();
}

class _SelectJourneyTimingState extends State<SelectJourneyTiming> {
  List<String> mondayTimings = ["05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];
  List<String> tuesdayTimings = ["05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];
  List<String> wednesdayTimings = ["05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];
  List<String> thursdayTimings = ["05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];
  List<String> fridayTimings = ["05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];
  List<String> saturdayTimings = ["05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];
  List<String> sundayTimings = ["05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00"];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Select journey timings')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: ListView(
          children: [
            selectMondayTimings(),
            selectTuesdayTimings(),
            selectWednesdayTimings(),
            selectThursdayTimings(),
            selectFridayTimings(),
            selectSaturdayTimings(),
            selectSundayTimings(),
            SizedBox(height: 20),
            CustomButton(
              text: 'Save and go back',
              function: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  selectMondayTimings() {
    return ExpansionTile(
      title: Text('Monday'),
      children: [
        GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
          children: <Widget>[
            ...mondayTimings
                .map(
                  (item) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(item),
                    value: SelectJourneyTiming.selectedMondayTimings.contains(item),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SelectJourneyTiming.selectedMondayTimings.add(item);
                        });
                      } else {
                        setState(() {
                          SelectJourneyTiming.selectedMondayTimings.remove(item);
                        });
                      }
                    },
                  ),
                )
                .toList()
          ],
        ),
      ],
    );
  }

  selectTuesdayTimings() {
    return ExpansionTile(
      title: Text('Tuesday'),
      children: [
        GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
          children: <Widget>[
            ...tuesdayTimings
                .map(
                  (item) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(item),
                    value: SelectJourneyTiming.selectedTuesdayTimings.contains(item),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SelectJourneyTiming.selectedTuesdayTimings.add(item);
                        });
                      } else {
                        setState(() {
                          SelectJourneyTiming.selectedTuesdayTimings.remove(item);
                        });
                      }
                    },
                  ),
                )
                .toList()
          ],
        ),
      ],
    );
  }

  selectWednesdayTimings() {
    return ExpansionTile(
      title: Text('Wednesday'),
      children: [
        GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
          children: <Widget>[
            ...wednesdayTimings
                .map(
                  (item) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(item),
                    value: SelectJourneyTiming.selectedWednesdayTimings.contains(item),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SelectJourneyTiming.selectedWednesdayTimings.add(item);
                        });
                      } else {
                        setState(() {
                          SelectJourneyTiming.selectedWednesdayTimings.remove(item);
                        });
                      }
                    },
                  ),
                )
                .toList()
          ],
        ),
      ],
    );
  }

  selectThursdayTimings() {
    return ExpansionTile(
      title: Text('Thursday'),
      children: [
        GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
          children: <Widget>[
            ...thursdayTimings
                .map(
                  (item) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(item),
                    value: SelectJourneyTiming.selectedThursdayTimings.contains(item),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SelectJourneyTiming.selectedThursdayTimings.add(item);
                        });
                      } else {
                        setState(() {
                          SelectJourneyTiming.selectedThursdayTimings.remove(item);
                        });
                      }
                    },
                  ),
                )
                .toList()
          ],
        ),
      ],
    );
  }

  selectFridayTimings() {
    return ExpansionTile(
      title: Text('Friday'),
      children: [
        GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
          children: <Widget>[
            ...fridayTimings
                .map(
                  (item) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(item),
                    value: SelectJourneyTiming.selectedFridayTimings.contains(item),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SelectJourneyTiming.selectedFridayTimings.add(item);
                        });
                      } else {
                        setState(() {
                          SelectJourneyTiming.selectedFridayTimings.remove(item);
                        });
                      }
                    },
                  ),
                )
                .toList()
          ],
        ),
      ],
    );
  }

  selectSaturdayTimings() {
    return ExpansionTile(
      title: Text('Saturday'),
      children: [
        GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
          children: <Widget>[
            ...saturdayTimings
                .map(
                  (item) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(item),
                    value: SelectJourneyTiming.selectedSaturdayTimings.contains(item),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SelectJourneyTiming.selectedSaturdayTimings.add(item);
                        });
                      } else {
                        setState(() {
                          SelectJourneyTiming.selectedSaturdayTimings.remove(item);
                        });
                      }
                    },
                  ),
                )
                .toList()
          ],
        ),
      ],
    );
  }

  selectSundayTimings() {
    return ExpansionTile(
      title: Text('Sunday'),
      children: [
        GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
          children: <Widget>[
            ...sundayTimings
                .map(
                  (item) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(item),
                    value: SelectJourneyTiming.selectedSundayTimings.contains(item),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          SelectJourneyTiming.selectedSundayTimings.add(item);
                        });
                      } else {
                        setState(() {
                          SelectJourneyTiming.selectedSundayTimings.remove(item);
                        });
                      }
                    },
                  ),
                )
                .toList()
          ],
        ),
      ],
    );
  }
}
