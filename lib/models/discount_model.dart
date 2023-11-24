class Discount {
  Coupon? coupon; // Coupon is nullable

  Discount({this.coupon});

  Discount.fromJson(Map<String, dynamic> json) {
    // Using null-aware operators for more concise code
    coupon = json['coupon'] != null ? Coupon.fromJson(json['coupon']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Using null-aware operators for more concise code
    data['coupon'] = coupon?.toJson();
    return data;
  }
}

class Coupon {
  num? discount; // Discount is nullable

  Coupon({this.discount});

  Coupon.fromJson(Map<String, dynamic> json) {
    // Directly assigning because num can be null, and json['discount'] will be null if it's not there
    discount = json['discount'] as num?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount'] = discount;
    return data;
  }
}
