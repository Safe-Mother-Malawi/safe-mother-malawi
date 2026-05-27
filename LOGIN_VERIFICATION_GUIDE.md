# Login Verification Guide

## ✅ Backend Status

- **Health Check:** ✅ Working
- **CORS:** ✅ Enabled (all origins allowed)
- **Login Endpoint:** ✅ `/api/v1/auth/login`
- **Default Users:** ✅ Auto-seeded

## 🔐 Default Credentials

### Admin Account
```
Email: admin@safemothermalawi.mw
Password: Admin@123
Role: Admin
```

### DHO Account
```
Email: dho@safemothermalawi.mw
Password: Dho@123
Role: DHO (District Health Officer)
District: Lilongwe
```

## 🌐 Vercel Projects

### Project 1: Web Portal (Admin/DHO)
- **URL:** https://safe-mothermalawi.vercel.app/
- **Backend:** https://backend-gsgb.onrender.com/api/v1
- **Supported Roles:** Admin, DHO, Clinician

### Project 2: Web Portal (Alternative)
- **URL:** https://safemothermalawi.vercel.app/
- **Backend:** https://backend-gsgb.onrender.com/api/v1
- **Supported Roles:** Admin, DHO, Clinician

## 🧪 Testing Steps

### Step 1: Verify Backend is Running
```bash
curl https://backend-gsgb.onrender.com/api/v1/health
```
Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-05-27T23:29:20.124Z",
  "service": "SafeMother Malawi API",
  "version": "1.0.0"
}
```

### Step 2: Test Login Endpoint
```bash
curl -X POST https://backend-gsgb.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "admin@safemothermalawi.mw",
    "password": "Admin@123"
  }'
```

### Step 3: Login via Web Portal
1. Go to https://safe-mothermalawi.vercel.app/
2. Enter email: `admin@safemothermalawi.mw`
3. Enter password: `Admin@123`
4. Click Login

## 🔍 Troubleshooting

### Issue: "Could not connect to server"
**Cause:** Backend URL mismatch or network issue
**Solution:**
1. Check `lib/config/api_config.dart`
2. Verify `prodBaseUrl` is `https://backend-gsgb.onrender.com/api/v1`
3. Test health endpoint manually

### Issue: "Invalid email or password"
**Cause:** Wrong credentials or users not seeded
**Solution:**
1. Verify you're using correct credentials (see above)
2. Check backend logs for seeding confirmation
3. May need to reseed database

### Issue: CORS Error in Browser Console
**Cause:** Backend CORS not configured for Vercel domain
**Solution:**
1. Check `backend/src/main.ts`
2. Verify `app.enableCors({ origin: true })`
3. Redeploy backend if needed

### Issue: Login works but can't access dashboard
**Cause:** User role not supported on web portal
**Solution:**
- Web portal only supports: Admin, DHO, Clinician
- Prenatal/Neonatal users must use mobile app

## 📋 Checklist

- [ ] Backend health check passes
- [ ] Login endpoint responds
- [ ] Default users exist in database
- [ ] Both Vercel projects use correct backend URL
- [ ] CORS is enabled on backend
- [ ] Can login with admin credentials
- [ ] Can access admin dashboard
- [ ] Can login with DHO credentials
- [ ] Can access DHO dashboard

## 🚀 Next Steps

1. **Test login** with provided credentials
2. **Change default passwords** after first login
3. **Create additional users** as needed
4. **Configure district assignments** for DHO users
5. **Set up clinician accounts** for health facilities

## 📞 Support

If login still fails:
1. Check browser console (F12) for exact error
2. Verify backend URL in `lib/config/api_config.dart`
3. Check backend logs on Render dashboard
4. Verify database has users (check seed logs)
