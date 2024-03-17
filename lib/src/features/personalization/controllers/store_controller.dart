import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/exceptions/firebase_exception.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/network_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/store_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find();

  final storeRepository = Get.put(StoreRepository());
  final addressController = Get.put(AddressController());
  final authenticationRepository = Get.put(AuthenticationRepository());

  var user = StoreModel.empty().obs;
  var isLoading = false.obs;
  var isUploadImageLoading = false.obs;
  var isUploadImageBackgroundLoading = false.obs;
  var streetAddress = ''.obs;
  var districtAddress = ''.obs;
  var cityAddress = ''.obs;
  var deliveryAddress = ''.obs;
  var currentPosition = Position(
          longitude: 0.0,
          latitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0)
      .obs;
  var isSetAddressDeliveryTo = false.obs;

  @override
  void onInit() {
    fetchStoreRecord();
    super.onInit();
  }

  Future<void> saveStoreRecord(
      UserCredential? userCredential, String authenticationBy) async {
    try {
      await fetchStoreRecord();
      if (user.value.id.isEmpty) {
        if (userCredential != null) {
          final user = StoreModel(
            id: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? '',
            email: userCredential.user!.email ?? '',
            phoneNumber: userCredential.user!.phoneNumber ?? '',
            storeImage: userCredential.user!.photoURL ?? '',
            storeImageBackground: '',
            description: '',
            creationDate:
                DateFormat('EEEE, d-M-y', 'vi').format(DateTime.now()),
            authenticationBy: authenticationBy,
            listOfCategoryId: [],
            rating: 5.0,
            import: false,
            isFamous: false,
            productCount: 0,
            cloudMessagingToken: '',
          );

          await storeRepository.saveStoreRecord(user);
        }
      }
    } on FirebaseException catch (e) {
      throw HFirebaseException(code: e.code).message;
    } catch (e) {
      isLoading.value = false;
      throw 'Đã xảy ra sự cố. Xin vui lòng thử lại sau.';
    }
  }

  Future<void> fetchStoreRecord() async {
    try {
      isLoading.value = true;
      final user = await storeRepository.getStoreInformation();
      this.user(user);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', 'Không tìm thấy dữ liệu của cửa hàng');
      user(StoreModel.empty());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadingUserRecord() async {
    try {
      HAppUtils.loadingOverlays();

      final isConnected = await NetworkController.instance.isConnected();
      if (!isConnected) {
        HAppUtils.stopLoading();
        return;
      }

      final user = await storeRepository.getStoreInformation();
      this.user(user);
      HAppUtils.stopLoading();
    } catch (e) {
      HAppUtils.showSnackBarError('Lỗi', 'Không tìm thấy dữ liệu của cửa hàng');
      user(StoreModel.empty());
    } finally {
      HAppUtils.stopLoading();
    }
  }

  void uploadStoreImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        isUploadImageLoading.value = true;
        final imageUrl = await storeRepository.uploadImage(
            'Stores/${user.value.id}/Images/Profile', image);
        Map<String, dynamic> json = {'StoreImage': imageUrl};
        await storeRepository.updateSingleField(json);

        user.value.storeImage = imageUrl;
        user.refresh();

        isUploadImageLoading.value = false;
      }
    } catch (e) {
      isUploadImageLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }

  void uploadStoreImageBackground() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        isUploadImageBackgroundLoading.value = true;
        final imageUrl = await storeRepository.uploadImage(
            'Stores/${user.value.id}/Images/Profile', image);
        Map<String, dynamic> json = {'StoreImageBackground': imageUrl};
        await storeRepository.updateSingleField(json);

        user.value.storeImageBackground = imageUrl;
        user.refresh();

        isUploadImageBackgroundLoading.value = false;
      }
    } catch (e) {
      isUploadImageBackgroundLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }
}
