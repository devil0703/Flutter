import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/widgets/custom_button.dart';

class SelectFeatures extends StatefulWidget {
  final List features;
  final String vesselType;

  SelectFeatures({required this.features, required this.vesselType});

  @override
  SelectFeaturesState createState() => new SelectFeaturesState();
}

class SelectFeaturesState extends State<SelectFeatures> {
  List selectedFeatures = [];
  Map<String, bool> yachtAmenities = {
    'Air Conditioning': false,
    'At Anchor Stabilizer': false,
    'BBQ': false,
    'Beach Club': false,
    'Beauty Room': false,
    'Conference': false,
    'Disabled Accessible': false,
    'Diving Equipment': false,
    'Elevator': false,
    'Fans': false,
    'Fishing Equipment': false,
    'Floats': false,
    'Full Kitchen': false,
    'Gym': false,
    'Handicap Accessible': false,
    'Inflatable Island': false,
    'Jacuzzi': false,
    'Jet Ski': false,
    'Jetpack': false,
    'Kayak': false,
    'Linens': false,
    'Movie Theatre': false,
    'Paddle Board': false,
    'Scooter': false,
    'Snorkel Gear': false,
    'Sound System': false,
    'Spa': false,
    'Stabilizers': false,
    'Steam Room': false,
    'Suana': false,
    'Swimming Pool': false,
    'Tender': false,
    'Underwater Camera': false,
    'Visually impaired accessible': false,
    'Wakeboard': false,
    'Water Ski': false,
  };
  Map<String, bool> fishingAmenities = {
    'Air Conditioning': false,
    'Child Friendly': false,
    'Clean and Filleting': false,
    'Disabled Accessible': false,
    'Fighting Chair': false,
    'First Mate': false,
    'Fishing License': false,
    'Food Provided': false,
    'Handicap Accessible': false,
    'Icebox': false,
    'Keep Your Catch': false,
    'Live Bait': false,
    'Pickup Included': false,
    'Rods and Reels Included': false,
    'Tackle Included': false,
    'Toilet': false,
    'Visually impaired accessible': false,
    'Water Provided': false,
  };

  @override
  void initState() {
    if (widget.vesselType != 'Fishing') {
      yachtAmenities['Air Conditioning'] = widget.features.contains('Air Conditioning');
      yachtAmenities['At Anchor Stabilizer'] = widget.features.contains('At Anchor Stabilizer');
      yachtAmenities['BBQ'] = widget.features.contains('BBQ');
      yachtAmenities['Beach Club'] = widget.features.contains('Beach Club');
      yachtAmenities['Beauty Room'] = widget.features.contains('Beauty Room');
      yachtAmenities['Conference'] = widget.features.contains('Conference');
      yachtAmenities['Disabled Accessible'] = widget.features.contains('Disabled Accessible');
      yachtAmenities['Diving Equipment'] = widget.features.contains('Diving Equipment');
      yachtAmenities['Elevator'] = widget.features.contains('Elevator');
      yachtAmenities['Fans'] = widget.features.contains('Fans');
      yachtAmenities['Fishing Equipment'] = widget.features.contains('Fishing Equipment');
      yachtAmenities['Floats'] = widget.features.contains('Floats');
      yachtAmenities['Full Kitchen'] = widget.features.contains('Full Kitchen');
      yachtAmenities['Gym'] = widget.features.contains('Gym');
      yachtAmenities['Handicap Accessible'] = widget.features.contains('Handicap Accessible');
      yachtAmenities['Inflatable Island'] = widget.features.contains('Inflatable Island');
      yachtAmenities['Jacuzzi'] = widget.features.contains('Jacuzzi');
      yachtAmenities['Jet Ski'] = widget.features.contains('Jet Ski');
      yachtAmenities['Jetpack'] = widget.features.contains('Jetpack');
      yachtAmenities['Kayak'] = widget.features.contains('Kayak');
      yachtAmenities['Linens'] = widget.features.contains('Linens');
      yachtAmenities['Movie Theatre'] = widget.features.contains('Movie Theatre');
      yachtAmenities['Paddle Board'] = widget.features.contains('Paddle Board');
      yachtAmenities['Scooter'] = widget.features.contains('Scooter');
      yachtAmenities['Snorkel Gear'] = widget.features.contains('Snorkel Gear');
      yachtAmenities['Sound System'] = widget.features.contains('Sound System');
      yachtAmenities['Spa'] = widget.features.contains('Spa');
      yachtAmenities['Stabilizers'] = widget.features.contains('Stabilizers');
      yachtAmenities['Steam Room'] = widget.features.contains('Steam Room');
      yachtAmenities['Suana'] = widget.features.contains('Suana');
      yachtAmenities['Swimming Pool'] = widget.features.contains('Swimming Pool');
      yachtAmenities['Tender'] = widget.features.contains('Tender');
      yachtAmenities['Underwater Camera'] = widget.features.contains('Underwater Camera');
      yachtAmenities['Visually impaired accessible'] = widget.features.contains('Visually impaired accessible');
      yachtAmenities['Wakeboard'] = widget.features.contains('Wakeboard');
      yachtAmenities['Water Ski'] = widget.features.contains('Water Ski');
    } else {
      fishingAmenities['Air Conditioning'] = widget.features.contains('Air Conditioning');
      fishingAmenities['Child Friendly'] = widget.features.contains('Child Friendly');
      fishingAmenities['Clean and Filleting'] = widget.features.contains('Clean and Filleting');
      fishingAmenities['Disabled Accessible'] = widget.features.contains('Disabled Accessible');
      fishingAmenities['Fighting Chair'] = widget.features.contains('Fighting Chair');
      fishingAmenities['First Mate'] = widget.features.contains('First Mate');
      fishingAmenities['Fishing License'] = widget.features.contains('Fishing License');
      fishingAmenities['Food Provided'] = widget.features.contains('Food Provided');
      fishingAmenities['Handicap Accessible'] = widget.features.contains('Handicap Accessible');
      fishingAmenities['Icebox'] = widget.features.contains('Icebox');
      fishingAmenities['Keep Your Catch'] = widget.features.contains('Keep Your Catch');
      fishingAmenities['Live Bait'] = widget.features.contains('Live Bait');
      fishingAmenities['Pickup Included'] = widget.features.contains('Pickup Included');
      fishingAmenities['Rods and Reels Included'] = widget.features.contains('Rods and Reels Included');
      fishingAmenities['Tackle Included'] = widget.features.contains('Tackle Included');
      fishingAmenities['Toilet'] = widget.features.contains('Toilet');
      fishingAmenities['Visually impaired accessible'] = widget.features.contains('Visually impaired accessible');
      fishingAmenities['Water Provided'] = widget.features.contains('Water Provided');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Select Vessel Features')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            widget.vesselType == 'Yacht'
                ? Expanded(
  child: new ListView(
    children: yachtAmenities.keys.map((String key) {
      return new CheckboxListTile(
        title: new Text(key),
        value: yachtAmenities[key],
        onChanged: (bool? value) { // Change here
          if (value != null) { // Check for null
            setState(() {
              yachtAmenities[key] = value;
              if (value)
                selectedFeatures.add(key);
              else
                selectedFeatures.remove(key);
            });
          }
        },
      );
    }).toList(),
  ),
)
: Expanded(
  child: new ListView(
    children: fishingAmenities.keys.map((String key) {
      return new CheckboxListTile(
        title: new Text(key),
        value: fishingAmenities[key],
        onChanged: (bool? value) { // Change here
          if (value != null) { // Check for null
            setState(() {
              fishingAmenities[key] = value;
              if (value)
                selectedFeatures.add(key);
              else
                selectedFeatures.remove(key);
            });
          }
        },
      );
    }).toList(),
  ),
),
            CustomButton(text: 'Save', function: () => Get.back(result: selectedFeatures)),
          ],
        ),
      ),
    );
  }
}
