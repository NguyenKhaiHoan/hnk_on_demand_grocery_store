import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/category_model.dart';
import 'package:on_demand_grocery_store/src/repositories/category_repository.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final categoryRepository = Get.put(CategoryRepository());

  var isLoading = false.obs;
  var listOfCategory = <CategoryModel>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await categoryRepository.getAllCategories();
      categories.sort((CategoryModel a, CategoryModel b) =>
          int.parse(a.id).compareTo(int.parse(b.id)));
      listOfCategory.assignAll(categories);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      HAppUtils.showSnackBarError('Lỗi', e.toString());
    }
  }
}
