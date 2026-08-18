import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/payee/payee.dart';
import 'package:bigpay/models/actions/beneficiary/delete_payee_action.dart';
import 'package:bigpay/models/actions/beneficiary/get_payees_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/beneficiary/add_beneficiary.pg.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiary_details.pg.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

class BeneficiariesPage extends StatefulWidget {
  const BeneficiariesPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/beneficiaries',
  );

  @override
  State<BeneficiariesPage> createState() => _BeneficiariesPageState();
}

class _BeneficiariesPageState extends State<BeneficiariesPage> with RouteAware {
  final _searchController = TextEditingController();

  ExecuteProcessEvent? _event;
  ExecuteProcessEvent? _deleteEvent;
  List<Payee>? _payees;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  // Returning from the details screen — a beneficiary may have been deleted.
  @override
  void didPopNext() => setState(_load);

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    _event = context.dispatchProcess(
      const GetPayeesAction(),
      returnSavedResponse: true,
      saveActionResponse: true,
    );
  }

  List<Payee> get _filtered {
    final all = _payees ?? const [];
    if (_query.isEmpty) return all;
    final query = _query.toLowerCase();
    return all
        .where(
          (p) => [p.title, p.value, p.formName, p.shortTitle].any(
            (f) => f?.toLowerCase().contains(query) ?? false,
          ),
        )
        .toList();
  }

  Future<bool> _confirmDelete(Payee payee) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const .all(20),
        padding: const .all(20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: .circular(16),
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(
              'Remove beneficiary',
              style: context.header3,
            ),
            const SizedBox(height: 8),
            Text(
              'Remove ${payee.displayName} from your beneficiaries?',
              style: context.smallDetails,
            ),
            const SizedBox(height: 20),
            FormButton(
              backgroundColor: AppColors.danger,
              onPressed: () => AppRouter.router.pop(true),
              text: 'Remove',
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => AppRouter.router.pop(false),
              child: Text('Cancel', style: context.formLabels),
            ),
          ],
        ),
      ),
    );
    return confirmed ?? false;
  }

  void _delete(Payee payee) {
    setState(() => _payees = List.of(_payees ?? const [])..remove(payee));
    _deleteEvent = context.dispatchProcess(
      DeletePayeeAction(payload: DeletePayeePayload(payeeId: payee.payeeId)),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return ProcessListener<bool>(
      event: () => _deleteEvent,
      listener: (context, snapshot) {
        if (snapshot.hasError) {
          _deleteEvent = null;
          MessageUtil.displayErrorDialog(
            context,
            message: snapshot.error!.message,
          );
          // Restore the optimistic removal.
          _load();
        } else if (snapshot.isSuccessful) {
          _deleteEvent = null;
        }
      },
      child: MainLayout(
        showBackBtn: true,
        bottomSize: 129,
        title: 'Beneficiaries',
        actions: SizedBox(
          width: 110,
          child: FormButton(
            padding: .zero,
            height: 35,
            labelSize: 13,
            onPressed: () =>
                AppRouter.router.push(AddBeneficiaryPage.route.path),
            text: 'Add New',
            icon: Icons.add,
            buttonIconAlignment: .left,
            iconSize: 16,
          ),
        ),
        subtitleWidget: Container(
          padding: .only(top: 20),
          child: FormInput(
            placeholder: 'Search',
            controller: _searchController,
            suffix: Icon(Icons.search),
            textInputAction: .search,
          ),
        ),
        child: ProcessConsumer<List<Payee>>(
          event: () => _event,
          listener: (context, snapshot) {
            if (snapshot.hasData) {
              setState(() => _payees = snapshot.data);
            }
          },
          builder: (context, snapshot) {
            if (_payees == null && snapshot.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final beneficiaries = _filtered;
            if (beneficiaries.isEmpty) {
              return _query.isNotEmpty
                  ? _noMatches()
                  : const EmptyBeneficiaries();
            }

            return Column(
              children: [
                for (final payee in beneficiaries) _buildItem(payee),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(Payee payee) {
    final name = payee.displayName;
    final subtitle = [
      payee.formName,
      payee.value,
    ].where((e) => e?.isNotEmpty ?? false).join(' - ');

    return Dismissible(
      key: ValueKey(payee.payeeId ?? name),
      direction: .endToStart,
      confirmDismiss: (_) => _confirmDelete(payee),
      onDismissed: (_) => _delete(payee),
      background: Container(
        margin: const .only(bottom: 6),
        alignment: .centerRight,
        padding: const .symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: .circular(10),
        ),
        child: SvgPicture.asset('assets/img/trash.svg'),
      ),
      child: ListTile(
        contentPadding: .zero,
        onTap: () => AppRouter.router.push(
          BeneficiaryDetailsPage.route.path,
          extra: payee,
        ),
        leading: CircleAvatar(
          radius: 21,
          backgroundColor: context.avatarBg,
          child: Text(_initials(name), style: context.caption),
        ),
        title: Text(name, style: context.p1Medium),
        subtitle: subtitle.isEmpty
            ? null
            : Text(subtitle, style: context.smallDetails),
        trailing: Icon(Icons.chevron_right_outlined),
      ),
    );
  }

  Widget _noMatches() {
    return Center(
      child: Padding(
        padding: const .symmetric(vertical: 60),
        child: Text(
          'No beneficiaries match "$_query"',
          textAlign: .center,
          style: context.smallDetails,
        ),
      ),
    );
  }
}

class EmptyBeneficiaries extends StatelessWidget {
  const EmptyBeneficiaries({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .max,
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        const Spacer(),
        SvgPicture.asset('assets/img/empty-wallet.svg'),
        Text('No beneficiary yet', style: context.header3),
        Text(
          'Add beneficiaries to see them here',
          style: context.smallDetails,
        ),
        const Spacer(flex: 4),
      ],
    );
  }
}
