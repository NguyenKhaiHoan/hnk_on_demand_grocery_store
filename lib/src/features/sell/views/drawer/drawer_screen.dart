import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/drawer/menu_screen.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/home/home_screen.dart';
import 'package:on_demand_grocery_store/src/services/messaging_service.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final zoomDrawerController = ZoomDrawerController();
  final _messagingService = HNotificationService();

  @override
  void initState() {
    super.initState();
    _messagingService.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HAppColor.hBluePrimaryColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: ZoomDrawer(
          controller: zoomDrawerController,
          menuScreen: const MenuScreen(),
          mainScreen: const HomeScreen(),
          style: DrawerStyle.defaultStyle,
          borderRadius: 24.0,
          showShadow: true,
          angle: 0.0,
          drawerShadowsBackgroundColor: HAppColor.hBackgroundColor,
          openCurve: Curves.fastOutSlowIn,
          closeCurve: Curves.bounceIn,
          slideWidth: MediaQuery.of(context).size.width * 0.65),
    );
  }
}
