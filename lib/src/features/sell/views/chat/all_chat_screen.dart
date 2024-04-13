import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/chat_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/chat_model.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/chat/chat_screen.dart';
import 'package:on_demand_grocery_store/src/features/sell/views/chat/chat_tile_widget.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';

class AllChatScreen extends StatelessWidget {
  AllChatScreen({super.key});

  final chatController = Get.put(ChatController());

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
          'Tin nhắn của bạn',
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Chats')
              .where('StoreId',
                  isEqualTo: StoreController.instance.user.value.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerChatTileWidget();
            }

            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text('Không tải được dữ liệu'),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return NotFoundScreenWidget(
                title: 'Không có tin nhắn',
                subtitle: 'Bạn không có tin nhắn với cửa hàng nào ở đây',
                widget: Container(),
                subWidget: Container(),
              );
            }
            final List<ChatModel> list = snapshot.data!.docs
                .map((e) => ChatModel.fromDocumentSnapshot(e))
                .toList();
            return ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  String userId = list[index].userId!;
                  String lastMessage = list[index].lastMessage ?? '';
                  return ChatTileWidget(
                      userId: userId,
                      ontap: () {
                        Get.to(const ChatScreen(),
                            arguments: {'userId': userId});
                      },
                      lastMessage: lastMessage);
                },
                separatorBuilder: (context, index) => gapH12,
                itemCount: list.length);
          },
        ),
      )),
    );
  }
}

class NotFoundScreenWidget extends StatelessWidget {
  const NotFoundScreenWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.widget,
    required this.subWidget,
  });

  final String title;
  final String subtitle;
  final Widget widget;
  final Widget subWidget;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(hAppDefaultPadding),
          child: Column(children: [
            gapH40,
            Container(
              width: HAppSize.deviceWidth * 0.4,
              height: HAppSize.deviceWidth * 0.4,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage('assets/images/other/not_found.jpg'),
                      fit: BoxFit.cover)),
            ),
            gapH24,
            Text(
              title,
              style: HAppStyle.label2Bold,
              textAlign: TextAlign.center,
            ),
            gapH10,
            Text(
              subtitle,
              style: HAppStyle.paragraph2Regular
                  .copyWith(color: HAppColor.hGreyColorShade600),
              textAlign: TextAlign.center,
            ),
            gapH24,
            widget,
            gapH40,
            subWidget,
          ]),
        )
      ],
    );
  }
}
