import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_store/src/common_widgets/user_image_logo.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/chat/all_chat_screen.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/product/product_infomation_screen.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/voucher/add_voucher_screen.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/voucher/all_voucher_screen.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final storeController = StoreController.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserImageLogoWidget(size: 70, hasFunction: false),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Obx(() => storeController.isLoading.value
                              ? CustomShimmerWidget.rectangular(height: 8)
                              : Text(
                                  storeController.user.value.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: HAppStyle.heading4Style
                                      .copyWith(color: HAppColor.hWhiteColor),
                                )),
                        ),
                        IconButton(
                            onPressed: () => Get.toNamed(HAppRoutes.changeName),
                            icon: const Icon(
                              EvaIcons.edit2Outline,
                              color: HAppColor.hWhiteColor,
                            ))
                      ],
                    ),
                  ],
                ),
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    Divider(
                      color: HAppColor.hGreyColorShade300,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(HAppRoutes.profileDetail);
                      },
                      child: const MenuItem(
                        icon: Icon(
                            color: HAppColor.hWhiteColor,
                            EvaIcons.personOutline),
                        title: 'Hồ sơ',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const MenuItem(
                        icon: Icon(
                            color: HAppColor.hWhiteColor,
                            EvaIcons.shoppingBagOutline),
                        title: 'Đơn hàng',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(AllChatScreen());
                      },
                      child: const MenuItem(
                        icon: Icon(
                            color: HAppColor.hWhiteColor,
                            EvaIcons.messageSquareOutline),
                        title: 'Tin nhắn',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(const AllVoucherScreen());
                      },
                      child: const MenuItem(
                        icon: Icon(
                            color: HAppColor.hWhiteColor, EvaIcons.giftOutline),
                        title: 'Mã ưu đãi',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(const ProductInformationScreen());
                      },
                      child: const MenuItem(
                        icon: Icon(
                            color: HAppColor.hWhiteColor, EvaIcons.gridOutline),
                        title: 'Sản phẩm',
                      ),
                    ),
                    const MenuItem(
                      icon: Icon(
                          color: HAppColor.hWhiteColor, EvaIcons.bellOutline),
                      title: 'Thông báo',
                    ),
                    const MenuItem(
                      icon: Icon(
                          color: HAppColor.hWhiteColor,
                          EvaIcons.settingsOutline),
                      title: 'Cài đặt',
                    ),
                    const MenuItem(
                      icon: Icon(
                          color: HAppColor.hWhiteColor,
                          EvaIcons.headphonesOutline),
                      title: 'Liên hệ',
                    ),
                    const MenuItem(
                      icon: Icon(
                          color: HAppColor.hWhiteColor,
                          EvaIcons.questionMarkCircleOutline),
                      title: 'Câu hỏi thường gặp',
                    ),
                  ],
                ),
              ],
            ),
            MenuItem(
              onPressed: () => AuthenticationRepository.instance.logOut(),
              title: "Logout",
              icon: const Icon(EvaIcons.logOutOutline,
                  color: HAppColor.hWhiteColor),
            )
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({super.key, this.icon, required this.title, this.onPressed});

  final Widget? icon;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon != null ? icon! : Container(),
          gapW6,
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HAppStyle.paragraph2Regular
                .copyWith(color: HAppColor.hWhiteColor),
          ),
        ],
      ),
    );
  }
}
