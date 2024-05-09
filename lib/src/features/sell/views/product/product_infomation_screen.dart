import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/category_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/product_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/order_detail/order_detail_screen.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class ProductInformationScreen extends StatefulWidget {
  const ProductInformationScreen({super.key});

  @override
  State<ProductInformationScreen> createState() =>
      _ProductInformationScreenState();
}

class _ProductInformationScreenState extends State<ProductInformationScreen> {
  var listProductData = <List<dynamic>>[].obs;
  String? filePath;

  // var StoreController.instance.user.value.listOfCategoryId =
  //     List<String>.from(StoreController.instance.user.value.listOfCategoryId)
  //         .obs;
  var selectedCategory = StoreController.instance.user.value.listOfCategoryId;
  var isChose = false.obs;

  final categoryController = Get.put(CategoryController());
  final productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              leadingWidth: 80,
              leading: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: hAppDefaultPadding),
                  child: Icon(EvaIcons.arrowIosBackOutline),
                ),
              ),
              title: const Text("Danh mục và Sản phẩm"),
              centerTitle: true,
              bottom: const TabBar(
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.zero,
                labelStyle: HAppStyle.label3Bold,
                isScrollable: true,
                indicatorColor: HAppColor.hBluePrimaryColor,
                labelColor: HAppColor.hBluePrimaryColor,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: 'Danh mục'),
                  Tab(text: 'Tất cả sản phẩm'),
                  Tab(text: 'Thêm sản phẩm')
                ],
              ),
            ),
            body: TabBarView(
              children: [
                SingleChildScrollView(
                    child: Padding(
                  padding: hAppDefaultPaddingLR,
                  child: Column(
                    children: [
                      gapH12,
                      Row(
                        children: [
                          const Text(
                            'Danh mục',
                            style: HAppStyle.heading4Style,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HAppColor.hBluePrimaryColor,
                            ),
                            child: Text(
                              "Cập nhật",
                              style: HAppStyle.paragraph2Regular
                                  .copyWith(color: HAppColor.hWhiteColor),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("Stores")
                                  .doc(StoreController.instance.user.value.id)
                                  .update({
                                'ListOfCategoryId': selectedCategory
                              }).then((value) {
                                HAppUtils.showSnackBarSuccess('Thành công',
                                    'Cập nhật danh mục cửa hàng thành công');
                                setState(() {});
                              }).onError((error, stackTrace) {
                                HAppUtils.showSnackBarError('Lỗi',
                                    'Không thể cập nhật danh mục cửa hàng');
                              });
                              StoreController.instance.user.refresh();
                            },
                          ),
                        ],
                      ),
                      gapH12,
                      Wrap(
                        children: categoryController.listOfCategory.map(
                          (category) {
                            var isSelected =
                                selectedCategory.contains(category.id)
                                    ? true
                                    : false;
                            return GestureDetector(
                              onTap: () {
                                if (!selectedCategory.contains(category.id)) {
                                  selectedCategory.add(category.id);
                                  print(selectedCategory);
                                } else {
                                  selectedCategory.removeWhere(
                                      (element) => element == category.id);
                                  print(selectedCategory);
                                }
                                setState(() {});
                              },
                              child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 10, right: 5),
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? HAppColor.hBluePrimaryColor
                                        : HAppColor.hBackgroundColor,
                                    border: Border.all(
                                      color: isSelected
                                          ? HAppColor.hBluePrimaryColor
                                          : HAppColor.hGreyColorShade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: HAppStyle.paragraph2Regular.copyWith(
                                        color: isSelected
                                            ? HAppColor.hWhiteColor
                                            : HAppColor.hDarkColor),
                                  )),
                            );
                          },
                        ).toList(),
                      ),
                      gapH24,
                    ],
                  ),
                )),
                Obx(() => FutureBuilder(
                    key: Key(
                        'Products${productController.refreshData.value.toString()}'),
                    future: productController.fetchProductsWithStatus(
                        productController.status.value),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: HAppColor.hBluePrimaryColor),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              'Đã xảy ra sự cố. Xin vui lòng thử lại sau.'),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                              'Không có sản phẩm. ${snapshot.data!.isNotEmpty.toString()}'),
                        );
                      } else {
                        final data = snapshot.data!;
                        return ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(hAppDefaultPadding,
                              0, hAppDefaultPadding, hAppDefaultPadding),
                          children: [
                            gapH12,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Trạng thái:'),
                                const Spacer(),
                                Row(
                                  children: [
                                    Obx(() => GestureDetector(
                                          onTap: () {
                                            productController.status.value =
                                                'Còn hàng';
                                          },
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 5, 10, 5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: productController
                                                            .status.value ==
                                                        'Còn hàng'
                                                    ? HAppColor
                                                        .hBluePrimaryColor
                                                    : HAppColor
                                                        .hBackgroundColor,
                                                border: Border.all(
                                                  color: productController
                                                              .status.value ==
                                                          'Còn hàng'
                                                      ? HAppColor
                                                          .hBluePrimaryColor
                                                      : HAppColor
                                                          .hGreyColorShade300,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Text(
                                                'Còn hàng',
                                                style: HAppStyle
                                                    .paragraph2Regular
                                                    .copyWith(
                                                        color: productController
                                                                    .status
                                                                    .value ==
                                                                'Còn hàng'
                                                            ? HAppColor
                                                                .hWhiteColor
                                                            : HAppColor
                                                                .hDarkColor),
                                              )),
                                        )),
                                    gapW10,
                                    Obx(() => GestureDetector(
                                          onTap: () {
                                            productController.status.value =
                                                'Tạm hết hàng';
                                          },
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 5, 10, 5),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: productController
                                                            .status.value ==
                                                        'Tạm hết hàng'
                                                    ? HAppColor
                                                        .hBluePrimaryColor
                                                    : HAppColor
                                                        .hBackgroundColor,
                                                border: Border.all(
                                                  color: productController
                                                              .status.value ==
                                                          'Tạm hết hàng'
                                                      ? HAppColor
                                                          .hBluePrimaryColor
                                                      : HAppColor
                                                          .hGreyColorShade300,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Text(
                                                'Tạm hết hàng',
                                                style: HAppStyle
                                                    .paragraph2Regular
                                                    .copyWith(
                                                        color: productController
                                                                    .status
                                                                    .value ==
                                                                'Tạm hết hàng'
                                                            ? HAppColor
                                                                .hWhiteColor
                                                            : HAppColor
                                                                .hDarkColor),
                                              )),
                                        )),
                                  ],
                                )
                              ],
                            ),
                            gapH12,
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                mainAxisExtent: 150,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return ProductItemHorizalWidget(
                                  model: data[index],
                                  // onTap: () => null,
                                );
                              },
                            ),
                            gapH24,
                          ],
                        );
                      }
                    }))),
                SingleChildScrollView(
                    child: Padding(
                  padding: hAppDefaultPaddingLR,
                  child: Column(
                    children: [
                      gapH12,
                      Row(
                        children: [
                          const Text(
                            'Thêm sản phẩm',
                            style: HAppStyle.heading4Style,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HAppColor.hBluePrimaryColor,
                            ),
                            child: Text(
                              "Chọn tệp",
                              style: HAppStyle.paragraph2Regular
                                  .copyWith(color: HAppColor.hWhiteColor),
                            ),
                            onPressed: () {
                              chooseFile();
                            },
                          ),
                        ],
                      ),
                      gapH12,
                      Obx(
                        () => listProductData.isNotEmpty
                            ? Column(
                                children: [
                                  SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      child: _createDataTable(),
                                    ),
                                  ),
                                  gapH12,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                            onPressed: () {
                                              listProductData.clear();
                                              filePath = null;
                                            },
                                            style: OutlinedButton.styleFrom(
                                                maximumSize: Size(
                                                    HAppSize.deviceWidth * 0.5,
                                                    50),
                                                foregroundColor:
                                                    HAppColor.hRedColor,
                                                side: const BorderSide(
                                                    color:
                                                        HAppColor.hRedColor)),
                                            child: Text(
                                              "Xóa dữ liệu",
                                              style: HAppStyle.label2Bold
                                                  .copyWith(
                                                      color:
                                                          HAppColor.hRedColor),
                                            )),
                                      ),
                                      gapW10,
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              HAppUtils.loadingOverlays();
                                              var storeCategory =
                                                  StoreController.instance.user
                                                      .value.listOfCategoryId;

                                              var productsCollection =
                                                  FirebaseFirestore.instance
                                                      .collection('Products');
                                              for (var element
                                                  in listProductData.skip(1)) {
                                                if (!storeCategory.contains(
                                                    element[1].toString())) {
                                                  HAppUtils.stopLoading();
                                                  HAppUtils.showSnackBarError(
                                                      'Lỗi',
                                                      'Danh mục của sản phầm không thuộc danh mục của cửa hàng');
                                                  return;
                                                }
                                                var productData = {
                                                  "Name": element[0].toString(),
                                                  "CategoryId":
                                                      element[1].toString(),
                                                  "Description":
                                                      element[2].toString(),
                                                  "Id": "",
                                                  "Image":
                                                      element[3].toString(),
                                                  "CountBuyed": int.parse(
                                                      element[4].toString()),
                                                  "Origin":
                                                      element[5].toString(),
                                                  "Price": int.parse(
                                                      element[6].toString()),
                                                  "SalePersent": int.parse(
                                                      element[7].toString()),
                                                  "PriceSale": getPriceSale(
                                                      int.parse(element[6]
                                                          .toString()),
                                                      int.parse(element[7]
                                                          .toString())),
                                                  "Rating": double.parse(
                                                      element[8].toString()),
                                                  "Status":
                                                      element[9].toString(),
                                                  "Unit":
                                                      element[10].toString(),
                                                  "StoreId": StoreController
                                                      .instance.user.value.id,
                                                  "UploadTime": DateTime.now()
                                                      .millisecondsSinceEpoch
                                                };
                                                await productsCollection
                                                    .add(productData);
                                              }
                                              listProductData.clear();
                                              filePath = null;
                                              HAppUtils.showSnackBarSuccess(
                                                  'Thành công',
                                                  "Thêm sản phẩm thành công");
                                            } catch (e) {
                                              print(e.toString());
                                              HAppUtils.showSnackBarError('Lỗi',
                                                  'Không thể thêm được dữ liệu sản phẩm: ${e.toString()}');
                                            } finally {
                                              HAppUtils.stopLoading();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            maximumSize: Size(
                                                HAppSize.deviceWidth * 0.5, 50),
                                            backgroundColor:
                                                HAppColor.hBluePrimaryColor,
                                          ),
                                          child: Text(
                                            "Tải dữ liệu",
                                            style: HAppStyle.label2Bold
                                                .copyWith(
                                                    color:
                                                        HAppColor.hWhiteColor),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : Container(),
                      ),
                      gapH24,
                    ],
                  ),
                ))
              ],
            )));
  }

  int getPriceSale(int price, int salePersent) {
    double priceNum = price.toDouble();
    double priceSaleNum = priceNum * (1 - salePersent / 100);

    return (priceSaleNum / 1000).ceil() * 1000;
  }

  int _currentSortColumn = 0;
  bool _isSortAsc = true;

  DataTable _createDataTable() {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(),
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        label: Text(
          'Name',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'CategoryId',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'Description',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'Image',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'CountBuyed',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'Origin',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'Price',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'SalePersent',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'Rating',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'Status',
          style: HAppStyle.label2Bold,
        ),
      ),
      const DataColumn(
        label: Text(
          'Unit',
          style: HAppStyle.label2Bold,
        ),
      ),
    ];
  }

  List<DataRow> _createRows() {
    return listProductData
        .skip(1)
        .map((book) => DataRow(cells: [
              DataCell(
                Text(book[0].toString()),
              ),
              DataCell(
                Text(book[1].toString()),
              ),
              DataCell(
                Text(book[2].toString().substring(
                    0,
                    book[2].toString().length > 20
                        ? 20
                        : book[2].toString().length)),
              ),
              DataCell(
                Text(book[3].toString().substring(
                    0,
                    book[3].toString().length > 20
                        ? 20
                        : book[3].toString().length)),
              ),
              DataCell(
                Text(book[4].toString()),
              ),
              DataCell(
                Text(book[5].toString()),
              ),
              DataCell(
                Text(book[6].toString()),
              ),
              DataCell(
                Text(book[7].toString()),
              ),
              DataCell(
                Text(book[8].toString()),
              ),
              DataCell(
                Text(book[9].toString()),
              ),
              DataCell(
                Text(book[10].toString()),
              ),
            ]))
        .toList();
  }

  void chooseFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    print(result.files.first.name);

    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    print(fields);

    listProductData.value = fields;
  }
}
