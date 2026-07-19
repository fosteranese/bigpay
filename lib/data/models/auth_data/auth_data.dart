import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../account/account.dart';
import '../general_flow/general_flow_form.dart';
import 'activity_datum.dart';
import 'recent_activity.dart';
import 'scan_to_pay.dart';
import 'user.dart';

enum UserType {
  customer,
  nonCustomer,
}

class AuthData extends Equatable {
  final UserType? userType;
  final String? sessionId;
  final User? user;
  final List<RecentActivity>? recentActivity;
  final List<Account>? customerData;
  final List<GeneralFlowForm>? nonCustomerData;
  final dynamic quickAction;
  final ScanToPay? scanToPay;
  final List<ActivityDatum>? activities;
  final String? imageBaseUrl;
  final String? imageDirectory;
  final String? profilePicture;

  const AuthData({
    this.userType,
    this.sessionId,
    this.user,
    this.recentActivity,
    this.customerData,
    this.nonCustomerData,
    this.quickAction,
    this.scanToPay,
    this.activities,
    this.imageBaseUrl,
    this.imageDirectory,
    this.profilePicture,
  });

  factory AuthData.fromMap(Map<String, dynamic> data) => AuthData(
    userType: (data['userType'] as String?) == 'CUSTOMER'
        ? UserType.customer
        : UserType.nonCustomer,
    sessionId: data['sessionId'] as String?,
    user: data['user'] == null
        ? null
        : User.fromMap(data['user'] as Map<String, dynamic>),
    recentActivity: (data['recentActivity'] as List<dynamic>?)
        ?.map((e) => RecentActivity.fromMap(e as Map<String, dynamic>))
        .toList(),
    customerData: (data['customerData'] as List<dynamic>?)
        ?.map((e) => Account.fromMap(e as Map<String, dynamic>))
        .toList(),
    // customerData: (data['customerData'] as List<dynamic>?)?.map((e) => CustomerDatum.fromJson(e as String)).toList(),
    nonCustomerData: (data['nonCustomerData'] as List<dynamic>?)
        ?.map((e) => GeneralFlowForm.fromMap(e as Map<String, dynamic>))
        .toList(),
    quickAction: data['quickAction'] as dynamic,
    scanToPay: data['scanToPay'] == null
        ? null
        : ScanToPay.fromMap(data['scanToPay'] as Map<String, dynamic>),
    activities: (data['activities'] as List<dynamic>?)
        ?.map((e) => ActivityDatum.fromMap(e as Map<String, dynamic>))
        .toList(),
    imageBaseUrl: data['imageBaseUrl'] as String?,
    imageDirectory: data['imageDirectory'] as String?,
    profilePicture: data['profilePicture'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'userType': userType == UserType.customer ? 'CUSTOMER' : 'NONCUSTOMER',
    'sessionId': sessionId,
    'user': user?.toMap(),
    'recentActivity': recentActivity?.map((e) => e.toMap()).toList(),
    'customerData': customerData?.map((e) => e.toMap()).toList(),
    'nonCustomerData': nonCustomerData?.map((e) => e.toMap()).toList(),
    'quickAction': quickAction,
    'scanToPay': scanToPay?.toMap(),
    'activities': activities?.map((e) => e.toMap()).toList(),
    'imageBaseUrl': imageBaseUrl,
    'imageDirectory': imageDirectory,
    'profilePicture': profilePicture,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AuthData].
  factory AuthData.fromJson(String data) {
    return AuthData.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AuthData] to a JSON string.
  String toJson() => json.encode(toMap());

  AuthData copyWith({
    UserType? userType,
    String? sessionId,
    User? user,
    List<RecentActivity>? recentActivity,
    List<Account>? customerData,
    List<GeneralFlowForm>? nonCustomerData,
    dynamic quickAction,
    ScanToPay? scanToPay,
    List<ActivityDatum>? activities,
    String? imageBaseUrl,
    String? imageDirectory,
    String? profilePicture,
  }) {
    return AuthData(
      userType: userType ?? this.userType,
      sessionId: sessionId ?? this.sessionId,
      user: user ?? this.user,
      recentActivity: recentActivity ?? this.recentActivity,
      customerData: customerData ?? this.customerData,
      nonCustomerData: nonCustomerData ?? this.nonCustomerData,
      quickAction: quickAction ?? this.quickAction,
      scanToPay: scanToPay ?? this.scanToPay,
      activities: activities ?? this.activities,
      imageBaseUrl: imageBaseUrl ?? this.imageBaseUrl,
      imageDirectory: imageDirectory ?? this.imageDirectory,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      userType,
      sessionId,
      user,
      recentActivity,
      customerData,
      nonCustomerData,
      quickAction,
      scanToPay,
      activities,
      imageBaseUrl,
      imageDirectory,
      profilePicture,
    ];
  }
}
