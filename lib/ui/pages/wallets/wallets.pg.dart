import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/models/account/account.dart';
import 'package:bigpay/data/models/auth_data/activity.dart';
import 'package:bigpay/data/models/auth_data/activity_datum.dart';
import 'package:bigpay/data/models/auth_data/recent_activity.dart';
import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/models/actions/services/get_service_form_data_action.dart';
import 'package:bigpay/utils/app_state.util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/constants/activity_type.const.dart';
import 'package:bigpay/models/wallet/delink_wallet_action.dart';
import 'package:bigpay/models/wallet/get_wallets_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/confirm_sheet.dart';
import 'package:bigpay/ui/components/animated/fade_in.dart';
import 'package:bigpay/ui/components/forms/button.dart';
import 'package:bigpay/ui/components/forms/radio_button.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/components/skeleton/variants.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/wallets/add_card.pg.dart';
import 'package:bigpay/ui/pages/wallets/virtual.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/assets/app_images.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/ui/theme/foldable.dart';
import 'package:bigpay/utils/app_modal.dart';
import 'package:bigpay/utils/message.util.dart';
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
  ExecuteProcessEvent? mainEvent;

  /// The last successful result, retained so the list survives once the
  /// detail pane's own fetches (e.g. [VirtualWalletView]'s mini-statement)
  /// dispatch their own events — [ProcessBloc] tracks a single current
  /// event/state pair, so once another event has been dispatched,
  /// [mainEvent]'s own live snapshot goes stale (reads back empty) until it
  /// is redispatched. Without this cache, going back from the split-view
  /// detail pane briefly showed an empty wallets list.
  List<Account>? _accounts;

  /// The wallet shown in the detail pane in split view
  /// ([MasterDetailLayout]) — unused (and the pane not shown) on any other
  /// device, where opening a wallet pushes [VirtualWalletPage] instead.
  Account? _selectedAccount;

  ExecuteProcessEvent? _delinkEvent;

  void _openWallet(Account account) {
    if (context.usesSplitView) {
      // Synchronous, before setState — see the matching comment in
      // services.pg.dart's _openService. Marks MainShell dirty in the same
      // window as this page's own rebuild instead of a frame later, so the
      // sidebar collapsing and the split appearing happen in one frame
      // instead of visibly jumping in two steps.
      AppState.splitDetailOpenNotifier.value = true;
      setState(() => _selectedAccount = account);
      return;
    }

    AppRouter.router.push(
      VirtualWalletPage.route.path,
      extra: account,
    );
  }

  void _closeDetails() {
    AppState.splitDetailOpenNotifier.value = false;
    setState(() => _selectedAccount = null);
  }

  /// The formId umb's own reference client (full_app_mode.dart) hardcodes
  /// for "Link Mobile Wallet" — both apps run against the same backend, so
  /// this identifies the same form here.
  static const _linkWalletFormId = '1AD40BE3-4D10-4CE1-AC51-A168348055DA';

  /// Fallback activity shape for the Add Mobile Wallet entry, used only when
  /// recentActivity has no link-wallet item (the dashboard gating we started
  /// from was removed precisely because it blocked the navigation). The
  /// link-wallet form runs over the online form flow — umb's own
  /// LinkMoMoWalletCard hardcodes this type for its form.
  static const _linkWalletActivityType = ActivityTypesConst.fblOnline;
  static const _linkWalletActivityName = 'Link Mobile Wallet';

  /// The backend-curated "quick action" for linking a new wallet (e.g.
  /// "Link Mobile Wallet") — the same entry the Dashboard's most-used-
  /// services carousel surfaces via [FrequentServiceItem]. Read only to
  /// enrich the synthesized activity with the real id/icon when present.
  RecentActivity? get _addWalletActivity {
    final recent = AppState.currentUser?.recentActivity ?? const [];
    for (final item in recent) {
      if (item.formId?.toLowerCase() == _linkWalletFormId.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  /// Opens the Add Mobile Wallet form through the generic, backend-driven
  /// service form. Mirrors VirtualWalletCard's Fund Wallet action (the "add
  /// funds" reference): dispatch straight to the central listener with
  /// static form/ins ids instead of depending on recentActivity, so the
  /// "Add New" → Mobile Wallet entry always navigates to the form. When the
  /// link activity does exist in recentActivity, its real id/type/icon are
  /// carried into the synthesized activity so a later submit stays correct.
  void _addMobileWallet(BuildContext context) {
    final activity = _addWalletActivity;

    GetServiceFormDataAction.activityDatum = ActivityDatum(
      activity: Activity(
        activityId: activity?.activityId ?? _linkWalletFormId,
        activityType: activity?.activityType ?? _linkWalletActivityType,
        activityName: activity?.activityName ?? _linkWalletActivityName,
        icon: activity?.icon,
      ),
    );
    GetServiceFormDataAction.event = context.dispatchProcess(
      saveActionResponse: true,
      returnSavedResponse: true,
      GetServiceFormDataAction(
        payload: GetServiceFormDataActionPayload(
          formId: _linkWalletFormId,
          insId: _linkWalletFormId,
        ),
        endpointFunc: () => GetServiceFormDataAction.endpointFor(
          activity?.activityType ?? _linkWalletActivityType,
        ),
      ),
    );
  }

  void _addCard() {
    AppRouter.router.push(AddCardPage.route.path);
  }

  void _showAddWalletSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    AppModal.showBottomModal(
      context,
      label: l10n.walletsAddWalletSheetTitle,
      padding: const .all(20),
      children: [
        const SizedBox(height: 10),
        ListTile(
          contentPadding: .zero,
          leading: CircleAvatar(
            backgroundColor: context.avatarBg,
            child: Icon(
              Icons.phone_android_outlined,
              color: context.accentGreen,
            ),
          ),
          title: Text(
            l10n.walletsAddWalletMobileOption,
            style: context.formLabels,
          ),
          trailing: Icon(Icons.chevron_right_outlined),
          onTap: () {
            AppRouter.router.pop();
            _addMobileWallet(context);
          },
        ),
        ListTile(
          contentPadding: .zero,
          leading: CircleAvatar(
            backgroundColor: context.avatarBg,
            child: Icon(Icons.credit_card_outlined, color: context.accentGreen),
          ),
          title: Text(
            l10n.walletsAddWalletCardOption,
            style: context.formLabels,
          ),
          trailing: Icon(Icons.chevron_right_outlined),
          onTap: () {
            AppRouter.router.pop();
            _addCard();
          },
        ),
      ],
    );
  }

  @override
  initState() {
    _load();
    // A wallet linked or a transaction processed elsewhere (a different
    // shell branch, so no same-navigator pop to catch) — see the
    // notifier's own doc for why this can't just be RouteAware.
    AppState.dataChangedNotifier.addListener(_onDataChanged);
    super.initState();
  }

  // setState(_load), not just _load — this fires from the notifier's own
  // listener list, outside this widget's normal rebuild triggers, so
  // without it the ProcessListener below wouldn't pick up the reassigned
  // mainEvent until something else happened to rebuild this page.
  void _onDataChanged() => setState(_load);

  @override
  void dispose() {
    // Leaving the page entirely (e.g. switching tabs) with a split still
    // open — don't leave the sidebar permanently collapsed with nothing
    // left to justify it.
    if (_selectedAccount != null) {
      AppState.splitDetailOpenNotifier.value = false;
    }
    AppState.dataChangedNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _load() {
    mainEvent = context.dispatchProcess(
      GetWalletsAction(),
    );
  }

  /// Removes [account] from the list right away (the Dismissible is already
  /// gone) and delinks it; a failure shows the error and reloads the list.
  void _delink(Account account) {
    if (_selectedAccount == account) _closeDetails();
    setState(() {
      _accounts = List.of(_accounts ?? const <Account>[])..remove(account);
      _delinkEvent = context.dispatchProcess(
        DelinkWalletAction(
          payload: DelinkWalletPayload(
            sourceValue: account.sources?.firstOrNull?.value,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Back closes an open split-view detail before it can reach
    // MainShell's back-at-root sign-out prompt.
    return PopScope(
      canPop: _selectedAccount == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeDetails();
      },
      child: MultiProcessListener(
        listeners: [
          ProcessListenerConfig<List<Account>>(
            event: () => mainEvent,
            listener: (context, snapshot) {
              if (snapshot.hasData) {
                setState(() => _accounts = snapshot.data);
              }
            },
          ),
          ProcessListenerConfig<bool>(
            event: () => _delinkEvent,
            listener: (context, snapshot) {
              if (snapshot.hasError) {
                _delinkEvent = null;
                MessageUtil.displayErrorDialog(
                  context,
                  message: snapshot.error!.message,
                );
                // Restore the optimistic removal.
                setState(_load);
              } else if (snapshot.isSuccessful) {
                _delinkEvent = null;
                // Drop the cached list so the reload below doesn't briefly
                // bring the removed wallet back before the network answers.
                AppState.store.cache.remove(
                  ResponseCache.keyFor(const GetWalletsAction()),
                );
                // Dashboard and payment-source pickers refresh too.
                AppState.notifyDataChanged();
              }
            },
          ),
        ],
        child: MasterDetailLayout(
          detail: _selectedAccount == null
              ? null
              : VirtualWalletView(
                  // Without a key, switching the selection reuses the same
                  // State instead of creating a fresh one for the new account
                  // (Account extends Equatable, so this compares by value).
                  key: ValueKey(_selectedAccount),
                  account: _selectedAccount,
                  onBack: _closeDetails,
                ),
          master: _master(context),
        ),
      ),
    );
  }

  Widget _master(BuildContext context) {
    return MainLayout(
      bottomSize: 61,
      title: AppLocalizations.of(context)!.walletsTitle,
      onRefresh: () async {
        setState(_load);
        await context.awaitProcess(mainEvent);
      },
      actions: SizedBox(
        width: 100,
        child: FormButton(
          padding: .zero,
          height: 44,
          labelSize: 13,
          onPressed: () => _showAddWalletSheet(context),
          text: AppLocalizations.of(context)!.commonAddNew,
          icon: Icons.add,
          buttonIconAlignment: .left,
          iconSize: 16,
        ),
      ),
      child: ProcessBuilder<List<Account>>(
        event: () => mainEvent,
        builder: (context, snapshot) {
          if (snapshot.isLoading && _accounts == null) {
            return Column(
              children: List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: ListItemSkeleton(),
                ),
              ),
            );
          }

          return Column(
            children: [
              // Subtle staggered entrance — each wallet settles in 40ms after
              // the last, capped so a long list doesn't drag on.
              ...?_accounts?.asMap().entries.map((entry) {
                final index = entry.key > 8 ? 8 : entry.key;
                return FadeInView(
                  delay: Duration(milliseconds: index * 40),
                  child: WalletListItem(
                    data: entry.value,
                    onTap: () => _openWallet(entry.value),
                    onRemove: entry.value.sources?.firstOrNull?.value == null
                        ? null
                        : () => _delink(entry.value),
                  ),
                );
              }),
              // Clear the floating bottom nav so the last item isn't hidden.
              const SizedBox(height: 110),
            ],
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
    this.onRemove,
  });
  final Account data;
  final VoidCallback? onTap;

  /// Called once the user confirms removal; null makes the row unswipeable.
  final VoidCallback? onRemove;

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
        // The source value, not formId — wallets of the same type share a
        // formId, and a duplicate key breaks Dismissible once one is removed.
        key: ValueKey(
          data.sources?.firstOrNull?.value ?? data.formId ?? Uuid().v4(),
        ),
        // The in-app virtual wallet can't be removed.
        direction:
            onRemove == null || data.mode?.toUpperCase() == 'VIRTUAL_WALLET'
            ? DismissDirection.none
            : DismissDirection.endToStart,
        confirmDismiss: (_) {
          final l10n = AppLocalizations.of(context)!;
          return showConfirmSheet(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.walletsRemoveTitle,
            message: l10n.walletsRemoveConfirm(
              data.sources?.firstOrNull?.tile ?? data.title ?? '',
            ),
            confirmText: l10n.commonRemove,
          );
        },
        onDismissed: (_) => onRemove?.call(),
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
          child: SvgPicture.asset(SvgImages.trash),
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
          child: SvgPicture.asset(SvgImages.trash),
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
                '${AppState.currentUser?.imageBaseUrl}${AppState.currentUser?.imageDirectory}/${data.sources?.firstOrNull?.picture ?? data.icon}',
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
            data.sources?.firstOrNull?.tile ?? '',
            style: context.caption.copyWith(
              color: context.textPrimary,
            ),
          ),
          subtitle: Text(
            data.sources?.firstOrNull?.balance ?? '0.00',
            style: context.caption,
          ),
          trailing: FormRadioButton(selected: false),
        ),
      ),
    );
  }
}
