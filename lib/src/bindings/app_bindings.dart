import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/change_password_controller.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/login_controller.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/sign_up_controller.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/verify_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/change_name_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/repositories/address_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/banner_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/category_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/chat_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/order_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/product_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/user_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/voucher_repository.dart';

class HAppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
    Get.lazyPut(() => StoreController(), fenix: true);
    Get.lazyPut(() => AddressController(), fenix: true);
    Get.lazyPut(() => ChangeNameController(), fenix: true);
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
    Get.lazyPut(() => VerifyController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => AddressRepository(), fenix: true);
    Get.lazyPut(() => BannerRepository(), fenix: true);
    Get.lazyPut(() => CategoryRepository(), fenix: true);
    Get.lazyPut(() => ChatRepository(), fenix: true);
    Get.lazyPut(() => OrderRepository(), fenix: true);
    Get.lazyPut(() => ProductRepository(), fenix: true);
    Get.lazyPut(() => VoucherRepository(), fenix: true);
    Get.lazyPut(() => AuthenticationRepository(), fenix: true);
    Get.lazyPut(() => UserRepository(), fenix: true);
    Get.lazyPut(() => StoreRepository(), fenix: true);
    Get.lazyPut(() => DeliveryPersonRepository(), fenix: true);
  }
}
