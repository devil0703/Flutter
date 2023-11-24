class MakaiFee {
  Fee fee;

  MakaiFee({required this.fee});

  factory MakaiFee.fromJson(Map<String, dynamic> json) {
    return MakaiFee(
      fee: Fee.fromJson(json['fee'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fee'] = this.fee.toJson();
    return data;
  }
}

class Fee {
  String total;

  Fee({this.total = '0'}); // Provide a default value for total

  factory Fee.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Fee(); // Returns a Fee object with the default total value
    }
    return Fee(
      total: json['total'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    return data;
  }
}
