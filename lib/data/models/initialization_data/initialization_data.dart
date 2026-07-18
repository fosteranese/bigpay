import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'advert.dart';
import 'help.dart';
import 'locator_type.dart';
import 'secret_question.dart';
import 'social.dart';
import 'walk_through.dart';

class InitializationData extends Equatable {
  final List<WalkThrough>? walkThrough;
  final String? termsAndConditions;
  final String? privacyPolicy;
  final List<SecretQuestion>? secretQuestions;
  final Help? help;
  final dynamic locatorsList;
  final List<LocatorType>? locatorTypes;
  final Social? social;
  final List<Advert>? advert;
  final List<dynamic>? otherLinks;
  final String? imageBaseUrl;
  final String? imageDirectory;

  const InitializationData({
    this.walkThrough,
    this.termsAndConditions,
    this.privacyPolicy,
    this.secretQuestions,
    this.help,
    this.locatorsList,
    this.locatorTypes,
    this.social,
    this.advert,
    this.otherLinks,
    this.imageBaseUrl,
    this.imageDirectory,
  });

  factory InitializationData.fromMap(Map<String, dynamic> data) {
    return InitializationData(
      walkThrough: (data['walkThrough'] as List<dynamic>?)
          ?.map((e) => WalkThrough.fromMap(e as Map<String, dynamic>))
          .toList(),
      termsAndConditions: data['termsAndConditions'] as String?,
      privacyPolicy: data['privacyPolicy'] as String?,
      secretQuestions: (data['secretQuestions'] as List<dynamic>?)
          ?.map((e) => SecretQuestion.fromMap(e as Map<String, dynamic>))
          .toList(),
      help: data['help'] == null
          ? null
          : Help.fromMap(data['help'] as Map<String, dynamic>),
      locatorsList: data['locatorsList'] as dynamic,
      locatorTypes: (data['locatorTypes'] as List<dynamic>?)
          ?.map((e) => LocatorType.fromMap(e as Map<String, dynamic>))
          .toList(),
      social: data['social'] == null
          ? null
          : Social.fromMap(data['social'] as Map<String, dynamic>),
      advert: (data['advert'] as List<dynamic>?)
          ?.map((e) => Advert.fromMap(e as Map<String, dynamic>))
          .toList(),
      otherLinks: data['otherLinks'] as List<dynamic>?,
      imageBaseUrl: data['imageBaseUrl'] as String?,
      imageDirectory: data['imageDirectory'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'walkThrough': walkThrough?.map((e) => e.toMap()).toList(),
    'termsAndConditions': termsAndConditions,
    'privacyPolicy': privacyPolicy,
    'secretQuestions': secretQuestions?.map((e) => e.toMap()).toList(),
    'help': help?.toMap(),
    'locatorsList': locatorsList,
    'locatorTypes': locatorTypes?.map((e) => e.toMap()).toList(),
    'social': social?.toMap(),
    'advert': advert?.map((e) => e.toMap()).toList(),
    'otherLinks': otherLinks,
    'imageBaseUrl': imageBaseUrl,
    'imageDirectory': imageDirectory,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [InitializationData].
  factory InitializationData.fromJson(String data) {
    return InitializationData.fromMap(
      json.decode(data) as Map<String, dynamic>,
    );
  }

  /// `dart:convert`
  ///
  /// Converts [InitializationData] to a JSON string.
  String toJson() => json.encode(toMap());

  InitializationData copyWith({
    List<WalkThrough>? walkThrough,
    String? termsAndConditions,
    String? privacyPolicy,
    List<SecretQuestion>? secretQuestions,
    Help? help,
    dynamic locatorsList,
    List<LocatorType>? locatorTypes,
    Social? social,
    List<Advert>? advert,
    List<dynamic>? otherLinks,
    String? imageBaseUrl,
    String? imageDirectory,
  }) {
    return InitializationData(
      walkThrough: walkThrough ?? this.walkThrough,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      secretQuestions: secretQuestions ?? this.secretQuestions,
      help: help ?? this.help,
      locatorsList: locatorsList ?? this.locatorsList,
      locatorTypes: locatorTypes ?? this.locatorTypes,
      social: social ?? this.social,
      advert: advert ?? this.advert,
      otherLinks: otherLinks ?? this.otherLinks,
      imageBaseUrl: imageBaseUrl ?? this.imageBaseUrl,
      imageDirectory: imageDirectory ?? this.imageDirectory,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      walkThrough,
      termsAndConditions,
      privacyPolicy,
      secretQuestions,
      help,
      locatorsList,
      locatorTypes,
      social,
      advert,
      otherLinks,
      imageBaseUrl,
      imageDirectory,
    ];
  }
}
