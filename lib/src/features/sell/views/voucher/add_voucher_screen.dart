import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/features/sell/controllers/voucher_controller.dart';
import 'package:on_demand_grocery_store/src/features/sell/models/voucher_model.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:on_demand_grocery_store/src/utils/utils.dart';

class AddVoucherScreen extends StatefulWidget {
  const AddVoucherScreen({super.key});

  @override
  State<AddVoucherScreen> createState() => _AddVoucherScreenState();
}

class _AddVoucherScreenState extends State<AddVoucherScreen> {
  final voucherController = Get.put(VoucherController());

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
                  voucherController.resetForm();
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                )),
          ),
        ),
        title: const Text(
          'Thêm voucher',
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: hAppDefaultPaddingLR,
          child: Form(
              key: voucherController.addVoucherFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.name,
                    enableSuggestions: true,
                    autocorrect: true,
                    controller: voucherController.nameController,
                    validator: (value) =>
                        HAppUtils.validateEmptyField('Tên Voucher', value),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: 'Tên Voucher',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  gapH12,
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 5,
                    enableSuggestions: true,
                    autocorrect: true,
                    controller: voucherController.descriptionController,
                    validator: (value) =>
                        HAppUtils.validateEmptyField('Mô tả', value),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: 'Mô tả',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  gapH12,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() => Radio(
                                activeColor: HAppColor.hBluePrimaryColor,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                value: 'Flat',
                                groupValue:
                                    voucherController.selectedType.value,
                                onChanged: (value) {
                                  voucherController.selectedType.value =
                                      value as String;
                                },
                              )),
                          Text(
                            'Giảm giá trực tiếp',
                            style: HAppStyle.paragraph2Regular
                                .copyWith(color: HAppColor.hGreyColorShade600),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() => Radio(
                                activeColor: HAppColor.hBluePrimaryColor,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                value: 'Percentage',
                                groupValue:
                                    voucherController.selectedType.value,
                                onChanged: (value) {
                                  voucherController.selectedType.value =
                                      value as String;
                                },
                              )),
                          Text('Phần trăm giảm giá',
                              style: HAppStyle.paragraph2Regular.copyWith(
                                  color: HAppColor.hGreyColorShade600)),
                        ],
                      )
                    ],
                  ),
                  gapH12,
                  Row(
                    children: [
                      const Text(
                        'Ngày bắt đầu:',
                        style: HAppStyle.heading5Style,
                      ),
                      const Spacer(),
                      Obx(() => Text(
                            DateFormat('dd/MM/yyyy')
                                .format(voucherController.startDate.value),
                            style: HAppStyle.paragraph2Regular
                                .copyWith(color: HAppColor.hGreyColorShade600),
                          )),
                      gapW6,
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            voucherController.startDate.value = pickedDate;
                          }
                        },
                        child: const Icon(EvaIcons.calendarOutline),
                      )
                    ],
                  ),
                  gapH12,
                  Row(
                    children: [
                      const Text(
                        'Ngày kết thúc:',
                        style: HAppStyle.heading5Style,
                      ),
                      const Spacer(),
                      Obx(() => Text(
                            DateFormat('dd/MM/yyyy')
                                .format(voucherController.endDate.value),
                            style: HAppStyle.paragraph2Regular
                                .copyWith(color: HAppColor.hGreyColorShade600),
                          )),
                      gapW6,
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            voucherController.endDate.value = pickedDate;
                          }
                        },
                        child: const Icon(EvaIcons.calendarOutline),
                      )
                    ],
                  ),
                  gapH12,
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enableSuggestions: true,
                    autocorrect: true,
                    controller: voucherController.minAmountController,
                    validator: (value) => HAppUtils.validateMinNumber(value),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: 'Số tiền tối thiểu (Mặc định là 0)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  gapH12,
                  Obx(
                    () => (voucherController.selectedType.value == 'Flat')
                        ? TextFormField(
                            keyboardType: TextInputType.number,
                            enableSuggestions: true,
                            autocorrect: true,
                            controller:
                                voucherController.discountValueController,
                            validator: (value) =>
                                HAppUtils.validateDiscountNumber(value),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HAppColor.hGreyColorShade300,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HAppColor.hGreyColorShade300,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: 'Giá trị giảm (VNĐ)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )
                        : TextFormField(
                            keyboardType: TextInputType.number,
                            enableSuggestions: true,
                            autocorrect: true,
                            controller:
                                voucherController.discountValueController,
                            validator: (value) =>
                                HAppUtils.validatePercentageNumber(value),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HAppColor.hGreyColorShade300,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: HAppColor.hGreyColorShade300,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: 'Phần trăm giảm (%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                  ),
                  gapH12,
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enableSuggestions: true,
                    autocorrect: true,
                    controller: voucherController.quantityController,
                    validator: (value) =>
                        HAppUtils.validateQuantityNumber(value),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: HAppColor.hGreyColorShade300, width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: 'Số lượng (Mặc định là không giới hạn)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  gapH12,
                  ElevatedButton(
                    onPressed: () {
                      voucherController.addVoucher();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: HAppColor.hBluePrimaryColor,
                        fixedSize: Size(
                            HAppSize.deviceWidth - hAppDefaultPadding * 2, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text("Lưu",
                        style: HAppStyle.label2Bold
                            .copyWith(color: HAppColor.hWhiteColor)),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
