import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services',
  );

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      backgroundColor: Color(0xffEEF0FA),
      miniTitle: 'Services',
      bottom: PreferredSize(
        preferredSize: Size(double.maxFinite, 60),
        child: Padding(
          padding: const .only(
            left: 20,
            right: 20,
            bottom: 10,
          ),
          child: FormInput(
            placeholder: 'Search',
            controller: TextEditingController(),
            suffix: Icon(Icons.search),
          ),
        ),
      ),
      builder: (_) => SliverList.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const .symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            child: ListTile(
              onTap: () {},
              contentPadding: .symmetric(
                horizontal: 15,
              ),
              tileColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: .circular(14),
              ),
              leading: SvgPicture.asset('assets/img/transfer.svg'),
              title: Text(
                'Transfer Money',
                style: AppTypography.header4,
              ),
              subtitle: Text(
                'Send funds anywhere securely',
                style: AppTypography.caption,
              ),
              trailing: Icon(Icons.chevron_right_outlined),
            ),
          );
        },
      ),
    );
  }
}
