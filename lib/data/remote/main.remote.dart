import 'dart:convert';
import 'dart:io';

import 'package:bigpay/constants/response.const.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

import 'package:bigpay/env/env.dart';
import 'package:bigpay/logger.dart';
import 'package:bigpay/utils/encryption.util.dart';
import 'package:bigpay/utils/response.util.dart';

class MainRemote {
  Future<IOClient> _createPinnedClient(
    void Function() onRejected,
  ) async {
    final sslCert = await rootBundle.load(
      'assets/certificate.pem',
    );
    SecurityContext securityContext = SecurityContext(
      withTrustedRoots: false,
    );
    securityContext.setTrustedCertificatesBytes(
      sslCert.buffer.asInt8List(),
    );

    HttpClient client = HttpClient(
      context: securityContext,
    );
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          // if (kDebugMode) return true;
          onRejected();
          return false;
        };
    return IOClient(client);
  }

  Future<Map<String, dynamic>> _formatRequestPayload({
    required String path,
    required Map<String, dynamic>? body,
    required bool isAuthenticated,
    bool encrypt = true,
  }) async {
    // final appInfo = AppUtil.info;
    Map<String, dynamic> data = {
      // 'meta': appInfo.toMap(),
      // 'EndPoint': path,
    };

    if (body != null) {
      // body["channel"] = appInfo.channel;
      // body["deviceId"] = appInfo.deviceId;

      data['payLoad'] = body;
    }

    if (isAuthenticated) {
      // data['meta']['sessionId'] = AppState.currentUser.sessionId;
    }

    if (encrypt) {
      final jsonText = json.encode(data);
      logger.i(jsonText);
      final (String cipher, Key key, IV iv) = await EncryptionUtil.encrypt(
        jsonText,
      );

      final finalCipher = json.encode(cipher);
      logger.i('Encrypted payload');
      logger.i(finalCipher);
      return {
        'payload': finalCipher,
        'key': key,
        'iv': iv,
      };
    }

    return {'payload': json.encode(data)};
  }

  Future<Response<dynamic>> _decodeResponse({
    required String cipherText,
    Key? key,
    IV? iv,
    bool isEncrypted = true,
  }) async {
    final responseBody = isEncrypted
        ? await EncryptionUtil.decrypt(
            cipherText,
            key!,
            iv!,
          )
        : cipherText;

    logger.i(responseBody);

    var info = json.decode(responseBody);
    var result = Response<dynamic>(
      code: info['status'].toString(),
      status: ResponseUtil.convertFromStatusCode(
        info['status'] as int,
      ),
      message: info['message'].toString(),
      data: info['data'] is! List<dynamic>
          ? info['data']
          : {'list': info['data']},
      timeStamp: info['timeStamp']?.toString(),
      imageBaseUrl: info['imageBaseUrl']?.toString(),
      imageDirectory: info['imageDirectory']?.toString(),
    );

    if (result.data != null && result.data is! String) {
      if (info['timeStamp'] != null) {
        result.data['timeStamp'] = info['timeStamp'];
      }
      if (info['imageBaseUrl'] != null) {
        result.data['imageBaseUrl'] = info['imageBaseUrl'];
      }
      if (info['imageDirectory'] != null) {
        result.data['imageDirectory'] = info['imageDirectory'];
      }
      if (info['extra'] != null) {
        result.data['extra'] = info['extra'];
      }
    }

    return result;
  }

  Future<Response<dynamic>> post({
    required String path,
    Map<String, dynamic>? body,
    bool isAuthenticated = false,
    bool encrypt = true,
  }) async {
    var pinningViolated = false;
    IOClient? client;
    try {
      logger.i('url: $path');
      var request = await _formatRequestPayload(
        body: body,
        path: path,
        isAuthenticated: isAuthenticated,
        encrypt: encrypt,
      );
      logger.i(body);

      final payload = request['payload'];
      final iv = request.containsKey('iv') ? (request['iv'] as IV) : null;
      final key = request.containsKey('key') ? (request['key'] as Key) : null;

      // SSL Pinned client for api calls
      client = await _createPinnedClient(() {
        pinningViolated = true;
      });
      var url = Uri.https(
        Env.mainBaseUrl,
        "${Env.mainRootPath}/$path",
      );
      var rsaAv = await EncryptionUtil.encryptRSA(
        iv?.base64 ?? '',
      );
      var rsaKey = await EncryptionUtil.encryptRSA(
        key?.base64 ?? '',
      );
      var response = await client.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "av": rsaAv,
          "key": rsaKey,
        },
        body: payload,
      );

      final result = await _decodeResponse(
        cipherText: response.body,
        isEncrypted: encrypt,
        iv: iv,
        key: key,
      );
      logger.i(result);

      return result;
    } on SocketException catch (e) {
      logger.e(e);
      // SecurityUtil.deviceStatus = GeneralResponseConst.offline;
      return GeneralResponseConst.offline;
    } on HandshakeException catch (_) {
      if (pinningViolated) {
        // SecurityUtil.deviceStatus = GeneralResponseConst.forceUpdate;
        return GeneralResponseConst.forceUpdate;
      }
      // SecurityUtil.deviceStatus = GeneralResponseConst.offline;
      return GeneralResponseConst.offline;
    } catch (e) {
      logger.e(e);
      // SecurityUtil.deviceStatus = GeneralResponseConst.unknown;
      return GeneralResponseConst.unknown;
    } finally {
      client?.close();
    }
  }
}
