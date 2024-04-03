import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/address_model.dart';
import 'package:on_demand_grocery_store/src/repositories/address_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/services/location_service.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class RegistrationController extends GetxController {
  static RegistrationController get instance => Get.find();

  GlobalKey<FormState> addAddressFormKey = GlobalKey<FormState>();
  final streetController = TextEditingController();
  var city = ''.obs;
  var district = ''.obs;
  var ward = ''.obs;
  final addressRepository = Get.put(AddressRepository());
  final addressController = Get.put(AddressController());
  final storeController = Get.put(StoreController());
  var isChoseCurrentPosition = false.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  Future<void> getCurrentPosition() async {
    if (isChoseCurrentPosition.value) {
      HAppUtils.loadingOverlaysAddress();
      final currentPosition = await HLocationService.getGeoLocationPosition();
      latitude.value = currentPosition.latitude;
      longitude.value = currentPosition.longitude;
      print('vị trí hiện tại: ${latitude.value}, ${longitude.value}');
      HAppUtils.stopLoading();
    }
  }

  Future<void> saveInfo() async {
    try {
      print('vào nhập địa chỉ');
      HAppUtils.loadingOverlays();
      print('vị trí hiện tại: ${latitude.value}, ${longitude.value}');

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }
      print('kiểm tra mạng');

      if (storeController.user.value.storeImage == '' ||
          storeController.user.value.storeImageBackground == '') {
        HAppUtils.stopLoading();
        HAppUtils.showSnackBarWarning('Chọn ảnh',
            'Bạn chưa chọn đầy đủ ảnh. Hãy chọn đầy đủ ảnh đại diện và ảnh nền cho cửa hàng.');
        return;
      }
      print('kiểm tra up ảnh');

      if (!addAddressFormKey.currentState!.validate() ||
          city.value == '' ||
          district.value == '' ||
          ward.value == '') {
        HAppUtils.stopLoading();
        HAppUtils.showSnackBarWarning('Chọn địa chỉ',
            'Bạn chưa điền đầy đủ địa chỉ. Hãy chọn đầy đủ Thành phố, Quận/Huyện, Phường/Xã và Số nhà, đường, ngõ.');
        return;
      }
      print('kiểm tra địa chỉ');

      final address = AddressModel(
        id: '',
        city: city.value,
        district: district.value,
        ward: ward.value,
        street: streetController.text.trim(),
        latitude: latitude.value,
        longitude: longitude.value,
      );

      final id = await addressRepository.addAndFindIdForNewAddress(address);
      address.id = id;

      addressController.currentAddress.value = address;
      StoreRepository.instance.updateSingleField({'Address': address.toJson()});
      resetFormAddAddress();

      Navigator.of(Get.context!).pop();
      Get.back();
    } catch (e) {
      HAppUtils.stopLoading();
      HAppUtils.showSnackBarError('Lỗi', 'Thêm địa chỉ không thành công');
    }
  }

  void resetFormAddAddress() {
    streetController.clear();
    city.value = '';
    district.value = '';
    ward.value = '';
    longitude.value = 0;
    latitude.value = 0;
    addAddressFormKey.currentState?.reset();
  }
}
