import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/services/firebase_storage_service.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<ProductModel>> getAllProducts() async {
    try {
      print('vào product');
      final user = AuthenticationRepository.instance.authUser!;
      print('lấy id: ${user.uid}');
      final snapshot = await _db
          .collection('Products')
          .where('StoreId', isEqualTo: user.uid)
          .orderBy('UploadTime', descending: true)
          .limit(10)
          .get();
      final list = snapshot.docs
          .map((document) => ProductModel.fromDocumentSnapshot(document))
          .toList();
      print('lấy được list ${list.length}');
      return list;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      print(e.toString());
      throw e.toString();
    }
  }

  Future<void> uploadDummyData(List<ProductModel> products) async {
    try {
      final storage = Get.put(FirebaseStorageService());
      for (var product in products) {
        final image = await storage.getImageData(product.image);
        final url = await storage.uploadImageData(
            'Products/Images', image, product.image.toString());
        product.image = url;
        await _db.collection('Products').add(product.toJson());
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    }
  }
}
