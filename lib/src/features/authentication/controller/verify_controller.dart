import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class VerifyController extends GetxController {
  static VerifyController get instance => Get.find();

  @override
  void onInit() {
    sendEmailVerification();
    setTimeAutoRedirectCompleteCreateAccountScreen();
    super.onInit();
  }

  sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }

  void setTimeAutoRedirectCompleteCreateAccountScreen() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await FirebaseAuth.instance.currentUser!.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        AuthenticationRepository.instance.screenRedirect();
      }
    });
  }

  checkEmailVerification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      AuthenticationRepository.instance.screenRedirect();
    }
  }
}
