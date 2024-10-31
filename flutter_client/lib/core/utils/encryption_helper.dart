import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:math';

class EncryptionHelper {
  static final EncryptionHelper _instance = EncryptionHelper._internal();

  factory EncryptionHelper() {
    return _instance;
  }

  late final encrypt.Key _encryptionKey;

  EncryptionHelper._internal() {
    // Generate a 256-bit key from the original string
    final keyString = 'PoseidonMakesOrderingsystem919042';
    final keyBytes = utf8.encode(keyString);
    final sha256Key = sha256.convert(keyBytes);
    final key32Bytes =
        sha256Key.bytes.sublist(0, 32); // Take the first 32 bytes (256 bits)

    _encryptionKey = encrypt.Key(Uint8List.fromList(key32Bytes));
  }

  String encryptData(String data) {
    try {
      final iv = encrypt.IV.fromLength(16); // Use a random IV for CBC mode
      final encrypter = encrypt.Encrypter(
          encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(data, iv: iv);

      // Combine IV and encrypted data
      final combined = iv.bytes + encrypted.bytes;
      final base64Encoded = base64Encode(combined);

      print('Original data: $data');
      print('Encrypted data with IV: $base64Encoded');
      return base64Encoded;
    } catch (e) {
      print('Encryption error: $e');
      return '';
    }
  }

  String decryptData(String encryptedData) {
    try {
      final decodedData = base64Decode(encryptedData);
      final ivBytes =
          decodedData.sublist(0, 16); // Extract IV from the beginning
      final encryptedBytes =
          decodedData.sublist(16); // Rest is the encrypted data

      final iv = encrypt.IV(ivBytes);
      final encrypter = encrypt.Encrypter(
          encrypt.AES(_encryptionKey, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted(encryptedBytes);

      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      print('Decrypted data: $decrypted');
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return '';
    }
  }
}
