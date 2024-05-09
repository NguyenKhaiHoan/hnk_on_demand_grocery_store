import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/repositories/product_repository.dart';
import 'package:on_demand_grocery_store/src/services/messaging_service.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final productRepository = Get.put(ProductRepository());

  var listOfProduct = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchAllProducts();
    super.onInit();
  }

  void fetchAllProducts() async {
    try {
      isLoading.value = true;
      final products = await productRepository.getAllProducts();
      listOfProduct.assignAll(products);
    } catch (e) {
      isLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  var status = 'Còn hàng'.obs;
  var refreshData = false.obs;

  Future<List<ProductModel>> fetchProductsWithStatus(String status) async {
    try {
      final products = await productRepository.getProductsWithStatus(status);
      return products;
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      return [];
    }
  }

  Future<bool> checkStatus(bool status, String productId) async {
    try {
      if (status) {
        await productRepository
            .updateStatusProduct(productId, {'Status': 'Tạm hết hàng'});
        print('Tạm hết hàng');
      } else {
        await productRepository
            .updateStatusProduct(productId, {'Status': 'Còn hàng'});
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child('RegisteredProducts/$productId');
        DatabaseEvent event = await ref.once();
        if (event.snapshot.value != null) {
          Map<String, dynamic> data =
              jsonDecode(jsonEncode(event.snapshot.value));

          List<String> tokens = [];
          List<String> userIds = [];
          data.forEach((key, value) {
            tokens.add(value.toString());
            userIds.add(key.toString());
          });
          await HNotificationService
              .sendNotificationToUserByProductRegistration(
                  tokens, productId, userIds);
          await ref.remove();
        } else {
          HAppUtils.showSnackBarError('Lỗi', 'Không có dữ liệu.');
        }
        print('Còn hàng');
      }
      refreshData.toggle();
      return true;
    } catch (e) {
      return false;
    }
  }
}
