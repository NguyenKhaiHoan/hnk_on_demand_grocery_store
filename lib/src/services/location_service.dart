import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/delivery_person_controller.dart';
import 'package:on_demand_grocery_store/src/repositories/address_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class HLocationService {
  static Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    print('vào lấy vị trí');

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      HAppUtils.showSnackBarError('Lỗi', 'Dịch vụ định vị bị vô hiệu hóa.');
      return Future.error('Dịch vụ định vị bị vô hiệu hóa.');
    }

    print('xong kiểm tra 1');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        HAppUtils.showSnackBarError('Lỗi', 'Quyền truy cập vị trí bị từ chối.');
        return Future.error('Quyền truy cập vị trí bị từ chối.');
      }
    }

    print('xong kiểm tra 2');

    if (permission == LocationPermission.deniedForever) {
      HAppUtils.showSnackBarError('Lỗi',
          'Quyền vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu quyền.');
      return Future.error(
          'Quyền vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu quyền.');
    }

    print('xong kiểm tra 3');

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    print('xong tất cả kiếm tra');

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  static Future<List<String>> getAddressFromLatLong(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      print(placemarks);
      return [
        place.street ?? '',
        place.subAdministrativeArea ?? '',
        place.administrativeArea ?? ''
      ];
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', e.toString());
      return [];
    }
  }

  static Future<void> getNearbyDeliveryPersons() async {
    final deliveryPersonController = DeliveryPersonController.instance;
    final addressRepository = Get.put(AddressRepository());
    deliveryPersonController.allNearbydeliveryPersonsId.clear();
    final currentPosition = await addressRepository.getStoreAddress();
    Geofire.initialize('DeliveryPersons');
    try {
      Geofire.queryAtLocation(currentPosition.first.latitude,
              currentPosition.first.longitude, 3)!
          .listen((map) async {
        print(map);
        if (map != null) {
          var callBack = map['callBack'];
          switch (callBack) {
            case Geofire.onKeyEntered:
              log('key: ${map['key']}');
              deliveryPersonController.addNearbyDeliveryPerson(map['key']);
              break;
            case Geofire.onKeyExited:
              deliveryPersonController.removeNearbyDeliveryPerson(map['key']);
              break;
            case Geofire.onGeoQueryReady:
              break;
          }
        }
      }).onError((error) {
        print(error);
      });
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }

  static checkStatus(bool online) async {
    if (online) {
      var addressModel = await AddressRepository.instance.getStoreAddress();
      Geofire.initialize('Stores');
      Geofire.setLocation(AuthenticationRepository.instance.authUser!.uid,
          addressModel.first.latitude, addressModel.first.longitude);
      await StoreRepository.instance.updateSingleField({'Status': true});
      StoreController.instance.user.value.status == true;
      StoreController.instance.user.refresh();
      HAppUtils.showSnackBarSuccess(
          "Bật nhận đơn", 'Bạn đã bật nhận đơn thành công');
    } else {
      log('Vào đây');
      Geofire.removeLocation(AuthenticationRepository.instance.authUser!.uid);
      await StoreRepository.instance.updateSingleField({'Status': true});
      StoreController.instance.user.value.status == false;
      StoreController.instance.user.refresh();
      HAppUtils.showSnackBarSuccess(
          "Đóng nhận đơn", 'Bạn đã đóng nhận đơn thành công');
    }
  }
}
