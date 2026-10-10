import 'package:bigpay/l10n/app_localizations.dart';
import 'package:bigpay/ui/components/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('back pops pushed pages, then goes Home, then offers sign-out',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => MainShell(navigationShell: shell),
          branches: [
            for (final tab in ['home', 'b', 'c', 'd'])
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/$tab',
                  builder: (_, _) => Text('root-$tab'),
                  routes: [
                    GoRoute(path: 'child', builder: (_, _) => const Text('child')),
                  ],
                ),
              ]),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();

    router.go('/c');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('root-home'), findsOneWidget);
    expect(find.text('Are you sure you want to sign out?'), findsNothing);

    router.push('/home/child');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('root-home'), findsOneWidget);
    expect(find.text('Are you sure you want to sign out?'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
    expect(find.text('root-home'), findsOneWidget); // app didn't exit/pop

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to sign out?'), findsNothing);
  });
}
