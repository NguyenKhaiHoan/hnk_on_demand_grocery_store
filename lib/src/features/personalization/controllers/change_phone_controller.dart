import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class ChangePhoneController extends GetxController {
  static ChangePhoneController get instance => Get.find();

  final TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> changePhoneFormKey = GlobalKey<FormState>();
  final storeController = StoreController.instance;
  final storeRepository = Get.put(StoreRepository());
  var isLoading = false.obs;

  @override
  void onInit() {
    initPhoneField();
    super.onInit();
  }

  Future<void> initPhoneField() async {
    if (storeController.user.value.phoneNumber.isNotEmpty) {
      phoneController.text = storeController.user.value.phoneNumber;
    }
  }

  changePhone() async {
    try {
      isLoading.value = true;
      HAppUtils.loadingOverlays();

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }

      if (!changePhoneFormKey.currentState!.validate()) {
        HAppUtils.stopLoading();
        return;
      }

      var phoneNumber = {'PhoneNumber': phoneController.text.trim()};
      await storeRepository.updateSingleField(phoneNumber);

      storeController.user.value.phoneNumber = phoneController.text.trim();
      storeController.user.refresh();

      HAppUtils.stopLoading();
      HAppUtils.showSnackBarSuccess(
          'Thành công', 'Bạn đã thay đổi tên của cửa hàng thành công.');

      isLoading.value = false;
      resetFormChangeName();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      isLoading.value = false;
      HAppUtils.stopLoading();
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }

  void resetFormChangeName() {
    phoneController.clear();
    changePhoneFormKey.currentState?.reset();
  }
}
