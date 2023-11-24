import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/widgets/custom_button.dart';

class SelectFishingFeatures extends StatefulWidget {
  final List features;
  final String featureType;

  SelectFishingFeatures({required this.features, required this.featureType});

  @override
  SelectFishingFeaturesState createState() => new SelectFishingFeaturesState();
}

class SelectFishingFeaturesState extends State<SelectFishingFeatures> {
  List selectedFeatures = [];
  Map<String, bool> fishingSpecies = {
    'Alligator Gar': false,
    'Amberjack': false,
    'Arapaima': false,
    'Arctic Char': false,
    'Asp': false,
    'Barracuda [Great]': false,
    'Barracuda [Pacific]': false,
    'Barramundi': false,
    'Bass [Australian]': false,
    'Bass [Calico]': false,
    'Bass [LargeMouth]': false,
    'Bass [Peacock]': false,
    'Bass [Rainbow]': false,
    'Bass[Smallmouth]': false,
    'Bass[Spotted]': false,
    'Bass[Striped]': false,
    'Bass[White]': false,
    'Black Drum': false,
    'Black Jewfish': false,
    'Bluefish': false,
    'Bluenose Warehou': false,
    'Boneish': false,
    'Bonito': false,
    'Bowfin': false,
    'Bream': false,
    'Bream [Black]': false,
    'Bream [Fingermark]': false,
    'Brook Trout': false,
    'Brown Trout': false,
    'Bullhead': false,
    'Burbot': false,
    'Caliornia Corbina': false,
    'Caliornia Sheephead': false,
    'Carp': false,
    'Catfish': false,
    'Cero Markerel': false,
    'Clam': false,
    'Clown Knife Fish': false,
    'Cobia': false,
    'Cod': false,
    'Cod [Blue]': false,
    'Cod [Breaksea]': false,
    'Common Ling': false,
    'Common Pandora': false,
    'Conger Eel': false,
    'Coral Trout': false,
    'Crab': false,
    'Crappie': false,
    'Crayfish': false,
    'Dentex': false,
    'Dhufish': false,
    'Dogfish': false,
    'Dolly Varden': false,
    'Dolphin [Mahi Mahi]': false,
    'Flathad': false,
    'Flounder': false,
    'Freshwater Drum': false,
    'Garfish': false,
    'Geelbek [Cape Salmon]': false,
    'Gilt-head [Seabream]': false,
    'Golden Dorado': false,
    'Grouper [Black]': false,
    'Grouper [Broomtail]': false,
    'Grouper [Gag]': false,
    'Grouper [Goliath]': false,
    'Grouper [Red]': false,
    'Grouper [Scamp]': false,
    'Grouper [Snowy]': false,
    'Grunt': false,
    'Grunter [Javelin]': false,
    'Gruper [Dusky]': false,
    'Gurnard': false,
    'Haddock': false,
    'Halibt': false,
    'Hapuka': false,
    'Herring': false,
    'Hogfish': false,
    'Hybrid Striped Bass': false,
    'Indian Threadfish': false,
    'Jack [African Pompano]': false,
    'Jack [Almaco]': false,
    'Jack [Horse-eye]': false,
    'Jack Crevalle': false,
    'Jobfish [Green]': false,
    'Jobfish [Rusty]': false,
    'John Dory': false,
    'Kahawai': false,
    'King George Whiting': false,
    'King Mackerel [Kingfish]': false,
    'Kob': false,
    'Ladyfish': false,
    'Lake Trout': false,
    'Leatherjacket': false,
    'Leerfish [Garrick]': false,
    'Lingcod': false,
    'Little Tunny [False Albacore]': false,
    'Lobster': false,
    'Long-Tail Red Snapper [Onaga]': false,
    'Mackerel [Atlantic]': false,
    'Marlin [Black]': false,
    'Marlin [Blue]': false,
    'Marlin [Striped]': false,
    'Marlin [White]': false,
    'Milkfish': false,
    'Morwong': false,
    'Murray Cod': false,
    'Muskelunge [Musky]': false,
    'Musselcracker': false,
    'Nannygai': false,
    'Needlefish': false,
    'Nursehound [Bull Huss]': false,
    'Paddlefish': false,
    'Papuan Black Bass': false,
    'Payara': false,
    'Pearl Perch': false,
    'Pejerrey [Silverside]': false,
    'Perch [European]': false,
    'Perch [Golden]': false,
    'Perch [Silver]': false,
    'Perch [White]': false,
    'Perch [Yellow]': false,
    'Permit': false,
    'Pike [Northern]': false,
    'Pike Perch [Zander]': false,
    'Pink Maomao': false,
    'Pollock': false,
    'Pompano': false,
    'Queen Snapper [Australian]': false,
    'Queen Snapper [Caribbean]': false,
    'Queenfish': false,
    'Queensland Grouper [Giant Grouper]': false,
    'Rainbow Runner': false,
    'Rainbow Trout': false,
    'Ray': false,
    'Red Bass': false,
    'Redfish': false,
    'Rockfish': false,
    'Roosterfish': false,
    'Sailfish': false,
    'Salmno [Chinook]': false,
    'Salmon': false,
    'Salmon [Alantic]': false,
    'Salmon [Australian]': false,
    'Salmon [Chum]': false,
    'Salmon [Coho]': false,
    'Salmon [Pink]': false,
    'Salmon [Sockeye]': false,
    'Samson Fish': false,
    'Saratoga': false,
    'Sauger': false,
    'Scallop': false,
    'Sculpin': false,
    'Scup [Porgy]': false,
    'Seabass [European]': false,
    'Seabass [Giant]': false,
    'Seabass [White]': false,
    'Shad': false,
    'Shark [Blacktip]': false,
    'Shark [Blue]': false,
    'Shark [Bonnethead]': false,
    'Shark [Bull]': false,
    'Shark [Great White]': false,
    'Shark [Greenland]': false,
    'Shark [Gummy]': false,
    'Shark [Hammerhead]': false,
    'Shark [Lemon]': false,
    'Shark [Leopard]': false,
    'Shark [Mako]': false,
    'Shark [Nurse]': false,
    'Shark [Porbeagle]': false,
    'Shark [Thresher]': false,
    'Shark [Tiger]': false,
    'Shark [Tope]': false,
    'Sheepshead': false,
    'Short-Tail Red Snapper [Ehu]': false,
    'Shrimp': false,
    'Skate': false,
    'Snakehead': false,
    'Snapper [Yellowtail]': false,
    'Snapper [Cubera]': false,
    'Snapper [Lane]': false,
    'Snapper [Mangrove]': false,
    'Snapper [Mullet]': false,
    'Snapper [Mutton]': false,
    'Snapper [Pink]': false,
    'Snapper [Red Emperor]': false,
    'Snapper [Red]': false,
    'Snapper [Vermilion]': false,
    'Snoek': false,
    'Snook': false,
    'Spadefish': false,
    'Spangled Emperor': false,
    'Spanish Mackerel': false,
    'Spanish Mackerel [Narrow-barred]': false,
    'Spearfish [Longbill]': false,
    'Spearfish [Shortbill]': false,
    'Speckled Trout': false,
    'Spotted Seatrout': false,
    'Strugeon': false,
    'Sunfish': false,
    'Sweetlip Emperor': false,
    'Swordfish': false,
    'Tailor': false,
    'Tarakihi': false,
    'Tarpon': false,
    'Tautog': false,
    'Threadfin Salmon': false,
    'Tigerfish': false,
    'Tigerfish [Goliath]': false,
    'Tilapia': false,
    'Tilfish': false,
    'Trevally [Bigeye]': false,
    'Trevally [Blacktip]': false,
    'Trevally [Bluefin]': false,
    'Trevally [Giant]': false,
    'Trevally [Golden]': false,
    'Trevally [Silver]': false,
    'Triggerfish [Gray]': false,
    'Tripletail': false,
    'Trumpeter [Striped]': false,
    'Tuna': false,
    'Tuna [Albacore]': false,
    'Tuna [Bigeye]': false,
    'Tuna [Bluefin]': false,
    'Tuna [Dogtooth]': false,
    'Tuna [Longtail]': false,
    'Tuna [Skipjack]': false,
    'Tuna [Yellowin]': false,
    'Tune [Blackfin]': false,
    'Wahoo': false,
    'Walleye': false,
    'Weakfish': false,
    'Whitefish [Lake]': false,
    'Whiting': false,
    'Wolffish': false,
    'Wrasse [Bluethroat]': false,
    'Wrasse [Humphead]': false,
    'Yellowtail Amberjack': false,
  };
  Map<String, bool> fishingTechniques = {
    'Bowfishing': false,
    'Deep Sea': false,
    'Drift': false,
    'Flounder Gigging': false,
    'Fly': false,
    'Handline': false,
    'Heavy Tackle': false,
    'Ice': false,
    'Jigging': false,
    'Kite': false,
    'Light Tackle': false,
    'Popping': false,
    'Spearfishing': false,
    'Spinning': false,
    'Trolling': false,
  };

  @override
  void initState() {
    if (widget.featureType == 'species') {
      fishingSpecies['Alligator Gar'] = widget.features.contains('Alligator Gar');
      fishingSpecies['Amberjack'] = widget.features.contains('Amberjack');
      fishingSpecies['Arapaima'] = widget.features.contains('Arapaima');
      fishingSpecies['Arctic Char'] = widget.features.contains('Arctic Char');
      fishingSpecies['Asp'] = widget.features.contains('Asp');
      fishingSpecies['Barracuda [Great]'] = widget.features.contains('Barracuda [Great]');
      fishingSpecies['Barracuda [Pacific]'] = widget.features.contains('Barracuda [Pacific]');
      fishingSpecies['Barramundi'] = widget.features.contains('Barramundi');
      fishingSpecies['Bass [Australian]'] = widget.features.contains('Bass [Australian]');
      fishingSpecies['Bass [Calico]'] = widget.features.contains('Bass [Calico]');
      fishingSpecies['Bass [LargeMouth]'] = widget.features.contains('Bass [LargeMouth]');
      fishingSpecies['Bass [Peacock]'] = widget.features.contains('Bass [Peacock]');
      fishingSpecies['Bass [Rainbow]'] = widget.features.contains('Bass [Rainbow]');
      fishingSpecies['Bass[Smallmouth]'] = widget.features.contains('Bass[Smallmouth]');
      fishingSpecies['Bass[Spotted]'] = widget.features.contains('Bass[Spotted]');
      fishingSpecies['Bass[Striped]'] = widget.features.contains('Bass[Striped]');
      fishingSpecies['Bass[White]'] = widget.features.contains('Bass[White]');
      fishingSpecies['Black Drum'] = widget.features.contains('Black Drum');
      fishingSpecies['Black Jewfish'] = widget.features.contains('Black Jewfish');
      fishingSpecies['Bluefish'] = widget.features.contains('Bluefish');
      fishingSpecies['Bluenose Warehou'] = widget.features.contains('Bluenose Warehou');
      fishingSpecies['Boneish'] = widget.features.contains('Boneish');
      fishingSpecies['Bonito'] = widget.features.contains('Bonito');
      fishingSpecies['Bowfin'] = widget.features.contains('Bowfin');
      fishingSpecies['Bream'] = widget.features.contains('Bream');
      fishingSpecies['Bream [Black]'] = widget.features.contains('Bream [Black]');
      fishingSpecies['Bream [Fingermark]'] = widget.features.contains('Bream [Fingermark]');
      fishingSpecies['Brook Trout'] = widget.features.contains('Brook Trout');
      fishingSpecies['Brown Trout'] = widget.features.contains('Brown Trout');
      fishingSpecies['Bullhead'] = widget.features.contains('Bullhead');
      fishingSpecies['Burbot'] = widget.features.contains('Burbot');
      fishingSpecies['Caliornia Corbina'] = widget.features.contains('Caliornia Corbina');
      fishingSpecies['Caliornia Sheephead'] = widget.features.contains('Caliornia Sheephead');
      fishingSpecies['Carp'] = widget.features.contains('Carp');
      fishingSpecies['Catfish'] = widget.features.contains('Catfish');
      fishingSpecies['Cero Markerel'] = widget.features.contains('Cero Markerel');
      fishingSpecies['Clam'] = widget.features.contains('Clam');
      fishingSpecies['Clown Knife Fish'] = widget.features.contains('Clown Knife Fish');
      fishingSpecies['Cobia'] = widget.features.contains('Cobia');
      fishingSpecies['Cod'] = widget.features.contains('Cod');
      fishingSpecies['Cod [Blue]'] = widget.features.contains('Cod [Blue]');
      fishingSpecies['Cod [Breaksea]'] = widget.features.contains('Cod [Breaksea]');
      fishingSpecies['Common Ling'] = widget.features.contains('Common Ling');
      fishingSpecies['Common Pandora'] = widget.features.contains('Common Pandora');
      fishingSpecies['Conger Eel'] = widget.features.contains('Conger Eel');
      fishingSpecies['Coral Trout'] = widget.features.contains('Coral Trout');
      fishingSpecies['Crab'] = widget.features.contains('Crab');
      fishingSpecies['Crappie'] = widget.features.contains('Crappie');
      fishingSpecies['Crayfish'] = widget.features.contains('Crayfish');
      fishingSpecies['Dentex'] = widget.features.contains('Dentex');
      fishingSpecies['Dhufish'] = widget.features.contains('Dhufish');
      fishingSpecies['Dogfish'] = widget.features.contains('Dogfish');
      fishingSpecies['Dolly Varden'] = widget.features.contains('Dolly Varden');
      fishingSpecies['Dolphin [Mahi Mahi]'] = widget.features.contains('Dolphin [Mahi Mahi]');
      fishingSpecies['Flathad'] = widget.features.contains('Flathad');
      fishingSpecies['Flounder'] = widget.features.contains('Flounder');
      fishingSpecies['Freshwater Drum'] = widget.features.contains('Freshwater Drum');
      fishingSpecies['Garfish'] = widget.features.contains('Garfish');
      fishingSpecies['Geelbek [Cape Salmon]'] = widget.features.contains('Geelbek [Cape Salmon]');
      fishingSpecies['Gilt-head [Seabream]'] = widget.features.contains('Gilt-head [Seabream]');
      fishingSpecies['Golden Dorado'] = widget.features.contains('Golden Dorado');
      fishingSpecies['Grouper [Black]'] = widget.features.contains('Grouper [Black]');
      fishingSpecies['Grouper [Broomtail]'] = widget.features.contains('Grouper [Broomtail]');
      fishingSpecies['Grouper [Gag]'] = widget.features.contains('Grouper [Gag]');
      fishingSpecies['Grouper [Goliath]'] = widget.features.contains('Grouper [Goliath]');
      fishingSpecies['Grouper [Red]'] = widget.features.contains('Grouper [Red]');
      fishingSpecies['Grouper [Scamp]'] = widget.features.contains('Grouper [Scamp]');
      fishingSpecies['Grouper [Snowy]'] = widget.features.contains('Grouper [Snowy]');
      fishingSpecies['Grunt'] = widget.features.contains('Grunt');
      fishingSpecies['Grunter [Javelin]'] = widget.features.contains('Grunter [Javelin]');
      fishingSpecies['Gruper [Dusky]'] = widget.features.contains('Gruper [Dusky]');
      fishingSpecies['Gurnard'] = widget.features.contains('Gurnard');
      fishingSpecies['Haddock'] = widget.features.contains('Haddock');
      fishingSpecies['Halibt'] = widget.features.contains('Halibt');
      fishingSpecies['Hapuka'] = widget.features.contains('Hapuka');
      fishingSpecies['Herring'] = widget.features.contains('Herring');
      fishingSpecies['Hogfish'] = widget.features.contains('Hogfish');
      fishingSpecies['Hybrid Striped Bass'] = widget.features.contains('Hybrid Striped Bass');
      fishingSpecies['Indian Threadfish'] = widget.features.contains('Indian Threadfish');
      fishingSpecies['Jack [African Pompano]'] = widget.features.contains('Jack [African Pompano]');
      fishingSpecies['Jack [Almaco]'] = widget.features.contains('Jack [Almaco]');
      fishingSpecies['Jack [Horse-eye]'] = widget.features.contains('Jack [Horse-eye]');
      fishingSpecies['Jack Crevalle'] = widget.features.contains('Jack Crevalle');
      fishingSpecies['Jobfish [Green]'] = widget.features.contains('Jobfish [Green]');
      fishingSpecies['Jobfish [Rusty]'] = widget.features.contains('Jobfish [Rusty]');
      fishingSpecies['John Dory'] = widget.features.contains('John Dory');
      fishingSpecies['Kahawai'] = widget.features.contains('Kahawai');
      fishingSpecies['King George Whiting'] = widget.features.contains('King George Whiting');
      fishingSpecies['King Mackerel [Kingfish]'] = widget.features.contains('King Mackerel [Kingfish]');
      fishingSpecies['Kob'] = widget.features.contains('Kob');
      fishingSpecies['Ladyfish'] = widget.features.contains('Ladyfish');
      fishingSpecies['Lake Trout'] = widget.features.contains('Lake Trout');
      fishingSpecies['Leatherjacket'] = widget.features.contains('Leatherjacket');
      fishingSpecies['Leerfish [Garrick]'] = widget.features.contains('Leerfish [Garrick]');
      fishingSpecies['Lingcod'] = widget.features.contains('Lingcod');
      fishingSpecies['Little Tunny [False Albacore]'] = widget.features.contains('Little Tunny [False Albacore]');
      fishingSpecies['Lobster'] = widget.features.contains('Lobster');
      fishingSpecies['Long-Tail Red Snapper [Onaga]'] = widget.features.contains('Long-Tail Red Snapper [Onaga]');
      fishingSpecies['Mackerel [Atlantic]'] = widget.features.contains('Mackerel [Atlantic]');
      fishingSpecies['Marlin [Black]'] = widget.features.contains('Marlin [Black]');
      fishingSpecies['Marlin [Blue]'] = widget.features.contains('Marlin [Blue]');
      fishingSpecies['Marlin [Striped]'] = widget.features.contains('Marlin [Striped]');
      fishingSpecies['Marlin [White]'] = widget.features.contains('Marlin [White]');
      fishingSpecies['Milkfish'] = widget.features.contains('Milkfish');
      fishingSpecies['Morwong'] = widget.features.contains('Morwong');
      fishingSpecies['Murray Cod'] = widget.features.contains('Murray Cod');
      fishingSpecies['Muskelunge [Musky]'] = widget.features.contains('Muskelunge [Musky]');
      fishingSpecies['Musselcracker'] = widget.features.contains('Musselcracker');
      fishingSpecies['Nannygai'] = widget.features.contains('Nannygai');
      fishingSpecies['Needlefish'] = widget.features.contains('Needlefish');
      fishingSpecies['Nursehound [Bull Huss]'] = widget.features.contains('Nursehound [Bull Huss]');
      fishingSpecies['Paddlefish'] = widget.features.contains('Paddlefish');
      fishingSpecies['Papuan Black Bass'] = widget.features.contains('Papuan Black Bass');
      fishingSpecies['Payara'] = widget.features.contains('Payara');
      fishingSpecies['Pearl Perch'] = widget.features.contains('Pearl Perch');
      fishingSpecies['Pejerrey [Silverside]'] = widget.features.contains('Pejerrey [Silverside]');
      fishingSpecies['Perch [European]'] = widget.features.contains('Perch [European]');
      fishingSpecies['Perch [Golden]'] = widget.features.contains('Perch [Golden]');
      fishingSpecies['Perch [Silver]'] = widget.features.contains('Perch [Silver]');
      fishingSpecies['Perch [White]'] = widget.features.contains('Perch [White]');
      fishingSpecies['Perch [Yellow]'] = widget.features.contains('Perch [Yellow]');
      fishingSpecies['Permit'] = widget.features.contains('Permit');
      fishingSpecies['Pike [Northern]'] = widget.features.contains('Pike [Northern]');
      fishingSpecies['Pike Perch [Zander]'] = widget.features.contains('Pike Perch [Zander]');
      fishingSpecies['Pink Maomao'] = widget.features.contains('Pink Maomao');
      fishingSpecies['Pollock'] = widget.features.contains('Pollock');
      fishingSpecies['Pompano'] = widget.features.contains('Pompano');
      fishingSpecies['Queen Snapper [Australian]'] = widget.features.contains('Queen Snapper [Australian]');
      fishingSpecies['Queen Snapper [Caribbean]'] = widget.features.contains('Queen Snapper [Caribbean]');
      fishingSpecies['Queenfish'] = widget.features.contains('Queenfish');
      fishingSpecies['Queensland Grouper [Giant Grouper]'] = widget.features.contains('Queensland Grouper [Giant Grouper]');
      fishingSpecies['Rainbow Runner'] = widget.features.contains('Rainbow Runner');
      fishingSpecies['Rainbow Trout'] = widget.features.contains('Rainbow Trout');
      fishingSpecies['Ray'] = widget.features.contains('Ray');
      fishingSpecies['Red Bass'] = widget.features.contains('Red Bass');
      fishingSpecies['Redfish'] = widget.features.contains('Redfish');
      fishingSpecies['Rockfish'] = widget.features.contains('Rockfish');
      fishingSpecies['Roosterfish'] = widget.features.contains('Roosterfish');
      fishingSpecies['Sailfish'] = widget.features.contains('Sailfish');
      fishingSpecies['Salmno [Chinook]'] = widget.features.contains('Salmno [Chinook]');
      fishingSpecies['Salmon'] = widget.features.contains('Salmon');
      fishingSpecies['Salmon [Alantic]'] = widget.features.contains('Salmon [Alantic]');
      fishingSpecies['Salmon [Australian]'] = widget.features.contains('Salmon [Australian]');
      fishingSpecies['Salmon [Chum]'] = widget.features.contains('Salmon [Chum]');
      fishingSpecies['Salmon [Coho]'] = widget.features.contains('Salmon [Coho]');
      fishingSpecies['Salmon [Pink]'] = widget.features.contains('Salmon [Pink]');
      fishingSpecies['Salmon [Sockeye]'] = widget.features.contains('Salmon [Sockeye]');
      fishingSpecies['Samson Fish'] = widget.features.contains('Samson Fish');
      fishingSpecies['Saratoga'] = widget.features.contains('Saratoga');
      fishingSpecies['Sauger'] = widget.features.contains('Sauger');
      fishingSpecies['Scallop'] = widget.features.contains('Scallop');
      fishingSpecies['Sculpin'] = widget.features.contains('Sculpin');
      fishingSpecies['Scup [Porgy]'] = widget.features.contains('Scup [Porgy]');
      fishingSpecies['Seabass [European]'] = widget.features.contains('Seabass [European]');
      fishingSpecies['Seabass [Giant]'] = widget.features.contains('Seabass [Giant]');
      fishingSpecies['Seabass [White]'] = widget.features.contains('Seabass [White]');
      fishingSpecies['Shad'] = widget.features.contains('Shad');
      fishingSpecies['Shark [Blacktip]'] = widget.features.contains('Shark [Blacktip]');
      fishingSpecies['Shark [Blue]'] = widget.features.contains('Shark [Blue]');
      fishingSpecies['Shark [Bonnethead]'] = widget.features.contains('Shark [Bonnethead]');
      fishingSpecies['Shark [Bull]'] = widget.features.contains('Shark [Bull]');
      fishingSpecies['Shark [Great White]'] = widget.features.contains('Shark [Great White]');
      fishingSpecies['Shark [Greenland]'] = widget.features.contains('Shark [Greenland]');
      fishingSpecies['Shark [Gummy]'] = widget.features.contains('Shark [Gummy]');
      fishingSpecies['Shark [Hammerhead]'] = widget.features.contains('Shark [Hammerhead]');
      fishingSpecies['Shark [Lemon]'] = widget.features.contains('Shark [Lemon]');
      fishingSpecies['Shark [Leopard]'] = widget.features.contains('Shark [Leopard]');
      fishingSpecies['Shark [Mako]'] = widget.features.contains('Shark [Mako]');
      fishingSpecies['Shark [Nurse]'] = widget.features.contains('Shark [Nurse]');
      fishingSpecies['Shark [Porbeagle]'] = widget.features.contains('Shark [Porbeagle]');
      fishingSpecies['Shark [Thresher]'] = widget.features.contains('Shark [Thresher]');
      fishingSpecies['Shark [Tiger]'] = widget.features.contains('Shark [Tiger]');
      fishingSpecies['Shark [Tope]'] = widget.features.contains('Shark [Tope]');
      fishingSpecies['Sheepshead'] = widget.features.contains('Sheepshead');
      fishingSpecies['Short-Tail Red Snapper [Ehu]'] = widget.features.contains('Short-Tail Red Snapper [Ehu]');
      fishingSpecies['Shrimp'] = widget.features.contains('Shrimp');
      fishingSpecies['Skate'] = widget.features.contains('Skate');
      fishingSpecies['Snakehead'] = widget.features.contains('Snakehead');
      fishingSpecies['Snapper [Yellowtail]'] = widget.features.contains('Snapper [Yellowtail]');
      fishingSpecies['Snapper [Cubera]'] = widget.features.contains('Snapper [Cubera]');
      fishingSpecies['Snapper [Lane]'] = widget.features.contains('Snapper [Lane]');
      fishingSpecies['Snapper [Mangrove]'] = widget.features.contains('Snapper [Mangrove]');
      fishingSpecies['Snapper [Mullet]'] = widget.features.contains('Snapper [Mullet]');
      fishingSpecies['Snapper [Mutton]'] = widget.features.contains('Snapper [Mutton]');
      fishingSpecies['Snapper [Pink]'] = widget.features.contains('Snapper [Pink]');
      fishingSpecies['Snapper [Red Emperor]'] = widget.features.contains('Snapper [Red Emperor]');
      fishingSpecies['Snapper [Red]'] = widget.features.contains('Snapper [Red]');
      fishingSpecies['Snapper [Vermilion]'] = widget.features.contains('Snapper [Vermilion]');
      fishingSpecies['Snoek'] = widget.features.contains('Snoek');
      fishingSpecies['Snook'] = widget.features.contains('Snook');
      fishingSpecies['Spadefish'] = widget.features.contains('Spadefish');
      fishingSpecies['Spangled Emperor'] = widget.features.contains('Spangled Emperor');
      fishingSpecies['Spanish Mackerel'] = widget.features.contains('Spanish Mackerel');
      fishingSpecies['Spanish Mackerel [Narrow-barred]'] = widget.features.contains('Spanish Mackerel [Narrow-barred]');
      fishingSpecies['Spearfish [Longbill]'] = widget.features.contains('Spearfish [Longbill]');
      fishingSpecies['Spearfish [Shortbill]'] = widget.features.contains('Spearfish [Shortbill]');
      fishingSpecies['Speckled Trout'] = widget.features.contains('Speckled Trout');
      fishingSpecies['Spotted Seatrout'] = widget.features.contains('Spotted Seatrout');
      fishingSpecies['Strugeon'] = widget.features.contains('Strugeon');
      fishingSpecies['Sunfish'] = widget.features.contains('Sunfish');
      fishingSpecies['Sweetlip Emperor'] = widget.features.contains('Sweetlip Emperor');
      fishingSpecies['Swordfish'] = widget.features.contains('Swordfish');
      fishingSpecies['Tailor'] = widget.features.contains('Tailor');
      fishingSpecies['Tarakihi'] = widget.features.contains('Tarakihi');
      fishingSpecies['Tarpon'] = widget.features.contains('Tarpon');
      fishingSpecies['Tautog'] = widget.features.contains('Tautog');
      fishingSpecies['Threadfin Salmon'] = widget.features.contains('Threadfin Salmon');
      fishingSpecies['Tigerfish'] = widget.features.contains('Tigerfish');
      fishingSpecies['Tigerfish [Goliath]'] = widget.features.contains('Tigerfish [Goliath]');
      fishingSpecies['Tilapia'] = widget.features.contains('Tilapia');
      fishingSpecies['Tilfish'] = widget.features.contains('Tilfish');
      fishingSpecies['Trevally [Bigeye]'] = widget.features.contains('Trevally [Bigeye]');
      fishingSpecies['Trevally [Blacktip]'] = widget.features.contains('Trevally [Blacktip]');
      fishingSpecies['Trevally [Bluefin]'] = widget.features.contains('Trevally [Bluefin]');
      fishingSpecies['Trevally [Giant]'] = widget.features.contains('Trevally [Giant]');
      fishingSpecies['Trevally [Golden]'] = widget.features.contains('Trevally [Golden]');
      fishingSpecies['Trevally [Silver]'] = widget.features.contains('Trevally [Silver]');
      fishingSpecies['Triggerfish [Gray]'] = widget.features.contains('Triggerfish [Gray]');
      fishingSpecies['Tripletail'] = widget.features.contains('Tripletail');
      fishingSpecies['Trumpeter [Striped]'] = widget.features.contains('Trumpeter [Striped]');
      fishingSpecies['Tuna'] = widget.features.contains('Tuna');
      fishingSpecies['Tuna [Albacore]'] = widget.features.contains('Tuna [Albacore]');
      fishingSpecies['Tuna [Bigeye]'] = widget.features.contains('Tuna [Bigeye]');
      fishingSpecies['Tuna [Bluefin]'] = widget.features.contains('Tuna [Bluefin]');
      fishingSpecies['Tuna [Dogtooth]'] = widget.features.contains('Tuna [Dogtooth]');
      fishingSpecies['Tuna [Longtail]'] = widget.features.contains('Tuna [Longtail]');
      fishingSpecies['Tuna [Skipjack]'] = widget.features.contains('Tuna [Skipjack]');
      fishingSpecies['Tuna [Yellowin]'] = widget.features.contains('Tuna [Yellowin]');
      fishingSpecies['Tune [Blackfin]'] = widget.features.contains('Tune [Blackfin]');
      fishingSpecies['Wahoo'] = widget.features.contains('Wahoo');
      fishingSpecies['Walleye'] = widget.features.contains('Walleye');
      fishingSpecies['Weakfish'] = widget.features.contains('Weakfish');
      fishingSpecies['Whitefish [Lake]'] = widget.features.contains('Whitefish [Lake]');
      fishingSpecies['Whiting'] = widget.features.contains('Whiting');
      fishingSpecies['Wolffish'] = widget.features.contains('Wolffish');
      fishingSpecies['Wrasse [Bluethroat]'] = widget.features.contains('Wrasse [Bluethroat]');
      fishingSpecies['Wrasse [Humphead]'] = widget.features.contains('Wrasse [Humphead]');
      fishingSpecies['Yellowtail Amberjack'] = widget.features.contains('Yellowtail Amberjack');
    } else {
      fishingTechniques['Bowfishing'] = widget.features.contains('Bowfishing');
      fishingTechniques['Deep Sea'] = widget.features.contains('Deep Sea');
      fishingTechniques['Drift'] = widget.features.contains('Drift');
      fishingTechniques['Flounder Gigging'] = widget.features.contains('Flounder Gigging');
      fishingTechniques['Fly'] = widget.features.contains('Fly');
      fishingTechniques['Handline'] = widget.features.contains('Handline');
      fishingTechniques['Heavy Tackle'] = widget.features.contains('Heavy Tackle');
      fishingTechniques['Ice'] = widget.features.contains('Ice');
      fishingTechniques['Jigging'] = widget.features.contains('Jigging');
      fishingTechniques['Kite'] = widget.features.contains('Kite');
      fishingTechniques['Light Tackle'] = widget.features.contains('Light Tackle');
      fishingTechniques['Popping'] = widget.features.contains('Popping');
      fishingTechniques['Spearfishing'] = widget.features.contains('Spearfishing');
      fishingTechniques['Spinning'] = widget.features.contains('Spinning');
      fishingTechniques['Trolling'] = widget.features.contains('Trolling');
    }
    selectedFeatures = widget.features;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('Select fishing ${widget.featureType}')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            widget.featureType == 'species'
                ? Expanded(
  child: new ListView(
    children: fishingSpecies.keys.map((String key) {
      return new CheckboxListTile(
        title: new Text(key),
        value: fishingSpecies[key],
        onChanged: (bool? value) { // Accept nullable boolean
          if (value != null) { // Null check
            setState(() {
              fishingSpecies[key] = value;
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
    children: fishingTechniques.keys.map((String key) {
      return new CheckboxListTile(
        title: new Text(key),
        value: fishingTechniques[key],
        onChanged: (bool? value) { // Accept nullable boolean
          if (value != null) { // Null check
            setState(() {
              fishingTechniques[key] = value;
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
,
            CustomButton(text: 'Save', function: () => Get.back(result: selectedFeatures)),
          ],
        ),
      ),
    );
  }
}
