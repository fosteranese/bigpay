import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FormRadioButton extends StatelessWidget {
  const FormRadioButton({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        borderRadius: .circular(17),
        border: Border.all(
          color: !selected ? AppColors.flora : AppColors.tint,
          width: 1.5,
        ),
      ),
      child: selected
          ? Container(
              margin: const .all(2.5),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: .circular(10),
              ),
            )
          : null,
    );
  }
}
