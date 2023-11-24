import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/widgets/custom_button.dart';

class SelectThingsAllowed extends StatefulWidget {
  final List thingsAllowed;

  SelectThingsAllowed({required this.thingsAllowed});

  @override
  SelectThingsAllowedState createState() => new SelectThingsAllowedState();
}

class SelectThingsAllowedState extends State<SelectThingsAllowed> {
  List selectedItems = [];
  Map<String, bool> listOfThings = {
    'Pets': false,
    'Smoking': false,
    'Fishing': false,
    'Shoes': false,
    'Glass bottles': false,
    'Alcohol': false,
    'Swimming': false,
    'Wines': false,
  };

  @override
  void initState() {
    listOfThings['Pets'] = widget.thingsAllowed.contains('Pets');
    listOfThings['Smoking'] = widget.thingsAllowed.contains('Smoking');
    listOfThings['Fishing'] = widget.thingsAllowed.contains('Fishing');
    listOfThings['Shoes'] = widget.thingsAllowed.contains('Shoes');
    listOfThings['Glass bottles'] = widget.thingsAllowed.contains('Glass bottles');
    listOfThings['Alcohol'] = widget.thingsAllowed.contains('Alcohol');
    listOfThings['Swimming'] = widget.thingsAllowed.contains('Swimming');
    listOfThings['Wines'] = widget.thingsAllowed.contains('Wines');
    selectedItems = widget.thingsAllowed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Select things allowed')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: new ListView(
                children: listOfThings.keys.map((String key) {
                  return new CheckboxListTile(
                    title: new Text(key),
                    value: listOfThings[key],
                    onChanged: (bool? value) {
                      setState(() {
                        listOfThings[key] = value != null;
                        if (value != null)
                          selectedItems.add(key);
                        else
                          selectedItems.remove(key);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            CustomButton(text: 'Save', function: () => Get.back(result: selectedItems)),
          ],
        ),
      ),
    );
  }
}
