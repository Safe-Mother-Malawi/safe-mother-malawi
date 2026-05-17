/// API Configuration
/// 
/// Switch between development and production environments
class ApiConfig {
  // Environment flag - change this to switch environments
  static const bool isProduction = true; // ✅ Production mode enabled

  // Development URLs (local development)
  static const String devBaseUrl = 'http://localhost:3001/api/v1';
  
  // Production URLs (Render backend)
  static const String prodBaseUrl = 'https://backend-gsgb.onrender.com/api/v1';

  // Get current base URL based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // WebSocket URLs
  static String get wsUrl => isProduction 
    ? 'wss://backend-gsgb.onrender.com'
    : 'ws://localhost:3001';
}
