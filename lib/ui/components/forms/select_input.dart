import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FormSelectInput extends StatefulWidget {
  const FormSelectInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.focusNode,
    this.next,
    this.onChanged,
    this.options = const [],
  });
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final FocusNode? focusNode;
  final void Function(String value)? next;
  final void Function(String value)? onChanged;
  final List<FormSelectOption> options;

  @override
  State<FormSelectInput> createState() => _FormSelectInputState();
}

class _FormSelectInputState extends State<FormSelectInput> {
  final _searchController = TextEditingController();
  final _controller = TextEditingController();
  List<FormSelectOption> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
  }

  @override
  void didUpdateWidget(FormSelectInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _filteredOptions = widget.options;
    }
  }

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
          controller: _controller,
          focusNode: widget.focusNode,
          next: widget.next,
          onChanged: widget.onChanged,
          suffix: const Icon(Icons.expand_more_outlined),
        ),
      ),
    );
  }

  void _onTap() {
    FocusScope.of(context).unfocus();
    widget.focusNode?.requestFocus();
    if (widget.options.length <= 5) {
      _onShortList();
    } else {
      _onLongList();
    }
  }

  void _onShortList() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      isDismissible: true,
      constraints: BoxConstraints(
        minWidth: double.maxFinite,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(20),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const .all(20),
        padding: const .all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: .circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            children: [
              Row(
                mainAxisSize: .max,
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    widget.label ?? 'Select',
                    style: AppTypography.header1,
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      alignment: .center,
                      tapTargetSize: .shrinkWrap,
                      backgroundColor: AppColors.offWhite,
                      fixedSize: Size(35, 35),
                      minimumSize: Size(35, 35),
                      maximumSize: Size(35, 35),
                    ),
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 17,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.options.isEmpty)
                _emptyState(message: 'No options available')
              else
                ...widget.options.map(_buildOption),
            ],
          ),
        ),
      ),
    );
  }

  void _onLongList() {
    _searchController.clear();
    _filteredOptions = widget.options;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  widget.label ?? 'Select',
                  style: AppTypography.formLabels,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: AppTypography.caption,
                      prefixIcon: const Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.tertiary,
                          style: BorderStyle.solid,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.offWhite,
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _filteredOptions.isEmpty
                      ? _emptyState(
                          message: _searchController.text.isEmpty
                              ? 'No options available'
                              : 'No results found',
                          icon: _searchController.text.isEmpty
                              ? Icons.inbox_outlined
                              : Icons.search_off_outlined,
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _filteredOptions.length,
                          itemBuilder: (_, i) =>
                              _buildOption(_filteredOptions[i]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required String message,
    IconData icon = Icons.inbox_outlined,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.flora),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.smallDetails,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(FormSelectOption option) {
    final selected = widget.controller.text == option.id;
    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(10),
        border: .all(
          color: AppColors.tertiary,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: () => _onSelect(option),
        title: Text(option.label),
        contentPadding: .symmetric(horizontal: 10),
        trailing: FormRadioButton(selected: selected),
      ),
    );
  }

  void _onSelect(FormSelectOption option) {
    _controller.text = option.label;
    widget.controller.text = option.id;
    widget.onChanged?.call(option.label);
    widget.next?.call(option.label);
    Navigator.pop(context);
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredOptions = widget.options
          .where((o) => o.label.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class FormSelectOption {
  final String id;
  final String label;
  final dynamic data;

  FormSelectOption({
    required this.id,
    required this.label,
    this.data,
  });
}
