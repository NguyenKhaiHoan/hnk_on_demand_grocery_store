import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class ChangeNameController extends GetxController {
  static ChangeNameController get instance => Get.find();

  final TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> changeNameFormKey = GlobalKey<FormState>();
  final storeController = StoreController.instance;
  final storeRepository = Get.put(StoreRepository());
  var isLoading = false.obs;

  @override
  void onInit() {
    initNameField();
    super.onInit();
  }

  Future<void> initNameField() async {
    nameController.text = storeController.user.value.name;
  }

  changeName() async {
    try {
      isLoading.value = true;
      HAppUtils.loadingOverlays();

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }

      if (!changeNameFormKey.currentState!.validate()) {
        HAppUtils.stopLoading();
        return;
      }

      var name = {'Name': nameController.text.trim()};
      await storeRepository.updateSingleField(name);

      storeController.user.value.name = nameController.text.trim();
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
    nameController.clear();
    changeNameFormKey.currentState?.reset();
  }
}
