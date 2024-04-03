import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_store/src/common_widgets/user_image_logo.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  @override
  bool get wantKeepAlive => true;

  final userController = StoreController.instance;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          // actions: [
          //   Padding(
          //     padding: hAppDefaultPaddingR,
          //     child: CartCircle(),
          //   )
          // ],
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: const Padding(
            padding: hAppDefaultPaddingL,
            child: Text(
              'GroFast',
              style: HAppStyle.heading3Style,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: hAppDefaultPaddingLR,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () async {
                  Get.toNamed(HAppRoutes.profileDetail);
                  // await userController.loadingUserRecord();
                },
                child: Row(
                  children: [
                    UserImageLogoWidget(
                      size: 80,
                      hasFunction: false,
                    ),
                    gapW10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => userController.isLoading.value
                            ? CustomShimmerWidget.rectangular(height: 10)
                            : Text(
                                userController.user.value.name,
                                style: HAppStyle.heading4Style,
                              )),
                        gapH4,
                        Text(
                          'Xem hồ sơ',
                          style: HAppStyle.paragraph3Regular
                              .copyWith(color: HAppColor.hGreyColorShade600),
                        )
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    )
                  ],
                ),
              ),
              gapH20,
              const Text(
                'Tài khoản',
                style: HAppStyle.heading4Style,
              ),
              // GestureDetector(
              //   onTap: () {
              //     final registrationController =
              //         Get.put(RegistrationController());
              //     registrationController.registerStoreLocationInGeofire();
              //   },
              //   child: Text('Set location'),
              // ),
              GestureDetector(
                onTap: () => Get.toNamed(HAppRoutes.allProduct),
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(EvaIcons.grid),
                  title: Text('Tất cả sản phẩm'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () => Get.toNamed(HAppRoutes.cart),
              //   child: const ListTile(
              //     contentPadding: EdgeInsets.zero,
              //     leading: Icon(EvaIcons.shoppingCartOutline),
              //     title: Text('Giỏ hàng'),
              //     trailing: Icon(
              //       Icons.arrow_forward_ios,
              //       size: 15,
              //     ),
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () => Get.toNamed(HAppRoutes.allAddress),
              //   child: const ListTile(
              //     contentPadding: EdgeInsets.zero,
              //     leading: Icon(EneftyIcons.location_outline),
              //     title: Text('Địa chỉ'),
              //     trailing: Icon(
              //       Icons.arrow_forward_ios,
              //       size: 15,
              //     ),
              //   ),
              // ),
              // const ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(EvaIcons.pricetagsOutline),
              //   title: Text('Mã ưu đãi'),
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: 15,
              //   ),
              // ),
              // const ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(EvaIcons.bellOutline),
              //   title: Text('Thông báo'),
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: 15,
              //   ),
              // ),
              // const ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(EvaIcons.externalLinkOutline),
              //   title: Text('Giới thiệu với bạn bè'),
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: 15,
              //   ),
              // ),
              // const ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(EvaIcons.settingsOutline),
              //   title: Text('Cài đặt'),
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: 15,
              //   ),
              // ),
              // gapH20,
              // const Text(
              //   'Trợ giúp và hỗ trợ',
              //   style: HAppStyle.heading4Style,
              // ),
              // const ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(EvaIcons.headphonesOutline),
              //   title: Text('Liên hệ'),
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: 15,
              //   ),
              // ),
              // const ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   leading: Icon(EvaIcons.questionMarkCircleOutline),
              //   title: Text('Câu hỏi thường gặp'),
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: 15,
              //   ),
              // ),
              gapH6,
              Center(
                child: GestureDetector(
                  onTap: () {
                    AuthenticationRepository.instance.logOut();
                  },
                  child: const Text('Đăng xuất'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(HAppRoutes.orderDetail);
                },
                child: Text('Set location'),
              ),
              gapH24,
            ]),
          ),
        ));
  }
}
