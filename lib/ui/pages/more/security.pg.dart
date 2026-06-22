import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/pages/more/account.pg.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/security',
  );

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _otp = ValueNotifier('');

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      bottomSize: 60,
      title: 'Security',
      child: Column(
        children: [
          ProfileItem(
            title: 'Sign in with Biometrics',
            icon: Icons.fingerprint,
            trailing: SizedBox(
              height: 30,
              width: 49,
              child: FittedBox(
                child: Switch(
                  value: true,
                  padding: .zero,
                  materialTapTargetSize: .shrinkWrap,

                  onChanged: (value) {},
                ),
              ),
            ),
          ),
          ProfileItem(
            title: 'Transact with Biometrics',
            icon: Icons.fingerprint,
            trailing: SizedBox(
              height: 30,
              width: 49,
              child: FittedBox(
                child: Switch(
                  value: true,
                  padding: .zero,
                  materialTapTargetSize: .shrinkWrap,

                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
