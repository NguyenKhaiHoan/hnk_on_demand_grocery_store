import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_key.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/store_model.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/user_address_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/delivery_person_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/store_note_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/user_model.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:http/http.dart' as http;
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class HNotificationService {
  static String? fcmToken;

  static final HNotificationService _instance =
      HNotificationService._internal();

  factory HNotificationService() => _instance;

  HNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final storeRepository = Get.put(StoreRepository());

  Future<void> init(BuildContext context) async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted notifications permission: ${settings.authorizationStatus}');

    fcmToken = await _fcm.getToken();
    log('fcmToken: $fcmToken');
    await storeRepository.updateSingleField({'CloudMessagingToken': fcmToken});

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.notification!.title.toString()}');

      if (message.notification != null) {
        if (message.notification!.title != null &&
            message.notification!.body != null) {
          final notificationData = message.data;
          if (notificationData['user'] == null) {
            print('Null không có gì');
          }
          UserAddressModel userData =
              UserAddressModel.fromJson(json.decode(notificationData['user']));

          showDialog(
            context: Get.overlayContext!,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(message.notification!.title!),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.notification!.body!,
                        style: HAppStyle.paragraph2Regular
                            .copyWith(color: HAppColor.hGreyColorShade600),
                      ),
                      gapH10,
                      const Text(
                        'Địa chỉ chi tiết:',
                        style: HAppStyle.paragraph1Bold,
                      ),
                      gapH4,
                      Text.rich(TextSpan(
                          text: userData.name,
                          style: HAppStyle.heading5Style,
                          children: [
                            TextSpan(
                                text: ' (${userData.phoneNumber})',
                                style: HAppStyle.paragraph2Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600))
                          ])),
                      Text(userData.toString(),
                          style: HAppStyle.paragraph2Regular
                              .copyWith(color: HAppColor.hGreyColorShade600))
                    ]),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Đã biết',
                      style: HAppStyle.label4Bold
                          .copyWith(color: HAppColor.hBluePrimaryColor),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationClick(context, message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'onMessageOpenedApp: ${message.notification!.title.toString()}');
      _handleNotificationClick(context, message);
    });
  }

  void _handleNotificationClick(BuildContext context, RemoteMessage message) {
    final notificationData = message.data;

    if (notificationData.containsKey('screen')) {
      final screen = notificationData['screen'];
      Navigator.of(context).pushNamed(screen);
    }
  }

  static sendNotificationToNearbyDeliveryPersons(
      DeliveryPersonModel nearbyDeliveryPerson, OrderModel order) async {
    try {
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      var data = {};

      if (order.orderType == 'uu_tien') {
        data = {
          'priority': 'high',
          "to": nearbyDeliveryPerson.cloudMessagingToken,
          "notification": {
            "title": 'Đơn giao hàng mới',
            "body": 'Có đơn hàng mới được đặt',
          },
          "data": {
            "order": order.toJson(),
            "storeId": StoreController.instance.user.value.id
          }
        };
      } else {
        data = {
          "to": nearbyDeliveryPerson.cloudMessagingToken,
          "notification": {
            "title": 'Đơn giao hàng mới',
            "body": 'Có đơn hàng mới được đặt',
          },
          "data": {
            "order": order.toJson(),
            "storeId": StoreController.instance.user.value.id
          }
        };
      }

      print(order.orderUserAddress.toString());

      final headers = {
        'content-type': 'application/json',
        'Authorization': 'key=${HAppKey.fcmKeyServer}'
      };
      print('Chờ vào gửi tin');

      await http
          .post(Uri.parse(postUrl),
              body: json.encode(data),
              encoding: Encoding.getByName('utf-8'),
              headers: headers)
          .then((value) => print('${value.body}'))
          .timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  static sendNotificationToUserByOneReject(
      OrderModel order, StoreOrderModel store) async {
    try {
      print('Đã vào gửi tin');
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      final data = {
        "to": order.orderUser.cloudMessagingToken,
        "notification": {
          "title": 'Từ chối',
          "body": 'Đơn hàng của bạn bị từ chối bởi cửa hàng: ${store.name}',
        },
        "data": {"reject": 'Bị từ chối', 'order': order.toJson()}
      };

      final headers = {
        'content-type': 'application/json',
        'Authorization': 'key=${HAppKey.fcmKeyServer}'
      };
      print('Chờ vào gửi tin');

      await http
          .post(Uri.parse(postUrl),
              body: json.encode(data),
              encoding: Encoding.getByName('utf-8'),
              headers: headers)
          .then((value) => print('${value.body}'))
          .timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  static sendNotificationToUserByAllReject(OrderModel order) async {
    try {
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      final data = {
        "to": order.orderUser.cloudMessagingToken,
        "notification": {
          "title": 'Từ chối',
          "body":
              'Đơn hàng của bạn bị từ chối bởi các cửa hàng, xin hãy vui lòng đặt đơn mới tại các cửa hàng khác hoặc đặt lại sau.',
        },
        "data": {"reject": 'Bị từ chối tất cả', 'order': order.toJson()}
      };

      print(order.orderUserAddress.toString());

      final headers = {
        'content-type': 'application/json',
        'Authorization': 'key=${HAppKey.fcmKeyServer}'
      };
      print('Chờ vào gửi tin');

      await http
          .post(Uri.parse(postUrl),
              body: json.encode(data),
              encoding: Encoding.getByName('utf-8'),
              headers: headers)
          .then((value) => print('${value.body}'))
          .timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      throw Exception(e);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.notification!.title}');
}
