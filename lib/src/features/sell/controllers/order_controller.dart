import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/delivery_person_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/category_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_in_cart_model.dart';
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

  var isFirstTimeRequest = true.obs;

  var allAccept = false.obs;
  var allReject = false.obs;

  final deliveryPersonController = Get.put(DeliveryPersonController());
  final deliveryPersonRepository = Get.put(DeliveryPersonRepository());

  final orderRepository = Get.put(OrderRepository());

  void sendNotificationToDeliveryPerson(OrderModel order) async {
    try {
      checkAllAccept(order);
      if (allAccept.value) {
        Future.forEach([1, 2, 3], (element) async {
          await HLocationService.getNearbyDeliveryPersons(element * 3);
          Future.delayed(Duration(seconds: element * 5)).then((value) async {
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
          if (deliveryPersonController.allNearbydeliveryPersonsId.isEmpty &&
              element == 3) {
            updateOrder(order: order, status: 'Từ chối', activeStep: 1);
            removeOrder(order.oderId);
          }
        });
        allAccept.value = false;
      }
    } catch (e) {
      log(e.toString());
      HAppUtils.showSnackBarError(
          "Lỗi", "Đã xảy ra lỗi trong quá trình tìm người giao hàng");
    }
  }

  checkAllAccept(OrderModel order) async {
    allAccept.value = true;
    if (order == OrderModel.empty()) {
      allAccept.value = false;
      // isFirstTimeRequest.value = false;
      return;
    }
    for (var storeOrder in order.storeOrders) {
      if (storeOrder.acceptByStore != 1) {
        allAccept.value = false;
        // isFirstTimeRequest.value = false;
        return;
      }
    }
    var ref = FirebaseDatabase.instance.ref("Orders/${order.oderId}");
    await ref.update({
      "OrderStatus": HAppUtils.orderStatus(1),
    });
    order.orderStatus = HAppUtils.orderStatus(1);
    // isFirstTimeRequest.value = true;
  }

  checkAllReject(OrderModel order) async {
    allReject.value = true;
    if (order == OrderModel.empty()) {
      allReject.value = false;
      return;
    }
    for (var storeOrder in order.storeOrders) {
      if (storeOrder.acceptByStore != -1) {
        allReject.value = false;
        return;
      }
    }
  }

  void sendNotificationToUser(OrderModel order) async {
    try {
      checkAllReject(order);
      if (allReject.value) {
        HNotificationService.sendNotificationToUserByAllReject(order);
        updateOrder(order: order, status: 'Từ chối', activeStep: 0);
        removeOrder(order.oderId);
      } else {
        Future.forEach(order.storeOrders, (element) {
          if (element.acceptByStore != -1) {
            int index = order.storeOrders
                .indexWhere((store) => store.storeId == element.storeId);
            HNotificationService.sendNotificationToUserByOneReject(
                order, element);
            order.orderProducts
                .removeWhere((product) => product.storeId == element.storeId);
            FirebaseDatabase.instance
                .ref()
                .child('Orders/${order.oderId}/StoreOrders/$index')
                .remove();
            FirebaseDatabase.instance
                .ref()
                .child('Orders/${order.oderId}')
                .update({'OrderProducts': order.orderProducts});
          }
        });
      }
    } catch (e) {
      log(e.toString());
      HAppUtils.showSnackBarError(
          "Lỗi", "Đã xảy ra lỗi trong quá trình tìm người giao hàng");
    }
  }

  // removeOrder(
  //     {required OrderModel order,
  //     required String status,
  //     required int activeStep}) {
  //   order.activeStep = activeStep;
  //   FirebaseDatabase.instance
  //       .ref()
  //       .child('Orders/${order.oderId}')
  //       .update({'ActiveStep': order.activeStep, 'OrderStatus': status});
  //   FirebaseDatabase.instance.ref().child('Orders/${order.oderId}').remove();
  //   allReject.value = false;
  //   allAccept.value = false;
  //   isFirstTimeRequest.value = false;
  // }

  updateOrder({required OrderModel order, String? status, int? activeStep}) {
    if (status != null && activeStep != null) {
      order.activeStep = activeStep;
      FirebaseDatabase.instance
          .ref()
          .child('Orders/${order.oderId}')
          .update({'ActiveStep': order.activeStep, 'OrderStatus': status});
    }
  }

  removeOrder(String orderId) {
    FirebaseDatabase.instance.ref().child('Orders/$orderId').remove();
    FirebaseDatabase.instance.ref().child('Charts/$orderId').remove();
    allReject.value = false;
    allAccept.value = false;
    // isFirstTimeRequest.value = true;
  }
}
