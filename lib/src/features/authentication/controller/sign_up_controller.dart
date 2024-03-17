import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/store_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/delivery_person_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  var isHide = true.obs;
  var isChoseCondition = true.obs;

  void signup() async {
    try {
      print('Vào đăng ký');
      HAppUtils.loadingOverlays();

      if (!signupFormKey.currentState!.validate()) {
        HAppUtils.stopLoading();
        return;
      }

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }

      if (!isChoseCondition.value) {
        HAppUtils.stopLoading();
        HAppUtils.showSnackBarWarning(
            'Chấp nhận Điều khoản và Chính Sách bảo mật',
            'Bạn cần đọc kỹ và chấp nhận Điều khoản dịch vụ và Chính sách bảo mật trước khi bắt đầu tạo tài khoản');
        return;
      }

      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              emailController.text.trim(), passController.text.trim());
      print('đã đăng ký');

      final newUser = StoreModel(
          id: userCredential.user!.uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          storeImage: '',
          storeImageBackground: '',
          description: descriptionController.text.trim(),
          creationDate: DateFormat('EEEE, d-M-y', 'vi').format(DateTime.now()),
          authenticationBy: 'Email',
          listOfCategoryId: [],
          rating: 5.0,
          import: false,
          isFamous: false,
          productCount: 0,
          cloudMessagingToken: '');

      final storeRepository = Get.put(StoreRepository());
      await storeRepository.saveStoreRecord(newUser);

      print('đã lưu');

      HAppUtils.stopLoading();

      HAppUtils.showSnackBarSuccess('Thành công!',
          'Tài khoản của bạn đã được tạo, hãy xác thực email để tiếp tục.');
      Get.toNamed(HAppRoutes.verify,
          arguments: {'email': emailController.text.trim()});
    } catch (e) {
      HAppUtils.stopLoading();
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }
}
