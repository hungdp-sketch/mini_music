import 'dart:convert';
import '../models/song_model.dart';
import '../core/constants.dart';
import '../helper/utils.dart';
import 'api_network.dart';

class MusicApi {
  static Future<List<SongModel>> getTrending({
    String countryCode = 'VN',
  }) async {
    final url = '${AppConstants.trending}country_code=$countryCode';
    final response = await ApiNetwork.instance.get(url);

    if (response != null && response is Map && response.containsKey('data')) {
      final decryptedData = Utils.decryptAESCrypto(response['data'] as String);
      if (decryptedData != null) {
        final decoded = jsonDecode(decryptedData as String);
        if (decoded is List) {
          return decoded
              .map(
                (item) => SongModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }
    }
    return [];
  }

  static Future<List<SongModel>> getPopular({String countryCode = 'VN'}) async {
    final url = '${AppConstants.popular}country_code=$countryCode';
    final response = await ApiNetwork.instance.get(url);

    if (response != null && response is Map && response.containsKey('data')) {
      final decryptedData = Utils.decryptAESCrypto(response['data'] as String);
      if (decryptedData != null) {
        final decoded = jsonDecode(decryptedData as String);
        if (decoded is List) {
          return decoded
              .map(
                (item) => SongModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }
    }
    return [];
  }
}
