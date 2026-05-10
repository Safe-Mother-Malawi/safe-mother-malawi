# APK Build Trigger

This file triggers the GitHub Actions APK build workflow.

**Build Date**: May 10, 2026
**Purpose**: Generate SafeMother Malawi mobile APK
**Target**: Android devices (API 26+)

## Build Status

The GitHub Actions workflow will:
1. ✅ Setup Flutter environment
2. ✅ Get project dependencies  
3. ✅ Build release APK
4. ✅ Upload APK as artifact
5. ✅ Create GitHub release

## APK Details

- **App Name**: Safe Mother Malawi
- **Package**: com.example.safemothermalawi_frontend
- **Version**: 1.0.0+1
- **Min Android**: 8.0 (API 26)
- **Target**: Latest Android

## Features Included

- 📱 Prenatal & Neonatal dashboards
- 🏥 Health facility integration (1000+ facilities)
- 📊 Health assessments & risk scoring
- 🚨 Real-time alerts to clinicians
- 📅 Appointment scheduling
- 👩‍⚕️ Clinician web portal integration
- 🔐 Secure authentication
- 📍 Location-based services

## Backend Integration

- **Production API**: https://backend-gsgb.onrender.com
- **Web Portal**: https://safe-mother-malawi.vercel.app
- **Real-time sync**: Mobile ↔ Web

## Installation

1. Download APK from GitHub release
2. Enable "Unknown Sources" on Android
3. Install APK
4. Create account or use test credentials

## Test Accounts

- **Admin**: admin@safemothermalawi.mw / Admin@123
- **DHO**: dho@safemothermalawi.mw / Dho@123

Build triggered at: $(date)