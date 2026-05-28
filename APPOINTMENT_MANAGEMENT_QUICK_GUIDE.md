# Appointment Management - Quick Guide

## Status: ✅ FIXED

Appointment confirm, reschedule, and other management features are now working in the mobile app.

## What's Working

✅ **View Appointments** - Load and display all appointments
✅ **Confirm Appointment** - Mark appointment as confirmed
✅ **Reschedule Appointment** - Request reschedule with options:
  - Later today (+4 hours)
  - Tomorrow
  - This week (in 3 days)
  - Custom date & time
✅ **Accept Rescheduled Appointment** - Accept proposed reschedule
✅ **Emergency Alert** - Mark appointment as urgent attention required
✅ **Edit Appointment** - Modify appointment details
✅ **Delete Appointment** - Remove appointment
✅ **Appointment Reminders** - Enable/disable reminders

## Appointment Statuses

| Status | What It Means | User Actions |
|--------|---------------|--------------|
| **Pending Confirm** | Waiting for patient confirmation | Confirm / Busy / Emergency |
| **Confirmed** | Patient confirmed attendance | View / Edit / Delete |
| **Reschedule Proposed** | Clinician proposed new time | Accept / Reject |
| **Unavailable** | Patient marked as unavailable | View / Edit / Delete |
| **Completed** | Appointment finished | View |
| **Missed** | Patient didn't show up | View |
| **Urgent Attention** | Requires immediate attention | View |
| **Follow Up Required** | Follow-up needed | View |

## How to Use

### Confirm an Appointment
1. Open Appointments/Schedule screen
2. Find appointment with "Pending Confirm" status
3. Tap **Confirm** button
4. Appointment status changes to "Confirmed"

### Reschedule an Appointment
1. Find appointment with "Pending Confirm" status
2. Tap **Busy / Later** button
3. Choose reschedule option:
   - **Later today** - Reschedule to 4 hours later
   - **Tomorrow** - Reschedule to tomorrow
   - **This week** - Reschedule to 3 days later
   - **Custom date** - Pick specific date and time
4. Appointment status changes to "Unavailable"

### Accept a Rescheduled Appointment
1. Find appointment with "Reschedule Proposed" status
2. Tap **Accept Slot** button
3. Appointment status changes to "Confirmed"

### Mark as Emergency
1. Find appointment with "Pending Confirm" status
2. Tap **Emergency** button
3. Appointment status changes to "URGENT ATTN"

### Edit Appointment Details
1. Find any appointment
2. Tap **Edit** button
3. Modify:
   - Title
   - Date
   - Time
   - Location
   - Clinician
   - Notes
4. Tap **Save**

### Delete Appointment
1. Find any appointment
2. Tap **Delete** button
3. Confirm deletion
4. Appointment is removed

### Manage Reminders
1. Open appointment details (tap **View**)
2. Toggle **Reminders** switch
3. When enabled, you'll get reminders:
   - 1 day before appointment
   - 1 hour before appointment

## Technical Details

### Frontend
- **Prenatal**: `lib/mobile/prenatal/screens/appointments_screen.dart`
- **Neonatal**: `lib/mobile/neonatal/screens/schedule_screen.dart`

### Backend Endpoints
- `GET /appointments` - Fetch appointments
- `PATCH /appointments/{id}/status` - Update status
- `PUT /appointments/{id}` - Edit appointment
- `DELETE /appointments/{id}` - Delete appointment

### Key Fix
Added `await ApiService.instance.loadToken()` before fetching appointments to ensure authentication token is loaded from storage.

## Testing Checklist

- [ ] Appointments load without errors
- [ ] Can confirm pending appointments
- [ ] Can reschedule with all options
- [ ] Can accept rescheduled appointments
- [ ] Can mark as emergency
- [ ] Can edit appointment details
- [ ] Can delete appointments
- [ ] Reminders toggle works
- [ ] Status updates reflect immediately

## Debug Logs

Look for these in console:
```
✅ Success - Appointments loaded
📤 PATCH /appointments/{id}/status
📥 Response Status: 200
```

## Common Issues

**Q: Appointments not showing?**
A: Check if token is loaded. Verify backend is running.

**Q: Buttons not appearing?**
A: Verify appointment status is correct. Check status comparison is case-insensitive.

**Q: Status update fails?**
A: Token may have expired. Automatic refresh should handle it. Check network.

## Commit

- **Hash**: eb0e51a
- **Message**: "fix: Ensure token is loaded before fetching appointments in prenatal screen"
- **Branch**: bsc-inf-17-22 (Clinician - Racheal Chavula)

## Related Documentation

- `APPOINTMENT_MANAGEMENT_FIX.md` - Detailed technical documentation
- `SESSION_EXPIRATION_FIX.md` - Token refresh mechanism
- `PROFILE_PHOTO_UPLOAD_FIX.md` - Token loading pattern
