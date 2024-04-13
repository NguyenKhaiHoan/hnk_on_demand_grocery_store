import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/chat_model.dart';

class ChatRepository extends GetxController {
  static ChatRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<ChatModel>> getAllChats(String storeId) async {
    try {
      final snapshot = await _db
          .collection('Chats')
          .where('StoreId', isEqualTo: storeId)
          .get();
      final list = snapshot.docs
          .map((document) => ChatModel.fromDocumentSnapshot(document))
          .toList();
      return list;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
