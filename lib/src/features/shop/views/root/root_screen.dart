import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/features/personalization/views/profile/profile_screen.dart';
import 'package:on_demand_grocery_store/src/features/shop/controllers/root_controller.dart';
import 'package:on_demand_grocery_store/src/features/shop/views/home/home_screen.dart';
import 'package:on_demand_grocery_store/src/features/shop/views/root/widgets/bottom_nav_bar.dart';
import 'package:on_demand_grocery_store/src/services/location_service.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final screens = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      HLocationService.getNearbyDeliveryPersons();
    });
  }

  final rootController = Get.put(RootController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: rootController.screenController,
          children: screens,
        ),
        bottomNavigationBar: Container(
          color: HAppColor.hTransparentColor,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: const BottomNavBar(),
        ),
      ),
    );
  }
}
