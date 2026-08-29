import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/components/forms/input.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/responsive.dart';

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
    return Tooltip(
      message: _controller.text,
      child: InkWell(
        onTap: _onTap,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
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
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  void _onTap() {
    FocusScope.of(context).unfocus();
    widget.focusNode?.requestFocus();
    if (widget.options.length <= 3) {
      _onShortList();
    } else {
      _onLongList();
    }
  }

  void _onShortList() {
    final cap = contentCapWidth(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      isDismissible: true,
      constraints: cap == double.infinity
          ? null
          : BoxConstraints(maxWidth: cap),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(20),
      ),
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const .all(20),
        padding: const .all(10),
        decoration: BoxDecoration(
          color: ctx.cardBg,
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
                    widget.label ?? l10n.commonSelect,
                    style: ctx.header1,
                  ),
                  IconButton.filled(
                    tooltip: l10n.commonClose,
                    style: IconButton.styleFrom(
                      alignment: .center,
                      backgroundColor: ctx.divider,
                      fixedSize: Size(44, 44),
                    ),
                    onPressed: () {
                      ctx.pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 17,
                      color: ctx.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.options.isEmpty)
                _emptyState(message: l10n.commonNoOptionsAvailable)
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
    final cap = contentCapWidth(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      useRootNavigator: true,
      constraints: cap == double.infinity
          ? null
          : BoxConstraints(maxWidth: cap),
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(
          top: .circular(20),
        ),
      ),
      builder: (ctx) => Container(
        margin: const .symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: ctx.cardBg,
          borderRadius: .circular(20),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => Padding(
            padding: const .symmetric(vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisSize: .max,
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      widget.label ?? l10n.commonSelect,
                      style: ctx.header1,
                    ),
                    IconButton.filled(
                      tooltip: l10n.commonClose,
                      style: IconButton.styleFrom(
                        alignment: .center,
                        backgroundColor: ctx.divider,
                        fixedSize: Size(44, 44),
                      ),
                      onPressed: () {
                        ctx.pop();
                      },
                      icon: Icon(
                        Icons.close,
                        size: 17,
                        color: ctx.textPrimary,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const .only(
                    top: 5,
                    bottom: 10,
                  ),
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.feedbackCategorySearchPlaceholder,
                        hintStyle: ctx.caption,
                        prefixIcon: const Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: .circular(10),
                          borderSide: BorderSide(
                            color: ctx.border,
                            style: .solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: .circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            style: .solid,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: ctx.divider,
                      ),
                      onChanged: _onSearch,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _filteredOptions.isEmpty
                      ? _emptyState(
                          message: _searchController.text.isEmpty
                              ? l10n.commonNoOptionsAvailable
                              : l10n.commonNoResultsFound,
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
          Icon(icon, size: 48, color: context.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            style: context.smallDetails,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(FormSelectOption option) {
    final selected = widget.controller.text == option.id;
    return Container(
      margin: const .only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: .circular(10),
        border: .all(
          color: context.border,
          width: 1,
        ),
      ),
      child: Material(
        borderRadius: .circular(10),
        child: ListTile(
          onTap: () => _onSelect(option),
          selected: selected,
          title: Text(option.label),
          contentPadding: .symmetric(horizontal: 10),
          trailing: FormRadioButton(selected: selected),
        ),
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
    _controller.dispose();
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
