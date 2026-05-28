# Profile Photo Upload - 401 Error Fix

## Problem
Profile photo upload was failing with a **401 Unauthorized** error, preventing users from uploading or updating their profile photos.

## Root Cause
The `uploadProfilePhoto()` method in `lib/services/api_service.dart` was calling `getToken()` without first loading the token from persistent storage (`SharedPreferences`).

### What Was Happening:
1. User clicks "Upload Photo"
2. `uploadProfilePhoto()` is called
3. `getToken()` is called, which checks the in-memory `_token` variable
4. Since `_token` was never loaded from storage, it returns `null`
5. Method throws `ApiException(401, 'Not authenticated')`
6. Upload fails with 401 error

### Why This Happened:
- The `_token` variable is only populated when `loadToken()` is explicitly called
- Other API methods (like `login()`, `register()`, etc.) call `loadToken()` before making requests
- The `uploadProfilePhoto()` method was missing this crucial step

## Solution
Added `await instance.loadToken();` before calling `getToken()` in the `uploadProfilePhoto()` method.

### Code Change:
```dart
static Future<String?> uploadProfilePhoto(String? photoDataUrl) async {
  // Ensure token is loaded from storage before making the request
  await instance.loadToken();
  
  final token = await instance.getToken();
  if (token == null) throw ApiException(401, 'Not authenticated');
  
  // ... rest of the method
}
```

## Files Modified
- `lib/services/api_service.dart` - Added `loadToken()` call in `uploadProfilePhoto()` method

## Testing
To verify the fix works:

1. **Login to the app** - Ensures token is saved to SharedPreferences
2. **Navigate to profile/edit profile screen**
3. **Select a photo from gallery or camera**
4. **Upload the photo** - Should now succeed with 200 response
5. **Verify photo displays** - Profile photo should update immediately

## How It Works Now
1. User clicks "Upload Photo"
2. `uploadProfilePhoto()` is called
3. `loadToken()` loads the token from SharedPreferences into `_token`
4. `getToken()` returns the loaded token
5. Authorization header is set: `Authorization: Bearer <token>`
6. PATCH request to `/users/me/photo` succeeds
7. Profile photo updates successfully

## Related Methods
This fix follows the same pattern used in other API methods:
- `getCurrentUser()` - calls `loadToken()` before API call
- `_load()` in home screens - calls `loadToken()` before API calls
- `_loadHistory()` in assessment screens - calls `loadToken()` before API calls

## Backend Endpoint
- **Method**: PATCH
- **URL**: `/users/me/photo`
- **Body**: `{ "photoBase64": "data:image/jpeg;base64,..." }`
- **Response**: `{ "profilePhotoUrl": "..." }`
- **Auth**: Requires valid Bearer token

## Commit
- **Hash**: a3197f2
- **Message**: "fix: Load token before profile photo upload to resolve 401 error"
- **Branch**: bsc-inf-17-22 (Clinician - Racheal Chavula)
