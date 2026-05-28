# Session Expiration - Quick Reference

## What Was Fixed
✅ Users no longer see "SESSION EXPIRED. PLEASE LOGIN AGAIN" after 15 minutes of inactivity
✅ Access tokens are automatically refreshed using the refresh token
✅ Users can stay logged in for up to 7 days

## How It Works
1. Access token expires after 15 minutes
2. Next API call receives 401 error
3. System automatically refreshes token using refresh token
4. Original request is retried with new token
5. User sees no interruption

## Token Lifetimes
- **Access Token**: 15 minutes (automatically refreshed)
- **Refresh Token**: 7 days (requires re-login if expired)

## What Users Experience

### Scenario 1: Normal Usage (Access Token Expires)
- User is active in the app
- After 15 minutes, they make an API call
- Token is automatically refreshed in background
- Request succeeds - user sees no error

### Scenario 2: Long Inactivity (Refresh Token Expires)
- User doesn't use app for 7+ days
- They try to make an API call
- Refresh token is expired
- "Session Expired" error shown
- User must log in again

## Technical Details

### New Files
- `lib/services/token_refresh_service.dart` - Handles token refresh logic

### Modified Files
- `lib/services/api_service.dart` - Integrated automatic token refresh

### Backend Endpoint Used
- `POST /auth/refresh` - Exchanges refresh token for new access token

## Testing Checklist

- [ ] Log in to app
- [ ] Wait 15+ minutes
- [ ] Make any API call (load data, upload photo, etc.)
- [ ] Verify request succeeds without "Session Expired" error
- [ ] Check debug logs for "Token refreshed" message

## Debug Logs to Look For

```
🔐 Received 401 - attempting token refresh...
🔄 Attempting to refresh access token...
✅ Token refreshed successfully
✅ Token refreshed, retrying request...
```

## If Session Expiration Still Occurs

1. **Check refresh token exists**
   - Open SharedPreferences
   - Verify `refresh_token` key exists

2. **Check backend is running**
   - Verify backend URL is correct
   - Test `/auth/refresh` endpoint manually

3. **Check network connectivity**
   - Ensure device has internet connection
   - Check firewall/proxy settings

4. **Check token validity**
   - Verify refresh token hasn't expired (7 days)
   - Try logging in again

## Related Issues Fixed

- Profile photo upload 401 error (fixed in PROFILE_PHOTO_UPLOAD_FIX.md)
- Session handler dialog (implemented in SESSION_HANDLER.dart)

## Commit Hash
`862af90` - feat: Implement automatic token refresh to prevent session expiration

## Branch
`bsc-inf-17-22` (Clinician - Racheal Chavula)
