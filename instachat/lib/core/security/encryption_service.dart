import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class EncryptionService {
  static const String _keyString = 'd01851e405106173a11030e463584852'; // 32 chars length
  
  static final _key = Key.fromUtf8(_keyString);
  
  // Encrypts a Map (JSON) and returns a Base64 string containing IV + Ciphertext
  static String encryptData(dynamic data) {
    if (data == null) return "";
    
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    
    final jsonString = json.encode(data);
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    
    // Return format: IV:Ciphertext (Base64 encoded)
    return '${iv.base64}:${encrypted.base64}';
  }

  // Decrypts a Base64 string (IV:Ciphertext) back to dynamic (Map/List)
  static dynamic decryptData(String encryptedData) {
    if (encryptedData.isEmpty) return null;
    
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        // Fallback: maybe it's not encrypted or different format?
        // Trying to decode as JSON directly just in case relevant for transition
        try {
            return json.decode(encryptedData);
        } catch (_) {
            return null;
        }
      }
      
      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      return json.decode(decrypted);
    } catch (e) {
      print('Decryption error: $e');
      // If decryption fails, it might be plain JSON (e.g. error message)
      try {
        return json.decode(encryptedData);
      } catch (_) {
         return null;
      }
    }
  }
}
