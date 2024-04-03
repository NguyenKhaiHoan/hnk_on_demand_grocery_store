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
import 'package:on_demand_grocery_store/src/features/personalization/models/user_address_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/category_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/order_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/order_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/product_in_cart_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/store_note_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/user_model.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/services/location_service.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({
    super.key,
  });

  final orderController = Get.put(OrderController());

  final String orderId = Get.arguments['orderId'];
  // final StoreOrderModel storeOrder = Get.arguments['storeOrder'];
  // final List<ProductInCartModel> products = Get.arguments['productOrders'];
  // final int price = Get.arguments['totalPrice'];
  // final int numberOfCart = Get.arguments['numberOfCart'];
  final int index = Get.arguments['index'];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref().child('Orders/$orderId').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(color: HAppColor.hBluePrimaryColor),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Lỗi, không thể tải dữ liệu'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Text('Lỗi, không có dữ liệu để hiển thị'),
          );
        }

        OrderModel order = OrderModel.fromJson(
            jsonDecode(jsonEncode(snapshot.data!.snapshot.value))
                as Map<String, dynamic>);

        orderController.acceptOrder.value =
            order.storeOrders[index].acceptByStore;

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
                  Text(
                    'Đơn hàng #${(order.oderId).substring(0, 15)}...',
                    style: HAppStyle.heading4Style,
                  ),
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
                      ),
                    ]),
                  ),
                  gapH12,
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
                          )),
                      gapH6,
                      Divider(
                        color: HAppColor.hGreyColorShade300,
                      ),
                      gapH6,
                      SectionWidget(
                        title: 'Tổng thu',
                        title2: HAppUtils.vietNamCurrencyFormatting(order
                            .orderProducts
                            .where((element) =>
                                element.storeId ==
                                AuthenticationRepository.instance.authUser!.uid)
                            .fold(
                                0,
                                (previous, current) =>
                                    previous + current.price!)),
                        down: false,
                      ),
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
                      return ProductItemHorizalWidget(
                          model: order.orderProducts
                              .where((element) =>
                                  element.storeId ==
                                  AuthenticationRepository
                                      .instance.authUser!.uid)
                              .toList()[index]);
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
                          TextButton(
                              onPressed: () {
                                orderController.acceptOrder.value = -1;
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
                              });
                              order.storeOrders[index].acceptByStore = 1;
                              orderController
                                  .sendNotificationToDeliveryPerson(order);
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
  });

  final String? title2;
  final String title;
  final bool down;
  final UserAddressModel? userAddress;

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
              userAddress != null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userAddress!.name,
                              style: HAppStyle.heading5Style,
                            ),
                            Text(userAddress!.phoneNumber),
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

class ProductItemHorizalWidget extends StatelessWidget {
  ProductItemHorizalWidget({
    super.key,
    required this.model,
  });
  final ProductInCartModel model;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
