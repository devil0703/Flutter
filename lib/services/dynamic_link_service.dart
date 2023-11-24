import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/services/dialog_service.dart';

class DynamicLinkService {
  Future handleDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleDeepLink(dynamicLinkData);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final dialogService = Get.find<DialogService>();
    final userController = Get.find<UserController>();
    final Uri deepLink = data.link;
    print('_handleDeepLink | deeplink: $deepLink');

    var isVoucher = deepLink.pathSegments.contains('voucher');
    if (isVoucher) {}
    // if (scanCode) {
    //   var issuedByAccountId = deepLink.queryParameters['issuedByAccountId'];
    //   var displayMessage = deepLink.queryParameters['displayMessage'];
    //   if (issuedByAccountId != null && displayMessage != null) {
    //     await addVoucher(issuedByAccountId, displayMessage, data.link.toString());
    //     Get.to(()=> MyVouchers());
    //   }
    // }

    print('Link handled');
    }
}
