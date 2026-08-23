import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/logger.dart';
import 'package:bigpay/models/wallet/get_wallets_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/wallets/virtual.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/foldable.dart';
import 'package:uuid/uuid.dart';

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
  ExecuteProcessEvent? mainEvent;

  /// The wallet shown in the detail pane in split view
  /// ([MasterDetailLayout]) — unused (and the pane not shown) on any other
  /// device, where opening a wallet pushes [VirtualWalletPage] instead.
  Account? _selectedAccount;

  void _openWallet(Account account) {
    if (context.usesSplitView) {
      setState(() => _selectedAccount = account);
      return;
    }

    AppRouter.router.push(
      VirtualWalletPage.route.path,
      extra: account,
    );
  }

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
      if (value != null) logger.i('Selected: $value');
    });
  }

  @override
  initState() {
    _load();
    super.initState();
  }

  void _load() {
    mainEvent = context.dispatchProcess(
      GetWalletsAction(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailLayout(
      detail: _selectedAccount == null
          ? null
          : VirtualWalletView(
              account: _selectedAccount,
              onBack: () => setState(() => _selectedAccount = null),
            ),
      master: _master(context),
    );
  }

  Widget _master(BuildContext context) {
    return MainLayout(
      bottomSize: 61,
      title: 'Wallets',
      onRefresh: () async {
        setState(_load);
        await context.awaitProcess(mainEvent);
      },
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
      child: ProcessBuilder<List<Account>>(
        event: () => mainEvent,
        builder: (context, snapshot) {
          return Column(
            children:
                snapshot.data?.map((item) {
                  return WalletListItem(
                    data: item,
                    onTap: () => _openWallet(item),
                  );
                }).toList() ??
                [],
          );
        },
      ),
    );
  }
}

class WalletListItem extends StatelessWidget {
  const WalletListItem({
    super.key,
    required this.data,
    this.onTap,
  });
  final Account data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const .only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: .circular(10),
        border: .all(
          color: context.border,
        ),
      ),
      child: Dismissible(
        key: ValueKey(data.formId ?? data.activityId ?? Uuid().v4()),
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
              color: context.border,
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
              color: context.border,
            ),
          ),
          child: SvgPicture.asset('assets/img/trash.svg'),
        ),

        child: ListTile(
          contentPadding: .symmetric(horizontal: 15),
          onTap:
              onTap ??
              () => AppRouter.router.push(
                VirtualWalletPage.route.path,
                extra: data,
              ),
          leading: CachedNetworkImage(
            imageUrl:
                '${AppState.currentUser?.imageBaseUrl}${AppState.currentUser?.imageDirectory}/${data.icon}',
            placeholder: (context, url) => Icon(
              Icons.circle_outlined,
              color: Theme.of(context).primaryColor,
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.circle_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
          title: Text(
            data.sources?.first.tile ?? '',
            style: AppTypography.caption.copyWith(
              color: context.textPrimary,
            ),
          ),
          subtitle: Text(
            data.sources?.first.balance ?? '0.00',
            style: AppTypography.caption,
          ),
          trailing: FormRadioButton(selected: false),
        ),
      ),
    );
  }
}
