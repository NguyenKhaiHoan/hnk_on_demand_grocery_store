import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/data/dummy_data.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/product_controller.dart';
import 'package:on_demand_grocery_store/src/features/shop/views/home/home_screen.dart';

class AllProductScreen extends StatefulWidget {
  AllProductScreen({super.key});

  @override
  State<AllProductScreen> createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  final productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text('Tất cả sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: Obx(() => productController.listOfProduct.isEmpty
            ? ElevatedButton(
                onPressed: () {
                  // categoryController.fetchCategories();
                  DummyData.getAllProducts();
                },
                child: const Text('Tải dữ liệu ảo'))
            : Padding(
                padding: hAppDefaultPaddingLR,
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    mainAxisExtent: 295,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return ProductItemWidget(
                        model: productController.listOfProduct[index],
                        storeIcon: false,
                        compare: false);
                  },
                ),
              )),
      ),
    );
  }
}
