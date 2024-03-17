import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/repositories/product_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final productRepository = Get.put(ProductRepository());

  var listOfProduct = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchAllProducts();
    super.onInit();
  }

  void fetchAllProducts() async {
    try {
      isLoading.value = true;
      final products = await productRepository.getAllProducts();
      listOfProduct.assignAll(products);
    } catch (e) {
      isLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
