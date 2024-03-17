// import 'package:enefty_icons/enefty_icons.dart';
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import 'package:image_network/image_network.dart';
// import 'package:lorem_ipsum/lorem_ipsum.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:readmore/readmore.dart';
// import 'package:toastification/toastification.dart';

// class ProductDetailScreen extends StatelessWidget {
//   ProductDetailScreen({super.key});

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold();
//   // }

//   final detailController = Get.put(DetailController());
//   final productController = Get.put(ProductController());

//   final ProductModel model = Get.arguments['model'];
//   final RxList<ProductModel> list = Get.arguments['list'];
//   final List<double> rates = [0.1, 0.3, 0.5, 0.7, 0.9];

//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(Duration.zero, () {
//       detailController.showAppBar.value = false;
//       detailController.showNameInAppBar.value = false;
//       // detailController.setCount(model);
//     });
//     return Scaffold(
//       body: SafeArea(
//           child: Stack(
//         children: [
//           ImageNetwork(
//             image: model.image,
//             height: HAppSize.deviceHeight * 0.5,
//             width: HAppSize.deviceWidth,
//             duration: 500,
//             curve: Curves.easeIn,
//             onPointer: true,
//             debugPrint: false,
//             fullScreen: false,
//             fitAndroidIos: BoxFit.cover,
//             fitWeb: BoxFitWeb.cover,
//             onLoading: const CircularProgressIndicator(
//               color: HAppColor.hBluePrimaryColor,
//             ),
//             onError: const Icon(
//               Icons.error,
//               color: Colors.red,
//             ),
//             onTap: () => null,
//           ),
//           Obx(() => SizedBox(
//                 height: 80,
//                 child: PreferredSize(
//                     preferredSize: const Size.fromHeight(80.0),
//                     child: AppBar(
//                       titleSpacing: 0,
//                       centerTitle: false,
//                       automaticallyImplyLeading: false,
//                       backgroundColor: detailController.showAppBar.value
//                           ? HAppColor.hBackgroundColor
//                           : HAppColor.hTransparentColor,
//                       toolbarHeight: 80,
//                       title: Padding(
//                         padding: hAppDefaultPaddingL,
//                         child: Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 Get.back();
//                                 detailController.changeShowNameInAppBar(false);
//                                 detailController.changeShowAppBar(false);
//                               },
//                               child: Container(
//                                 width: 40,
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: HAppColor.hGreyColorShade300,
//                                       width: 1.5,
//                                     ),
//                                     color: HAppColor.hBackgroundColor),
//                                 child: const Center(
//                                   child: Icon(
//                                     EvaIcons.arrowBackOutline,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             gapW16,
//                             Expanded(
//                               child: AnimatedOpacity(
//                                 opacity: detailController.showNameInAppBar.value
//                                     ? 1
//                                     : 0,
//                                 duration: const Duration(milliseconds: 300),
//                                 child: Text(
//                                   model.name,
//                                   style: HAppStyle.heading4Style,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       actions: [
//                         gapW10,
//                         // AnimatedOpacity(
//                         //   opacity: detailController.showAppBar.value ? 1 : 0,
//                         //   duration: const Duration(milliseconds: 300),
//                         //   child: GestureDetector(
//                         //     onTap: () {
//                         //       productController.addProductInFavorited(model);
//                         //       if (productController.isFavoritedProducts
//                         //           .contains(model)) {
//                         //         HAppUtils.showToastSuccess(
//                         //             Text(
//                         //               'Thêm vào Yêu thích!',
//                         //               style: HAppStyle.label2Bold.copyWith(
//                         //                   color: HAppColor.hBluePrimaryColor),
//                         //             ),
//                         //             RichText(
//                         //                 text: TextSpan(
//                         //                     style: HAppStyle.paragraph2Regular
//                         //                         .copyWith(
//                         //                             color: HAppColor
//                         //                                 .hGreyColorShade600),
//                         //                     text: 'Bạn đã thêm thành công',
//                         //                     children: [
//                         //                   TextSpan(
//                         //                       text: ' ${model.name} ',
//                         //                       style: HAppStyle.paragraph2Regular
//                         //                           .copyWith(
//                         //                               color: HAppColor
//                         //                                   .hBluePrimaryColor)),
//                         //                   const TextSpan(text: 'vào Yêu thích.')
//                         //                 ])),
//                         //             1,
//                         //             context,
//                         //             const ToastificationCallbacks());
//                         //       } else {
//                         //         HAppUtils.showToastSuccess(
//                         //             Text(
//                         //               'Xóa khỏi Yêu thích!',
//                         //               style: HAppStyle.label2Bold.copyWith(
//                         //                   color: HAppColor.hBluePrimaryColor),
//                         //             ),
//                         //             RichText(
//                         //                 text: TextSpan(
//                         //                     style: HAppStyle.paragraph2Regular
//                         //                         .copyWith(
//                         //                             color: HAppColor
//                         //                                 .hGreyColorShade600),
//                         //                     text: 'Bạn đã xóa thành công',
//                         //                     children: [
//                         //                   TextSpan(
//                         //                       text: ' ${model.name} ',
//                         //                       style: HAppStyle.paragraph2Regular
//                         //                           .copyWith(
//                         //                               color: HAppColor
//                         //                                   .hBluePrimaryColor)),
//                         //                   const TextSpan(
//                         //                       text: 'khỏi Yêu thích.')
//                         //                 ])),
//                         //             1,
//                         //             context,
//                         //             const ToastificationCallbacks());
//                         //       }
//                         //     },
//                         //     child: Container(
//                         //       width: 40,
//                         //       height: 40,
//                         //       decoration: BoxDecoration(
//                         //           border: Border.all(
//                         //             color: HAppColor.hGreyColorShade300,
//                         //             width: 1.5,
//                         //           ),
//                         //                          shape: BoxShape.circle,
//                         //           color: HAppColor.hBackgroundColor),
//                         //       child: Center(
//                         //           child: Obx(() => productController
//                         //                   .isFavoritedProducts
//                         //                   .contains(model)
//                         //               ? const Icon(
//                         //                   EvaIcons.heart,
//                         //                   color: HAppColor.hRedColor,
//                         //                 )
//                         //               : const Icon(
//                         //                   EvaIcons.heartOutline,
//                         //                   color: HAppColor.hGreyColor,
//                         //                 ))),
//                         //     ),
//                         //   ),
//                         // ),
//                         gapW10,
//                         Padding(
//                           padding: hAppDefaultPaddingR,
//                           child: CartCircle(),
//                         )
//                       ],
//                     )),
//               )),
//           SizedBox.expand(
//             child: DraggableScrollableSheet(
//               initialChildSize: 0.6,
//               minChildSize: 0.6,
//               maxChildSize: 1.0 - (90 / HAppSize.deviceHeight),
//               builder: (context, scrollController) {
//                 scrollController.addListener(() {
//                   if (scrollController.offset > 0) {
//                     detailController.changeShowAppBar(true);
//                     if (scrollController.offset >= 93) {
//                       detailController.changeShowNameInAppBar(true);
//                     }
//                   } else {
//                     detailController.changeShowNameInAppBar(false);
//                     detailController.changeShowAppBar(false);
//                   }
//                 });
//                 return Obx(() => Container(
//                     decoration: BoxDecoration(
//                       color: HAppColor.hBackgroundColor,
//                       borderRadius: BorderRadius.only(
//                           topLeft: detailController.showAppBar.value
//                               ? const Radius.circular(0)
//                               : const Radius.circular(20),
//                           topRight: detailController.showAppBar.value
//                               ? const Radius.circular(0)
//                               : const Radius.circular(20)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: !detailController.showAppBar.value
//                               ? Colors.grey.withOpacity(0.5)
//                               : Colors.grey.withOpacity(0.3),
//                           spreadRadius:
//                               !detailController.showAppBar.value ? 5 : 2,
//                           blurRadius:
//                               !detailController.showAppBar.value ? 7 : 3,
//                           offset: !detailController.showAppBar.value
//                               ? const Offset(0, 3)
//                               : const Offset(
//                                   0, 2), // changes position of shadow
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: hAppDefaultPaddingLR,
//                       child: SingleChildScrollView(
//                         controller: scrollController,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             gapH24,
//                             Obx(
//                               () => detailController.showAppBar.value
//                                   ? Container()
//                                   : Padding(
//                                       padding: const EdgeInsets.only(bottom: 0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             height: 5,
//                                             width: 60,
//                                             decoration: BoxDecoration(
//                                                 color: Colors.black12,
//                                                 borderRadius:
//                                                     BorderRadius.circular(100)),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                             ),
//                             Row(
//                               children: [
//                                 Icon(
//                                   EvaIcons.listOutline,
//                                   color: HAppColor.hGreyColorShade600,
//                                 ),
//                                 gapW4,
//                                 Text(
//                                   model.categoryId,
//                                   style: HAppStyle.paragraph2Regular.copyWith(
//                                       color: HAppColor.hGreyColorShade600),
//                                 ),
//                                 const Spacer(),
//                                 // AnimatedOpacity(
//                                 //   opacity:
//                                 //       detailController.showAppBar.value ? 0 : 1,
//                                 //   duration: const Duration(milliseconds: 300),
//                                 //   child: GestureDetector(
//                                 //     onTap: () {
//                                 //       productController
//                                 //           .addProductInFavorited(model);
//                                 //       if (productController.isFavoritedProducts
//                                 //           .contains(model)) {
//                                 //         HAppUtils.showToastSuccess(
//                                 //             Text(
//                                 //               'Thêm vào Yêu thích!',
//                                 //               style: HAppStyle.label2Bold
//                                 //                   .copyWith(
//                                 //                       color: HAppColor
//                                 //                           .hBluePrimaryColor),
//                                 //             ),
//                                 //             RichText(
//                                 //                 text: TextSpan(
//                                 //                     style: HAppStyle
//                                 //                         .paragraph2Regular
//                                 //                         .copyWith(
//                                 //                             color: HAppColor
//                                 //                                 .hGreyColorShade600),
//                                 //                     text:
//                                 //                         'Bạn đã thêm thành công',
//                                 //                     children: [
//                                 //                   TextSpan(
//                                 //                       text: ' ${model.name} ',
//                                 //                       style: HAppStyle
//                                 //                           .paragraph2Regular
//                                 //                           .copyWith(
//                                 //                               color: HAppColor
//                                 //                                   .hBluePrimaryColor)),
//                                 //                   const TextSpan(
//                                 //                       text: 'vào Yêu thích.')
//                                 //                 ])),
//                                 //             1,
//                                 //             context,
//                                 //             const ToastificationCallbacks());
//                                 //       } else {
//                                 //         HAppUtils.showToastSuccess(
//                                 //             Text(
//                                 //               'Xóa khỏi Yêu thích!',
//                                 //               style: HAppStyle.label2Bold
//                                 //                   .copyWith(
//                                 //                       color: HAppColor
//                                 //                           .hBluePrimaryColor),
//                                 //             ),
//                                 //             RichText(
//                                 //                 text: TextSpan(
//                                 //                     style: HAppStyle
//                                 //                         .paragraph2Regular
//                                 //                         .copyWith(
//                                 //                             color: HAppColor
//                                 //                                 .hGreyColorShade600),
//                                 //                     text:
//                                 //                         'Bạn đã xóa thành công',
//                                 //                     children: [
//                                 //                   TextSpan(
//                                 //                       text: ' ${model.name} ',
//                                 //                       style: HAppStyle
//                                 //                           .paragraph2Regular
//                                 //                           .copyWith(
//                                 //                               color: HAppColor
//                                 //                                   .hBluePrimaryColor)),
//                                 //                   const TextSpan(
//                                 //                       text: 'khỏi Yêu thích.')
//                                 //                 ])),
//                                 //             1,
//                                 //             context,
//                                 //             const ToastificationCallbacks());
//                                 //       }
//                                 //     },
//                                 //     child: Container(
//                                 //       width: 40,
//                                 //       height: 40,
//                                 //       decoration: BoxDecoration(
//                                 //           border: Border.all(
//                                 //             color: HAppColor.hGreyColorShade300,
//                                 //             width: 1.5,
//                                 //           ),
//                                 //           borderRadius:
//                                 //               BorderRadius.circular(100),
//                                 //           color: HAppColor.hBackgroundColor),
//                                 //       child: Center(
//                                 //           child: Obx(() => productController
//                                 //                   .isFavoritedProducts
//                                 //                   .contains(model)
//                                 //               ? const Icon(
//                                 //                   EvaIcons.heart,
//                                 //                   color: HAppColor.hRedColor,
//                                 //                 )
//                                 //               : const Icon(
//                                 //                   EvaIcons.heartOutline,
//                                 //                   color: HAppColor.hGreyColor,
//                                 //                 ))),
//                                 //     ),
//                                 //   ),
//                                 // ),
//                               ],
//                             ),
//                             gapH12,
//                             Text(
//                               model.name,
//                               style: HAppStyle.heading2Style,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             gapH6,
//                             Row(
//                               children: [
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       EvaIcons.star,
//                                       color: HAppColor.hOrangeColor,
//                                       size: 20,
//                                     ),
//                                     gapW2,
//                                     Text.rich(
//                                       TextSpan(
//                                         style: HAppStyle.paragraph1Bold,
//                                         text: model.rating.toStringAsFixed(1),
//                                         children: [
//                                           TextSpan(
//                                             text: '/5',
//                                             style: HAppStyle.paragraph2Regular
//                                                 .copyWith(
//                                                     color: HAppColor
//                                                         .hGreyColorShade600),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Expanded(
//                                     child: Center(
//                                   child: Text(
//                                     "•",
//                                     style: HAppStyle.paragraph2Regular.copyWith(
//                                         color: HAppColor.hGreyColorShade600),
//                                   ),
//                                 )),
//                                 Text.rich(
//                                   TextSpan(
//                                     style: HAppStyle.paragraph1Bold,
//                                     text: "2.3k+ ",
//                                     children: [
//                                       TextSpan(
//                                         text: 'Nhận xét',
//                                         style: HAppStyle.paragraph2Regular
//                                             .copyWith(
//                                                 color: HAppColor
//                                                     .hGreyColorShade600),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                     child: Center(
//                                   child: Text(
//                                     "•",
//                                     style: HAppStyle.paragraph2Regular.copyWith(
//                                         color: HAppColor.hGreyColorShade600),
//                                   ),
//                                 )),
//                                 Text.rich(
//                                   TextSpan(
//                                     style: HAppStyle.paragraph1Bold,
//                                     text: '${model.countBuyed} ',
//                                     children: [
//                                       TextSpan(
//                                         text: 'Đã bán',
//                                         style: HAppStyle.paragraph2Regular
//                                             .copyWith(
//                                                 color: HAppColor.hGreyColor),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // gapH12,
//                             // ExpansionTile(
//                             //   initiallyExpanded: false,
//                             //   tilePadding: EdgeInsets.zero,
//                             //   shape: const Border(),
//                             //   onExpansionChanged: (value) {
//                             //     if (value) {
//                             //       productController
//                             //           .getComparePriceProduct(model);
//                             //     }
//                             //   },
//                             //   title: Row(
//                             //     children: [
//                             //       model.salePersent == 0
//                             //           ? Text(
//                             //               DummyData.vietNamCurrencyFormatting(
//                             //                   model.price),
//                             //               style: HAppStyle.label1Bold.copyWith(
//                             //                   color:
//                             //                       HAppColor.hBluePrimaryColor),
//                             //             )
//                             //           : Text.rich(
//                             //               TextSpan(
//                             //                 style:
//                             //                     HAppStyle.label1Bold.copyWith(
//                             //                   color: HAppColor.hOrangeColor,
//                             //                 ),
//                             //                 text:
//                             //                     '${DummyData.vietNamCurrencyFormatting(model.priceSale)} ',
//                             //                 children: [
//                             //                   TextSpan(
//                             //                     text: DummyData
//                             //                         .vietNamCurrencyFormatting(
//                             //                             model.price),
//                             //                     style: HAppStyle.paragraph2Bold
//                             //                         .copyWith(
//                             //                             color: HAppColor
//                             //                                 .hGreyColor,
//                             //                             decoration:
//                             //                                 TextDecoration
//                             //                                     .lineThrough),
//                             //                   ),
//                             //                 ],
//                             //               ),
//                             //             ),
//                             //       const Spacer(),
//                             //       const Text("So sánh giá")
//                             //     ],
//                             //   ),
//                             //   children: [
//                             //     SizedBox(
//                             //         width: double.infinity,
//                             //         height: 315,
//                             //         child: Obx(() => ListView.separated(
//                             //               scrollDirection: Axis.horizontal,
//                             //               itemCount: productController
//                             //                   .comparePriceProducts.length,
//                             //               itemBuilder:
//                             //                   (BuildContext context, index) {
//                             //                 String differentText = "";
//                             //                 String compareOperator = "";
//                             //                 String comparePrice = "";

//                             //                 if (model.salePersent == 0) {
//                             //                   differentText = detailController
//                             //                       .calculatingDifference(
//                             //                           productController
//                             //                                   .comparePriceProducts[
//                             //                               index],
//                             //                           model.price);
//                             //                   compareOperator = detailController
//                             //                       .comparePrice(differentText);
//                             //                   comparePrice = detailController
//                             //                       .comparePriceNumber(
//                             //                           differentText);
//                             //                 } else {
//                             //                   differentText = detailController
//                             //                       .calculatingDifference(
//                             //                           productController
//                             //                                   .comparePriceProducts[
//                             //                               index],
//                             //                           model.priceSale);
//                             //                   compareOperator = detailController
//                             //                       .comparePrice(differentText);
//                             //                   comparePrice = detailController
//                             //                       .comparePriceNumber(
//                             //                           differentText);
//                             //                 }
//                             //                 return Padding(
//                             //                   padding: const EdgeInsets.only(
//                             //                       bottom: 16),
//                             //                   child: ProductItemWidget(
//                             //                     storeIcon: true,
//                             //                     model: productController
//                             //                             .comparePriceProducts[
//                             //                         index],
//                             //                     list: productController
//                             //                         .comparePriceProducts,
//                             //                     compare: true,
//                             //                     differentText: differentText,
//                             //                     compareOperator:
//                             //                         compareOperator,
//                             //                     comparePrice: comparePrice,
//                             //                   ),
//                             //                 );
//                             //               },
//                             //               separatorBuilder:
//                             //                   (BuildContext context,
//                             //                           int index) =>
//                             //                       gapW10,
//                             //             )))
//                             //   ],
//                             // ),
//                             // gapH12,
//                             // Row(
//                             //   children: [
//                             //     const Text(
//                             //       "Số lượng",
//                             //       style: HAppStyle.heading4Style,
//                             //     ),
//                             //     const Spacer(),
//                             //     model.status == ""
//                             //         ? Row(
//                             //             children: [
//                             //               GestureDetector(
//                             //                 onTap: () {
//                             //                   detailController.changeCount("-");
//                             //                 },
//                             //                 child: Container(
//                             //                     height: 30,
//                             //                     width: 30,
//                             //                     decoration: BoxDecoration(
//                             //                         borderRadius:
//                             //                             BorderRadius.circular(
//                             //                                 100),
//                             //                         color: HAppColor
//                             //                             .hBackgroundColor),
//                             //                     child: const Center(
//                             //                       child: Icon(
//                             //                         EvaIcons.minus,
//                             //                       ),
//                             //                     )),
//                             //               ),
//                             //               gapW16,
//                             //               Obx(() => Text.rich(
//                             //                     TextSpan(
//                             //                       style:
//                             //                           HAppStyle.paragraph1Bold,
//                             //                       text: detailController
//                             //                           .countText.value,
//                             //                       children: [
//                             //                         TextSpan(
//                             //                           text: '  /${model.unit}',
//                             //                           style: HAppStyle
//                             //                               .paragraph3Regular
//                             //                               .copyWith(
//                             //                             color: HAppColor
//                             //                                 .hGreyColorShade600,
//                             //                           ),
//                             //                         ),
//                             //                       ],
//                             //                     ),
//                             //                   )),
//                             //               gapW16,
//                             //               GestureDetector(
//                             //                 onTap: () {
//                             //                   detailController.changeCount("+");
//                             //                 },
//                             //                 child: Container(
//                             //                     height: 30,
//                             //                     width: 30,
//                             //                     decoration: BoxDecoration(
//                             //                         borderRadius:
//                             //                             BorderRadius.circular(
//                             //                                 100),
//                             //                         color: HAppColor
//                             //                             .hBluePrimaryColor),
//                             //                     child: const Center(
//                             //                       child: Icon(
//                             //                         EvaIcons.plus,
//                             //                         color:
//                             //                             HAppColor.hWhiteColor,
//                             //                       ),
//                             //                     )),
//                             //               ),
//                             //             ],
//                             //           )
//                             //         : Container(
//                             //             padding: const EdgeInsets.fromLTRB(
//                             //                 10, 5, 10, 5),
//                             //             decoration: BoxDecoration(
//                             //                 borderRadius:
//                             //                     BorderRadius.circular(10),
//                             //                 color:
//                             //                     HAppColor.hGreyColorShade300),
//                             //             child: Center(
//                             //                 child: Text(
//                             //               model.status,
//                             //               style: HAppStyle.label3Regular,
//                             //             )),
//                             //           ),
//                             //   ],
//                             // ),
//                             gapH24,
//                             // Row(
//                             //   children: [
//                             //     Container(
//                             //       width: 80,
//                             //       height: 80,
//                             //       decoration: BoxDecoration(
//                             //           shape: BoxShape.circle,
//                             //           color: HAppColor.hGreyColorShade300,
//                             //           image: DecorationImage(
//                             //               image: NetworkImage(
//                             //                   model.store.imageStore),
//                             //               fit: BoxFit.cover)),
//                             //     ),
//                             //     gapW10,
//                             //     Expanded(
//                             //       child: Column(
//                             //         crossAxisAlignment:
//                             //             CrossAxisAlignment.start,
//                             //         children: [
//                             //           Text(
//                             //             model.store.name,
//                             //             style: HAppStyle.heading4Style,
//                             //           ),
//                             //           gapH4,
//                             //           Row(
//                             //             children: [
//                             //               const Icon(
//                             //                 EvaIcons.star,
//                             //                 color: HAppColor.hOrangeColor,
//                             //                 size: 20,
//                             //               ),
//                             //               gapW2,
//                             //               Text.rich(
//                             //                 TextSpan(
//                             //                   style: HAppStyle.paragraph2Bold,
//                             //                   text: model.store.rating
//                             //                       .toStringAsFixed(1),
//                             //                   children: [
//                             //                     TextSpan(
//                             //                       text: '/5',
//                             //                       style: HAppStyle
//                             //                           .paragraph2Regular
//                             //                           .copyWith(
//                             //                               color: HAppColor
//                             //                                   .hGreyColor),
//                             //                     ),
//                             //                   ],
//                             //                 ),
//                             //               ),
//                             //             ],
//                             //           ),
//                             //           gapH4,
//                             //           Row(
//                             //             children: [
//                             //               const Icon(
//                             //                 EneftyIcons.location_outline,
//                             //                 size: 15,
//                             //                 color: HAppColor.hDarkColor,
//                             //               ),
//                             //               gapW4,
//                             //               Text('Hà Nội',
//                             //                   style: HAppStyle.paragraph2Regular
//                             //                       .copyWith(
//                             //                           color: HAppColor
//                             //                               .hGreyColorShade600))
//                             //             ],
//                             //           )
//                             //         ],
//                             //       ),
//                             //     ),
//                             //     gapW10,
//                             //     GestureDetector(
//                             //         child: Container(
//                             //             width: 40,
//                             //             height: 40,
//                             //             decoration: BoxDecoration(
//                             //               borderRadius:
//                             //                   BorderRadius.circular(100),
//                             //               color: HAppColor.hGreyColorShade300,
//                             //             ),
//                             //             child: const Icon(
//                             //               EvaIcons.messageSquare,
//                             //               color: HAppColor.hBluePrimaryColor,
//                             //               size: 20,
//                             //             )),
//                             //         onTap: () {
//                             //           // Get.toNamed(HAppRoutes.chat, arguments: {
//                             //           //   'model': model,
//                             //           //   'store': productController
//                             //           //       .checkProductInStore(model),
//                             //           //   'check': true
//                             //           // });
//                             //         }),
//                             //     gapW10,
//                             //     GestureDetector(
//                             //       child: Container(
//                             //           width: 40,
//                             //           height: 40,
//                             //           decoration: BoxDecoration(
//                             //             borderRadius:
//                             //                 BorderRadius.circular(100),
//                             //             color: HAppColor.hGreyColorShade300,
//                             //           ),
//                             //           child: const Icon(
//                             //             Icons.storefront_rounded,
//                             //             color: HAppColor.hBluePrimaryColor,
//                             //             size: 20,
//                             //           )),
//                             //       // onTap: () => Get.toNamed(
//                             //       //     HAppRoutes.storeDetail,
//                             //       //     arguments: {
//                             //       //       'model': productController
//                             //       //           .checkProductInStore(model)
//                             //       //     }),
//                             //       onTap: () {},
//                             //     ),
//                             //   ],
//                             // ),
//                             gapH24,
//                             OutlinedButton(
//                                 onPressed: () {
//                                   Get.toNamed(HAppRoutes.wishlist,
//                                       arguments: {'model': model});
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                     minimumSize:
//                                         Size(HAppSize.deviceWidth - 48, 40),
//                                     backgroundColor: HAppColor.hBackgroundColor,
//                                     side: BorderSide(
//                                         width: 2,
//                                         color: HAppColor.hGreyColorShade300)),
//                                 child: const Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       EvaIcons.plus,
//                                       size: 20,
//                                       color: HAppColor.hDarkColor,
//                                     ),
//                                     gapW4,
//                                     Text(
//                                       "Thêm vào Danh sách mong ước",
//                                       style: HAppStyle.label2Bold,
//                                     )
//                                   ],
//                                 )),
//                             gapH24,
//                             const Text(
//                               "Nhận xét",
//                               style: HAppStyle.heading4Style,
//                             ),
//                             gapH12,
//                             GestureDetector(
//                               onTap: () => Get.toNamed(HAppRoutes.review),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 1,
//                                     child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text.rich(TextSpan(
//                                               style: HAppStyle.heading3Style,
//                                               text: model.rating
//                                                   .toStringAsFixed(1),
//                                               children: [
//                                                 TextSpan(
//                                                     text: '/5',
//                                                     style: HAppStyle
//                                                         .paragraph1Regular
//                                                         .copyWith(
//                                                             color: HAppColor
//                                                                 .hGreyColorShade600))
//                                               ])),
//                                           Text(
//                                             '2.3k+ Nhận xét',
//                                             style: HAppStyle.paragraph2Regular
//                                                 .copyWith(
//                                                     color: HAppColor
//                                                         .hGreyColorShade600),
//                                           ),
//                                           gapH10,
//                                           RatingBar.builder(
//                                             itemSize: 20,
//                                             initialRating: 4.3,
//                                             minRating: 1,
//                                             direction: Axis.horizontal,
//                                             allowHalfRating: true,
//                                             itemCount: 5,
//                                             itemPadding: const EdgeInsets.only(
//                                                 right: 4.0),
//                                             itemBuilder: (context, _) =>
//                                                 const Icon(
//                                               EvaIcons.star,
//                                               color: Colors.amber,
//                                             ),
//                                             onRatingUpdate: (rating) {},
//                                           ),
//                                         ]),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: ListView.builder(
//                                         padding: EdgeInsets.zero,
//                                         shrinkWrap: true,
//                                         itemCount: 5,
//                                         reverse: true,
//                                         itemBuilder: (context, index) {
//                                           return Row(
//                                             children: [
//                                               const Spacer(),
//                                               Text(
//                                                 "${index + 1}",
//                                                 style: HAppStyle
//                                                     .paragraph3Regular
//                                                     .copyWith(
//                                                         color: HAppColor
//                                                             .hGreyColorShade600),
//                                               ),
//                                               gapW4,
//                                               const Icon(
//                                                 EvaIcons.star,
//                                                 color: Colors.amber,
//                                                 size: 15,
//                                               ),
//                                               gapW4,
//                                               LinearPercentIndicator(
//                                                 barRadius:
//                                                     const Radius.circular(100),
//                                                 backgroundColor: HAppColor
//                                                     .hGreyColorShade300,
//                                                 width: (HAppSize.deviceWidth /
//                                                     2.8),
//                                                 lineHeight: 5,
//                                                 animation: true,
//                                                 animationDuration: 2000,
//                                                 percent: rates[index],
//                                                 progressColor: Colors.amber,
//                                               )
//                                             ],
//                                           );
//                                         }),
//                                   )
//                                 ],
//                               ),
//                             ),
//                             gapH24,
//                             const Text(
//                               "Mô tả",
//                               style: HAppStyle.heading4Style,
//                             ),
//                             gapH12,
//                             ReadMoreText(
//                               model.description,
//                               trimLines: 3,
//                               style: HAppStyle.paragraph2Regular.copyWith(
//                                   color: HAppColor.hGreyColorShade600),
//                               trimMode: TrimMode.Line,
//                               trimCollapsedText: 'Hiển thị thêm',
//                               trimExpandedText: ' Rút gọn',
//                               moreStyle: HAppStyle.label3Bold
//                                   .copyWith(color: HAppColor.hBluePrimaryColor),
//                               lessStyle: HAppStyle.label3Bold
//                                   .copyWith(color: HAppColor.hBluePrimaryColor),
//                             ),
//                             gapH12,
//                             Table(
//                               children: [
//                                 TableRow(children: [
//                                   const Text(
//                                     'Xuất xứ',
//                                     style: HAppStyle.paragraph2Regular,
//                                   ),
//                                   Text(
//                                     model.origin,
//                                     style: HAppStyle.paragraph2Regular.copyWith(
//                                         color: HAppColor.hGreyColorShade600),
//                                   )
//                                 ]),
//                                 TableRow(children: [
//                                   const Text(
//                                     'Đơn vị',
//                                     style: HAppStyle.paragraph2Regular,
//                                   ),
//                                   Text(
//                                     model.unit,
//                                     style: HAppStyle.paragraph2Regular.copyWith(
//                                         color: HAppColor.hGreyColorShade600),
//                                   )
//                                 ])
//                               ],
//                             ),
//                             gapH24,
//                           ],
//                         ),
//                       ),
//                     )));
//               },
//             ),
//           )
//         ],
//       )),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.fromLTRB(
//             hAppDefaultPadding, 20, hAppDefaultPadding, 16),
//         decoration: BoxDecoration(
//           color: HAppColor.hBackgroundColor,
//           boxShadow: [
//             BoxShadow(
//               offset: const Offset(0, -15),
//               blurRadius: 20,
//               color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
//             )
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             model.status == ""
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Obx(() => Text.rich(
//                             TextSpan(
//                               text: "Giá:\n",
//                               children: [
//                                 TextSpan(
//                                   text: model.priceSale != 0
//                                       ? DummyData.vietNamCurrencyFormatting(
//                                           model.priceSale)
//                                       : DummyData.vietNamCurrencyFormatting(
//                                           model.price),
//                                   style: HAppStyle.heading4Style.copyWith(
//                                       color: HAppColor.hBluePrimaryColor),
//                                 ),
//                               ],
//                             ),
//                           )),
//                       ElevatedButton(
//                         onPressed: () {
//                           // if (model.quantity == 0) {
//                           //   productController.addProductInCart(model);
//                           // }
//                           // model.quantity =
//                           //     int.parse(detailController.countText.value);
//                           // detailController.setCount(model);
//                           // productController.refreshAllList();
//                           // productController
//                           //     .refreshList(productController.isInCart);
//                           // productController.addMapProductInCart();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size(HAppSize.deviceWidth * 0.1, 50),
//                           backgroundColor: HAppColor.hBluePrimaryColor,
//                         ),
//                         child: Text(
//                           "Thêm vào Giỏ hàng",
//                           style: HAppStyle.label2Bold
//                               .copyWith(color: HAppColor.hWhiteColor),
//                         ),
//                       ),
//                     ],
//                   )
//                 : Row(children: [
//                     // GestureDetector(
//                     //   onTap: () {
//                     //     productController
//                     //         .addRegisterNotificationProducts(model);
//                     //     if (productController.registerNotificationProducts
//                     //         .contains(model)) {
//                     //       HAppUtils.showToastSuccess(
//                     //           Text(
//                     //             'Đăng ký nhận thông báo khi có hàng!',
//                     //             style: HAppStyle.label2Bold.copyWith(
//                     //                 color: HAppColor.hBluePrimaryColor),
//                     //           ),
//                     //           RichText(
//                     //               text: TextSpan(
//                     //                   style: HAppStyle.paragraph2Regular
//                     //                       .copyWith(
//                     //                           color:
//                     //                               HAppColor.hGreyColorShade600),
//                     //                   text:
//                     //                       'Chúng tôi sẽ gửi cho bạn thông báo khi sản phẩm',
//                     //                   children: [
//                     //                 TextSpan(
//                     //                     text: ' ${model.name} ',
//                     //                     style: HAppStyle.paragraph2Regular
//                     //                         .copyWith(
//                     //                             color: HAppColor
//                     //                                 .hBluePrimaryColor)),
//                     //                 const TextSpan(
//                     //                     text:
//                     //                         'có sẵn để đặt hàng. Bạn có thể hủy đăng ký bất cứ lúc nào bằng cách nhấn lại nút thông báo.')
//                     //               ])),
//                     //           5,
//                     //           context,
//                     //           const ToastificationCallbacks());
//                     //     } else {
//                     //       HAppUtils.showToastSuccess(
//                     //           Text(
//                     //             'Hủy đăng ký nhận thông báo khi có hàng!',
//                     //             style: HAppStyle.label2Bold.copyWith(
//                     //                 color: HAppColor.hBluePrimaryColor),
//                     //           ),
//                     //           RichText(
//                     //               text: TextSpan(
//                     //                   style: HAppStyle.paragraph2Regular
//                     //                       .copyWith(
//                     //                           color:
//                     //                               HAppColor.hGreyColorShade600),
//                     //                   text:
//                     //                       'Bạn đã được gỡ khỏi danh sách nhận thông báo về sản phẩm',
//                     //                   children: [
//                     //                 TextSpan(
//                     //                     text: ' ${model.name}',
//                     //                     style: HAppStyle.paragraph2Regular
//                     //                         .copyWith(
//                     //                             color: HAppColor
//                     //                                 .hBluePrimaryColor)),
//                     //                 const TextSpan(
//                     //                     text:
//                     //                         '. Nếu bạn muốn đăng ký lại, bạn có thể nhấn vào nút chuông bất cứ lúc nào.')
//                     //               ])),
//                     //           5,
//                     //           context,
//                     //           const ToastificationCallbacks());
//                     //     }
//                     //   },
//                     //   child: Container(
//                     //     width: 40,
//                     //     height: 40,
//                     //     decoration: BoxDecoration(
//                     //         border: Border.all(
//                     //           color: HAppColor.hGreyColorShade300,
//                     //           width: 1.5,
//                     //         ),
//                     //                        shape: BoxShape.circle,
//                     //         color: HAppColor.hBackgroundColor),
//                     //     child: Center(
//                     //         child: Obx(() => !productController
//                     //                 .registerNotificationProducts
//                     //                 .contains(model)
//                     //             ? const Icon(
//                     //                 EneftyIcons.notification_bing_outline)
//                     //             : const Icon(
//                     //                 EneftyIcons.notification_bing_bold,
//                     //                 color: HAppColor.hBluePrimaryColor,
//                     //               ))),
//                     //   ),
//                     // ),
//                     // gapW10,
//                     Expanded(
//                       child: ElevatedButton(
//                           onPressed: () {
//                             // productController.addProductInFavorited(model);
//                             // if (productController.isFavoritedProducts
//                             //     .contains(model)) {
//                             //   HAppUtils.showToastSuccess(
//                             //       Text(
//                             //         'Thêm vào Yêu thích!',
//                             //         style: HAppStyle.label2Bold.copyWith(
//                             //             color: HAppColor.hBluePrimaryColor),
//                             //       ),
//                             //       RichText(
//                             //           text: TextSpan(
//                             //               style: HAppStyle.paragraph2Regular
//                             //                   .copyWith(
//                             //                       color: HAppColor
//                             //                           .hGreyColorShade600),
//                             //               text: 'Bạn đã thêm thành công',
//                             //               children: [
//                             //             TextSpan(
//                             //                 text: ' ${model.name} ',
//                             //                 style: HAppStyle.paragraph2Regular
//                             //                     .copyWith(
//                             //                         color: HAppColor
//                             //                             .hBluePrimaryColor)),
//                             //             const TextSpan(text: 'vào Yêu thích.')
//                             //           ])),
//                             //       1,
//                             //       context,
//                             //       const ToastificationCallbacks());
//                             // } else {
//                             //   HAppUtils.showToastSuccess(
//                             //       Text(
//                             //         'Xóa khỏi Yêu thích!',
//                             //         style: HAppStyle.label2Bold.copyWith(
//                             //             color: HAppColor.hBluePrimaryColor),
//                             //       ),
//                             //       RichText(
//                             //           text: TextSpan(
//                             //               style: HAppStyle.paragraph2Regular
//                             //                   .copyWith(
//                             //                       color: HAppColor
//                             //                           .hGreyColorShade600),
//                             //               text: 'Bạn đã xóa thành công',
//                             //               children: [
//                             //             TextSpan(
//                             //                 text: ' ${model.name} ',
//                             //                 style: HAppStyle.paragraph2Regular
//                             //                     .copyWith(
//                             //                         color: HAppColor
//                             //                             .hBluePrimaryColor)),
//                             //             const TextSpan(text: 'khỏi Yêu thích.')
//                             //           ])),
//                             //       1,
//                             //       context,
//                             //       const ToastificationCallbacks());
//                             // }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: HAppColor.hBluePrimaryColor,
//                           ),
//                           // child: Obx(
//                           //   () => productController.isFavoritedProducts
//                           //           .contains(model)
//                           //       ? Text(
//                           //           "Xóa khỏi Yêu thích",
//                           //           style: HAppStyle.label2Bold
//                           //               .copyWith(color: HAppColor.hWhiteColor),
//                           //         )
//                           //       : Text(
//                           //           "Thêm vào Yêu thích",
//                           //           style: HAppStyle.label2Bold
//                           //               .copyWith(color: HAppColor.hWhiteColor),
//                           //         ),
//                           child: Text(
//                             "Thêm vào Yêu thích",
//                             style: HAppStyle.label2Bold
//                                 .copyWith(color: HAppColor.hWhiteColor),
//                           )),
//                     ),
//                   ]),
//           ],
//         ),
//       ),
//     );
//   }
// }
