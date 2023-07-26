// ignore_for_file: camel_case_types

import 'dart:math';
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:basic_utils/basic_utils.dart';

class E2EE_RSA {
  // --------------------------------------------------------------
  // Generate RSA KeyPair
  // --------------------------------------------------------------
  AsymmetricKeyPair<PublicKey, PrivateKey> generateRSAKeyPair() {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (var i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final keyParams = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);
    final keyGenerator = RSAKeyGenerator()
      ..init(ParametersWithRandom(keyParams, secureRandom));

    return keyGenerator.generateKeyPair();
  }

  // --------------------------------------------------------------
  // Function for RSA Encryption
  // --------------------------------------------------------------
  String encrypter(PublicKey publicKey, String text) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final chiper = encryptor.process(Uint8List.fromList(text.codeUnits));
    return hex.encode(chiper);
  }

  // --------------------------------------------------------------
  // Function for RSA Decryption
  // --------------------------------------------------------------
  String decrypter(PrivateKey privateKey, String hex) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final decryptedText =
        String.fromCharCodes(decryptor.process(HexUtils.decode(hex)));
    return decryptedText;
  }
}

// --------------------------------------------------------------
// Function to extract String from Key
// --------------------------------------------------------------
String extractKeyString(String keyString) {
  final items = <String>[
    '\n',
    '-----BEGIN PUBLIC KEY-----',
    '-----END PUBLIC KEY-----',
    '-----BEGIN PRIVATE KEY-----',
    '-----END PRIVATE KEY-----',
  ];
  for (var i = 0; i < items.length; i++) {
    keyString = keyString.replaceAll(items[i], '');
  }
  return keyString;
}

// --------------------------------------------------------------
// Function to add String from Key
// *this function is necessary for encryption & decryption to work
// --------------------------------------------------------------
String addHeaderFooter(String keyString, bool isPublicKey) {
  const pubHeader = '-----BEGIN PUBLIC KEY-----';
  const pubFooter = '-----END PUBLIC KEY-----';
  const privHeader = '-----BEGIN PRIVATE KEY-----';
  const privFooter = '-----END PRIVATE KEY-----';

  final formattedKey = StringBuffer();

  for (var i = 0; i < keyString.length; i += 64) {
    formattedKey.write(keyString.substring(
        i, i + 64 < keyString.length ? i + 64 : keyString.length));
    formattedKey.write('\n');
  }

  return isPublicKey == true
      ? '$pubHeader\n$formattedKey$pubFooter'
      : '$privHeader\n$formattedKey$privFooter';
}
