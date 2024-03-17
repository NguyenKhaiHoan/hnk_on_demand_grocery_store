import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/delivery_person_model.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';

class DeliveryPersonController extends GetxController {
  static DeliveryPersonController get instance => Get.find();

  var isLoadingNearby = false.obs;

  var allNearbyDeliveryPersons = <DeliveryPersonModel>[].obs;
  var allNearbydeliveryPersonIds = <String>[].obs;

  void addNearbyDeliveryPersons(String deliveryPersonId) async {
    isLoadingNearby.value = true;

    var deliveryPersonIdsSet = Set<String>.from(allNearbydeliveryPersonIds);

    if (!deliveryPersonIdsSet.contains(deliveryPersonId)) {
      final deliveryPerson = await DeliveryPersonRepository.instance
          .getDeliveryPersonInformation(deliveryPersonId);
      print(deliveryPersonId);
      allNearbyDeliveryPersons.addIf(
          !allNearbyDeliveryPersons.contains(deliveryPerson), deliveryPerson);
      allNearbydeliveryPersonIds.value =
          List<String>.from(deliveryPersonIdsSet);
    }

    isLoadingNearby.value = false;
  }

  void removeNearbyDeliveryPerson(String deliveryPersonId) {
    int index = allNearbyDeliveryPersons
        .indexWhere((element) => element.id == deliveryPersonId);
    if (index >= 0) {
      allNearbyDeliveryPersons.removeAt(index);
    }
  }
}
