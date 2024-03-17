import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/common_widgets/custom_shimmer_widget.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/authentication/controller/registration_store_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/address_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/controllers/store_controller.dart';
import 'package:on_demand_grocery_store/src/features/personalization/models/district_ward_model.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class FormRegistrationStoreWidget extends StatefulWidget {
  const FormRegistrationStoreWidget({
    super.key,
  });

  @override
  State<FormRegistrationStoreWidget> createState() =>
      _FormRegistrationStoreWidgetState();
}

class _FormRegistrationStoreWidgetState
    extends State<FormRegistrationStoreWidget> {
  final double storeBackgroundHeight = 200;
  final double storeImageHeight = 140;

  Uint8List? storeImage;
  Uint8List? storeImageBackground;

  final addressController = AddressController.instance;
  final registrationController = Get.put(RegistrationController());
  final storeController = StoreController.instance;

  String? valueDistrict;
  String? valueWard;
  String? valueCity;
  List<String> list = [];

  void selectWard(String? newValue) {
    valueWard = newValue!;
    registrationController.ward.value = valueWard!;
    setState(() {});
  }

  void selectCity(String? newValue) {
    valueCity = newValue!;
    valueDistrict = null;
    valueWard = null;
    registrationController.city.value = valueCity!;
    registrationController.district.value = '';
    registrationController.ward.value = '';
    setState(() {});
  }

  void selectDistrict(String? newValue) {
    valueDistrict = newValue!;
    valueWard = null;
    registrationController.district.value = valueDistrict!;
    registrationController.ward.value = '';
    list.assignAll(List<String>.from(addressController.hanoiData
        .firstWhere((DistrictModel model) => model.name == valueDistrict)
        .children!
        .map((WardModel model) => model.name)
        .toList()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: registrationController.addAddressFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hoàn thiện đăng ký cửa hàng,",
            style: HAppStyle.heading3Style,
          ),
          gapH6,
          Text.rich(
            TextSpan(
              text:
                  'Hãy hoàn thành nốt các thông tin sau đây để hoàn tất đăng ký cửa hàng.',
              style: HAppStyle.paragraph2Regular
                  .copyWith(color: HAppColor.hGreyColorShade600),
              children: const [],
            ),
          ),
          gapH24,
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Stack(
                children: [
                  Container(
                      margin:
                          EdgeInsets.only(bottom: storeBackgroundHeight / 2),
                      height: storeBackgroundHeight,
                      width: HAppSize.deviceWidth,
                      decoration: BoxDecoration(
                          color: HAppColor.hGreyColorShade300,
                          borderRadius: BorderRadius.circular(10)),
                      child: Stack(
                        children: [
                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                  color: HAppColor.hGreyColorShade300,
                                  borderRadius: BorderRadius.circular(10)),
                              child: storeController
                                          .user.value.storeImageBackground !=
                                      ''
                                  ? storeController.isLoading.value ||
                                          storeController
                                              .isUploadImageBackgroundLoading
                                              .value
                                      ? CustomShimmerWidget.rectangular(
                                          height: storeBackgroundHeight,
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            storeController.user.value
                                                .storeImageBackground,
                                            height: storeBackgroundHeight,
                                            width: HAppSize.deviceWidth,
                                            fit: BoxFit.cover,
                                          ))
                                  : Container(),
                            ),
                          ),
                        ],
                      )),
                  Positioned(
                      right: 10,
                      bottom: 10 + storeBackgroundHeight / 2,
                      child: GestureDetector(
                        onTap: () =>
                            storeController.uploadStoreImageBackground(),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: HAppColor.hBluePrimaryColor,
                            border: Border.all(
                                width: 2, color: HAppColor.hWhiteColor),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: HAppColor.hDarkColor.withOpacity(0.1))
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            EvaIcons.camera,
                            size: 15,
                            color: HAppColor.hWhiteColor,
                          ),
                        ),
                      ))
                ],
              ),
              Positioned(
                top: storeBackgroundHeight - storeImageHeight / 2,
                child: Stack(
                  children: [
                    Container(
                      height: storeImageHeight,
                      width: storeImageHeight,
                      decoration: BoxDecoration(
                        color: HAppColor.hGreyColorShade300,
                        border:
                            Border.all(width: 4, color: HAppColor.hWhiteColor),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: HAppColor.hDarkColor.withOpacity(0.1))
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: Obx(() =>
                          storeController.user.value.storeImage != ''
                              ? storeController.isLoading.value ||
                                      storeController.isUploadImageLoading.value
                                  ? CustomShimmerWidget.circular(
                                      height: storeImageHeight,
                                      width: storeImageHeight,
                                    )
                                  : ClipOval(
                                      child: Image.network(
                                        storeController.user.value.storeImage,
                                        height: storeImageHeight,
                                        width: storeImageHeight,
                                      ),
                                    )
                              : Container()),
                    ),
                    Positioned(
                        right: 10,
                        bottom: 10,
                        child: GestureDetector(
                          onTap: () => storeController.uploadStoreImage(),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: HAppColor.hBluePrimaryColor,
                              border: Border.all(
                                  width: 2, color: HAppColor.hWhiteColor),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color:
                                        HAppColor.hDarkColor.withOpacity(0.1))
                              ],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              EvaIcons.camera,
                              size: 15,
                              color: HAppColor.hWhiteColor,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ],
          ),
          gapH12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: HAppColor.hGreyColorShade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: Container(),
                        value: valueCity,
                        hint: const Text('Chọn Thành phố'),
                        onChanged: (String? newValue) {
                          selectCity(newValue);
                        },
                        items: <String>['Hà Nội']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  gapH12,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: HAppColor.hGreyColorShade300,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: Container(),
                              value: valueDistrict,
                              hint: const Text('Chọn Quận/Huyện'),
                              onChanged: (String? newValue) {
                                selectDistrict(newValue);
                              },
                              items: addressController.hanoiData
                                  .map<DropdownMenuItem<String>>(
                                      (DistrictModel model) {
                                return DropdownMenuItem<String>(
                                  value: model.name,
                                  child: Text(model.name!),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      gapW10,
                      Expanded(
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: HAppColor.hGreyColorShade300,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: Container(),
                              value: valueWard,
                              hint: const Text('Chọn Phường/Xã'),
                              onChanged: (String? newValue) {
                                selectWard(newValue);
                              },
                              items: list.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              gapH12,
              TextFormField(
                keyboardType: TextInputType.text,
                enableSuggestions: true,
                autocorrect: true,
                controller: registrationController.streetController,
                validator: (value) =>
                    HAppUtils.validateEmptyField('Số nhà, ngõ, đường', value),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: HAppColor.hGreyColorShade300, width: 1),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: HAppColor.hGreyColorShade300, width: 1),
                      borderRadius: BorderRadius.circular(10)),
                  hintText: 'Nhập số nhà, ngõ, đường của bạn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          gapH12,
          Obx(() => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Lấy vị trí hiện tại',
                style: HAppStyle.paragraph2Regular,
              ),
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
              value: registrationController.isChoseCurrentPosition.value,
              onChanged: (changed) {
                registrationController.isChoseCurrentPosition.value = changed;
                registrationController.getCurrentPosition();
              })),
          gapH6,
          ElevatedButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              registrationController.saveInfo();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: HAppColor.hBluePrimaryColor,
                fixedSize:
                    Size(HAppSize.deviceWidth - hAppDefaultPadding * 2, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            child: Text("Lưu",
                style: HAppStyle.label2Bold
                    .copyWith(color: HAppColor.hWhiteColor)),
          ),
        ],
      ),
    );
  }
}
