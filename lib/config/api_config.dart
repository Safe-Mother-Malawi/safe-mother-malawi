/// API Configuration
/// 
/// Switch between development and production environments
/// 
/// COMPREHENSIVE CORS FIX:
/// - Production: Uses Render backend (https://backend-gsgb.onrender.com)
/// - Development: Uses localhost (http://localhost:3001)
/// - All URLs include /api/v1 prefix
/// - WebSocket URLs configured for real-time features
class ApiConfig {
  // Environment flag - change this to switch environments
  static const bool isProduction = true; // Production mode enabled

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

  // Alternative backend URLs (for fallback/testing)
  static const List<String> alternativeBackendUrls = [
    'https://backend-gsgb.onrender.com/api/v1',
    'http://localhost:3001/api/v1',
    'http://localhost:3000/api/v1',
  ];

  // Request timeout in seconds
  static const int requestTimeoutSeconds = 30;

  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;
}

