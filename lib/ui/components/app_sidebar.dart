import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/ui/components/nav_items.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';

/// The desktop-class counterpart to [NeumorphicBottomNav]/[SideNavRail] —
/// same 5 tabs (shared via [navBarItems]), laid out as a proper full-width
/// left sidebar (icon + label rows, brand mark up top) instead of a floating
/// icon rail. Swapped in by [MainShell] once the viewport is expanded width.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _width = 248.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(right: BorderSide(color: context.border)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: SvgPicture.asset(SvgImages.icon, height: 22),
            ),
            for (var i = 0; i < navBarItems.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _Item(
                  index: i,
                  selected: i == selectedIndex,
                  onTap: onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final item = navBarItems[index];
    final color = selected ? AppColors.tint : context.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        label: item.label,
        button: true,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onTap(index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: selected ? context.border : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Icon(item.icon, size: 20, color: color),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
