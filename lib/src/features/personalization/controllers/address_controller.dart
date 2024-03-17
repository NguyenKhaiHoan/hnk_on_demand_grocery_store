import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/address_model.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/district_ward_model.dart';
import 'package:on_demand_grocery_store/src/repositories/address_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  var listDropdownButtonWard = <String>[].obs;

  final addressRepository = Get.put(AddressRepository());
  var currentAddress = AddressModel.empty().obs;

  var toggleRefresh = true.obs;


  List<DistrictModel> hanoiData = <DistrictModel>[].obs;

  @override
  void onInit() {
    readHaNoiDataJson();
    super.onInit();
  }

  Future<void> readHaNoiDataJson() async {
    final String response =
        await rootBundle.loadString('assets/json/hanoi_data.json');
    final data = await json.decode(response);

    var list = data['data'] as List<dynamic>;
    hanoiData = list.map((e) => DistrictModel.fromJson(e)).toList();
  }

  Future<List<AddressModel>> fetchStoreAddresses() async {
    try {
      final addresses = await addressRepository.getStoreAddress();
      currentAddress.value = addresses.first;
      return addresses;
    } catch (e) {
      HAppUtils.showSnackBarError('Không tìm thấy địa chỉ', e.toString());
      return Future.error('Lỗi không thể tải được địa chỉ từ hệ thống');
    }
  }
}
