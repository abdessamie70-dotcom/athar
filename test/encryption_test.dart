import 'package:flutter_test/flutter_test.dart';
import 'package:athar/services/encryption_service.dart';

void main() {
  group('EncryptionService Tests (AES-256)', () {
    const plainText = 'وصية للأجيال القادمة: الزموا الصدق والعلم النافع.';
    const correctPassphrase = 'MySecurePassphrase#2026';
    const wrongPassphrase = 'IncorrectPassword123';

    test('should encrypt and successfully decrypt with correct passphrase', () {
      final cipherPayload = EncryptionService.encryptText(plainText, correctPassphrase);

      expect(cipherPayload, isNotEmpty);
      expect(cipherPayload.contains(':'), isTrue); // iv:ciphertext

      final decrypted = EncryptionService.decryptText(cipherPayload, correctPassphrase);
      expect(decrypted, equals(plainText));
    });

    test('should fail decryption when given wrong passphrase', () {
      final cipherPayload = EncryptionService.encryptText(plainText, correctPassphrase);

      expect(
        () => EncryptionService.decryptText(cipherPayload, wrongPassphrase),
        throwsA(isA<EncryptionException>()),
      );

      final safeResult = EncryptionService.tryDecrypt(cipherPayload, wrongPassphrase);
      expect(safeResult, isNull);
    });

    test('should produce different ciphertexts for the same plainText due to randomized IV', () {
      final cipher1 = EncryptionService.encryptText(plainText, correctPassphrase);
      final cipher2 = EncryptionService.encryptText(plainText, correctPassphrase);

      expect(cipher1, isNot(equals(cipher2)));

      // But both should decrypt to the same plainText
      expect(EncryptionService.decryptText(cipher1, correctPassphrase), equals(plainText));
      expect(EncryptionService.decryptText(cipher2, correctPassphrase), equals(plainText));
    });
  });
}
