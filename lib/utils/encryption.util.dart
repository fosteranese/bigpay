import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart' as crypt;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';
import 'package:xml/xml.dart' as xml;
import 'package:convert/convert.dart';

import '../env/env.dart';

class EncryptionUtil {
  /// A fresh AES-GCM key and nonce for a single request.
  ///
  /// Both are drawn straight from a CSPRNG. Deriving them through a KDF would
  /// only stretch an already-random value: the key never leaves the client
  /// unencrypted and is handed to the server via RSA rather than re-derived
  /// there, so there is nothing low-entropy to strengthen.
  static (enc.Key, enc.IV) get _keys {
    final random = Random.secure();

    // 16 bytes — AesGcm.with128bits.
    final key = Uint8List(16);
    for (int i = 0; i < key.length; i++) {
      key[i] = random.nextInt(256);
    }

    // 12 bytes — the standard AES-GCM nonce length.
    final iv = Uint8List(12);
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }

    return (enc.Key(key), enc.IV(iv));
  }

  /// Built once, on first use.
  ///
  /// The key is a compile-time constant, but parsing it walks an XML document
  /// and rebuilds two BigInts from hex, and the RSA engine behind the encrypter
  /// is not cheap to construct either. `encryptRSA` runs twice per request, so
  /// deriving this per call repeated all of that work for an unchanging result.
  /// Reuse is safe: `RSA.encrypt` resets and re-initialises its cipher on every
  /// call and never yields, so calls cannot interleave or inherit state.
  static final enc.Encrypter _rsaEncrypter = enc.Encrypter(
    enc.RSA(
      publicKey: _parseRsaPublicKey(),
    ),
  );

  static RSAPublicKey _parseRsaPublicKey() {
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
    final (key, iv) = _keys;
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
    final encrypted = _rsaEncrypter.encrypt(clearText);

    return encrypted.base64;
  }
}
