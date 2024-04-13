import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/voucher_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class VoucherRepository extends GetxController {
  static VoucherRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<VoucherModel>> getAllVoucher() async {
    try {
      final storeId = AuthenticationRepository.instance.authUser!.uid;
      if (storeId.isEmpty) throw 'Không có thông tin người dùng';

      final vouchers = await _db
          .collection('Vouchers')
          .where('StoreId', isEqualTo: storeId)
          .get();
      return vouchers.docs
          .map((snapshot) => VoucherModel.fromDocumentSnapshot(snapshot))
          .toList();
    } catch (e) {
      HAppUtils.showSnackBarError("Lỗi", e.toString());
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<String> addAndFindIdForNewVoucher(VoucherModel voucher) async {
    try {
      final currentVoucher =
          await _db.collection('Vouchers').add(voucher.toJson());
      return currentVoucher.id;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
