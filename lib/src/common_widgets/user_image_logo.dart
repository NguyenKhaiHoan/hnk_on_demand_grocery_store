import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:on_demand_grocery_store/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/shop/controllers/root_controller.dart';

class UserImageLogoWidget extends StatelessWidget {
  UserImageLogoWidget({
    super.key,
    required this.size,
    required this.hasFunction,
  });

  final bool hasFunction;
  final storeController = StoreController.instance;
  final rootController = RootController.instance;

  final double size;

  @override
  Widget build(BuildContext context) {
    return storeController.isLoading.value ||
            storeController.isUploadImageLoading.value
        ? CustomShimmerWidget.circular(width: size, height: size)
        : storeController.user.value.storeImage == ''
            ? GestureDetector(
                onTap: () =>
                    hasFunction ? rootController.animateToScreen(4) : null,
                child: Container(
                  color: HAppColor.hBackgroundColor,
                  width: size,
                  height: size,
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/logos/logo.png'),
                  ),
                ))
            : ImageNetwork(
                image: storeController.user.value.storeImage,
                height: size,
                width: size,
                duration: 500,
                curve: Curves.easeIn,
                onPointer: true,
                debugPrint: false,
                fullScreen: false,
                fitAndroidIos: BoxFit.cover,
                fitWeb: BoxFitWeb.cover,
                borderRadius: BorderRadius.circular(100),
                onLoading:
                    CustomShimmerWidget.circular(width: size, height: size),
                onError: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                onTap: () =>
                    hasFunction ? rootController.animateToScreen(4) : null,
              );
  }
}
