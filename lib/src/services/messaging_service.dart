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
import 'package:on_demand_grocery_store/src/features/sell/models/notification_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/store_note_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/user_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/notification_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/product_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:http/http.dart' as http;
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

class HNotificationService {
  static String? fcmToken;

  static final HNotificationService _instance =
      HNotificationService._internal();

  factory HNotificationService() => _instance;

  HNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final storeRepository = Get.put(StoreRepository());
  static final productRepository = Get.put(ProductRepository());
  static final notificationRepository = Get.put(NotificationRepository());

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

          // if (notificationData['dat_lich'] != null) {
          //   var time = int.parse(notificationData['dat_lich']);
          //   Future.delayed(Duration(seconds: ))
          // }
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

  static Future<void> sendNotificationToNearbyDeliveryPersons(
      DeliveryPersonModel nearbyDeliveryPerson, String orderId) async {
    try {
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      var data = {
        "to": nearbyDeliveryPerson.cloudMessagingToken,
        "notification": {
          "title": 'Đơn giao hàng mới',
          "body": 'Có đơn hàng mới được đặt',
        },
        "data": {
          "orderId": orderId,
          "storeId": StoreController.instance.user.value.id
        }
      };

      print(data.toString());

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
          .then((value) => print(value.body))
          .timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      throw Exception(e);
    }
  }

  static Future<void> sendNotificationToUserByOneReject(
      OrderModel order, StoreOrderModel store) async {
    try {
      print('Đã vào gửi tin');
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      String title = 'Từ chối đơn hàng';
      String body = 'Đơn hàng của bạn bị từ chối bởi cửa hàng: ${store.name}';

      final data = {
        "to": order.orderUser.cloudMessagingToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {"reject": 'Bị từ chối', 'order': order.oderId}
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
          .then((value) async {
        print(value.body);
        var uuid = const Uuid();
        await notificationRepository.addNotification(
            NotificationModel(
                id: uuid.v1(),
                title: title,
                body: body,
                time: DateTime.now(),
                type: 'order'),
            order.orderUserId);
      }).timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      throw Exception(e);
    }
  }

  // static Future<void> sendNotificationToUserByAcceptOrder(
  //     OrderModel order, StoreOrderModel store) async {
  //   try {
  //     print('Đã vào gửi tin');
  //     const postUrl = 'https://fcm.googleapis.com/fcm/send';
  //     String title = 'Chấp nhận đơn hàng';
  //     String body =
  //         'Đơn hàng của bạn đã được chấp nhận bởi cửa hàng: ${store.name}';

  //     final data = {
  //       "to": order.orderUser.cloudMessagingToken,
  //       "notification": {
  //         "title": title,
  //         "body": body,
  //       },
  //     };

  //     final headers = {
  //       'content-type': 'application/json',
  //       'Authorization': 'key=${HAppKey.fcmKeyServer}'
  //     };
  //     print('Chờ vào gửi tin');

  //     await http
  //         .post(Uri.parse(postUrl),
  //             body: json.encode(data),
  //             encoding: Encoding.getByName('utf-8'),
  //             headers: headers)
  //         .then((value) async {
  //       print(value.body);
  //       var uuid = const Uuid();
  //       await notificationRepository.addNotification(
  //           NotificationModel(
  //               id: uuid.v1(),
  //               title: title,
  //               body: body,
  //               time: DateTime.now(),
  //               type: 'order'),
  //           order.orderUserId);
  //     }).timeout(const Duration(seconds: 60), onTimeout: () {
  //       log('Đã hết thời gian kết nối');
  //       throw TimeoutException('Đã hết thời gian kết nối');
  //     }).onError((error, stackTrace) {
  //       HAppUtils.showSnackBarError('Lỗi', error.toString());
  //       throw Exception(error);
  //     });
  //   } catch (e) {
  //     HAppUtils.showSnackBarError('Lỗi', e.toString());
  //     throw Exception(e);
  //   }
  // }

  static Future<void> sendNotificationToUserByAllReject(
      OrderModel order) async {
    try {
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      String title = 'Từ chối đơn hàng';
      String body =
          'Đơn hàng của bạn bị từ chối bởi các cửa hàng, xin hãy vui lòng đặt đơn mới tại các cửa hàng khác hoặc đặt lại sau.';
      final data = {
        "to": order.orderUser.cloudMessagingToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {"reject": 'Bị từ chối tất cả', 'order': order.oderId}
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
          .then((value) async {
        print(value.body);
        var uuid = const Uuid();
        await notificationRepository.addNotification(
            NotificationModel(
                id: uuid.v1(),
                title: title,
                body: body,
                time: DateTime.now(),
                type: 'order'),
            order.orderUserId);
      }).timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      throw Exception(e);
    }
  }

  static Future<void> sendNotificationToUserByAllAcceptOrder(
      OrderModel order) async {
    try {
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      String title = 'Chấp nhận đơn hàng';
      String body = 'Đơn hàng của bạn đã được cửa hàng chấp nhận.';
      final data = {
        "to": order.orderUser.cloudMessagingToken,
        "notification": {
          "title": title,
          "body": body,
        },
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
          .then((value) async {
        print(value.body);
        var uuid = const Uuid();
        await notificationRepository.addNotification(
            NotificationModel(
                id: uuid.v1(),
                title: title,
                body: body,
                time: DateTime.now(),
                type: 'order'),
            order.orderUserId);
      }).timeout(const Duration(seconds: 60), onTimeout: () {
        log('Đã hết thời gian kết nối');
        throw TimeoutException('Đã hết thời gian kết nối');
      }).onError((error, stackTrace) {
        HAppUtils.showSnackBarError('Lỗi', error.toString());
        throw Exception(error);
      });
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      throw Exception(e);
    }
  }

  static Future<void> sendNotificationToUserByProductRegistration(
      List<String> tokens, String productId, List<String> userId) async {
    try {
      print('Đã vào gửi tin');
      ProductModel product =
          await productRepository.getProductInformation(productId);
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      for (int i = 0; i < tokens.length; i++) {
        String title = HAppUtils.shortenProductName(
            'Sản phẩm ${product.name} có hàng trở lại!', product.name);
        String body = HAppUtils.shortenProductName(
            'Bạn đã có thể đặt hàng ngay với sản phẩm ${product.name} đã được cập nhật trạng thái trở lại.',
            product.name);
        final data = {
          "to": tokens[i],
          "notification": {
            "title": title,
            "body": body,
          },
          'data': {'type': 'product'},
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
            .then((value) async {
          print(value.body);
          var uuid = const Uuid();
          await notificationRepository.addNotification(
              NotificationModel(
                  id: uuid.v1(),
                  title: title,
                  body: body,
                  time: DateTime.now(),
                  type: 'product'),
              userId[i]);
        }).timeout(const Duration(seconds: 60), onTimeout: () {
          log('Đã hết thời gian kết nối');
          throw TimeoutException('Đã hết thời gian kết nối');
        }).onError((error, stackTrace) {
          HAppUtils.showSnackBarError('Lỗi', error.toString());
          throw Exception(error);
        });
      }
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      throw Exception(e);
    }
  }

  static Future<void> sendNotificationToUserByStore(
      List<String> tokens, List<String> userId) async {
    try {
      print('Đã vào gửi tin');
      StoreModel store = await StoreRepository.instance.getStoreInformation();
      const postUrl = 'https://fcm.googleapis.com/fcm/send';
      for (int i = 0; i < tokens.length; i++) {
        String title = HAppUtils.shortenProductName(
            'Cửa hàng ${store.name} có ưu đãi mới', store.name);
        String body = HAppUtils.shortenProductName(
            'Cửa hàng ${store.name} đã cập nhật thêm mã ưu đãi mới. Hãy truy cập để kiểm tra ngay.',
            store.name);
        final data = {
          "to": tokens[i],
          "notification": {
            "title": title,
            "body": body,
          },
          'data': {'type': 'store'},
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
            .then((value) async {
          print(value.body);
          var uuid = const Uuid();
          await notificationRepository.addNotification(
              NotificationModel(
                  id: uuid.v1(),
                  title: title,
                  body: body,
                  time: DateTime.now(),
                  type: 'store'),
              userId[i]);
        }).timeout(const Duration(seconds: 60), onTimeout: () {
          log('Đã hết thời gian kết nối');
          throw TimeoutException('Đã hết thời gian kết nối');
        }).onError((error, stackTrace) {
          HAppUtils.showSnackBarError('Lỗi', error.toString());
          throw Exception(error);
        });
      }
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      throw Exception(e);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.notification!.title}');
}
