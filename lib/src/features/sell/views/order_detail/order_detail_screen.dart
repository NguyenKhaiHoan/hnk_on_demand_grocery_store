import 'dart:convert';
import 'dart:developer';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/user_address_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/category_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/delivery_person_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/order_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/product_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/delivery_person_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/store_note_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/user_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/order_detail/chat_order.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/order_detail/generate_qr_widget.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/repositories/product_repository.dart';
import 'package:on_demand_grocery_store/src/services/location_service.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({
    super.key,
  });

  final orderController = Get.put(OrderController());
  final deliveryPersonController = Get.put(DeliveryPersonController());

  final String orderId = Get.arguments['orderId'];
  final int index = Get.arguments['index'];
  var isSend = false.obs;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref().child('Orders/$orderId').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(color: HAppColor.hBluePrimaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back();
          });
          return const SizedBox();
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back();
          });
          return const SizedBox();
        }

        OrderModel order = OrderModel.fromJson(
            jsonDecode(jsonEncode(snapshot.data!.snapshot.value))
                as Map<String, dynamic>);

        orderController.acceptOrder.value =
            order.storeOrders[index].acceptByStore;

        if (order.deliveryPerson == null &&
            !isSend.value &&
            order.storeOrders
                    .where((element) =>
                        element.storeId ==
                        StoreController.instance.user.value.id)
                    .first
                    .acceptByStore ==
                1) {
          isSend.value = true;
          orderController.sendNotificationToDeliveryPerson(order);
        }

        return Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Padding(
                  padding: hAppDefaultPaddingL,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HAppColor.hGreyColorShade300,
                          width: 1.5,
                        ),
                        color: HAppColor.hBackgroundColor),
                    child: const Center(
                      child: Icon(
                        EvaIcons.arrowBackOutline,
                      ),
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text('Chi tiết đơn hàng'),
              backgroundColor: HAppColor.hBackgroundColor,
            ),
            body: SingleChildScrollView(
                child: Padding(
              padding: hAppDefaultPaddingLR,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      'Đơn hàng #${(order.oderId).substring(0, 15)}...',
                      style: HAppStyle.heading4Style,
                    ),
                    gapW6,
                    GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('Mã QR'),
                                content: GenerateCodeWidget(
                                    qrData: order.oderId
                                        .substring(orderId.length - 4)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text(
                                      'Thoát',
                                      style: HAppStyle.label4Bold.copyWith(
                                          color: HAppColor.hBluePrimaryColor),
                                    ),
                                  ),
                                ],
                              )),
                      child: const Icon(EvaIcons.eye),
                    )
                  ]),
                  gapH6,
                  Text(
                    'Dưới đây là chi tiết về đơn hàng',
                    style: HAppStyle.paragraph3Regular
                        .copyWith(color: HAppColor.hGreyColorShade600),
                  ),
                  gapH12,
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: HAppColor.hWhiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      SectionWidget(
                        title: 'Ghi chú',
                        down: true,
                        title2: order.storeOrders
                            .where((element) =>
                                element.storeId ==
                                AuthenticationRepository.instance.authUser!.uid)
                            .first
                            .note,
                        isUser: true,
                      ),
                      gapH6,
                      Divider(
                        color: HAppColor.hGreyColorShade300,
                      ),
                      gapH6,
                      SectionWidget(
                        title: 'Địa chỉ khách hàng',
                        down: true,
                        userAddress: order.orderUserAddress,
                        order: order,
                        anotherId: order.orderUserId,
                        isUser: true,
                      ),
                    ]),
                  ),
                  gapH12,
                  order.deliveryPerson != null
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: HAppColor.hWhiteColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              order.deliveryPerson!.image! != ''
                                  ? ImageNetwork(
                                      image: order.deliveryPerson!.image!,
                                      height: 60,
                                      width: 60,
                                      borderRadius: BorderRadius.circular(100),
                                      onLoading:
                                          const CustomShimmerWidget.circular(
                                              width: 60, height: 60),
                                    )
                                  : Image.asset(
                                      'assets/logos/logo.png',
                                      height: 60,
                                      width: 60,
                                    ),
                              gapW10,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.deliveryPerson!.name!,
                                    style: HAppStyle.heading5Style,
                                  ),
                                  gapH4,
                                  Text(
                                    order.deliveryPerson!.phoneNumber!,
                                    style: HAppStyle.paragraph2Regular.copyWith(
                                        color: HAppColor.hGreyColorShade600),
                                  )
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: const Icon(
                                  EvaIcons.phoneOutline,
                                  size: 18,
                                ),
                              ),
                              gapW10,
                              GestureDetector(
                                onTap: () => Get.to(
                                    const ChatOrderRealtimeScreen(),
                                    arguments: {
                                      'orderId': order.oderId,
                                      'anotherId': order.deliveryPerson!.id,
                                      'otherId': AuthenticationRepository
                                          .instance.authUser!.uid
                                    }),
                                child: const Icon(
                                  EvaIcons.messageSquareOutline,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: HAppColor.hWhiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      SectionWidget(
                        title: 'Thời gian',
                        title2: DateFormat('EEEE, d-M-y', 'vi')
                            .format(order.orderDate!),
                        down: false,
                        isUser: true,
                      ),
                      gapH6,
                      Divider(
                        color: HAppColor.hGreyColorShade300,
                      ),
                      gapH6,
                      Obx(() => SectionWidget(
                            title: 'Trạng thái đơn hàng',
                            title2: orderController.acceptOrder.value == 0
                                ? 'Đang chờ xác nhận'
                                : orderController.acceptOrder.value == -1
                                    ? 'Từ chối'
                                    : 'Đã xác nhận',
                            down: false,
                            isUser: true,
                          )),
                      gapH6,
                      Divider(
                        color: HAppColor.hGreyColorShade300,
                      ),
                      gapH6,
                      SectionWidget(
                        title: 'Tổng thu',
                        title2: order.voucher != null
                            ? HAppUtils.vietNamCurrencyFormatting(
                                order.orderProducts.where((element) => element.storeId == StoreController.instance.user.value.id).map((product) => product.price! * product.quantity).fold(
                                        0,
                                        (previous, current) =>
                                            previous + current) -
                                    (order.voucher!.storeId != ''
                                        ? (order.voucher!.storeId ==
                                                StoreController
                                                    .instance.user.value.id
                                            ? order.discount
                                            : 0)
                                        : 0))
                            : HAppUtils.vietNamCurrencyFormatting(order.orderProducts
                                .where((element) =>
                                    element.storeId == StoreController.instance.user.value.id)
                                .map((product) => product.price! * product.quantity)
                                .fold(0, (previous, current) => previous + current)),
                        down: false,
                        isUser: true,
                      )
                    ]),
                  ),
                  gapH12,
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.orderProducts
                        .where((element) =>
                            element.storeId ==
                            AuthenticationRepository.instance.authUser!.uid)
                        .toList()
                        .length,
                    itemBuilder: (context, index) {
                      var product = order.orderProducts
                          .where((element) =>
                              element.storeId ==
                              AuthenticationRepository.instance.authUser!.uid)
                          .toList()[index];
                      return ProductItemHorizalOrderWidget(
                        model: product,
                        onTap: () {
                          print('Ấn vào đây');

                          if (product.replacementProduct != null &&
                              (order.replacedProducts == null ||
                                  (order.replacedProducts != null &&
                                      !order.replacedProducts!.any((element) =>
                                          element.replacementProduct!.id ==
                                          product.productId)))) {
                            showModalBottomSheet(
                                context: context,
                                useRootNavigator: true,
                                isScrollControlled: true,
                                builder: (context) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: hAppDefaultPadding,
                                        horizontal: hAppDefaultPadding),
                                    decoration: const BoxDecoration(
                                        color: HAppColor.hBackgroundColor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    child: SingleChildScrollView(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Thay thế sản phẩm",
                                                  style:
                                                      HAppStyle.heading4Style,
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: const Icon(
                                                        EvaIcons.close))
                                              ],
                                            ),
                                            gapH6,
                                            Divider(
                                              color:
                                                  HAppColor.hGreyColorShade300,
                                            ),
                                            gapH12,
                                            ProductItemHorizalOrderWidget(
                                              model: orderController
                                                  .convertToCartProduct(
                                                      product
                                                          .replacementProduct!,
                                                      product.quantity),
                                              onTap: () {},
                                            ),
                                            gapH12,
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      style: OutlinedButton.styleFrom(
                                                          maximumSize: Size(
                                                              HAppSize.deviceWidth *
                                                                  0.5,
                                                              50),
                                                          foregroundColor:
                                                              HAppColor
                                                                  .hRedColor,
                                                          side: const BorderSide(
                                                              color: HAppColor
                                                                  .hRedColor)),
                                                      child: Text(
                                                        "Bỏ",
                                                        style: HAppStyle
                                                            .label2Bold
                                                            .copyWith(
                                                                color: HAppColor
                                                                    .hRedColor),
                                                      )),
                                                ),
                                                gapW10,
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      orderController.replaceProductInCart(
                                                          productId:
                                                              product.productId,
                                                          newReplacementProduct:
                                                              orderController.convertToCartProduct(
                                                                  product
                                                                      .replacementProduct!,
                                                                  product
                                                                      .quantity),
                                                          order: order);
                                                      Get.back();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      maximumSize: Size(
                                                          HAppSize.deviceWidth *
                                                              0.5,
                                                          50),
                                                      backgroundColor: HAppColor
                                                          .hBluePrimaryColor,
                                                    ),
                                                    child: Text(
                                                      "Thay thế",
                                                      style: HAppStyle
                                                          .label2Bold
                                                          .copyWith(
                                                              color: HAppColor
                                                                  .hWhiteColor),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            gapH12,
                                          ]),
                                    ),
                                  );
                                });
                          }
                        },
                      );
                    },
                    separatorBuilder: (context, index) => gapH12,
                  ),
                  gapH24,
                ],
              ),
            )),
            bottomNavigationBar: Obx(() => Container(
                  padding: const EdgeInsets.fromLTRB(
                      hAppDefaultPadding,
                      hAppDefaultPadding,
                      hAppDefaultPadding,
                      hAppDefaultPadding),
                  decoration: BoxDecoration(
                    color: HAppColor.hBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -15),
                        blurRadius: 20,
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text.rich(TextSpan(
                                text: 'Số lượng: ',
                                style: HAppStyle.paragraph2Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600),
                                children: [
                                  TextSpan(
                                      text: order.orderProducts
                                          .where((element) =>
                                              element.storeId ==
                                              AuthenticationRepository
                                                  .instance.authUser!.uid)
                                          .fold(
                                              0,
                                              (previous, current) =>
                                                  previous + current.quantity)
                                          .toString(),
                                      style: HAppStyle.label2Bold.copyWith(
                                          color: HAppColor.hDarkColor))
                                ])),
                          ),
                          order.deliveryPerson != null
                              ? Container()
                              : TextButton(
                                  onPressed: () async {
                                    orderController.acceptOrder.value = -1;
                                    var ref = FirebaseDatabase.instance.ref(
                                        "Orders/$orderId/StoreOrders/$index/");
                                    await ref.update({
                                      "AcceptByStore": -1,
                                    }).then((value) async {
                                      order.storeOrders[index].acceptByStore =
                                          -1;
                                      await orderController
                                          .sendNotificationToUser(order);
                                    });
                                    Get.back();
                                  },
                                  child: Text(
                                    'Từ chối',
                                    style: HAppStyle.paragraph2Regular.copyWith(
                                      color: HAppColor.hRedColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  )),
                          gapW10,
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () async {
                              orderController.acceptOrder.value = 1;
                              var ref = FirebaseDatabase.instance
                                  .ref("Orders/$orderId/StoreOrders/$index/");
                              await ref.update({
                                "AcceptByStore": 1,
                              }).then((value) async {
                                order.storeOrders[index].acceptByStore = 1;
                                await orderController
                                    .sendNotificationToDeliveryPerson(order);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              maximumSize: Size(HAppSize.deviceWidth * 0.5, 50),
                              backgroundColor: HAppColor.hBluePrimaryColor,
                            ),
                            child: orderController.acceptOrder.value == 1
                                ? Text("Đã xác nhận",
                                    style: HAppStyle.label2Bold
                                        .copyWith(color: HAppColor.hWhiteColor))
                                : Text("Xác nhận",
                                    style: HAppStyle.label2Bold.copyWith(
                                        color: HAppColor.hWhiteColor)),
                          )),
                        ],
                      ),
                    ],
                  ),
                )));
      },
    );
  }
}

class SectionWidget extends StatelessWidget {
  const SectionWidget({
    super.key,
    required this.title,
    this.title2,
    required this.down,
    this.userAddress,
    this.order,
    this.anotherId,
    this.deliveryPerson,
    required this.isUser,
  });

  final String? title2;
  final String title;
  final bool down;
  final UserAddressModel? userAddress;
  final DeliveryPersonModel? deliveryPerson;
  final String? anotherId;
  final OrderModel? order;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return down
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: HAppStyle.paragraph2Bold
                    .copyWith(color: HAppColor.hGreyColorShade600),
              ),
              gapH6,
              isUser
                  ? userAddress != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userAddress!.name,
                                  style: HAppStyle.heading5Style,
                                ),
                                Row(
                                  children: [
                                    Text(userAddress!.phoneNumber),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Icon(
                                        EvaIcons.phoneOutline,
                                        size: 18,
                                      ),
                                    ),
                                    gapW10,
                                    GestureDetector(
                                      onTap: () => Get.to(
                                          const ChatOrderRealtimeScreen(),
                                          arguments: {
                                            'orderId': order!.oderId,
                                            'anotherId': order!.orderUserId,
                                            'otherId': AuthenticationRepository
                                                .instance.authUser!.uid
                                          }),
                                      child: const Icon(
                                        EvaIcons.messageSquareOutline,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(userAddress!.toString())
                              ]),
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title2! == '' ? 'Không có ghi chú' : title2!,
                            style: HAppStyle.paragraph2Regular,
                            textAlign: TextAlign.right,
                          ),
                        )
                  : order!.deliveryPerson != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deliveryPerson!.name!,
                                  style: HAppStyle.heading5Style,
                                ),
                                Row(
                                  children: [
                                    Text(deliveryPerson!.phoneNumber!),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Icon(
                                        EvaIcons.phoneOutline,
                                        size: 18,
                                      ),
                                    ),
                                    gapW10,
                                    GestureDetector(
                                      onTap: () => Get.to(
                                          const ChatOrderRealtimeScreen(),
                                          arguments: {
                                            'orderId': order!.oderId,
                                            'anotherId':
                                                order!.deliveryPerson!.id,
                                            'otherId': AuthenticationRepository
                                                .instance.authUser!.uid
                                          }),
                                      child: const Icon(
                                        EvaIcons.messageSquareOutline,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        )
                      : Container()
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: HAppStyle.paragraph2Bold
                      .copyWith(color: HAppColor.hGreyColorShade600),
                ),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title2!,
                    style: HAppStyle.paragraph2Regular,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          );
  }
}

class ProductItemHorizalOrderWidget extends StatelessWidget {
  const ProductItemHorizalOrderWidget({
    super.key,
    required this.model,
    required this.onTap,
  });
  final ProductInCartModel model;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: HAppColor.hWhiteColor,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(model.image!),
                          fit: BoxFit.fitHeight)),
                ),
              ),
            ]),
            gapW10,
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.unit!,
                            style: HAppStyle.paragraph3Regular
                                .copyWith(color: HAppColor.hGreyColorShade600)),
                        gapH6,
                        Text(
                          model.productName!,
                          style: HAppStyle.label2Bold.copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ]),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      HAppUtils.vietNamCurrencyFormatting(model.price!),
                      style: HAppStyle.label2Bold
                          .copyWith(color: HAppColor.hBluePrimaryColor),
                    ),
                    Text('x${model.quantity}')
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class ProductItemHorizalWidget extends StatefulWidget {
  ProductItemHorizalWidget({
    super.key,
    required this.model,
  });
  final ProductModel model;

  @override
  State<ProductItemHorizalWidget> createState() =>
      _ProductItemHorizalWidgetState();
}

class _ProductItemHorizalWidgetState extends State<ProductItemHorizalWidget> {
  final productController = ProductController.instance;

  var status = true.obs;

  @override
  void initState() {
    super.initState();
    status.value = widget.model.status == 'Còn hàng' ? true : false;
  }

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
                          image: NetworkImage(widget.model.image),
                          fit: BoxFit.fill)),
                ),
              ),
              widget.model.salePersent != 0
                  ? Positioned(
                      bottom: 10,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: HAppColor.hOrangeColor),
                        child: Text('${widget.model.salePersent}%',
                            style: HAppStyle.label4Bold
                                .copyWith(color: HAppColor.hWhiteColor)),
                      ),
                    )
                  : Container(),
              Positioned(
                top: 0,
                left: 0,
                child: Obx(() => Switch(
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
                    value: status.value,
                    onChanged: (changed) async {
                      final check = await productController.checkStatus(
                          status.value, widget.model.id);
                      if (check) {
                        status.value = changed;
                      }
                    })),
              )
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
                                        int.parse(widget.model.categoryId)]
                                    .name,
                                style: HAppStyle.paragraph3Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600)),
                            const Spacer(),
                            Text(widget.model.unit,
                                style: HAppStyle.paragraph3Regular.copyWith(
                                    color: HAppColor.hGreyColorShade600)),
                          ],
                        ),
                        gapH8,
                        Text(
                          widget.model.name,
                          style: HAppStyle.label2Bold.copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                        gapH8,
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
                                    text:
                                        widget.model.rating.toStringAsFixed(1),
                                    children: [
                                      TextSpan(
                                        text: '/5',
                                        style: HAppStyle.paragraph3Regular
                                            .copyWith(
                                                color: HAppColor
                                                    .hGreyColorShade600),
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
                                text: '${widget.model.countBuyed} ',
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
                        ),
                      ]),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 45,
                      child: Center(
                        child: widget.model.salePersent == 0
                            ? Text(
                                HAppUtils.vietNamCurrencyFormatting(
                                    widget.model.price),
                                style: HAppStyle.label2Bold.copyWith(
                                    color: HAppColor.hBluePrimaryColor),
                              )
                            : widget.model.status == "Còn hàng"
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          HAppUtils.vietNamCurrencyFormatting(
                                              widget.model.price),
                                          style: HAppStyle.paragraph3Bold
                                              .copyWith(
                                                  color: HAppColor.hGreyColor,
                                                  decoration: TextDecoration
                                                      .lineThrough)),
                                      Text(
                                          HAppUtils.vietNamCurrencyFormatting(
                                              widget.model.priceSale),
                                          style: HAppStyle.label2Bold.copyWith(
                                              color: HAppColor.hOrangeColor,
                                              decoration: TextDecoration.none))
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          style: HAppStyle.label2Bold.copyWith(
                                              color: HAppColor.hOrangeColor,
                                              decoration: TextDecoration.none),
                                          text:
                                              '${HAppUtils.vietNamCurrencyFormatting(widget.model.priceSale)} ',
                                          children: [
                                            TextSpan(
                                              text: HAppUtils
                                                  .vietNamCurrencyFormatting(
                                                      widget.model.price),
                                              style: HAppStyle.label4Regular
                                                  .copyWith(
                                                      color:
                                                          HAppColor.hGreyColor,
                                                      decoration: TextDecoration
                                                          .lineThrough),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
      onTap: () async {},
    );
  }
}
