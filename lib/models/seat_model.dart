class SeatAvailabilityModel {
  Vessel? vessel; // Vessel can now be nullable

  SeatAvailabilityModel({this.vessel});

  factory SeatAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return SeatAvailabilityModel(
      vessel: json['vessel'] != null ? Vessel.fromJson(json['vessel']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vessel != null) {
      data['vessel'] = vessel!.toJson(); // Use of ! asserts that vessel is not null
    }
    return data;
  }
}

class Vessel {
  int? capacity;
  int? bookings;
  int? guestCount;
  int? availableSeats;

  Vessel({
    this.capacity,
    this.bookings,
    this.guestCount,
    this.availableSeats,
  });

  factory Vessel.fromJson(Map<String, dynamic> json) {
    return Vessel(
      capacity: json['capacity'] as int?,
      bookings: json['bookings'] as int?,
      guestCount: json['guestCount'] as int?,
      availableSeats: json['availableSeats'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capacity': capacity,       // nulls are allowed by default
      'bookings': bookings,
      'guestCount': guestCount,
      'availableSeats': availableSeats,
    };
  }
}
