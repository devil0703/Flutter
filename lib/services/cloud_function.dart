import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/utils/constants.dart';

final dialogService = Get.find<DialogService>();

cloudFunction({required String functionName, required Map parameters, required Function action}) async {
  dialogService.showLoading();
  try {
    HttpsCallable addVoucherCall = FirebaseFunctions.instance.httpsCallable(functionName);
    HttpsCallableResult results = await addVoucherCall(parameters);
    Get.back(); //closes loading dialog;
    action();
    print(results.data);
    if (results.data['success'] == false)
      showRedAlert(results.data['message']);
    else
      showGreenAlert(results.data['message']);
    return;
  } catch (e) {
    print(e);
    Get.back();
    showRedAlert('Something went wrong. Please try again');
    return false;
  }
}

Future<HttpsCallableResult?> cloudFunctionValueReturn({required String functionName, required Map parameters}) async {
  dialogService.showLoading();
  try {
    HttpsCallable addVoucherCall = FirebaseFunctions.instance.httpsCallable(functionName);
    HttpsCallableResult results = await addVoucherCall(parameters);
    Get.back(); //closes loading dialog;
    print(results.data);
    return results;
  } catch (e) {
    print(e);
    Get.back();
    showRedAlert('Something went wrong. Please try again');
    return null;
  }
}

Future<Map> callFunction(String url) async {
  var response = await http.get(Uri.parse(url));
  //Map data = json.decode(response.body);
  print('===========================================');
  print(url);
  printWrapped(response.body);
  print('===========================================');
  return json.decode(response.body);
}

printWrapped(String text) {
  final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

getMethod(String url, Map params) async {
  try {
    print('https://us-central1-makai-65aae.cloudfunctions.net/$url');
    Map<String, String> header = {"Content-Type": "application/json"};
    var response = await http.get(Uri.parse('https://us-central1-makai-65aae.cloudfunctions.net/$url'), headers: header);
    print(response.body);
    return response;
  } catch (e) {
    printWrapped(e as String);
  }
}

postMethod(String url, Map params) async {
  try {
    print('https://us-central1-makai-65aae.cloudfunctions.net/$url');
    Map<String, String> header = {"Content-Type": "application/json"};
    var response = await http.post(Uri.parse('https://us-central1-makai-65aae.cloudfunctions.net/$url'), body: json.encode(params), headers: header);
    print(response.body);
    return response;
  } catch (e) {
    printWrapped(e as String);
  }
}
