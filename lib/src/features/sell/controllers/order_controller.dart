import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/category_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/category_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  void fetchOrders() async {
    try {
      var snapshot = await FirebaseDatabase.instance
          .ref()
          .child('Orders')
          .orderByChild('OrderStoreId')
          .equalTo(AuthenticationRepository.instance.authUser!.uid)
          .get();
      if (snapshot.value != null) {}
    } catch (e) {}
  }
}
