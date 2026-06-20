import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/wallets',
  );

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  final _buttonKey = GlobalKey();
  void _showContextMenu(BuildContext context) {
    // 2. Find the RenderBox of the button
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    // 3. Display the menu right below the button
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy +
            buttonSize.height +
            5, // Placed directly under the button
        buttonPosition.dx + buttonSize.width,
        buttonPosition.dy,
      ),
      items: [
        const PopupMenuItem(value: 'share', child: Text('Share')),
        const PopupMenuItem(value: 'archive', child: Text('Archive')),
      ],
    ).then((value) {
      if (value != null) print('Selected: $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottomSize: 61,
      title: 'Wallets',
      actions: SizedBox(
        width: 100,
        child: FormButton(
          key: _buttonKey,
          padding: .zero,
          height: 35,
          labelSize: 13,
          onPressed: () {
            _showContextMenu(context);
          },
          text: 'Add New',
          icon: Icons.add,
          buttonIconAlignment: .left,
          iconSize: 16,
        ),
      ),
      child: Column(
        children: [
          WalletListItem(
            id: '1',
          ),
          WalletListItem(
            id: '2',
          ),
          WalletListItem(
            id: '3',
          ),
          WalletListItem(
            id: '4',
          ),
          WalletListItem(
            id: '5',
          ),
          WalletListItem(
            id: '6',
          ),
          WalletListItem(
            id: '7',
          ),
          WalletListItem(
            id: '8',
          ),
          WalletListItem(
            id: '9',
          ),
        ],
      ),
    );
  }
}

class WalletListItem extends StatelessWidget {
  const WalletListItem({
    super.key,
    required this.id,
  });
  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const .only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: .circular(10),
        border: .all(
          color: AppColors.tertiary,
        ),
      ),
      child: Dismissible(
        key: ValueKey(id),
        direction: DismissDirection.endToStart,
        dismissThresholds: const {
          DismissDirection.endToStart: 1,
        },
        background: Container(
          padding: .all(20),
          alignment: .centerLeft,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: .circular(10),
            border: .all(
              color: AppColors.tertiary,
            ),
          ),
          child: SvgPicture.asset('assets/img/trash.svg'),
        ),
        secondaryBackground: Container(
          padding: .all(20),
          alignment: .centerRight,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: .circular(10),
            border: .all(
              color: AppColors.tertiary,
            ),
          ),
          child: SvgPicture.asset('assets/img/trash.svg'),
        ),

        child: ListTile(
          contentPadding: .symmetric(horizontal: 15),
          leading: SvgPicture.asset('assets/img/bigpay-icon.svg'),
          title: Text(
            'BigPay Virtual Wallet',
            style: AppTypography.caption.copyWith(
              color: AppColors.black,
            ),
          ),
          subtitle: Text(
            'Balance - GHS 20,000.00',
            style: AppTypography.caption,
          ),
          trailing: FormRadioButton(selected: false),
        ),
      ),
    );
  }
}
