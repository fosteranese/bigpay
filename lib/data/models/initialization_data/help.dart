import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'social.dart';

class Help extends Equatable {
  final String? privacyUrl;
  final String? termsUrl;
  final String? websiteUrl;
  final String? faqUrl;
  final String? email;
  final String? phoneNumber;
  final String? whatsApp;
  final String? linkGhCard;
  final String? formId;
  final String? descrption;
  final Social? social;
  final String? activityType;

  const Help({
    this.privacyUrl,
    this.termsUrl,
    this.websiteUrl,
    this.faqUrl,
    this.email,
    this.phoneNumber,
    this.whatsApp,
    this.linkGhCard,
    this.formId,
    this.descrption,
    this.social,
    this.activityType,
  });

  factory Help.fromMap(Map<String, dynamic> data) => Help(
    privacyUrl: data['privacyUrl'] as String?,
    termsUrl: data['termsUrl'] as String?,
    websiteUrl: data['websiteUrl'] as String?,
    faqUrl: data['faqUrl'] as String?,
    email: data['email'] as String?,
    phoneNumber: data['phoneNumber'] as String?,
    whatsApp: data['whatsApp'] as String?,
    linkGhCard: data['linkGHCard'] as String?,
    formId: data['formId'] as String?,
    descrption: data['descrption'] as String?,
    social: data['social'] == null
        ? null
        : Social.fromMap(data['social'] as Map<String, dynamic>),
    activityType: data['activityType'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'privacyUrl': privacyUrl,
    'termsUrl': termsUrl,
    'websiteUrl': websiteUrl,
    'faqUrl': faqUrl,
    'email': email,
    'phoneNumber': phoneNumber,
    'whatsApp': whatsApp,
    'linkGHCard': linkGhCard,
    'formId': formId,
    'descrption': descrption,
    'social': social?.toMap(),
    'activityType': activityType,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Help].
  factory Help.fromJson(String data) {
    return Help.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Help] to a JSON string.
  String toJson() => json.encode(toMap());

  Help copyWith({
    String? privacyUrl,
    String? termsUrl,
    String? websiteUrl,
    String? faqUrl,
    String? email,
    String? phoneNumber,
    String? whatsApp,
    String? linkGhCard,
    String? formId,
    String? descrption,
    Social? social,
    String? activityType,
  }) {
    return Help(
      privacyUrl: privacyUrl ?? this.privacyUrl,
      termsUrl: termsUrl ?? this.termsUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      faqUrl: faqUrl ?? this.faqUrl,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsApp: whatsApp ?? this.whatsApp,
      linkGhCard: linkGhCard ?? this.linkGhCard,
      formId: formId ?? this.formId,
      descrption: descrption ?? this.descrption,
      social: social ?? this.social,
      activityType: activityType ?? this.activityType,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      privacyUrl,
      termsUrl,
      websiteUrl,
      faqUrl,
      email,
      phoneNumber,
      whatsApp,
      linkGhCard,
      formId,
      descrption,
      social,
      activityType,
    ];
  }
}
