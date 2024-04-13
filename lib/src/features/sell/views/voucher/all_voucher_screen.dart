import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/store_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/chat_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/voucher_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/chat_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/chat/chat_screen.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/chat/chat_tile_widget.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/voucher/add_voucher_screen.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class AllVoucherScreen extends StatefulWidget {
  const AllVoucherScreen({super.key});

  @override
  State<AllVoucherScreen> createState() => _AllVoucherScreenState();
}

class _AllVoucherScreenState extends State<AllVoucherScreen> {
  final voucherController = Get.put(VoucherController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: hAppDefaultPaddingL,
            child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                )),
          ),
        ),
        title: const Text(
          'Tất cả voucher',
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(
            left: hAppDefaultPadding,
            right: hAppDefaultPadding,
            bottom: hAppDefaultPadding),
        child: Obx(() => FutureBuilder(
            key: Key(
                'Vouchers${voucherController.toggleRefresh.value.toString()}'),
            future: voucherController.fetchAllVouchers(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: HAppColor.hBluePrimaryColor,
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Đã xảy ra sự cố. Xin vui lòng thử lại sau.'),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return Container();
              } else {
                final vouchers = snapshot.data!;
                return Column(
                  children: [
                    ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var voucher = vouchers[index];
                          return CouponCard(
                              height: 170,
                              curveAxis: Axis.vertical,
                              borderRadius: 10,
                              firstChild: Container(
                                padding: const EdgeInsets.all(10),
                                color: HAppColor.hOrangeColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      voucher.type == 'Flat'
                                          ? NumberFormat.compact(locale: 'vi')
                                              .format(voucher.discountValue)
                                          : '${voucher.discountValue} %',
                                      textAlign: TextAlign.center,
                                      style: HAppStyle.heading3Style.copyWith(
                                          color: HAppColor.hWhiteColor),
                                    ),
                                    Text(
                                      "Tất cả",
                                      style: HAppStyle.paragraph2Regular
                                          .copyWith(
                                              color: HAppColor.hWhiteColor),
                                    ),
                                  ],
                                ),
                              ),
                              secondChild: Container(
                                padding: const EdgeInsets.all(10),
                                color: HAppColor.hWhiteColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      voucher.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: HAppStyle.label2Bold,
                                    ),
                                    // const Text(
                                    //   "Từ GroFast",
                                    //   style: HAppStyle.paragraph3Regular,
                                    // ),
                                    gapH4,
                                    voucher.minAmount != 0 ||
                                            voucher.minAmount != null
                                        ? Text(
                                            "Điều kiện: Đơn hàng phải có giá trị trên ${HAppUtils.vietNamCurrencyFormatting(voucher.minAmount!)}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: HAppStyle.paragraph3Regular
                                                .copyWith(
                                                    color: HAppColor
                                                        .hBluePrimaryColor),
                                          )
                                        : Container(),
                                    const Spacer(),
                                    Text(
                                      "HSD: ${DateFormat('dd/MM/yyyy').format(voucher.endDate)}",
                                      style: HAppStyle.paragraph3Regular,
                                    ),
                                  ],
                                ),
                              ));
                        },
                        separatorBuilder: (context, index) => gapH12,
                        itemCount: vouchers.length),
                    gapH24,
                  ],
                );
              }
            }))),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddVoucherScreen());
        },
        shape: const CircleBorder(),
        backgroundColor: HAppColor.hBluePrimaryColor,
        child: const Icon(
          EvaIcons.plus,
          color: HAppColor.hWhiteColor,
        ),
      ),
    );
  }
}
