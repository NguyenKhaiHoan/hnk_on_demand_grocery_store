import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/category_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  final _dbRealtime = FirebaseDatabase.instance;

  Future<OrderModel> getOrderRealtime(String orderId) async {
    try {
      log('Đã vào get');
      final snapshot = await _dbRealtime.ref().child('Orders/$orderId').get();
      // log(snapshot.value.toString());
      if (snapshot.value is String) {
        return OrderModel.fromJson(
            jsonEncode(jsonDecode(snapshot.value as String))
                as Map<String, dynamic>);
      }
      return OrderModel.empty();
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  final _dbFireStore = FirebaseFirestore.instance;

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _dbFireStore.collection('Orders').get();
      final list = snapshot.docs
          .map((document) => OrderModel.fromDocumentSnapshot(document))
          .toList();

      return list;
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }
}
