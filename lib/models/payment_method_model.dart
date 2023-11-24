class PaymentMethodsList {
  PaymentMethods? paymentMethods;

  PaymentMethodsList({this.paymentMethods});

  PaymentMethodsList.fromJson(Map<String, dynamic> json)
      : paymentMethods = json['paymentMethods'] != null
            ? PaymentMethods.fromJson(json['paymentMethods'])
            : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentMethods'] = paymentMethods?.toJson();
    return data;
  }
}

class PaymentMethods {
  String object;
  List<Data> data;
  bool hasMore;
  String url;

  PaymentMethods({
    this.object = 'default_object',
    List<Data>? data,
    this.hasMore = false,
    this.url = 'default_url',
  }) : data = data ?? [];

  PaymentMethods.fromJson(Map<String, dynamic> json)
      : object = json['object'] ?? 'default_object',
        data = (json['data'] as List<dynamic>?)
                ?.map((item) => Data.fromJson(item))
                .toList() ??
            [],
        hasMore = json['has_more'] ?? false,
        url = json['url'] ?? 'default_url';

  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'data': data.map((v) => v.toJson()).toList(),
      'has_more': hasMore,
      'url': url,
    };
  }
}

class Data {
  String id;
  String object;
  BillingDetails? billingDetails;
  Card? card;
  int created;
  String customer;
  bool livemode;
  String type;

  Data({
    this.id = '',
    this.object = '',
    this.billingDetails,
    this.card,
    this.created = 0,
    this.customer = '',
    this.livemode = false,
    this.type = '',
  });

  Data.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        object = json['object'] ?? '',
        billingDetails = json['billing_details'] != null
            ? BillingDetails.fromJson(json['billing_details'])
            : null,
        card = json['card'] != null ? Card.fromJson(json['card']) : null,
        created = json['created'] ?? 0,
        customer = json['customer'] ?? '',
        livemode = json['livemode'] ?? false,
        type = json['type'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'object': object,
      'created': created,
      'customer': customer,
      'livemode': livemode,
      'type': type,
    };
    data['billing_details'] = billingDetails?.toJson();
    data['card'] = card?.toJson();
    return data;
  }
}

class BillingDetails {
  Address? address;
  String email;
  String name;
  String phone;

  BillingDetails({
    this.address,
    this.email = '',
    this.name = '',
    this.phone = '',
  });

  BillingDetails.fromJson(Map<String, dynamic> json)
      : address = json['address'] != null ? Address.fromJson(json['address']) : null,
        email = json['email'] ?? '',
        name = json['name'] ?? '',
        phone = json['phone'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'email': email,
      'name': name,
      'phone': phone,
    };
    data['address'] = address?.toJson();
    return data;
  }
}

class Address {
  String city;
  String country;
  String line1;
  String? line2;
  String postalCode;
  String state;

  Address({
    this.city = '',
    this.country = '',
    this.line1 = '',
    this.line2,
    this.postalCode = '',
    this.state = '',
  });

  Address.fromJson(Map<String, dynamic> json)
      : city = json['city'] ?? '',
        country = json['country'] ?? '',
        line1 = json['line1'] ?? '',
        line2 = json['line2'],
        postalCode = json['postal_code'] ?? '',
        state = json['state'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'city': city,
      'country': country,
      'line1': line1,
      'postal_code': postalCode,
      'state': state,
    };
    if (line2 != null) {
      data['line2'] = line2;
    }
    return data;
  }
}

class Card {
  String brand;
  Checks? checks;
  String country;
  int expMonth;
  int expYear;
  String funding;
  String last4;
  Networks? networks;
  ThreeDSecureUsage? threeDSecureUsage;
  var wallet;

  Card({
    this.brand = '',
    this.checks,
    this.country = '',
    this.expMonth = 0,
    this.expYear = 0,
    this.funding = '',
    this.last4 = '',
    this.networks,
    this.threeDSecureUsage,
    this.wallet,
  });

  Card.fromJson(Map<String, dynamic> json)
      : brand = json['brand'] ?? '',
        checks = json['checks'] != null ? Checks.fromJson(json['checks']) : null,
        country = json['country'] ?? '',
        expMonth = json['exp_month'] ?? 0,
        expYear = json['exp_year'] ?? 0,
        funding = json['funding'] ?? '',
        last4 = json['last4'] ?? '',
        networks = json['networks'] != null ? Networks.fromJson(json['networks']) : null,
        threeDSecureUsage = json['three_d_secure_usage'] != null
            ? ThreeDSecureUsage.fromJson(json['three_d_secure_usage'])
            : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'brand': brand,
      'country': country,
      'exp_month': expMonth,
      'exp_year': expYear,
      'funding': funding,
      'last4': last4,
    };
    data['checks'] = checks?.toJson();
    data['networks'] = networks?.toJson();
    data['three_d_secure_usage'] = threeDSecureUsage?.toJson();
    return data;
  }
}

class Checks {
  String addressLine1Check;
  String addressPostalCodeCheck;
  String cvcCheck;

  Checks({
    this.addressLine1Check = '',
    this.addressPostalCodeCheck = '',
    this.cvcCheck = '',
  });

  Checks.fromJson(Map<String, dynamic> json)
      : addressLine1Check = json['address_line1_check'] ?? '',
        addressPostalCodeCheck = json['address_postal_code_check'] ?? '',
        cvcCheck = json['cvc_check'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'address_line1_check': addressLine1Check,
      'address_postal_code_check': addressPostalCodeCheck,
      'cvc_check': cvcCheck,
    };
  }
}

class Networks {
  List<String> available;
  String? preferred;

  Networks({
    List<String>? available,
    this.preferred,
  }) : available = available ?? [];

  Networks.fromJson(Map<String, dynamic> json)
      : available = List<String>.from(json['available'] ?? []),
        preferred = json['preferred'];

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'preferred': preferred,
    };
  }
}

class ThreeDSecureUsage {
  bool supported;

  ThreeDSecureUsage({
    this.supported = false,
  });

  ThreeDSecureUsage.fromJson(Map<String, dynamic> json)
      : supported = json['supported'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'supported': supported,
    };
  }
}
