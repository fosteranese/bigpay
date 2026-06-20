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

  static const _navBg = Color(0xFFE8E8EC);
  static const _shadowDark = Color(0xFFAFAFBD);
  static const _shadowLight = Color(0xFFFFFFFF);

  Widget _buildNavItemContent(
    IconData icon,
    String label,
    bool isActive,
  ) {
    final Color activeColor = AppColors.tint;
    final Color inactiveColor = const Color(0xFF3A4250);

    return Container(
      width: isActive ? 78 : 64,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(296),
        color: isActive ? AppColors.tertiary : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 21,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.home_outlined, label: 'Home'),
      (icon: Icons.account_balance_wallet_outlined, label: 'Wallets'),
      (icon: Icons.description_outlined, label: 'Services'),
      (icon: Icons.history, label: 'History'),
      (icon: Icons.more_horiz, label: 'More'),
    ];

    return Container(
      height: 66,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _navBg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: _shadowDark,
            offset: Offset(5, 5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: _shadowLight,
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            // PLATE INNER CAVITY DEPTH LAYERS
            Container(color: const Color(0xFFDCDCE0)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_shadowDark.withOpacity(0.65), Colors.transparent],
                    stops: const [0.0, 0.25],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [_shadowLight.withOpacity(0.9), Colors.transparent],
                    stops: const [0.0, 0.2],
                  ),
                ),
              ),
            ),

            // NAV CONTENT SYSTEM
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(items.length, (index) {
                    final bool isActive = selectedIndex == index;

                    return GestureDetector(
                      onTap: () => onTap(
                        index,
                      ), // Handled directly without local side effects
                      behavior: HitTestBehavior.opaque,
                      child: _buildNavItemContent(
                        items[index].icon,
                        items[index].label,
                        isActive,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
