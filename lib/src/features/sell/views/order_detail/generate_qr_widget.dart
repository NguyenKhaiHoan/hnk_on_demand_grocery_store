import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/constants/app_sizes.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_style.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class GenerateCodeWidget extends StatefulWidget {
  const GenerateCodeWidget({super.key, required this.qrData});

  final String qrData;

  @override
  State<GenerateCodeWidget> createState() => _GenerateCodeWidgetState();
}

class _GenerateCodeWidgetState extends State<GenerateCodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Mã QR cho 4 ký tự cuối của mã đơn hàng',
              style: HAppStyle.paragraph2Regular
                  .copyWith(color: HAppColor.hGreyColorShade600)),
          gapH12,
          PrettyQrView.data(data: widget.qrData)
        ],
      ),
    );
  }
}
