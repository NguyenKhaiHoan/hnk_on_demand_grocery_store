import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:on_demand_grocery_store/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/user_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<UserModel> getUserInformation(String userId) async {
    try {
      final documentSnapshot = await _db.collection('Users').doc(userId).get();
      if (documentSnapshot.exists) {
        return UserModel.fromDocumentSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _db.collection('Users').doc(user.id).update(user.toJon());
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> updateSingleField(
      String userId, Map<String, dynamic> json) async {
    try {
      await _db.collection('Users').doc(userId).update(json);
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
