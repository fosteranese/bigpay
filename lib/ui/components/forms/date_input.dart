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
    this.firstDate,
    this.lastDate,
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final void Function(DateTime? value)? next;
  final void Function(DateTime? value)? onChanged;

  /// Earliest / latest selectable dates, e.g. to force a date after or up to
  /// today. Default to an effectively unbounded range.
  final DateTime? firstDate;
  final DateTime? lastDate;

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

  Future<void> _onTap() async {
    FocusScope.of(context).unfocus();

    final first =
        widget.firstDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final last =
        widget.lastDate ?? DateTime.now().add(const Duration(days: 365 * 100));

    // The initial date must sit within [first, last].
    var initial = _date ?? DateTime.now();
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) _onSelect(picked);
  }

  void _onSelect(DateTime date) {
    setState(() => _date = date);
    // ISO date (yyyy-MM-dd) — no intl dependency.
    widget.controller.text = date.toIso8601String().split('T').first;
    widget.onChanged?.call(date);
    widget.next?.call(date);
  }
}
