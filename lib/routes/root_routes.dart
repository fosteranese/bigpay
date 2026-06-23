import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/pages/beneficiary/beneficiaries.pg.dart';
import 'package:bigpay/ui/pages/dashboard.pg.dart';
import 'package:bigpay/ui/pages/history/history.pg.dart';
import 'package:bigpay/ui/pages/history/transaction_details.pg.dart';
import 'package:bigpay/ui/pages/kyc/info-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/intro-kyc.pg.dart';
import 'package:bigpay/ui/pages/kyc/start-kyc.pg.dart';
import 'package:bigpay/ui/pages/more/account.pg.dart';
import 'package:bigpay/ui/pages/more/account_details.pg.dart';
import 'package:bigpay/ui/pages/more/security.pg.dart';
import 'package:bigpay/ui/pages/pin_auth.pg.dart';
import 'package:bigpay/ui/pages/process_flow/feedback.pg.dart';
import 'package:bigpay/ui/pages/process_flow/service.pg.dart';
import 'package:bigpay/ui/pages/process_flow/services.pg.dart';
import 'package:bigpay/ui/pages/process_flow/summary.pg.dart';
import 'package:bigpay/ui/pages/splash_screen.pg.dart';
import 'package:bigpay/ui/pages/walkthrough.pg.dart';
import 'package:bigpay/ui/pages/wallets/add_card.pg.dart';
import 'package:bigpay/ui/pages/wallets/momo/add_momo.pg.dart';
import 'package:bigpay/ui/pages/wallets/momo/otp_momo.pg.dart';
import 'package:bigpay/ui/pages/wallets/virtual.pg.dart';
import 'package:bigpay/ui/pages/wallets/wallets.pg.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> get rootRoutes => [
  SplashScreenPage.route.toGoRoute(() => const SplashScreenPage()),
  WalkthroughPage.route.toGoRoute(() => const WalkthroughPage()),
  DashboardPage.route.toGoRoute(() => const DashboardPage()),
  WalletsPage.route.toGoRoute(() => const WalletsPage()),
  AddCardPage.route.toGoRoute(() => const AddCardPage()),
  AddMoMoPage.route.toGoRoute(() => const AddMoMoPage()),
  OtpMoMoPage.route.toGoRoute(() => const OtpMoMoPage()),
  VirtualWalletPage.route.toGoRoute(() => const VirtualWalletPage()),
  HistoryPage.route.toGoRoute(() => const HistoryPage()),
  TransactionDetailsPage.route.toGoRoute(() => const TransactionDetailsPage()),
  MyProfilePage.route.toGoRoute(() => const MyProfilePage()),
  ProfileDetailsPage.route.toGoRoute(() => const ProfileDetailsPage()),
  PinAuthPage.route.toGoRoute(() => const PinAuthPage()),
  SecurityPage.route.toGoRoute(() => const SecurityPage()),
  FeedbackPage.route.toGoRoute(() => const FeedbackPage()),
  BeneficiariesPage.route.toGoRoute(() => const BeneficiariesPage()),
  ServicesPage.route.toGoRoute(() => const ServicesPage()),
  ServicePage.route.toGoRoute(() => const ServicePage()),
  SummaryPage.route.toGoRoute(() => const SummaryPage()),
  IntroKycPage.route.toGoRoute(() => const IntroKycPage()),
  StartKycPage.route.toGoRoute(() => const StartKycPage()),
  InfoKycPage.route.toGoRoute(() => const InfoKycPage()),
];
