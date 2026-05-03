/// API Configuration
/// 
/// Switch between development and production environments
class ApiConfig {
  // Environment flag - change this to switch environments
  static const bool isProduction = false;

  // Development URLs
  static const String devBaseUrl = 'http://41.70.47.173:3001/api/v1';
  
  // Production URLs (update after deploying backend to Vercel)
  static const String prodBaseUrl = 'https://backend-5fxl.vercel.app/api/v1';

  // Get current base URL based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // WebSocket URLs
  static String get wsUrl => isProduction 
    ? 'wss://backend-5fxl.vercel.app'
    : 'ws://41.70.47.173:3001';
}
