import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/startup_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';

class AppErrorPage extends StatelessWidget {
  const AppErrorPage({
    super.key,
    required this.error,
    this.title = 'App Error',
  });
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/app-error',
  );

  final String title;
  final DataError error;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      showBackBtn: false,
      bottomNav: BlocBuilder<ProcessBloc, ProcessState>(
        buildWhen: (previous, current) => current.event == startUpEvent,
        builder: (context, state) {
          return FormButton(
            loading: state is ExecutingProcess && state.event == startUpEvent,
            onPressed: () {
              context.read<ProcessBloc>().add(startUpEvent);
            },
            text: 'Retry',
          );
        },
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300,
          ),
          child: Column(
            mainAxisSize: .max,
            crossAxisAlignment: .center,
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 100,
                color: AppColors.danger,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: .center,
                style: AppTypography.display2.copyWith(
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error.message,
                textAlign: .center,
                style: AppTypography.smallDetails.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
