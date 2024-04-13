import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/category_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/order_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/product_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/store_note_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/services/location_service.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final categoryController = Get.put(CategoryController());
  final productController = Get.put(ProductController());
  final orderController = Get.put(OrderController());
  RxBool online = false.obs;

  @override
  void initState() {
    super.initState();
    online.value = StoreController.instance.user.value.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: hAppDefaultPaddingL,
            child: GestureDetector(
              onTap: () {
                if (ZoomDrawer.of(context)!.isOpen()) {
                  ZoomDrawer.of(context)!.close();
                } else {
                  ZoomDrawer.of(context)!.open();
                }
              },
              child: const Icon(
                EvaIcons.menu2Outline,
              ),
            ),
          ),
          actions: [
            Obx(() => online.value
                ? StreamBuilder(
                    stream: FirebaseDatabase.instance
                        .ref()
                        .child(
                            'Stores/${StoreController.instance.user.value.id}')
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }
                      if (snapshot.hasError) {
                        return Container();
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return Padding(
                          padding: hAppDefaultPaddingR,
                          child: Switch(
                              trackOutlineColor:
                                  MaterialStateProperty.resolveWith(
                                (final Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return null;
                                  }
                                  return HAppColor.hGreyColorShade300;
                                },
                              ),
                              activeColor: HAppColor.hBluePrimaryColor,
                              activeTrackColor: HAppColor.hBlueSecondaryColor,
                              inactiveThumbColor: HAppColor.hWhiteColor,
                              inactiveTrackColor: HAppColor.hGreyColorShade300,
                              value: online.value,
                              onChanged: (changed) async {
                                online.value = changed;
                                HLocationService.checkStatus(online.value);
                              }),
                        );
                      }
                      return Padding(
                        padding: hAppDefaultPaddingR,
                        child: Obx(() {
                          return Switch(
                              trackOutlineColor:
                                  MaterialStateProperty.resolveWith(
                                (final Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return null;
                                  }
                                  return HAppColor.hGreyColorShade300;
                                },
                              ),
                              activeColor: HAppColor.hBluePrimaryColor,
                              activeTrackColor: HAppColor.hBlueSecondaryColor,
                              inactiveThumbColor: HAppColor.hWhiteColor,
                              inactiveTrackColor: HAppColor.hGreyColorShade300,
                              value: online.value,
                              onChanged: (changed) async {
                                online.value = changed;
                                HLocationService.checkStatus(online.value);
                              });
                        }),
                      );
                    },
                  )
                : Padding(
                    padding: hAppDefaultPaddingR,
                    child: Switch(
                        trackOutlineColor: MaterialStateProperty.resolveWith(
                          (final Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return null;
                            }
                            return HAppColor.hGreyColorShade300;
                          },
                        ),
                        activeColor: HAppColor.hBluePrimaryColor,
                        activeTrackColor: HAppColor.hBlueSecondaryColor,
                        inactiveThumbColor: HAppColor.hWhiteColor,
                        inactiveTrackColor: HAppColor.hGreyColorShade300,
                        value: online.value,
                        onChanged: (changed) async {
                          online.value = changed;
                          HLocationService.checkStatus(online.value);
                        }),
                  )),
            // Padding(
            //   padding: hAppDefaultPaddingR,
            //   child: Obx(() {
            //     return Switch(
            //         trackOutlineColor: MaterialStateProperty.resolveWith(
            //           (final Set<MaterialState> states) {
            //             if (states.contains(MaterialState.selected)) {
            //               return null;
            //             }
            //             return HAppColor.hGreyColorShade300;
            //           },
            //         ),
            //         activeColor: HAppColor.hBluePrimaryColor,
            //         activeTrackColor: HAppColor.hBlueSecondaryColor,
            //         inactiveThumbColor: HAppColor.hWhiteColor,
            //         inactiveTrackColor: HAppColor.hGreyColorShade300,
            //         value: online.value,
            //         onChanged: (changed) async {
            //           online.value = changed;
            //           HLocationService.checkStatus(online.value);
            //         });
            //   }),
            // )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: hAppDefaultPaddingLR,
            child: FirebaseAnimatedList(
              sort: (a, b) {
                return ((b.value as Map)['OrderDate'] as int)
                    .compareTo(((a.value as Map)['OrderDate'] as int));
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              query: FirebaseDatabase.instance.ref().child('Orders'),
              itemBuilder: (context, snapshot, animation, index) {
                final orderData = snapshot.value as Map;
                if (orderData.isEmpty || orderData == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Không có đơn mới bây giờ'),
                  );
                } else if (orderData['StoreOrders'] == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Không có đơn mới bây giờ'),
                  );
                } else {
                  final storeOrdersData =
                      (orderData['StoreOrders'] as List<dynamic>).map((e) {
                    return StoreOrderModel.fromJson(jsonDecode(jsonEncode(e)));
                  }).toList();
                  final storeId =
                      AuthenticationRepository.instance.authUser!.uid;
                  final index = storeOrdersData
                      .indexWhere((store) => store.storeId == storeId);
                  if (index >= 0) {
                    final order = OrderModel.fromJson(
                        jsonDecode(jsonEncode(snapshot.value))
                            as Map<String, dynamic>);

                    int numberOfCart = 0;
                    final productOrders = order.orderProducts
                        .where((element) => element.storeId == storeId)
                        .toList();
                    for (var product in productOrders) {
                      numberOfCart += product.quantity;
                    }
                    return GestureDetector(
                      onTap: () => Get.toNamed(HAppRoutes.orderDetail,
                          arguments: {'orderId': order.oderId, 'index': index}),
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(
                              bottom: hAppDefaultPadding / 2),
                          decoration: BoxDecoration(
                              color: HAppColor.hWhiteColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  width: 1,
                                  color: HAppColor.hGreyColorShade300)),
                          child: Column(children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                      '#${(order.oderId).substring(0, 15)}...',
                                      style: HAppStyle.label2Bold.copyWith(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          DateFormat('h:mm a')
                                              .format(order.orderDate!),
                                        ),
                                        Text(
                                          DateFormat('EEEE, d-M-y', 'vi')
                                              .format(order.orderDate!),
                                          style: HAppStyle.paragraph3Regular
                                              .copyWith(
                                                  color: HAppColor
                                                      .hGreyColorShade600),
                                        ),
                                      ],
                                    ),
                                  ]),
                                ]),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                    child: ProductListStackWidget(
                                  maxItems: 6,
                                  items: productOrders,
                                )),
                                Text(
                                  'Số lượng: $numberOfCart',
                                  style: HAppStyle.paragraph2Bold.copyWith(
                                      color: HAppColor.hBluePrimaryColor),
                                ),
                              ],
                            )
                          ])),
                    );
                  } else {
                    return Container();
                  }
                }
              },
            ),
          ),
        ));
  }

  Map<String, dynamic> convertToMap(Map data) {
    final Map<String, dynamic> map = {};
    data.forEach((key, value) {
      if (key is String) {
        map[key] = value;
      }
    });
    return map;
  }
}

class ProductItemWidget extends StatelessWidget {
  ProductItemWidget({
    super.key,
    required this.model,
    required this.storeIcon,
    required this.compare,
    this.modelCompare,
    this.differentText,
    this.compareOperator,
    this.comparePrice,
  });
  final ProductModel model;
  final ProductModel? modelCompare;
  final bool storeIcon;
  final bool compare;
  final String? differentText;
  final String? compareOperator;
  final String? comparePrice;

  final productController = Get.put(ProductController());
  // final detailController = Get.put(DetailController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.zero,
        width: 165,
        decoration: BoxDecoration(
            color: HAppColor.hWhiteColor,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              ImageNetwork(
                image: model.image,
                height: 165,
                width: HAppSize.deviceWidth,
                duration: 500,
                curve: Curves.easeIn,
                onPointer: true,
                debugPrint: false,
                fullScreen: false,
                fitAndroidIos: BoxFit.fill,
                fitWeb: BoxFitWeb.fill,
                borderRadius: BorderRadius.circular(10),
                // onLoading: CustomShimmerWidget.rectangular(height: 165),
                onError: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                onTap: () => null,
              ),
              model.salePersent != 0
                  ? Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: HAppColor.hOrangeColor),
                        child: Text('${model.salePersent}%',
                            style: HAppStyle.label4Bold
                                .copyWith(color: HAppColor.hWhiteColor)),
                      ),
                    )
                  : Container(),
              // Positioned(
              //   top: 10,
              //   right: 10,
              //   child: GestureDetector(
              //     onTap: () => productController.addProductInFavorited(model),
              //     child: Container(
              //       width: 32,
              //       height: 32,
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(100),
              //           color: HAppColor.hBackgroundColor),
              //       child: Center(
              //           child: Obx(
              //         () =>
              //             !productController.isFavoritedProducts.contains(model)
              //                 ? const Icon(
              //                     EvaIcons.heartOutline,
              //                     color: HAppColor.hGreyColor,
              //                   )
              //                 : const Icon(
              //                     EvaIcons.heart,
              //                     color: HAppColor.hRedColor,
              //                   ),
              //       )),
              //     ),
              //   ),
              // ),
              model.status != "Còn hàng"
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5)),
                            color: HAppColor.hGreyColorShade300),
                        child: Center(
                            child: Text(
                          model.status,
                          style: HAppStyle.label4Regular,
                        )),
                      ),
                    )
                  : Container()
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                                CategoryController
                                    .instance
                                    .listOfCategory[int.parse(model.categoryId)]
                                    .name,
                                style: HAppStyle.paragraph3Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600,
                                    overflow: TextOverflow.ellipsis))),
                        Text(model.unit,
                            style: HAppStyle.paragraph3Regular
                                .copyWith(color: HAppColor.hGreyColorShade600)),
                      ],
                    ),
                    gapH4,
                    Text(
                      model.name,
                      style: HAppStyle.label2Bold.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    gapH4,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              EvaIcons.star,
                              color: HAppColor.hOrangeColor,
                              size: 16,
                            ),
                            gapW2,
                            Text.rich(
                              TextSpan(
                                style: HAppStyle.paragraph2Bold,
                                text: model.rating.toStringAsFixed(1),
                                children: [
                                  TextSpan(
                                    text: '/5',
                                    style: HAppStyle.paragraph3Regular.copyWith(
                                        color: HAppColor.hGreyColorShade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text.rich(
                          TextSpan(
                            style: HAppStyle.paragraph2Bold,
                            text: '${model.countBuyed} ',
                            children: [
                              TextSpan(
                                text: 'Đã bán',
                                style: HAppStyle.paragraph3Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
            ),
            const Spacer(),
            !compare
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 45,
                        padding: const EdgeInsets.only(left: 10),
                        child: Center(
                          child: model.salePersent == 0
                              ? Text(
                                  HAppUtils.vietNamCurrencyFormatting(
                                      model.price),
                                  style: HAppStyle.label2Bold.copyWith(
                                      color: HAppColor.hBluePrimaryColor),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        HAppUtils.vietNamCurrencyFormatting(
                                            model.price),
                                        style: HAppStyle.paragraph3Bold
                                            .copyWith(
                                                color: HAppColor.hGreyColor,
                                                decoration: TextDecoration
                                                    .lineThrough)),
                                    Text(
                                        HAppUtils.vietNamCurrencyFormatting(
                                            model.priceSale),
                                        style: HAppStyle.label2Bold.copyWith(
                                            color: HAppColor.hOrangeColor,
                                            decoration: TextDecoration.none))
                                  ],
                                ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: model.salePersent == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        compareOperator == '>'
                                            ? const Icon(
                                                EvaIcons
                                                    .diagonalArrowRightUpOutline,
                                                color: HAppColor.hRedColor,
                                                size: 20,
                                              )
                                            : compareOperator == "<"
                                                ? const Icon(
                                                    EvaIcons
                                                        .diagonalArrowRightDownOutline,
                                                    color: Colors.greenAccent,
                                                    size: 20,
                                                  )
                                                : Container(),
                                        gapW4,
                                        Text(
                                          compareOperator == "="
                                              ? "Ngang nhau"
                                              : "$comparePrice",
                                          style: HAppStyle.paragraph3Regular,
                                        )
                                      ],
                                    ),
                                    Text(
                                        HAppUtils.vietNamCurrencyFormatting(
                                            model.price),
                                        style: HAppStyle.label2Bold.copyWith(
                                            color: HAppColor.hBluePrimaryColor,
                                            decoration: TextDecoration.none))
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        compareOperator == '>'
                                            ? const Icon(
                                                EvaIcons
                                                    .diagonalArrowRightUpOutline,
                                                color: HAppColor.hRedColor,
                                                size: 20,
                                              )
                                            : compareOperator == "<"
                                                ? const Icon(
                                                    EvaIcons
                                                        .diagonalArrowRightDownOutline,
                                                    color: Colors.greenAccent,
                                                    size: 20,
                                                  )
                                                : Container(),
                                        gapW4,
                                        Text(
                                          compareOperator == "="
                                              ? "Bằng giá"
                                              : "$comparePrice",
                                          style: HAppStyle.paragraph3Regular,
                                        )
                                      ],
                                    ),
                                    Text(
                                        HAppUtils.vietNamCurrencyFormatting(
                                            model.priceSale),
                                        style: HAppStyle.label2Bold.copyWith(
                                            color: HAppColor.hOrangeColor,
                                            decoration: TextDecoration.none))
                                  ],
                                )),
                      GestureDetector(
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: HAppColor.hBluePrimaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Center(
                              child: Image.asset(
                            'assets/images/other/search_tick.png',
                            height: 20,
                            width: 20,
                          )),
                        ),
                        // onTap: () => Get.toNamed(HAppRoutes.compare),
                      )
                    ],
                  )
          ],
        ),
      ),
      onTap: () {
        Get.toNamed(
          HAppRoutes.productDetail,
          arguments: {
            'model': model,
          },
          preventDuplicates: false,
        );
      },
    );
  }
}

class ProductListStackWidget extends StatelessWidget {
  const ProductListStackWidget({
    super.key,
    required this.items,
    this.maxItems = 5,
    this.stackHeight = 60,
  });

  final List<ProductInCartModel> items;
  final int maxItems;
  final double stackHeight;

  @override
  Widget build(BuildContext context) {
    bool checkMax = items.length < maxItems;
    return SizedBox(
        height: stackHeight,
        child: Stack(
          children: List.generate(
            checkMax ? items.length : maxItems,
            (index) => checkMax
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset((index) * 40, 0),
                      child: ProductItemStack(model: items[index]),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset((index) * 40, 0),
                      child: index < maxItems - 1
                          ? ProductItemStack(model: items[index])
                          : Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HAppColor.hBackgroundColor),
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                      child: Text(
                                    "+${(items.length - maxItems + 1)}",
                                    style: HAppStyle.paragraph2Regular,
                                  )))),
                    ),
                  ),
          ),
        ));
  }
}

class ProductItemStack extends StatelessWidget {
  ProductItemStack({
    super.key,
    required this.model,
    this.child,
  });

  ProductInCartModel model;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: HAppColor.hGreyColorShade300),
      padding: const EdgeInsets.all(2),
      child: Container(
        alignment: Alignment.bottomLeft,
        // padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: NetworkImage(model.image!), fit: BoxFit.fill)),
        child: RoundedBackgroundText(
          'x${model.quantity}',
          style: HAppStyle.paragraph3Bold.copyWith(
            color: HAppColor.hWhiteColor,
          ),
          backgroundColor: HAppColor.hBluePrimaryColor,
        ),
      ),
    );
  }
}
