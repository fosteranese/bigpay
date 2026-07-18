import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAIN_BASE_URL', obfuscate: true)
  static final String mainBaseUrl = _Env.mainBaseUrl;

  @EnviedField(varName: 'MAIN_ROOT_PATH', obfuscate: true)
  static final String mainRootPath = _Env.mainRootPath;

  @EnviedField(varName: 'PIN_LENGTH', obfuscate: true)
  static final int pingLength = _Env.pingLength;

  @EnviedField(
    varName: 'RESEND_OTP_AFTER_IN_SECONDS',
    obfuscate: true,
  )
  static final int resendOtpAfterInSeconds = _Env.resendOtpAfterInSeconds;

  @EnviedField(
    varName: 'COUNTRY_FLAG_BASE_URL',
    obfuscate: true,
  )
  static final String countryFlagBaseUrl = _Env.countryFlagBaseUrl;

  @EnviedField(
    varName: 'GOOGLE_MAP_API_KEY',
    obfuscate: true,
  )
  static final String googleMapApiKey = _Env.googleMapApiKey;

  @EnviedField(
    varName: 'GOOGLE_MAP_BASE_URL',
    obfuscate: true,
  )
  static final String googleMapBaseUrl = _Env.googleMapBaseUrl;

  @EnviedField(
    varName: 'GOOGLE_MAP_PLACE_BASE_PATH_URL',
    obfuscate: true,
  )
  static final String googleMapPlaceBasePathUrl =
      _Env.googleMapPlaceBasePathUrl;

  @EnviedField(
    varName: 'GOOGLE_SHARE_LOCATION_URL',
    obfuscate: true,
  )
  static final String googleShareLocationUrl = _Env.googleShareLocationUrl;

  @EnviedField(varName: 'RSA_PUBLIC_KEY', obfuscate: true)
  static final String rsaPublicKey = _Env.rsaPublicKey;

  @EnviedField(varName: 'APP_ID', obfuscate: true)
  static final String appId = _Env.appId;

  @EnviedField(varName: 'APPLE_TEAM', obfuscate: true)
  static final String appleTeam = _Env.appleTeam;

  @EnviedField(
    varName: 'ANDROID_SIGNING_CERT_HASHES',
    obfuscate: true,
  )
  static final String androidSigningCertHashes = _Env.androidSigningCertHashes;

  @EnviedField(
    varName: 'ANDROID_SIGNING_CERT_HASH_UPLOAD',
    obfuscate: true,
  )
  static final String androidSigningCertHashUpload =
      _Env.androidSigningCertHashUpload;

  @EnviedField(
    varName: 'ANDROID_SIGNING_CERT_HASH_DEBUG',
    obfuscate: true,
  )
  static final String androidSigningCertHashDebug =
      _Env.androidSigningCertHashDebug;

  @EnviedField(varName: 'WATCH_EMAIL', obfuscate: true)
  static final String watchEmail = _Env.watchEmail;

  @EnviedField(varName: 'ANDROID_API_KEY', obfuscate: true)
  static final String androidApiKey = _Env.androidApiKey;
  @EnviedField(varName: 'ANDROID_APP_ID', obfuscate: true)
  static final String androidAppId = _Env.androidAppId;
  @EnviedField(
    varName: 'ANDROID_MESSAGING_SENDER_ID',
    obfuscate: true,
  )
  static final String androidMessagingSenderId = _Env.androidMessagingSenderId;
  @EnviedField(
    varName: 'ANDROID_PROJECT_ID',
    obfuscate: true,
  )
  static final String androidProjectId = _Env.androidProjectId;
  @EnviedField(
    varName: 'ANDROID_DATABASE_URL',
    obfuscate: true,
  )
  static final String androidDatabaseUrl = _Env.androidDatabaseUrl;
  @EnviedField(
    varName: 'ANDROID_STORAGE_BUCKET',
    obfuscate: true,
  )
  static final String androidStorageBucket = _Env.androidStorageBucket;
  @EnviedField(
    varName: 'ANDROID_BUNDLE_ID',
    obfuscate: true,
  )
  static final String androidBundleId = _Env.androidBundleId;

  @EnviedField(varName: 'IOS_API_KEY', obfuscate: true)
  static final String iosApiKey = _Env.iosApiKey;
  @EnviedField(varName: 'IOS_APP_ID', obfuscate: true)
  static final String iosAppId = _Env.iosAppId;
  @EnviedField(
    varName: 'IOS_MESSAGING_SENDER_ID',
    obfuscate: true,
  )
  static final String iosMessagingSenderId = _Env.iosMessagingSenderId;
  @EnviedField(varName: 'IOS_PROJECT_ID', obfuscate: true)
  static final String iosProjectId = _Env.iosProjectId;
  @EnviedField(varName: 'IOS_DATABASE_URL', obfuscate: true)
  static final String iosDatabaseUrl = _Env.iosDatabaseUrl;
  @EnviedField(
    varName: 'IOS_STORAGE_BUCKET',
    obfuscate: true,
  )
  static final String iosStorageBucket = _Env.iosStorageBucket;
  @EnviedField(varName: 'IOS_BUNDLE_ID', obfuscate: true)
  static final String iosBundleId = _Env.iosBundleId;

  @EnviedField(varName: 'IOS_APP_STORE_ID', obfuscate: true)
  static final String iosAppStoreId = _Env.iosAppStoreId;

  @EnviedField(varName: 'BUILD_NUMBER', obfuscate: true)
  static final String buildNumber = _Env.buildNumber;
}
