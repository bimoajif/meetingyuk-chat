// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:convert/convert.dart';
import 'package:encrypt/encrypt.dart';
import 'package:realtime_chat/common/utils/rsa_encryption.dart';

void main() {
  E2EE_RSA e2eersa = E2EE_RSA();
  AesEncryption aes = AesEncryption();
  AES_Key aeskey = aes.generateAESKey();
  AsymmetricKeyPair key = e2eersa.generateRSAKeyPair();
  final String text = "ZJaTmYn6YRVa/Ao79+QRzg==";
  // final encryptedText = '8cbc1ae88f595ad20c9fa55dfb19ff14f6f3852802771ff244790352382982c9893709d8a9ce0a164c953bf6b2de5d25442b729213f1ba1e785c348538670f62a8bdc723a0b6b758125957cefcd57da39c4b196bb52f4d962a4b71a881d223522fc8c639b114b9004f24f073e4afac36dee3b30f66c9daeefc2118a13bae6da61230f6eefc68f03391874e26480c6824ba689cbb8561267a01e4d35993a8c77cfb8cf4a99ed87885efec7ef4f376c9650b81e40e43fb3567f116e6e0055202046f44e5cd70fb2c6c857229d0dc379d405aa29bce3f9be82b6cf27c0b9f0c573f0323b6aabb42e37db27c76b0feb626a787b6dca4eeb925cbec0336f35a80925c';

  String publicKey =
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAh9li1m0VWUjN2wZiCX46k9U3aAgfJ6WKkW0Y6MP30n2ajScZUFqj2eB3w7qHyLJAXVAxXe0E2sxtO20mRphOtv91fRjWj2nLXGKi//jZb/JewZvvgXRIi5JAZQlL5ChrBpNf8RRFscj2HzBNyNlZd0GrOwYoyf8+fSGO8Sj4tDrcq0FctCEqww7eUEP8+4VKOYSnwmMtnowxmeEv6hNUz0hHx2qiT425YtOIwRB0H5B773oTsZH9o04343ZlU+8H/3TEU1QA/OZU+S45jc6tmy9cmS+wulsyB1ps3XMAorvVkDcEBZTvJGr2iO/R4pfT8DW0PtzqwcWxiqkn40ZnZQIDAQAB';
  String privateKey =
      'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCH2WLWbRVZSM3bBmIJfjqT1TdoCB8npYqRbRjow/fSfZqNJxlQWqPZ4HfDuofIskBdUDFd7QTazG07bSZGmE62/3V9GNaPactcYqL/+Nlv8l7Bm++BdEiLkkBlCUvkKGsGk1/xFEWxyPYfME3I2Vl3Qas7BijJ/z59IY7xKPi0OtyrQVy0ISrDDt5QQ/z7hUo5hKfCYy2ejDGZ4S/qE1TPSEfHaqJPjbli04jBEHQfkHvvehOxkf2jTjfjdmVT7wf/dMRTVAD85lT5LjmNzq2bL1yZL7C6WzIHWmzdcwCiu9WQNwQFlO8kavaI79Hil9PwNbQ+3OrBxbGKqSfjRmdlAgMBAAECggEAEQUwd/MU0KnpeL6U++F/z1PQbE1QMfRwpwXHMCqVWx73hSXX6xRgIQUZnEE7j+6dV9ObS8xNZmhkaySivgeJHS5mdvTstO0pWHrXN0DjZT41lwZFfK+oAyygusfuZTiXKCzAwYCrtrmZ9JBlvntU1Tc6D9wWsjAzkRPqR9a9Sj9CblxIgy/zmfRicKh/F7jOG26Gyl+Dov1ggeKwgg6DAaGQOECLhQz7YIoW10LXfk66ssZ2FxMtP7Qy2oROXlA9+7WGciR8sLF9uxWTWiBtytRkfKhsqOgH/6/mpc1h3ytqHz3jlgD5PnKYSbE4pc1DpGp6DnRubRu+eSZsrOqo4QKBgQDZM9Ndxag8L1JuZSXPncJS5MKshOg+6vGHtRFiAFHdLfyIwB9Z9QllKbY4Hnr+6v+sn0mnstgX6hWU6GkAVsC1gA6bt97nbcYTeCbrk2idGXZGNgo/45ga+tZWkAZLEnezmDhl5/cPQlEkZYq1ZNK/XLzTt/NvdvLDpS9cT+7leQKBgQCgHXWzX5IRV9gcVGgrbSqjJNlblRR7dABRjykVwSFuJciGIoz7K5QvYtDTAl8fbky/rW/HdCINSq6wbVhBdVIa4NBAYADv3m+27rO8G2Q6Pt9NKjfzTqZg2vJSLEAqnll69efFD1neR67LzNxq7wKMhs9xWXiPSqGue/lBSrfyTQKBgQDAd/ZC0BYGTwDCporc8TTzc5c2fQe4SUUCNmdS6mmgj1GKdITTmBldNZstG4VuQxuRAg2otwhaGKpLK69wB2/45aMMReEWPuYY9o22jwdSvu9ZxCVM/AcbUU+BoVqSR6ke0jKXyvfY47E3iWti1hcST8Fb81OaYFM7HzNan9JYMQKBgQCECKcVmpreGF1Kx0P7g5MkY2+l+OKiBv94QiC0IsXJifi4u+cb/Ey/YrInPw5n4dICQigqBpdJ9KrnK9Qabn+dUIQKgeBj7T6cUG0AkmntKgmEHWt0BQhoWER5BKqJOnk5T2yncMg/50a6Ip4kxCGK9mQ76XbkWrvHIc5iTBYyBQKBgQCXmVHmG/Q3diI3rwXWx+8xGG2kU2/PFfM9rPBZ2EeOA95JGdvAQb6GEprMjbx8OgwtUqNFlebGiywnc71lFtNGjPnO5AvDNRFusxUonwpM2zXeLsRYf9ke6CJzzykvxf6bHnna/wzaSXxn6m2wwrfbPao2urFDF+/eFj1G1+PjGw==';

  // String publicKey = extractKeyString(CryptoUtils.encodeRSAPublicKeyToPem(
  //         key.publicKey as RSAPublicKey));
  
  // String privateKey = extractKeyString(CryptoUtils.encodeRSAPrivateKeyToPem(
  //         key.privateKey as RSAPrivateKey));

  // print('private key=\n$privateKey');
  // print('public key=\n$publicKey');

  final senderPublicKey = CryptoUtils.rsaPublicKeyFromPem(
    addHeaderFooter(
      publicKey,
      true,
    ),
  );
  
  final senderPrivateKey = CryptoUtils.rsaPrivateKeyFromPem(
    addHeaderFooter(privateKey, false,)
  );
  final encryptedRoomKey = e2eersa.encrypter(senderPublicKey, text);
  print("ciphertext=$encryptedRoomKey");

  final decryptedRoomKey = e2eersa.decrypter(senderPrivateKey, encryptedRoomKey);

  print("decryptedtext=$decryptedRoomKey");

  print(decryptedRoomKey==text);

  // final decryptedText = aes.decrypter(roomKey, aeskey.iv, ciphertext);
  // print(decryptedText);
}

class AES_Key {
  final String key;
  final String iv;

  AES_Key({
    required this.key,
    required this.iv,
  });

  List<String> toList() {
    return [key, iv];
  }
}

class AesEncryption {
  AES_Key generateAESKey() {
    final key = Key.fromSecureRandom(16);
    final iv = IV.fromSecureRandom(8);

    final keyString = key.base64; // Convert the key to a string
    final ivString = iv.base64; // Convert the IV to a string

    return AES_Key(key: keyString, iv: ivString);
  }

  String encrypter(String savedKey, String savedIv, String text) {
    final key = Key.fromBase64(savedKey);
    final iv = IV.fromBase64(savedIv);
    final encrypter = Encrypter(AES(key, padding: null));

    final cipher = encrypter.encrypt(text, iv: iv);

    final cipherHexString = hex.encode(cipher.bytes);

    return cipherHexString;
  }

  String decrypter(String savedKey, String savedIv, String cipher) {
    final encryptedBytes = hex.decode(cipher);

    final key = Key.fromBase64(savedKey);
    final iv = IV.fromBase64(savedIv);
    final decrypter = Encrypter(AES(key, padding: null));

    final encrypted = Encrypted(encryptedBytes as Uint8List);

    final decrypted = decrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }

  Uint8List hexToBytes(String hexString) {
    final regex = RegExp(r"([0-9a-fA-F]{2})");
    final matches = regex.allMatches(hexString);

    final bytes =
        matches.map((match) => int.parse(match.group(0)!, radix: 16)).toList();

    return Uint8List.fromList(bytes);
  }
}
