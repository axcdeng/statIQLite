import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roboscout_iq/src/constants.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: AppConstants.robotEventsApiKeyKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: AppConstants.robotEventsApiKeyKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: AppConstants.robotEventsApiKeyKey);
  }

  Future<void> saveRoboStemApiKey(String apiKey) async {
    // We need a constant for this key, I'll add it inline or to constants.dart
    // For now I'll use a string literal here and define it properly later if needed to be reused
    await _storage.write(key: 'robo_stem_api_key', value: apiKey);
  }

  Future<String?> getRoboStemApiKey() async {
    return await _storage.read(key: 'robo_stem_api_key');
  }

  Future<void> deleteRoboStemApiKey() async {
    await _storage.delete(key: 'robo_stem_api_key');
  }
}
