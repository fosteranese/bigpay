import 'dart:convert';

import 'package:equatable/equatable.dart';

class DeviceInfo extends Equatable {
  final String? version;
  final String? build;
  final String? channel;
  final String? deviceId;
  final String? deviceName;
  final String? description;
  final String? deviceType;
  final String? ipAddress;
  final String? macAddress;
  final String? longitude;
  final String? latitude;
  final String? userAgent;
  final String? fcmToken;
  final bool? isPhysicalDevice;

  const DeviceInfo({
    this.version,
    this.build,
    this.channel,
    this.deviceId,
    this.deviceName,
    this.description,
    this.deviceType,
    this.ipAddress,
    this.macAddress,
    this.longitude,
    this.latitude,
    this.userAgent,
    this.fcmToken,
    this.isPhysicalDevice,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> data) => DeviceInfo(
    version: data['version'] as String?,
    build: data['build'] as String?,
    channel: data['channel'] as String?,
    deviceId: data['deviceId'] as String?,
    deviceName: data['deviceName'] as String?,
    description: data['description'] as String?,
    deviceType: data['deviceType'] as String?,
    ipAddress: data['ipAddress'] as String?,
    macAddress: data['macAddress'] as String?,
    longitude: data['longitude'] as String?,
    latitude: data['latitude'] as String?,
    userAgent: data['userAgent'] as String?,
    fcmToken: data['fcmToken'] as String?,
    isPhysicalDevice: data['isPhysicalDevice'] as bool?,
  );

  Map<String, dynamic> toMap() => {
    'version': version,
    'build': build,
    'channel': channel,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'description': description,
    'deviceType': deviceType,
    'ipAddress': ipAddress,
    'macAddress': macAddress,
    'longitude': longitude,
    'latitude': latitude,
    'userAgent': userAgent,
    'fcmToken': fcmToken,
    'isPhysicalDevice': isPhysicalDevice,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [DeviceInfo].
  factory DeviceInfo.fromJson(String data) {
    return DeviceInfo.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [DeviceInfo] to a JSON string.
  String toJson() => json.encode(toMap());

  DeviceInfo copyWith({
    String? version,
    String? build,
    String? channel,
    String? deviceId,
    String? deviceName,
    String? description,
    String? deviceType,
    String? ipAddress,
    String? macAddress,
    String? longitude,
    String? latitude,
    String? userAgent,
    String? fcmToken,
    bool? isPhysicalDevice,
  }) {
    return DeviceInfo(
      version: version ?? this.version,
      build: build ?? this.build,
      channel: channel ?? this.channel,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      description: description ?? this.description,
      deviceType: deviceType ?? this.deviceType,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      userAgent: userAgent ?? this.userAgent,
      fcmToken: fcmToken ?? this.fcmToken,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
    );
  }

  @override
  List<Object?> get props {
    return [
      version,
      build,
      channel,
      deviceId,
      deviceName,
      description,
      deviceType,
      ipAddress,
      macAddress,
      longitude,
      latitude,
      userAgent,
      fcmToken,
      isPhysicalDevice,
    ];
  }
}
