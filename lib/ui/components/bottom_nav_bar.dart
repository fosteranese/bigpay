// ─── Neumorphic Bottom Nav ────────────────────────────────────────────────────

import 'package:bigpay/ui/components/bottom_nav_bar.1.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NeumorphicBottomNav extends StatefulWidget {
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

  @override
  State<NeumorphicBottomNav> createState() => _NeumorphicBottomNavState();
}

class _NeumorphicBottomNavState extends State<NeumorphicBottomNav> {
  int _selectedIndex = 0;

  Widget _buildNavItemContent(
    int index,
    IconData icon,
    String label,
    bool isActive,
  ) {
    final Color activeColor = AppColors.tint; // Precise Image 1 Green
    final Color inactiveColor = const Color(
      0xFF3A4250,
    ); // Deep charcoal slate tint

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: isActive ? 78 : null,
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(296),
          backgroundBlendMode: BlendMode.multiply,
          // Soft grey cavity color when pressed
          color: isActive ? AppColors.tertiary : Colors.transparent,
          // --- SUNKEN (INSET) ACTIVE MAPPING ---
          // boxShadow: isActive
          //     ? [
          //         // Sunk Shadow Top-Left
          //         BoxShadow(
          //           color: Colors.black.withAlpha(26),
          //           offset: const Offset(2.0, 2.5),
          //           blurRadius: 3,
          //         ),
          //         // Relief Highlight Bottom-Right
          //         BoxShadow(
          //           color: Colors.white.withAlpha(255),
          //           offset: const Offset(-1.5, -1.5),
          //           blurRadius: 2,
          //         ),
          //       ]
          //     : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 21,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w600, // Thick character lines
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = _selectedIndex == index;

    if (isActive) {
      return _buildNavItemContent(
        index,
        icon,
        label,
        isActive,
      );
    }

    return Expanded(
      child: _buildNavItemContent(
        index,
        icon,
        label,
        isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: NeumorphicBottomNav._navBg,
        borderRadius: .circular(999),
        boxShadow: [
          BoxShadow(
            color: NeumorphicBottomNav._shadowDark,
            offset: Offset(6, 6),
            blurRadius: 14,
          ),
          BoxShadow(
            color: NeumorphicBottomNav._shadowLight,
            offset: Offset(-6, -6),
            blurRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: .circular(999),
        child: BackdropFilter(
          filter: .blur(sigmaX: 7.0, sigmaY: 7.0),
          child: Padding(
            padding: const .all(8),
            child: Row(
              mainAxisSize: .max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: .center,
              children: [
                // Standard Flex Distribution Items
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  label: 'Wallets',
                ),

                // Standard Flex Distribution Items
                _buildNavItem(
                  index: 1,
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallets',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.description_outlined,
                  label: 'Services',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.history,
                  label: 'History',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.more_horiz,
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Accounts for the absolute position bleed: left/right/top/bottom: -4px
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(296),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(296),
          child: Stack(
            children: [
              // Layer 1: Fill + Shadow — blended background
              _buildFillLayer(),

              // Layer 2: Glass Effect — subtle dark tint overlay
              _buildGlassLayer(),

              // Layer 3: Content
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }

  /// Simulates:
  /// background: linear-gradient(0deg, #F7F7F7, #F7F7F7),
  ///             linear-gradient(0deg, #778899, #778899),
  ///             rgba(255, 255, 255, 0.65);
  /// background-blend-mode: darken, color-burn, normal;
  Widget _buildFillLayer() {
    // The three layers blend to a light steel-grey.
    // Closest solid approximation of darken + color-burn on these values:
    // #F7F7F7 darkened over #778899 over white 65% ≈ #D8DDE3
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8ECEF), // top — lighter
            Color(0xFFD4D9DF), // bottom — slightly darker (simulates blend)
          ],
        ),
      ),
      child: BackdropFilter(
        filter: .blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7).withOpacity(0.65),
          ),
        ),
      ),
    );
  }

  /// Simulates:
  /// background: rgba(0, 0, 0, 0.004);
  Widget _buildGlassLayer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.004),
        borderRadius: BorderRadius.circular(296),
      ),
    );
  }
}
