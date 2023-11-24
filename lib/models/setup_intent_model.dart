class SetupIntentModel {
  SetupIntent? setupIntent;

  SetupIntentModel({this.setupIntent});

  factory SetupIntentModel.fromJson(Map<String, dynamic> json) {
    return SetupIntentModel(
      setupIntent: json['setupIntent'] != null ? SetupIntent.fromJson(json['setupIntent']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (setupIntent != null) {
      data['setupIntent'] = setupIntent!.toJson();
    }
    return data;
  }
}

class SetupIntent {
  String? id;
  String? object;
  String? clientSecret;
  int? created;
  String? customer;
  String? latestAttempt;
  bool? livemode;
  String? paymentMethod;
  List<String>? paymentMethodTypes;
  String? status;
  String? usage;

  SetupIntent({
    this.id,
    this.object,
    this.clientSecret,
    this.created,
    this.customer,
    this.latestAttempt,
    this.livemode,
    this.paymentMethod,
    this.paymentMethodTypes,
    this.status,
    this.usage,
  });

  factory SetupIntent.fromJson(Map<String, dynamic> json) {
    return SetupIntent(
      id: json['id'] as String?,
      object: json['object'] as String?,
      clientSecret: json['client_secret'] as String?,
      created: json['created'] as int?,
      customer: json['customer'] as String?,
      latestAttempt: json['latest_attempt'] as String?,
      livemode: json['livemode'] as bool?,
      paymentMethod: json['payment_method'] as String?,
      paymentMethodTypes: (json['payment_method_types'] as List<dynamic>?)?.cast<String>(),
      status: json['status'] as String?,
      usage: json['usage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'client_secret': clientSecret,
      'created': created,
      'customer': customer,
      'latest_attempt': latestAttempt,
      'livemode': livemode,
      'payment_method': paymentMethod,
      'payment_method_types': paymentMethodTypes,
      'status': status,
      'usage': usage,
    };
  }
}
