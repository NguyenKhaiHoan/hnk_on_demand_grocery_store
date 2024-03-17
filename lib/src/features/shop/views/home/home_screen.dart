import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/data/dummy_data.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/category_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/product_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: hAppDefaultPaddingLR,
          child: FirebaseAnimatedList(
            query: FirebaseDatabase.instance.ref().child('Orders'),
            itemBuilder: (context, snapshot, animation, index) {
              final orderData = snapshot.value as Map;
              if (orderData.isEmpty) {
                print('Không có đơn hàng');
                return const Text('Không có đơn mới bây giờ');
              } else {
                print('Có đơn');
                final storeIds =
                    List<String>.from(orderData['OrderStoreIds'] ?? []);

                if (storeIds.contains(
                    AuthenticationRepository.instance.authUser!.uid)) {
                  final products =
                      (orderData['OrderProducts'] as List<dynamic>).map((e) {
                    return ProductInCartModel.fromJson(
                        e.cast<String, dynamic>());
                  }).toList();
                  return Container(
                      padding: const EdgeInsets.all(10),
                      margin:
                          const EdgeInsets.only(bottom: hAppDefaultPadding / 2),
                      decoration: BoxDecoration(
                          color: HAppColor.hWhiteColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              width: 2, color: HAppColor.hGreyColorShade300)),
                      child: Column(children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(
                                  '#${(orderData['OrderId'] as String).substring(0, 10)}...',
                                  style: HAppStyle.label2Bold
                                      .copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      DateFormat('h:mm a').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              orderData['OrderDate'])),
                                    ),
                                    Text(
                                      DateFormat('EEEE, d-M-y', 'vi').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              orderData['OrderDate'])),
                                      style: HAppStyle.paragraph3Regular
                                          .copyWith(
                                              color:
                                                  HAppColor.hGreyColorShade600),
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
                              items: products,
                            )),
                            Text(
                              'Số lượng: ${products.length}',
                              style: HAppStyle.paragraph2Bold
                                  .copyWith(color: HAppColor.hBluePrimaryColor),
                            ),
                          ],
                        )
                      ]));
                } else {
                  print('Có đơn nhưng của cửa hàng khác');
                  return Center(
                    child: Text(
                      'Không có đơn hàng mới',
                      style: HAppStyle.paragraph1Regular
                          .copyWith(color: HAppColor.hGreyColorShade600),
                    ),
                  );
                }
              }
            },
          ),
        ));
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
                      Visibility(
                          visible: model.status == "Còn hàng" ? true : false,
                          child: GestureDetector(
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
                                  // child: model.quantity != 0
                                  //     ? Text(
                                  //         "${model.quantity}",
                                  //         style: HAppStyle.label2Bold.copyWith(
                                  //             color: HAppColor.hWhiteColor),
                                  //       )
                                  //     : const Icon(
                                  //         EvaIcons.plus,
                                  //         color: HAppColor.hWhiteColor,
                                  //       )
                                  ),
                            ),
                            onTap: () {
                              // productController.addProductInCart(model);
                              // if (model.quantity == 0) {
                              //   model.quantity++;
                              //   productController
                              //       .refreshList(productController.isInCart);
                              //   productController.refreshAllList();
                              //   HAppUtils.showToastSuccess(
                              //       Text(
                              //         'Thêm vào Giỏ hàng!',
                              //         style: HAppStyle.label2Bold.copyWith(
                              //             color: HAppColor.hBluePrimaryColor),
                              //       ),
                              //       RichText(
                              //           text: TextSpan(
                              //               style: HAppStyle.paragraph2Regular
                              //                   .copyWith(
                              //                       color: HAppColor
                              //                           .hGreyColorShade600),
                              //               text: 'Bạn đã thêm thành công',
                              //               children: [
                              //             TextSpan(
                              //                 text: ' ${model.name} ',
                              //                 style: HAppStyle.paragraph2Regular
                              //                     .copyWith(
                              //                         color: HAppColor
                              //                             .hBluePrimaryColor)),
                              //             const TextSpan(text: 'vào Giỏ hàng.')
                              //           ])),
                              //       1,
                              //       context,
                              //       const ToastificationCallbacks());
                              // }
                            },
                          ))
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

class ProductItemHorizalWidget extends StatelessWidget {
  ProductItemHorizalWidget({
    super.key,
    required this.model,
  });
  final ProductInCartModel model;

  final productController = ProductController.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 110,
        padding: const EdgeInsets.only(left: 10, top: 10),
        decoration: BoxDecoration(
            color: HAppColor.hWhiteColor,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Stack(children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(model.image!), fit: BoxFit.fill)),
                ),
              ),
            ]),
            gapW10,
            Expanded(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                                CategoryController
                                    .instance
                                    .listOfCategory[
                                        int.parse(model.categoryId!)]
                                    .name,
                                style: HAppStyle.paragraph3Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600)),
                            const Spacer(),
                          ],
                        ),
                        gapH8,
                        Text(
                          model.productName!,
                          style: HAppStyle.label2Bold.copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ]),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        style: HAppStyle.label2Bold.copyWith(
                            color: HAppColor.hOrangeColor,
                            decoration: TextDecoration.none),
                        text: HAppUtils.vietNamCurrencyFormatting(model.price!),
                        children: [],
                      ),
                    ),
                  ],
                ),
              ],
            ))
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
