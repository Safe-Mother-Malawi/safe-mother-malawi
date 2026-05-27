// Stub for web platform - NotificationService not available on web
class NotificationService {
  NotificationService() {
    throw UnsupportedError('NotificationService is not available on web platform');
  }
  
  Future<void> initialize(dynamic apiService) async {
    throw UnsupportedError('NotificationService is not available on web platform');
  }
}
