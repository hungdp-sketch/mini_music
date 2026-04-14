import 'package:flutter/material.dart';
import 'aes_crypto/cryptojs_aes_encryption_helper.dart';
import '../core/constants.dart';

class Utils {
  static dynamic decryptAESCrypto(String data) {
    try {
      final decrypted = decryptAESCryptoJS(
        data,
        AppConstants.secretKey,
      );
      return decrypted;
    } catch (e) {
      debugPrint('Decryption Error: $e');
      return null;
    }
  }

  static String escape(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}
