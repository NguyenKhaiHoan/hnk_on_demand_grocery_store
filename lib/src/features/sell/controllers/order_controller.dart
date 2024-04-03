import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/delivery_person_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/category_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/store_note_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/category_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/order_repository.dart';
import 'package:on_demand_grocery_store/src/services/location_service.dart';
import 'package:on_demand_grocery_store/src/services/messaging_service.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  var acceptOrder = 0.obs;

  var allAccept = false.obs;

  final deliveryPersonController = Get.put(DeliveryPersonController());
  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());

  final orderRepository = Get.put(OrderRepository());

  // void sendNotificationToDeliveryPerson(String orderId) async {
  //   bool allAccept = true;
  //   await HLocationService.getNearbyDeliveryPersons();
  //   orderRepository.getOrderRealtime(orderId).then((value) {
  //     if (value == OrderModel.empty()) {
  //       HAppUtils.showSnackBarWarning("Cảnh báo", "Đơn hàng không tồn tại");
  //       return;
  //     }
  //     log(value.toString());
  //     for (var storeOrder in value.storeOrders) {
  //       if (storeOrder.acceptByStore != 1) {
  //         allAccept = false;
  //         break;
  //       }
  //     }
  //     log(allAccept.toString());

  //     if (allAccept) {
  //       final listDeliveryPerson =
  //           deliveryPersonController.allNearbyDeliveryPersons;
  //       log('độ dài của mảng: ${listDeliveryPerson.length}');
  //       for (var deliveryPerson in listDeliveryPerson) {
  //         log('Chuẩn bị vào gửi tb: ${deliveryPerson.id}');
  //         HNotificationService.sendNotificationToNearbyDeliveryPersons(
  //             deliveryPerson, value);
  //       }
  //     }
  //   }).timeout(
  //     const Duration(seconds: 60),
  //     onTimeout: () {
  //       HAppUtils.showSnackBarWarning("Cảnh báo",
  //           "Có vẻ đã xảy ra sự cố trong quá trình tải dữ liệu đơn hàng");
  //       return Future.error('Cảnh báo');
  //     },
  //   ).onError((error, stackTrace) {
  //     HAppUtils.showSnackBarError("Lỗi",
  //         "Đã xảy ra lỗi trong quá trình tải đơn hàng: ${error.toString()}");
  //     return Future.error(error.toString());
  //   });
  // }

  // var isLoadingNotification = true.obs;

  void sendNotificationToDeliveryPerson(OrderModel order) async {
    try {
      checkAllAccept(order);
      if (allAccept.value) {
        print(allAccept.value);
        await HLocationService.getNearbyDeliveryPersons();
        Future.delayed(const Duration(seconds: 5)).then((value) async {
          final listDeliveryPersonId =
              deliveryPersonController.allNearbydeliveryPersonsId;
          log('độ dài của mảng: ${listDeliveryPersonId.length}');
          for (var deliveryPersonId in listDeliveryPersonId) {
            final deliveryPersonData = await deliveryPersonRepository
                .getDeliveryPersonInformation(deliveryPersonId);
            log('Chuẩn bị vào gửi tb: $deliveryPersonId');
            HNotificationService.sendNotificationToNearbyDeliveryPersons(
                deliveryPersonData, order);
          }
        });
      }
      // await HLocationService.getNearbyDeliveryPersons();
      // Future.delayed(const Duration(seconds: 5)).then((value) async {
      //   print('Vào');
      //   final listDeliveryPersonId =
      //       deliveryPersonController.allNearbydeliveryPersonsId;
      //   print('độ dài của mảng: ${listDeliveryPersonId.length}');
      //   for (var deliveryPersonId in listDeliveryPersonId) {
      //     final deliveryPersonData = await deliveryPersonRepository
      //         .getDeliveryPersonInformation(deliveryPersonId);
      //     print('Chuẩn bị vào gửi tb: $deliveryPersonId');
      //     HNotificationService.sendNotificationToNearbyDeliveryPersons(
      //         deliveryPersonData, orderData);
      //   }
      // });
    } catch (e) {
      log(e.toString());
      HAppUtils.showSnackBarError(
          "Lỗi", "Đã xảy ra lỗi trong quá trình tìm người giao hàng");
    }
  }

  checkAllAccept(OrderModel order) async {
    allAccept.value = true;
    if (order == OrderModel.empty()) {
      return false;
    }
    for (var storeOrder in order.storeOrders) {
      if (storeOrder.acceptByStore != 1) {
        allAccept.value = false;
        return;
      }
    }
    var ref = FirebaseDatabase.instance.ref("Orders/${order.oderId}");
    await ref.update({
      "OrderStatus": HAppUtils.orderStatus(1),
    });
    order.orderStatus = HAppUtils.orderStatus(1);
  }
}
