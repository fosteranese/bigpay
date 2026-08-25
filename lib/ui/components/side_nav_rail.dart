import 'package:bigpay/ui/components/nav_items.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The tablet/desktop counterpart to [NeumorphicBottomNav] — same 5 tabs,
/// same pill-highlight language, laid out as a vertical rail instead of a
/// floating bottom bar. Swapped in by [MainShell] once the viewport is
/// medium width or wider.
class SideNavRail extends StatelessWidget {
  const SideNavRail({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _activeColor = AppColors.tint;
  static const _width = 96.0;

  Widget _item(
    BuildContext context,
    int index,
    Color pillColor,
    Color inactiveColor,
  ) {
    final item = navBarItems(context)[index];
    final isActive = selectedIndex == index;
    final color = isActive ? _activeColor : inactiveColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Semantics(
        label: item.label,
        button: true,
        selected: isActive,
        child: GestureDetector(
          behavior: .opaque,
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            constraints: const BoxConstraints(minHeight: 44),
            decoration: BoxDecoration(
              color: isActive ? pillColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExcludeSemantics(
              child: Column(
                mainAxisSize: .min,
                children: [
                  Icon(item.icon, color: color, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: MediaQuery.textScalerOf(
                      context,
                    ).clamp(maxScaleFactor: 1.3),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barColor = context.navBarBg;
    final pillColor = context.border;
    final inactiveColor = context.textTertiary;

    return SafeArea(
      right: false,
      child: Container(
        width: _width,
        margin: const EdgeInsets.fromLTRB(16, 24, 0, 24),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            for (var i = 0; i < navBarItems(context).length; i++)
              _item(context, i, pillColor, inactiveColor),
          ],
        ),
      ),
    );
  }
}
