import 'dart:developer';

import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/delivery_person_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/services/location_service.dart';
import 'package:on_demand_grocery_store/src/services/messaging_service.dart';

class DeliveryPersonController extends GetxController {
  static DeliveryPersonController get instance => Get.find();

  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());

  var isLoadingNearby = false.obs;

  var allNearbydeliveryPersonsId = <String>[].obs;

  addNearbyDeliveryPerson(String id) {
    allNearbydeliveryPersonsId.addIf(
        !allNearbydeliveryPersonsId.contains(id), id);
  }

  removeNearbyDeliveryPerson(String id) {
    int index =
        allNearbydeliveryPersonsId.indexWhere((nearbyId) => nearbyId == id);
    allNearbydeliveryPersonsId.removeAt(index);
  }
}
