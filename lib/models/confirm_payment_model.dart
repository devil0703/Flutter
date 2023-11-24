// To parse this JSON data, do
//
//     final welcome = ConfirmPaymentModel.fromJson(jsonString);

class ConfirmPaymentModel {
  ConfirmPaymentModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final Data data;

  factory ConfirmPaymentModel.fromJson(Map<String, dynamic> json) => ConfirmPaymentModel(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.id,
    required this.object,
    required this.amount,
    required this.amountCapturable,
    required this.amountDetails,
    required this.amountReceived,
    this.application,
    this.applicationFeeAmount,
    this.automaticPaymentMethods,
    this.canceledAt,
    this.cancellationReason,
    required this.captureMethod,
    required this.charges,
    required this.clientSecret,
    required this.confirmationMethod,
    required this.created,
    required this.currency,
    this.customer,
    this.description,
    this.invoice,
    this.lastPaymentError,
    required this.livemode,
    required this.metadata,
    this.nextAction,
    this.onBehalfOf,
    this.paymentMethod,
    required this.paymentMethodOptions,
    required this.paymentMethodTypes,
    this.processing,
    this.receiptEmail,
    this.review,
    this.setupFutureUsage,
    this.shipping,
    this.statementDescriptor,
    this.statementDescriptorSuffix,
    required this.status,
    this.transferData,
    this.transferGroup,
  });

  final String id;
  final String object;
  final int amount;
  final int amountCapturable;
  final AmountDetails amountDetails;
  final int amountReceived;
  final dynamic application;
  final dynamic applicationFeeAmount;
  final dynamic automaticPaymentMethods;
  final dynamic canceledAt;
  final dynamic cancellationReason;
  final String captureMethod;
  final Charges charges;
  final String clientSecret;
  final String confirmationMethod;
  final int created;
  final String currency;
  final dynamic customer;
  final dynamic description;
  final dynamic invoice;
  final dynamic lastPaymentError;
  final bool livemode;
  final Metadata metadata;
  final dynamic nextAction;
  final dynamic onBehalfOf;
  final dynamic paymentMethod;
  final PaymentMethodOptions paymentMethodOptions;
  final List<String> paymentMethodTypes;
  final dynamic processing;
  final dynamic receiptEmail;
  final dynamic review;
  final dynamic setupFutureUsage;
  final dynamic shipping;
  final dynamic statementDescriptor;
  final dynamic statementDescriptorSuffix;
  final String status;
  final dynamic transferData;
  final dynamic transferGroup;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        object: json["object"],
        amount: json["amount"],
        amountCapturable: json["amount_capturable"],
        amountDetails: AmountDetails.fromJson(json["amount_details"]),
        amountReceived: json["amount_received"],
        application: json["application"],
        applicationFeeAmount: json["application_fee_amount"],
        automaticPaymentMethods: json["automatic_payment_methods"],
        canceledAt: json["canceled_at"],
        cancellationReason: json["cancellation_reason"],
        captureMethod: json["capture_method"],
        charges: Charges.fromJson(json["charges"]),
        clientSecret: json["client_secret"],
        confirmationMethod: json["confirmation_method"],
        created: json["created"],
        currency: json["currency"],
        customer: json["customer"],
        description: json["description"],
        invoice: json["invoice"],
        lastPaymentError: json["last_payment_error"],
        livemode: json["livemode"],
        metadata: Metadata.fromJson(json["metadata"]),
        nextAction: json["next_action"],
        onBehalfOf: json["on_behalf_of"],
        paymentMethod: json["payment_method"],
        paymentMethodOptions: PaymentMethodOptions.fromJson(json["payment_method_options"]),
        paymentMethodTypes: List<String>.from(json["payment_method_types"].map((x) => x)),
        processing: json["processing"],
        receiptEmail: json["receipt_email"],
        review: json["review"],
        setupFutureUsage: json["setup_future_usage"],
        shipping: json["shipping"],
        statementDescriptor: json["statement_descriptor"],
        statementDescriptorSuffix: json["statement_descriptor_suffix"],
        status: json["status"],
        transferData: json["transfer_data"],
        transferGroup: json["transfer_group"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "amount": amount,
        "amount_capturable": amountCapturable,
        "amount_details": amountDetails.toJson(),
        "amount_received": amountReceived,
        "application": application,
        "application_fee_amount": applicationFeeAmount,
        "automatic_payment_methods": automaticPaymentMethods,
        "canceled_at": canceledAt,
        "cancellation_reason": cancellationReason,
        "capture_method": captureMethod,
        "charges": charges.toJson(),
        "client_secret": clientSecret,
        "confirmation_method": confirmationMethod,
        "created": created,
        "currency": currency,
        "customer": customer,
        "description": description,
        "invoice": invoice,
        "last_payment_error": lastPaymentError,
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "next_action": nextAction,
        "on_behalf_of": onBehalfOf,
        "payment_method": paymentMethod,
        "payment_method_options": paymentMethodOptions.toJson(),
        "payment_method_types": List<dynamic>.from(paymentMethodTypes.map((x) => x)),
        "processing": processing,
        "receipt_email": receiptEmail,
        "review": review,
        "setup_future_usage": setupFutureUsage,
        "shipping": shipping,
        "statement_descriptor": statementDescriptor,
        "statement_descriptor_suffix": statementDescriptorSuffix,
        "status": status,
        "transfer_data": transferData,
        "transfer_group": transferGroup,
      };
}

class AmountDetails {
  AmountDetails({
    required this.tip,
    required this.tax,
  });

  final int tip;
  final int tax;

  factory AmountDetails.fromJson(Map<String, dynamic> json) => AmountDetails(
        tip: json["tip"],
        tax: json["tax"],
      );

  Map<String, dynamic> toJson() => {
        "tip": tip,
        "tax": tax,
      };
}

class Charges {
  Charges({
    required this.object,
    required this.data,
    required this.hasMore,
    required this.totalCount,
    required this.url,
  });

  final String object;
  final List<dynamic> data;
  final bool hasMore;
  final int totalCount;
  final String url;

  factory Charges.fromJson(Map<String, dynamic> json) => Charges(
        object: json["object"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
        hasMore: json["has_more"],
        totalCount: json["total_count"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(data.map((x) => x)),
        "has_more": hasMore,
        "total_count": totalCount,
        "url": url,
      };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata();

  Map<String, dynamic> toJson() => {};
}

class PaymentMethodOptions {
  PaymentMethodOptions({
    required this.card,
  });

  final Card card;

  factory PaymentMethodOptions.fromJson(Map<String, dynamic> json) => PaymentMethodOptions(
        card: Card.fromJson(json["card"]),
      );

  Map<String, dynamic> toJson() => {
        "card": card.toJson(),
      };
}

class Card {
  Card({
    required this.requestThreeDSecure,
  });

  final String requestThreeDSecure;

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        requestThreeDSecure: json["request_three_d_secure"],
      );

  Map<String, dynamic> toJson() => {
        "request_three_d_secure": requestThreeDSecure,
      };
}
