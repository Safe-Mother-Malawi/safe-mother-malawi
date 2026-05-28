# Session Expiration - Automatic Token Refresh Fix

## Problem
Users were experiencing "SESSION EXPIRED. PLEASE LOGIN AGAIN" messages even though they had valid refresh tokens available. The app was not automatically refreshing expired access tokens, forcing users to log in again after 15 minutes of inactivity.

## Root Cause
The backend implements a token refresh mechanism:
- **Access Token**: Expires in 15 minutes
- **Refresh Token**: Expires in 7 days
- **Refresh Endpoint**: `POST /auth/refresh` accepts refresh token and returns new access token

However, the frontend was:
1. Saving both tokens to SharedPreferences
2. NOT using the refresh token when access token expired
3. Immediately showing "Session Expired" error on 401 responses
4. Forcing users to log in again

## Solution
Implemented automatic token refresh mechanism with two new components:

### 1. TokenRefreshService (`lib/services/token_refresh_service.dart`)
Handles token refresh logic:
- **`refreshAccessToken()`** - Calls backend `/auth/refresh` endpoint with refresh token
- **`isTokenExpired(token)`** - Checks if JWT token is expired (with 30-second buffer)
- **`getTokenTimeRemaining(token)`** - Returns duration until token expires
- Prevents multiple simultaneous refresh attempts with queuing
- Automatically clears tokens if refresh token is invalid

### 2. Updated ApiService (`lib/services/api_service.dart`)
Integrated automatic token refresh:
- All HTTP methods (GET, POST, PATCH, PUT, DELETE) now support retry
- When 401 error received:
  1. Calls `TokenRefreshService.refreshAccessToken()`
  2. If successful, updates in-memory token
  3. Automatically retries the original request
  4. If refresh fails, throws "Session expired" error
- Prevents infinite retry loops with `_isRetryingAfterRefresh` flag

## How It Works

### Before (Old Flow):
```
User makes API call
    ↓
Access token expired (401)
    ↓
Show "Session Expired" error
    ↓
Force user to log in again
```

### After (New Flow):
```
User makes API call
    ↓
Access token expired (401)
    ↓
Automatically refresh token using refresh token
    ↓
Token refreshed successfully
    ↓
Retry original request with new token
    ↓
Request succeeds (user doesn't notice)
```

## Token Expiration Timeline

| Token Type | Expiration | Action |
|-----------|-----------|--------|
| Access Token | 15 minutes | Automatically refreshed when expired |
| Refresh Token | 7 days | User must log in again if expired |

## Implementation Details

### TokenRefreshService
```dart
// Refresh access token
final newToken = await TokenRefreshService.instance.refreshAccessToken();

// Check if token is expired
final isExpired = TokenRefreshService.isTokenExpired(token);

// Get time remaining
final remaining = TokenRefreshService.getTokenTimeRemaining(token);
```

### ApiService Integration
```dart
// All HTTP methods now support automatic retry
// Example: GET request
final res = await http.get(...);
return _handle(res, () => _performGet(path)); // Pass retry function

// If 401 received, automatically:
// 1. Refresh token
// 2. Retry request
// 3. Return result to caller
```

## Benefits

✅ **Seamless Experience** - Users don't see "Session Expired" unless refresh token is actually expired
✅ **Long Sessions** - Users can stay logged in for up to 7 days
✅ **Automatic Refresh** - No manual intervention needed
✅ **Secure** - Refresh tokens are stored securely in SharedPreferences
✅ **Prevents Loops** - Built-in protection against infinite retry loops

## Testing

### Test 1: Normal Token Refresh
1. Log in to the app
2. Wait 15+ minutes
3. Make any API call (e.g., load data)
4. Verify request succeeds without showing "Session Expired"

### Test 2: Refresh Token Expiration
1. Log in to the app
2. Wait 7+ days (or manually clear refresh token)
3. Make any API call
4. Verify "Session Expired" error is shown
5. User must log in again

### Test 3: Multiple Simultaneous Requests
1. Log in to the app
2. Wait 15+ minutes
3. Make multiple API calls simultaneously
4. Verify only one token refresh occurs (not multiple)
5. All requests succeed

## Files Modified

1. **Created**: `lib/services/token_refresh_service.dart`
   - New service for token refresh logic
   - JWT token expiration checking
   - Prevents multiple simultaneous refreshes

2. **Updated**: `lib/services/api_service.dart`
   - Added import for TokenRefreshService
   - Added `_isRetryingAfterRefresh` flag
   - Updated all HTTP methods to pass retry function
   - Updated `_handle()` to accept retry function
   - Added `_handleUnauthorized()` for automatic token refresh

## Backend Endpoints

### Token Refresh Endpoint
- **Method**: POST
- **URL**: `/auth/refresh`
- **Body**: `{ "refreshToken": "..." }`
- **Response**: `{ "accessToken": "...", "refreshToken": "..." }`
- **Status**: 200 on success, 401 if refresh token invalid/expired

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Access token expired, refresh token valid | Automatically refresh and retry |
| Access token expired, refresh token expired | Show "Session Expired" error |
| Network error during refresh | Show "Session Expired" error |
| Refresh endpoint returns 401 | Clear tokens and show "Session Expired" error |

## Commits

- **Token Refresh Service**: `lib/services/token_refresh_service.dart`
- **API Service Integration**: `lib/services/api_service.dart`
- **Branch**: `bsc-inf-17-22` (Clinician - Racheal Chavula)

## Related Documentation

- `PROFILE_PHOTO_UPLOAD_FIX.md` - Token loading fix for profile photo upload
- `SESSION_HANDLER.dart` - Session expiration dialog and logout handling
- Backend: `src/auth/auth.service.ts` - Token generation and refresh logic
