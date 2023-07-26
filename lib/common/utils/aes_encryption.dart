// ignore_for_file: camel_case_types

import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:encrypt/encrypt.dart';

class AES_Key {
  final String key;
  final String iv;

  AES_Key({
    required this.key,
    required this.iv,
  });
}

class E2EE_AES {
  // --------------------------------------------------------------
  // Generate AES KeyPair
  // --------------------------------------------------------------
  AES_Key generateAESKey() {
    final key = Key.fromSecureRandom(16);
    final iv = IV.fromSecureRandom(8);

    final keyString = key.base64; // Convert the key to a string
    final ivString = iv.base64; // Convert the IV to a string

    return AES_Key(key: keyString, iv: ivString);
  }

  // --------------------------------------------------------------
  // Function for AES Encryption
  // --------------------------------------------------------------
  String encrypter(String savedKey, String savedIv, String text) {
    final key = Key.fromBase64(savedKey);
    final iv = IV.fromBase64(savedIv);
    final encrypter = Encrypter(AES(key, padding: null));

    final cipher = encrypter.encrypt(text, iv: iv);

    final cipherHexString = hex.encode(cipher.bytes);

    return cipherHexString;
  }

  // --------------------------------------------------------------
  // Function for AES Decryption
  // --------------------------------------------------------------
  String decrypter(String savedKey, String savedIv, String cipher) {
    final encryptedBytes = hex.decode(cipher);

    final key = Key.fromBase64(savedKey);
    final iv = IV.fromBase64(savedIv);
    final decrypter = Encrypter(AES(key, padding: null));

    final encrypted = Encrypted(encryptedBytes as Uint8List);

    final decrypted = decrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }
}
