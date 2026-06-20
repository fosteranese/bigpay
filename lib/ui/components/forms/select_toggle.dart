import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

class FormSelectToggleInput extends StatefulWidget {
  const FormSelectToggleInput({
    super.key,
    required this.controller,
    this.label,
    this.options = const [],
    this.selected,
  });

  final TextEditingController controller;
  final String? label;
  final List<FormSelectToggleOption> options;
  final FormSelectToggleOption? selected;

  @override
  State<FormSelectToggleInput> createState() => _FormSelectToggleInputState();
}

class _FormSelectToggleInputState extends State<FormSelectToggleInput> {
  late final _selected = ValueNotifier<FormSelectToggleOption>(
    widget.selected ?? widget.options.first,
  );

  @override
  initState() {
    _selected.value = widget.selected ?? widget.options.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      mainAxisAlignment: .start,
      crossAxisAlignment: .start,
      children: [
        if (widget.label != null)
          FormLabel(
            label: widget.label!,
          ),
        Container(
          width: double.maxFinite,
          height: 67,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: .circular(10),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 0.06,
                spreadRadius: 0,
                color: AppColors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: .circular(10),
            child: ValueListenableBuilder(
              valueListenable: _selected,
              builder: (context, value, child) {
                return Row(
                  children: widget.options
                      .map((item) {
                        return [
                          FormSelectToggleListItem(
                            option: item,
                            selected: value,
                            onSelected: () {
                              _selected.value = item;
                              widget.controller.text = item.value;
                            },
                          ),
                          if (item != widget.options.last)
                            const VerticalDivider(
                              color: AppColors.fade,
                              width: 0,
                            ),
                        ];
                      })
                      .expand((item) => item)
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FormSelectToggleListItem extends StatelessWidget {
  const FormSelectToggleListItem({
    super.key,
    required this.option,
    required this.selected,
    this.onSelected,
  });

  final FormSelectToggleOption selected;
  final FormSelectToggleOption option;
  final void Function()? onSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onSelected,
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          color: option.value == selected.value ? AppColors.tintShade1 : null,
          child: Row(
            mainAxisSize: .max,
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              CircleAvatar(
                radius: 11.5,
                backgroundColor: AppColors.tintShade3,
              ),
              const SizedBox(width: 10),
              Text(
                option.label,
                style: AppTypography.smallDetails.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormSelectToggleOption {
  final String label;
  final String value;
  final dynamic data;
  final String icon;

  FormSelectToggleOption({
    required this.label,
    required this.value,
    this.data,
    required this.icon,
  });
}
