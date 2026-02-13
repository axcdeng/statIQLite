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
}
