import 'dart:math';

import 'package:get/get.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/store_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/category_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/category_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/product_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/delivery_person_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';

class DummyData {
  static Random random = Random();

  static int randomInt(int min, int max) {
    return min + random.nextInt(max - min);
  }

  static double randomDouble(double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  static bool randomBool() {
    return random.nextBool();
  }

  static int randomSalePersent() {
    return random.nextBool() ? randomInt(10, 99) : 0;
  }

  static int randomPriceSale(int price, int salePersent) {
    double priceNum = price.toDouble();
    double priceSaleNum = priceNum * (1 - salePersent / 100);

    return (priceSaleNum / 1000).ceil() * 1000;
  }

  static T randomElement<T>(List<T> list) {
    return list[random.nextInt(list.length)];
  }

  static List<String> getRandomElements(List<CategoryModel> list, int count) {
    var random = Random();
    List<String> temp = List<String>.from(list.map((e) => e.id));
    List<String> result = [];

    for (int i = 0; i < count; i++) {
      if (temp.isNotEmpty) {
        int index = random.nextInt(temp.length);
        result.add(temp[index]);
        temp.removeAt(index);
      }
    }
    return result;
  }

  static Future<void> getAllProducts() async {
    List<ProductModel> list = [];
    print('vào get All product');
    final storeController = StoreController.instance;
    final categoryController = CategoryController.instance;
    final categoryIds = getRandomElements(categoryController.listOfCategory,
        randomInt(10, categoryController.listOfCategory.length));
    print('cate length:${categoryIds.length}');

    StoreModel store = storeController.user.value;
    store.listOfCategoryId.assignAll(categoryIds);
    await StoreRepository.instance
        .updateSingleField({'ListOfCategoryId': categoryIds});
    store.import = randomBool() ? true : false;
    await StoreRepository.instance.updateSingleField({'Import': store.import});
    storeController.user.refresh();
    list = List<ProductModel>.generate(
      70,
      (index) {
        String storeId = store.id;
        String origin = '';
        if (store.import) {
          origin = randomBool() ? randomElement(otherCountry) : 'Việt Nam';
        } else {
          origin = 'Việt Nam';
        }
        String description =
            loremIpsum(words: 30, paragraphs: 2, initWithLorem: true);
        String categoryId = randomElement(store.listOfCategoryId);
        String name = randomElement(names);
        int price = randomInt(1, 1000) * 1000;
        String unit = randomElement(units);
        int salePersent = randomSalePersent();
        int priceSale = randomPriceSale(price, salePersent);
        String image = randomElement(imageProduct);
        String status = randomInt(1, 10) <= 1 ? "Tạm hết hàng" : "Còn hàng";
        int countBuyed = randomInt(10, 500);
        double rating = randomDouble(3.0, 5.0);
        DateTime uploadTime =
            DateTime.now().subtract(Duration(days: randomInt(1, 30)));
        return ProductModel(
            id: '',
            name: name,
            image: image,
            categoryId: categoryId,
            description: description,
            status: status,
            price: price,
            salePersent: salePersent,
            priceSale: priceSale,
            unit: unit,
            countBuyed: countBuyed,
            rating: rating,
            origin: origin,
            storeId: storeId,
            uploadTime: DateTime.fromMillisecondsSinceEpoch(
                uploadTime.millisecondsSinceEpoch));
      },
    );
    await ProductRepository.instance.uploadDummyData(list);
  }

  static List<String> names = [
    "Táo",
    "Bơ",
    "Chuối",
    "Kiwi",
    "Chanh vàng",
    "Chanh xanh",
    "Xoài",
    "Dưa",
    "Xuân đào",
    "Cam",
    "Đu đủ",
    "Chanh dây",
    "Đào",
    "Lê",
    "Dứa",
    "Mận",
    "Lựu",
    "Bưởi đỏ",
    "Quýt",
    "Nước ép",
    "Sữa",
    "Sữa yến mạch",
    "Sữa đậu nành",
    "Sữa chua",
    "Măng tây",
    "Cà tím",
    "Bắp cải",
    "Cà rốt",
    "Dưa chuột",
    "Tỏi",
    "Gừng",
    "Tỏi tây",
    "Nấm",
    "Hành tây",
    "Hạt tiêu",
    "Khoai tây",
    "Củ dền",
    "Cà chua",
    "Bí xanh"
  ];

  static List<String> otherCountry = [
    'Trung Quốc',
    'Hàn Quốc',
    'Nhật Bản',
    'Thái Lan',
    'Lào',
    'Mỹ',
  ];

  static List<String> units = ['kg', 'cái', 'vỉ', 'chai', 'gói'];

  static List<String> imageProduct = [
    'assets/products/Fruit/Golden-Delicious_Iconic.jpg',
    'assets/products/Fruit/Granny-Smith_Iconic.jpg',
    'assets/products/Fruit/Pink-Lady_Iconic.jpg',
    'assets/products/Fruit/Red-Delicious_Iconic.jpg',
    'assets/products/Fruit/Royal-Gala_Iconic.jpg',
    'assets/products/Fruit/Avocado_Iconic.jpg',
    'assets/products/Fruit/Banana_Iconic.jpg',
    'assets/products/Fruit/Kiwi_Iconic.jpg',
    'assets/products/Fruit/Lemon_Iconic.jpg',
    'assets/products/Fruit/Lime_Iconic.jpg',
    'assets/products/Fruit/Mango_Iconic.jpg',
    'assets/products/Fruit/Cantaloupe_Iconic.jpg',
    'assets/products/Fruit/Galia-Melon_Iconic.jpg',
    'assets/products/Fruit/Honeydew-Melon_Iconic.jpg',
    'assets/products/Fruit/Watermelon_Iconic.jpg',
    'assets/products/Fruit/Nectarine_Iconic.jpg',
    'assets/products/Fruit/Orange_Iconic.jpg',
    'assets/products/Fruit/Papaya_Iconic.jpg',
    'assets/products/Fruit/Passion-Fruit_Iconic.jpg',
    'assets/products/Fruit/Peach_Iconic.jpg',
    'assets/products/Fruit/Anjou_Iconic.jpg',
    'assets/products/Fruit/Conference_Iconic.jpg',
    'assets/products/Fruit/Kaiser_Iconic.jpg',
    'assets/products/Fruit/Pineapple_Iconic.jpg',
    'assets/products/Fruit/Plum_Iconic.jpg',
    'assets/products/Fruit/Pomegranate_Iconic.jpg',
    'assets/products/Fruit/Red-Grapefruit_Iconic.jpg',
    'assets/products/Fruit/Satsumas_Iconic.jpg',
    'assets/products/Packages/Bravo-Apple-Juice_Iconic.jpg',
    'assets/products/Packages/Bravo-Orange-Juice_Iconic.jpg',
    'assets/products/Packages/God-Morgon-Apple-Juice_Iconic.jpg',
    'assets/products/Packages/God-Morgon-Orange-Juice_Iconic.jpg',
    'assets/products/Packages/God-Morgon-Orange-Red-Grapefruit-Juice_Iconic.jpg',
    'assets/products/Packages/God-Morgon-Red-Grapefruit-Juice_Iconic.jpg',
    'assets/products/Packages/Tropicana-Apple-Juice_Iconic.jpg',
    'assets/products/Packages/Tropicana-Golden-Grapefruit_Iconic.jpg',
    'assets/products/Packages/Tropicana-Juice-Smooth_Iconic.jpg',
    'assets/products/Packages/Tropicana-Mandarin-Morning_Iconic.jpg',
    'assets/products/Packages/Arla-Ecological-Medium-Fat-Milk_Iconic.jpg',
    'assets/products/Packages/Arla-Lactose-Medium-Fat-Milk_Iconic.jpg',
    'assets/products/Packages/Arla-Medium-Fat-Milk_Iconic.jpg',
    'assets/products/Packages/Arla-Standard-Milk_Iconic.jpg',
    'assets/products/Packages/Garant-Ecological-Medium-Fat-Milk_Iconic.jpg',
    'assets/products/Packages/Garant-Ecological-Standard-Milk_Iconic.jpg',
    'assets/products/Packages/Oatly-Oat-Milk_Iconic.jpg',
    'assets/products/Packages/Alpro-Fresh-Soy-Milk_Iconic.jpg',
    'assets/products/Packages/Alpro-Shelf-Soy-Milk_Iconic.jpg',
    'assets/products/Packages/Arla-Mild-Vanilla-Yoghurt_Iconic.jpg',
    'assets/products/Packages/Arla-Natural-Mild-Low-Fat-Yoghurt_Iconic.jpg',
    'assets/products/Packages/Arla-Natural-Yoghurt_Iconic.jpg',
    'assets/products/Packages/Valio-Vanilla-Yoghurt_Iconic.jpg',
    'assets/products/Packages/Yoggi-Strawberry-Yoghurt_Iconic.jpg',
    'assets/products/Packages/Yoggi-Vanilla-Yoghurt_Iconic.jpg',
    'assets/products/Vegetables/Asparagus_Iconic.jpg',
    'assets/products/Vegetables/Aubergine_Iconic.jpg',
    'assets/products/Vegetables/Cabbage_Iconic.jpg',
    'assets/products/Vegetables/Carrots_Iconic.jpg',
    'assets/products/Vegetables/Cucumber_Iconic.jpg',
    'assets/products/Vegetables/Garlic_Iconic.jpg',
    'assets/products/Vegetables/Ginger_Iconic.jpg',
    'assets/products/Vegetables/Leek_Iconic.jpg',
    'assets/products/Vegetables/Brown-Cap-Mushroom_Iconic.jpg',
    'assets/products/Vegetables/Yellow-Onion_Iconic.jpg',
    'assets/products/Vegetables/Green-Bell-Pepper_Iconic.jpg',
    'assets/products/Vegetables/Orange-Bell-Pepper_Iconic.jpg',
    'assets/products/Vegetables/Red-Bell-Pepper_Iconic.jpg',
    'assets/products/Vegetables/Yellow-Bell-Pepper_Iconic.jpg',
    'assets/products/Vegetables/Floury-Potato_Iconic.jpg',
    'assets/products/Vegetables/Solid-Potato_Iconic.jpg',
    'assets/products/Vegetables/Sweet-Potato_Iconic.jpg',
    'assets/products/Vegetables/Red-Beet_Iconic.jpg',
    'assets/products/Vegetables/Beef-Tomato_Iconic.jpg',
    'assets/products/Vegetables/Regular-Tomato_Iconic.jpg',
    'assets/products/Vegetables/Vine-Tomato_Iconic.jpg',
    'assets/products/Vegetables/Zucchini_Iconic.jpg',
  ];
}
