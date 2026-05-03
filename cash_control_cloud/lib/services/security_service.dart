import 'package:encrypt/encrypt.dart' as encrypt;

class SecurityService {
  // Dans une version de production, cette clé serait dérivée du PIN SHA-256
  static final _key = encrypt.Key.fromUtf8('my_super_secret_key_32_chars_long');
  static final _iv = encrypt.IV.fromLength(16);

  static String encryptData(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptData(String encryptedBase64) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: _iv);
    return decrypted;
  }
}