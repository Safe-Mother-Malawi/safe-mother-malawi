# Analytics Dashboard - Troubleshooting Guide

## Issue: "Failed to load analytics" Error

The Analytics Dashboard shows an error message with a "Retry" button. This guide helps diagnose and fix the issue.

## Common Causes & Solutions

### 1. Backend Server Not Running

**Symptoms:**
- "Backend server is not responding"
- Connection refused error
- Failed host lookup

**Solution:**
```bash
# Start the backend server
cd backend/backend
npm install
npm run start

# Or for development with auto-reload
npm run dev
```

**Verify backend is running:**
```bash
# Test the backend health endpoint
curl https://backend-gsgb.onrender.com/api/v1/health

# Or for local development
curl http://localhost:3001/api/v1/health
```

### 2. Incorrect Backend URL

**Symptoms:**
- 404 errors
- Connection timeouts
- "Failed to load analytics"

**Solution:**
Check `lib/config/api_config.dart`:

```dart
// For production (Render)
static const String prodBaseUrl = 'https://backend-gsgb.onrender.com/api/v1';

// For development (local)
static const String devBaseUrl = 'http://localhost:3001/api/v1';

// Switch environment
static const bool isProduction = true; // Change to false for local development
```

### 3. Authentication Issues

**Symptoms:**
- "Unauthorized" error (401)
- "You do not have permission" error (403)

**Solution:**
1. Log out and log back in
2. Ensure your user account has the correct role (Admin, DHO, or Clinician)
3. Check that the JWT token is valid and not expired

```dart
// Clear stored token and re-authenticate
final prefs = await SharedPreferences.getInstance();
await prefs.remove('access_token');
await prefs.remove('refresh_token');
```

### 4. CORS Issues

**Symptoms:**
- Browser console shows CORS errors
- "Failed to load analytics" with no specific error message

**Solution:**
The backend CORS configuration is already set up in `backend/backend/src/config/cors.config.ts`. Ensure:

1. Backend is running with CORS enabled
2. Frontend URL is in the allowed origins list
3. Browser is not blocking cross-origin requests

**Check CORS headers:**
```bash
curl -i -X OPTIONS https://backend-gsgb.onrender.com/api/v1/analytics/overview \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET"
```

### 5. Network Timeout

**Symptoms:**
- "Request timeout" error
- Takes too long to load

**Solution:**
1. Check your internet connection
2. Verify backend server is responsive
3. Increase timeout in `lib/config/api_config.dart`:

```dart
// Increase timeout from 30 to 60 seconds
static const int requestTimeoutSeconds = 60;
```

### 6. Database Connection Issues

**Symptoms:**
- Backend returns 500 errors
- Analytics endpoints return empty data

**Solution:**
Check backend database connection:

```bash
# Check backend logs
cd backend/backend
npm run dev

# Look for database connection errors
# Verify database credentials in .env file
```

## Debugging Steps

### Step 1: Check Browser Console
Open browser DevTools (F12) and check the Console tab for detailed error messages.

### Step 2: Check Network Tab
1. Open DevTools → Network tab
2. Click "Retry" on the analytics dashboard
3. Look for failed requests
4. Click on failed request to see response details

### Step 3: Test Backend Directly
```bash
# Test analytics overview endpoint
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://backend-gsgb.onrender.com/api/v1/analytics/overview

# Test with local backend
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3001/api/v1/analytics/overview
```

### Step 4: Check API Configuration
Verify the correct backend URL is being used:

```dart
// In your app, print the current base URL
print('Using backend: ${ApiConfig.baseUrl}');
print('Is production: ${ApiConfig.isProduction}');
```

## Analytics Endpoints

All endpoints require authentication (JWT token) and appropriate user role.

| Endpoint | Method | Description | Roles |
|----------|--------|-------------|-------|
| `/analytics/overview` | GET | Dashboard overview metrics | Admin, DHO, Clinician |
| `/analytics/risk-distribution` | GET | Risk level distribution | Admin, DHO, Clinician |
| `/analytics/districts` | GET | District statistics | Admin, DHO, Clinician |
| `/analytics/task-analytics` | GET | Task completion metrics | Admin, DHO, Clinician |
| `/analytics/neonatal-analytics` | GET | Neonatal health metrics | Admin, DHO, Clinician |
| `/analytics/geographic-insights` | GET | Geographic data insights | Admin, DHO, Clinician |
| `/analytics/anc-analytics` | GET | ANC-specific analytics | Admin, DHO, Clinician |
| `/analytics/clinician-activity` | GET | Clinician activity metrics | Admin, DHO, Clinician |

## Performance Optimization

If analytics are loading slowly:

1. **Reduce data range** - Load only recent data
2. **Implement caching** - Cache analytics data locally
3. **Use pagination** - Load data in chunks
4. **Optimize backend queries** - Add database indexes

## Error Messages Reference

| Error | Cause | Solution |
|-------|-------|----------|
| "Backend server is not responding" | Backend not running | Start backend server |
| "Request timeout" | Network slow or backend unresponsive | Check connection, increase timeout |
| "Unauthorized" | Invalid or expired token | Log in again |
| "You do not have permission" | Insufficient user role | Contact admin |
| "Invalid data format" | Backend returned unexpected data | Check backend logs |

## Testing Analytics Locally

```bash
# 1. Start backend
cd backend/backend
npm run dev

# 2. In another terminal, start frontend
cd safe-mother-malawi
flutter run -d chrome

# 3. Log in with test credentials
# 4. Navigate to Analytics Dashboard
# 5. Check browser console for errors
```

## Production Deployment

For production deployment:

1. **Update backend URL** in `lib/config/api_config.dart`:
   ```dart
   static const bool isProduction = true;
   static const String prodBaseUrl = 'https://your-production-backend.com/api/v1';
   ```

2. **Ensure CORS is configured** for production domain

3. **Test all analytics endpoints** before deploying

4. **Monitor backend logs** for errors

## Getting Help

If you're still experiencing issues:

1. Check the backend logs: `npm run dev` in `backend/backend`
2. Check browser console for detailed error messages
3. Verify network connectivity
4. Ensure authentication token is valid
5. Check that user has appropriate role permissions

## Related Documentation

- [CORS Resolution Summary](./CORS_RESOLUTION_SUMMARY.md)
- [API Configuration](./lib/config/api_config.dart)
- [Backend Analytics Service](./backend/backend/src/analytics/analytics.service.ts)

---

**Last Updated**: May 28, 2026
**Status**: ✅ Complete
