import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/address_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<AddressModel>> getStoreAddress() async {
    try {
      final storeId = AuthenticationRepository.instance.authUser!.uid;
      if (storeId.isEmpty) throw 'Không có thông tin người dùng';
      final addresses = await _db
          .collection('Stores')
          .doc(storeId)
          .collection('Addresses')
          .get();

      return addresses.docs
          .map((snapshot) => AddressModel.fromDocumentSnapshot(snapshot))
          .toList();
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateAddressField(
      String addressId, Map<String, dynamic> json) async {
    try {
      final storeId = AuthenticationRepository.instance.authUser!.uid;
      await _db
          .collection('Stores')
          .doc(storeId)
          .collection('Addresses')
          .doc(addressId)
          .update(json);
    } catch (e) {
      throw 'Đã xảy ra sự cố. Không thể cập nhật lựa chọn địa chỉ của bạn. Vui lòng thử lại sau.';
    }
  }

  Future<String> addAndFindIdForNewAddress(AddressModel address) async {
    try {
      final storeId = AuthenticationRepository.instance.authUser?.uid;
      final currentAddress = await _db
          .collection('Stores')
          .doc(storeId)
          .collection('Addresses')
          .add(address.toJson());
      return currentAddress.id;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
