// ─── Neumorphic Bottom Nav ────────────────────────────────────────────────────

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
  static const _inactiveColor = Color(0xFF3A4250); // slate
  // Neumorphic (soft-UI): the bar and the page background share this tone so the
  // shadows read as raised/carved rather than as a grey rectangle on white.
  static const _barColor = Color(0xFFECEDF1);
  static const _pillColor = AppColors.tertiary; // #EDEDED highlight
  static const _shadowDark = Color(0xFFC6C8D1);

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Wallets'),
    (icon: Icons.description_outlined, label: 'Services'),
    (icon: Icons.history, label: 'History'),
    (icon: Icons.more_horiz, label: 'More'),
  ];

  Widget _item(int index) {
    final item = _items[index];
    final isActive = selectedIndex == index;
    final color = isActive ? _activeColor : _inactiveColor;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            height: 1.1,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? _pillColor : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: _barColor,
        borderRadius: .circular(38),
        boxShadow: const [
          // raised soft-UI: dark bottom-right, light top-left
          .new(
            color: _shadowDark,
            offset: Offset(5, 8),
            blurRadius: 18,
          ),
          .new(
            color: Colors.white,
            offset: Offset(-5, -5),
            blurRadius: 14,
          ),
        ],
        image: .new(
          image: AssetImage('assets/img/navbar.png'),
          alignment: .center,
          repeat: .noRepeat,
          fit: .cover,
        ),
      ),
      padding: const .symmetric(horizontal: 6),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++) _item(i),
        ],
      ),
    );
  }
}
