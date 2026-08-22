// ─── Neumorphic Bottom Nav ────────────────────────────────────────────────────

import 'package:bigpay/ui/components/nav_items.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NeumorphicBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const NeumorphicBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _activeColor = AppColors.tint; // brand green

  Widget _item(
    BuildContext context,
    int index,
    Color pillColor,
    Color inactiveColor,
  ) {
    final item = navBarItems[index];
    final isActive = selectedIndex == index;
    final color = isActive ? _activeColor : inactiveColor;

    final content = ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            // A tab bar conventionally caps its own text scale (rather than
            // ballooning the whole bar) so a large system font size doesn't
            // clip against the bar's minimum height.
            textScaler: MediaQuery.textScalerOf(
              context,
            ).clamp(maxScaleFactor: 1.3),
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );

    final navItem = Semantics(
      label: item.label,
      button: true,
      selected: isActive,
      child: GestureDetector(
        behavior: .opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          width: isActive ? 90 : null,
          duration: const .new(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const .symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? pillColor : Colors.transparent,
            borderRadius: .circular(38),
          ),
          child: content,
        ),
      ),
    );

    if (isActive) {
      return navItem;
    }

    return Expanded(
      child: navItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final barColor = context.navBarBg;
    final pillColor = context.border;
    final inactiveColor = context.textTertiary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: .circular(38),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFFC6C8D1),
            offset: const Offset(5, 8),
            blurRadius: 18,
          ),
          BoxShadow(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            offset: const Offset(-5, -5),
            blurRadius: 14,
          ),
        ],
        image: .new(
          image: AssetImage(
            isDark ? 'assets/img/navbar_dark.png' : 'assets/img/navbar.png',
          ),
          alignment: .center,
          repeat: .noRepeat,
          fit: .cover,
        ),
      ),
      padding: const .symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: .max,
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          for (var i = 0; i < navBarItems.length; i++)
            _item(context, i, pillColor, inactiveColor),
        ],
      ),
    );
  }
}
