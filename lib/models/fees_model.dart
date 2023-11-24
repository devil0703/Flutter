class FeesModel {
  Fees? fees;

  FeesModel({this.fees});

  FeesModel.fromJson(Map<String, dynamic> json) {
    fees = json['fees'] != null ? Fees.fromJson(json['fees']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (fees != null) {
      data['fees'] = fees!.toJson();
    }
    return data;
  }
}

class Fees {
  List<Types>? types;
  List<Summary>? summary;
  Total? total;

  Fees({this.types, this.summary, this.total});

  Fees.fromJson(Map<String, dynamic> json) {
    if (json['types'] != null) {
      types = (json['types'] as List).map((v) => Types.fromJson(v)).toList();
    }
    if (json['summary'] != null) {
      summary = (json['summary'] as List).map((v) => Summary.fromJson(v)).toList();
    }
    total = json['total'] != null ? Total.fromJson(json['total']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (types != null) {
      data['types'] = types!.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      data['summary'] = summary!.map((v) => v.toJson()).toList();
    }
    if (total != null) {
      data['total'] = total!.toJson();
    }
    return data;
  }
}

class Types {
  String? feeID;
  int? amount;
  String? type;
  bool? status;
  String? name;
  String? category;

  Types({this.feeID, this.amount, this.type, this.status, this.name, this.category});

  Types.fromJson(Map<String, dynamic> json) {
    feeID = json['feeID'];
    amount = json['amount'];
    type = json['type'];
    status = json['status'];
    name = json['name'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['feeID'] = feeID;
    data['amount'] = amount;
    data['type'] = type;
    data['status'] = status;
    data['name'] = name;
    data['category'] = category;
    return data;
  }
}

class Summary {
  String? name;
  String? total;

  Summary({this.name, this.total});

  Summary.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['total'] = total;
    return data;
  }
}

class Total {
  String? feesTotal;
  String? finalTotal;

  Total({this.feesTotal, this.finalTotal});

  Total.fromJson(Map<String, dynamic> json) {
    feesTotal = json['feesTotal'];
    finalTotal = json['finalTotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['feesTotal'] = feesTotal;
    data['finalTotal'] = finalTotal;
    return data;
  }
}
