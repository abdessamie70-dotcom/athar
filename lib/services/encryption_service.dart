import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionException implements Exception {
  final String message;
  const EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}

class EncryptionService {
  /// Derives a 256-bit (32 byte) key from the user passphrase using SHA-256.
  static enc.Key _deriveKey(String passphrase) {
    if (passphrase.trim().isEmpty) {
      throw const EncryptionException('Passphrase cannot be empty');
    }
    final bytes = utf8.encode(passphrase.trim());
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Encrypts [plainText] using AES-256-CBC with a randomly generated 16-byte IV.
  /// Formats the result as `ivBase64:cipherBase64`.
  static String encryptText(String plainText, String passphrase) {
    try {
      final key = _deriveKey(passphrase);
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw EncryptionException('Failed to encrypt: ${e.toString()}');
    }
  }

  /// Decrypts [payload] (`ivBase64:cipherBase64`) using AES-256-CBC and [passphrase].
  static String decryptText(String payload, String passphrase) {
    try {
      final parts = payload.split(':');
      if (parts.length != 2) {
        throw const EncryptionException('Invalid encrypted payload format');
      }

      final key = _deriveKey(passphrase);
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw const EncryptionException('Decryption failed. Please check your passphrase.');
    }
  }

  /// Safely attempts to decrypt; returns null if passphrase is incorrect.
  static String? tryDecrypt(String payload, String passphrase) {
    try {
      return decryptText(payload, passphrase);
    } catch (_) {
      return null;
    }
  }
}
