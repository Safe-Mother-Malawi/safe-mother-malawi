# Appointment Management - Confirm, Reschedule, etc. Logic Fix

## Problem
Appointment management features (confirm, reschedule, etc.) are not appearing or working in the mobile app, even though the logic is implemented in the code.

## Root Cause Analysis

### What's Implemented:
✅ **Frontend**: Appointment screens have full UI for confirm/reschedule/delete
✅ **Backend**: Appointment status update endpoint exists (`PATCH /appointments/:id/status`)
✅ **API Service**: Methods exist for updating appointment status
✅ **Status Handling**: Multiple appointment statuses are supported

### What's Missing/Broken:
❌ **Appointments not loading** - May not be fetching from correct endpoint
❌ **Status buttons not showing** - Conditional rendering may not be working
❌ **Token not loaded** - API calls may fail due to missing token
❌ **Patient ID mismatch** - May be fetching wrong patient's appointments

## Solution

### 1. Ensure Token is Loaded Before Fetching Appointments

**File**: `lib/mobile/prenatal/screens/appointments_screen.dart`

Add token loading before fetching appointments:

```dart
Future<void> _load() async {
  setState(() { _loading = true; _error = null; });
  try {
    // IMPORTANT: Load token from storage first
    await ApiService.instance.loadToken();
    
    // Get the current logged-in patient's ID
    String? patientId;
    try {
      final patientData = await ApiService.instance.get('/patients/me/prenatal');
      if (patientData is Map) {
        patientId = patientData['id']?.toString();
      }
    } catch (_) {}

    if (patientId == null || patientId.isEmpty) {
      final currentUser = await AuthService().getCurrentUser();
      patientId = currentUser?.id;
    }

    final data = await ApiService.getAppointments(patientId: patientId).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Request timeout. Please check your connection.'),
    );
    
    // ... rest of the method
  }
}
```

### 2. Verify Appointment Status Conditions

The appointment card shows different buttons based on status:

```dart
// Status: pending_confirmation → Shows Confirm/Busy/Emergency buttons
if (statusLower == 'pending_confirmation') {
  // Show action buttons
}

// Status: reschedule_requested → Shows Accept/Reject buttons
else if (statusLower == 'reschedule_requested') {
  // Show reschedule options
}

// Other statuses → Show View/Edit/Delete buttons
else {
  // Show standard buttons
}
```

### 3. Supported Appointment Statuses

| Status | Display | Actions |
|--------|---------|---------|
| `pending_confirmation` | "Pending Confirm" | Confirm, Busy/Later, Emergency |
| `confirmed` | "Confirmed" | View, Edit, Delete |
| `reschedule_requested` | "Reschedule Proposed" | Accept Slot, Reject/Busy |
| `patient_unavailable` | "Unavailable" | View, Edit, Delete |
| `completed` | "Completed" | View |
| `missed` | "Missed" | View |
| `urgent_attention_required` | "URGENT ATTN" | View |
| `follow_up_required` | "Follow Up Req" | View |
| `no_response` | "No Response" | View |

### 4. API Endpoints Used

**Get Appointments**:
```
GET /appointments?patientId={patientId}
```

**Update Appointment Status**:
```
PATCH /appointments/{id}/status
Body: {
  "status": "confirmed|patient_unavailable|urgent_attention_required",
  "preferredTimeSelection": "later_today|tomorrow|this_week|custom",
  "customDateTime": "2024-12-25T14:30:00Z"
}
```

**Update Appointment**:
```
PUT /appointments/{id}
Body: { title, date, time, location, doctor, notes, ... }
```

**Delete Appointment**:
```
DELETE /appointments/{id}
```

## Implementation Checklist

- [ ] **Token Loading**: Ensure `loadToken()` is called before API requests
- [ ] **Patient ID**: Verify correct patient ID is being used
- [ ] **Status Filtering**: Check that appointments have correct status values
- [ ] **UI Rendering**: Verify status-based button rendering logic
- [ ] **Error Handling**: Check for API errors in debug logs
- [ ] **Network**: Verify backend is accessible and responding

## Testing Steps

### Test 1: Load Appointments
1. Log in to mobile app
2. Navigate to Appointments/Schedule screen
3. Verify appointments load without errors
4. Check debug logs for "✅ Success" messages

### Test 2: Confirm Appointment
1. Find appointment with status "pending_confirmation"
2. Tap "Confirm" button
3. Verify status changes to "confirmed"
4. Verify appointment reloads with new status

### Test 3: Reschedule Appointment
1. Find appointment with status "pending_confirmation"
2. Tap "Busy / Later" button
3. Select reschedule option (Later today, Tomorrow, etc.)
4. Verify appointment status changes to "patient_unavailable"

### Test 4: Accept Rescheduled Appointment
1. Find appointment with status "reschedule_requested"
2. Tap "Accept Slot" button
3. Verify status changes to "confirmed"

### Test 5: Edit Appointment
1. Find any appointment
2. Tap "Edit" button
3. Modify details (title, time, location, etc.)
4. Tap "Save"
5. Verify appointment updates

### Test 6: Delete Appointment
1. Find any appointment
2. Tap "Delete" button
3. Confirm deletion
4. Verify appointment is removed from list

## Debug Logs to Monitor

```
✅ Success - Appointments loaded
❌ Failed to load appointments: [error]
🔐 Received 401 - attempting token refresh...
📤 POST /appointments/{id}/status
📥 Response Status: 200
```

## Common Issues & Solutions

### Issue: "No appointments showing"
**Solution**: 
- Check if token is loaded: `await ApiService.instance.loadToken()`
- Verify patient ID is correct
- Check backend is running
- Check network connectivity

### Issue: "Buttons not appearing"
**Solution**:
- Verify appointment status is one of the supported values
- Check status comparison is case-insensitive: `statusLower == 'pending_confirmation'`
- Verify appointment data is being parsed correctly

### Issue: "Status update fails with 401"
**Solution**:
- Token may have expired
- Automatic token refresh should handle this
- Check if refresh token is valid

### Issue: "Status update fails with 400"
**Solution**:
- Invalid status value being sent
- Check supported statuses in backend
- Verify preferredTimeSelection is valid

## Files Involved

### Frontend
- `lib/mobile/prenatal/screens/appointments_screen.dart` - Prenatal appointments
- `lib/mobile/neonatal/screens/schedule_screen.dart` - Neonatal appointments
- `lib/services/api_service.dart` - API methods
- `lib/services/reminder_service.dart` - Appointment reminders

### Backend
- `src/appointments/appointments.controller.ts` - Endpoints
- `src/appointments/appointments.service.ts` - Business logic
- `src/appointments/entities/appointment.entity.ts` - Status enum

## Next Steps

1. **Verify token loading** - Add `loadToken()` calls before API requests
2. **Test appointment loading** - Ensure appointments fetch correctly
3. **Test status updates** - Verify confirm/reschedule buttons work
4. **Monitor logs** - Check for any errors during testing
5. **Deploy** - Push changes to production

## Related Documentation

- `SESSION_EXPIRATION_FIX.md` - Token refresh mechanism
- `PROFILE_PHOTO_UPLOAD_FIX.md` - Token loading pattern
- Backend: `src/appointments/appointments.service.ts` - Status update logic
