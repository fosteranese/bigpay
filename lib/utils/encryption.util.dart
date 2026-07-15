import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart' as crypt;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart' as xml;
import 'package:convert/convert.dart';

import '../env/env.dart';

class EncryptionUtil {
  static Future<(enc.Key, enc.IV)> get _keys async {
    // Generate a random password
    final pwd1 = const Uuid().v4();
    final random = Random.secure();

    // Generate a 32-byte salt
    // Generate a 16-byte salt
    final salt1 = Uint8List(16);
    for (int i = 0; i < salt1.length; i++) {
      salt1[i] = random.nextInt(128);
    }

    // Generate a key from the password and salt
    final keyGen = crypt.Pbkdf2(
      macAlgorithm: crypt.Hmac.sha256(),
      iterations: 10000,
      bits: 128,
    );

    final secretKey = await keyGen.deriveKey(
      secretKey: crypt.SecretKey(utf8.encode(pwd1)),
      nonce: salt1,
    );

    final key = await secretKey.extractBytes();

    // Generate a 12-byte IV
    final iv = Uint8List(12);
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(128);
    }

    final key64 = base64Encode(key);
    final iv64 = base64Encode(iv);
    return (enc.Key.fromBase64(key64), enc.IV.fromBase64(iv64));
  }

  static RSAPublicKey get _rsaPublicKey {
    var xmlDocument = xml.XmlDocument.parse(Env.rsaPublicKey);
    var modulus = _getData(xmlDocument, 'Modulus');
    var exponent = _getData(xmlDocument, 'Exponent');
    var publicKey = RSAPublicKey(modulus, exponent);

    return publicKey;
  }

  static BigInt _getData(xml.XmlDocument xmlDocument, String element) {
    var elementNode = xmlDocument.findAllElements(element).firstOrNull;
    if (elementNode == null) {
      throw StateError('Missing RSA key element: $element');
    }
    var dataB64 = elementNode.innerText;
    var dataBytes = Uint8List.fromList(base64.decode(dataB64));
    return BigInt.parse(hex.encode(dataBytes), radix: 16);
  }

  static Uint8List createUint8ListFromString(String s) {
    var ret = Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }
    return ret;
  }

  static Future<(String, enc.Key, enc.IV)> encrypt(String clearText) async {
    final (key, iv) = await _keys;
    final plaintextBytes = utf8.encode(clearText);

    // Encrypt using AES-GCM
    final aesGcm = crypt.AesGcm.with128bits();
    final secretKey = crypt.SecretKey(key.bytes);
    final nonce = Uint8List.fromList(iv.bytes);

    final secretBox = await aesGcm.encrypt(
      plaintextBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    // Combine IV, cipher text, and tag into a single array
    var combined =
        Uint8List(
            iv.bytes.length +
                secretBox.cipherText.length +
                secretBox.mac.bytes.length,
          )
          ..setRange(0, iv.bytes.length, iv.bytes)
          ..setRange(
            iv.bytes.length,
            iv.bytes.length + secretBox.cipherText.length,
            secretBox.cipherText,
          );
    combined = combined
      ..setRange(
        iv.bytes.length + secretBox.cipherText.length,
        combined.length,
        secretBox.mac.bytes,
      );

    final cipher = base64Encode(combined);
    return (cipher, key, iv);
  }

  static Future<String> decrypt(
    String cipherTextCombined,
    enc.Key key,
    enc.IV iv,
  ) async {
    final combined = base64Decode(cipherTextCombined);

    // Define lengths based on GCM standard
    final iv = combined.sublist(0, 12); // 12-byte IV for AES-GCM
    final tag = combined.sublist(
      combined.length - 16,
    ); // 16-byte authentication tag
    final cipherText = combined.sublist(12, combined.length - 16);

    // Decrypt using AES-GCM
    final aesGcm = crypt.AesGcm.with128bits();
    final secretKey = crypt.SecretKey(key.bytes);

    final secretBox = crypt.SecretBox(
      cipherText,
      nonce: iv,
      mac: crypt.Mac(tag),
    );

    final plainTextBytes = await aesGcm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(plainTextBytes);
  }

  static Future<String> encryptRSA(String clearText) async {
    final encrypter = enc.Encrypter(
      enc.RSA(
        publicKey: _rsaPublicKey,
      ),
    );
    final encrypted = encrypter.encrypt(clearText);

    return encrypted.base64;
  }
}
