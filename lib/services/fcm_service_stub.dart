// Stub for web platform - FCM not available on web
class FCMService {
  Future<void> initialize(dynamic apiService) async {
    // No-op on web
  }

  Future<String?> getToken() async {
    return null;
  }

  Future<void> deleteToken() async {
    // No-op on web
  }
}
