import 'package:cloud_firestore/cloud_firestore.dart';

class Vessel {
  final String? userID;
  String? vesselChatUserID;
  final String? vesselID;
  final String? vesselName;
  final String? description;
  final List<dynamic>? thingsAllowed;
  final num? rating;
  final num? ratingCount;
  final List<dynamic>? prices;
  final num? passengerCapacity;
  final num? availableSeats;
  final List<dynamic>? durations;
  final List<dynamic>? images;
  final bool? disabledByAdmin;
  final bool? approved;
  late final bool? licensed;
  late final bool? captainLicensed;
  final Timestamp? disabledUntil;
  final GeoPoint? geoPoint;
  final String? address;
  final String? shortAddress;
  final num? length;
  final num? cabins;
  final num? bathrooms;
  final num? crewSize;
  final num? speed;
  final String? builder;
  final String? vesselType;
  final String? yachtType;
  final String? fishingVesselType;
  final String? fishingType;
  final String? cancellationPolicy;
  final List<dynamic>? features;
  final List<dynamic>? fishingSpecies;
  final List<dynamic>? fishingTechniques;
  final List<dynamic>? monday;
  final List<dynamic>? tuesday;
  final List<dynamic>? wednesday;
  final List<dynamic>? thursday;
  final List<dynamic>? friday;
  final List<dynamic>? saturday;
  final List<dynamic>? sunday;

  Vessel({
    this.userID,
    this.vesselID,
    this.vesselName,
    this.description,
    this.thingsAllowed,
    this.rating,
    this.ratingCount,
    this.prices,
    this.passengerCapacity,
    this.availableSeats,
    this.durations,
    this.images,
    this.disabledByAdmin,
    this.approved,
    this.licensed,
    this.captainLicensed,
    this.geoPoint,
    this.address,
    this.shortAddress,
    this.length,
    this.cabins,
    this.bathrooms,
    this.crewSize,
    this.speed,
    this.builder,
    this.vesselType,
    this.yachtType,
    this.fishingVesselType,
    this.fishingType,
    this.cancellationPolicy,
    this.features,
    this.fishingSpecies,
    this.fishingTechniques,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.vesselChatUserID,
    this.disabledUntil,
  });

  factory Vessel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final snapshot = doc.data();
    if (snapshot != null) {
      return Vessel(
        userID: snapshot['userID'] as String,
        vesselID: snapshot['vesselID'] as String,
        vesselName: snapshot['vesselName'] as String,
        description: snapshot['description'] as String,
        thingsAllowed: snapshot['thingsAllowed'] as List<dynamic>,
        rating: snapshot['rating'] as num,
        ratingCount: snapshot['ratingCount'] as num,
        prices: snapshot['prices'] as List<dynamic>,
        passengerCapacity: snapshot['passengerCapacity'] as num,
        availableSeats: snapshot['availableSeats'] as num,
        durations: snapshot['durations'] as List<dynamic>,
        images: snapshot['images'] as List<dynamic>,
        disabledByAdmin: snapshot['disabledByAdmin'] as bool,
        approved: snapshot['approved'] as bool,
        licensed: snapshot['licensed'] as bool,
        captainLicensed: snapshot['captainLicensed'] as bool,
        geoPoint: snapshot['geoPoint'] as GeoPoint,
        address: snapshot['address'] as String,
        shortAddress: snapshot['shortAddress'] as String,
        length: snapshot['length'] as num,
        cabins: snapshot['cabins'] as num,
        bathrooms: snapshot['bathrooms'] as num,
        crewSize: snapshot['crewSize'] as num,
        speed: snapshot['speed'] as num,
        builder: snapshot['builder'] as String,
        vesselType: snapshot['vesselType'] as String,
        yachtType: snapshot['yachtType'] as String,
        fishingVesselType: snapshot['fishingVesselType'] as String,
        fishingType: snapshot['fishingType'] as String,
        cancellationPolicy: snapshot['cancellationPolicy'] as String,
        features: snapshot['features'] as List<dynamic>,
        fishingSpecies: snapshot['fishingSpecies'] as List<dynamic>,
        fishingTechniques: snapshot['fishingTechniques'] as List<dynamic>,
        monday: snapshot['monday'] as List<dynamic>,
        tuesday: snapshot['tuesday'] as List<dynamic>,
        wednesday: snapshot['wednesday'] as List<dynamic>,
        thursday: snapshot['thursday'] as List<dynamic>,
        friday: snapshot['friday'] as List<dynamic>,
        saturday: snapshot['saturday'] as List<dynamic>,
        sunday: snapshot['sunday'] as List<dynamic>,
        vesselChatUserID: snapshot['vesselChatUserID'] as String?,
        disabledUntil: snapshot['disabledUntil'] as Timestamp?,
      );
    } else {
      throw Exception('Document data is null');
    }
  }
}
