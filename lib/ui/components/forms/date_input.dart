import 'package:bigpay/ui/components/forms/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormDateInput extends StatefulWidget {
  const FormDateInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.focusNode,
    this.next,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final void Function(DateTime? value)? next;
  final void Function(DateTime? value)? onChanged;

  @override
  State<FormDateInput> createState() => _FormDateInputState();
}

class _FormDateInputState extends State<FormDateInput> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      highlightColor: Colors.transparent,
      child: AbsorbPointer(
        child: FormInput(
          readOnly: true,
          label: widget.label,
          placeholder: widget.placeholder,
          controller: widget.controller,
          focusNode: widget.focusNode,
          next: (value) {
            widget.next?.call(_date);
          },
          onChanged: (value) {
            _onSelect(_date);
          },
          suffix: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              SvgPicture.asset(
                'assets/img/calendar.svg',
                width: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap() {
    FocusScope.of(context).unfocus();
    widget.focusNode?.requestFocus();

    showDatePicker(
      context: context,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: DateTime.now().add(Duration(days: 365 * 100)),
    );
  }

  void _onSelect(DateTime? date) {
    widget.controller.text = date.toString();
    widget.onChanged?.call(date);
    widget.next?.call(date);
    Navigator.pop(context);
  }
}
