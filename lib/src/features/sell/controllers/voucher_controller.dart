import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/category_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/voucher_model.dart';
import 'package:on_demand_grocery_store/src/repositories/category_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/voucher_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class VoucherController extends GetxController {
  static VoucherController get instance => Get.find();

  var toggleRefresh = false.obs;

  var isLoading = false.obs;
  var listOfVoucher = <VoucherModel>[].obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().add(const Duration(days: 30)).obs;
  TextEditingController minAmountController = TextEditingController();
  TextEditingController discountValueController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  GlobalKey<FormState> addVoucherFormKey = GlobalKey<FormState>();

  var selectedType = 'Flat'.obs;

  final voucherRepository = Get.put(VoucherRepository());

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    minAmountController.dispose();
    discountValueController.dispose();
    quantityController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    fetchAllVouchers();
    super.onInit();
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 30));
    minAmountController.clear();
    discountValueController.clear();
    selectedType.value = 'Flat';
  }

  Future<List<VoucherModel>> fetchAllVouchers() async {
    try {
      final vouchers = await voucherRepository.getAllVoucher();
      vouchers.sort((VoucherModel a, VoucherModel b) =>
          (a.endDate.millisecondsSinceEpoch -
                  DateTime.now().millisecondsSinceEpoch)
              .compareTo(b.endDate.millisecondsSinceEpoch -
                  DateTime.now().millisecondsSinceEpoch));
      return vouchers;
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      return [];
    }
  }

  Future<void> addVoucher() async {
    try {
      print('Vao day them voucher');
      HAppUtils.loadingOverlays();

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }
      print('kiem tra xong mang');

      if (!addVoucherFormKey.currentState!.validate()) {
        HAppUtils.stopLoading();
        HAppUtils.showSnackBarWarning(
            'Cảnh báo', 'Bạn chưa điền đầy đủ voucher');
        return;
      }
      print('kiem tra xong validate');

      final voucher = VoucherModel(
          id: '',
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          type: selectedType.value,
          startDate: startDate.value,
          endDate: endDate.value,
          minAmount: minAmountController.text.isNotEmpty
              ? int.parse(minAmountController.text.trim())
              : 0,
          discountValue: int.parse(discountValueController.text.trim()),
          usedById: [],
          isActive: true,
          quantity: quantityController.text.isNotEmpty
              ? int.parse(quantityController.text.trim())
              : null,
          storeId: StoreController.instance.user.value.id);
      print(voucher.toString());

      final id = await voucherRepository.addAndFindIdForNewVoucher(voucher);
      voucher.id = id;

      toggleRefresh.toggle();
      resetForm();

      HAppUtils.stopLoading();
      HAppUtils.showSnackBarSuccess(
          'Thành công', 'Bạn đã thêm voucher giao hàng mới thành công');

      Navigator.of(Get.overlayContext!).pop();
    } catch (e) {
      HAppUtils.stopLoading();
      print(e.toString());
      HAppUtils.showSnackBarError('Lỗi', 'Thêm voucher mới không thành công');
    }
  }
}
