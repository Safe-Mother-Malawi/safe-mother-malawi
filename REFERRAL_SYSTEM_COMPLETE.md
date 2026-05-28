# Complete Referral System Documentation

## Overview
The Safe Mother Malawi referral system is a comprehensive end-to-end solution for managing patient referrals between health facilities. It includes real-time updates, multi-facility coordination, transport tracking, and complete audit trails.

---

## System Architecture

### 1. Backend Components

#### API Endpoints (12 total)
```
POST   /referrals                          - Create new referral
GET    /referrals                          - Get all referrals
GET    /referrals/:id                      - Get specific referral
GET    /referrals/facility/:facilityId     - Get referrals by facility
GET    /referrals/patient/:patientId       - Get referrals by patient
GET    /referrals/code/:referralCode       - Get referral by code
GET    /referrals/stats                    - Get referral statistics
PUT    /referrals/:id/accept               - Accept referral
PUT    /referrals/:id/reject               - Reject referral
PUT    /referrals/:id/transport            - Update transport status
PUT    /referrals/:id/complete             - Complete referral
PUT    /referrals/:id/cancel               - Cancel referral
```

#### Data Model (Referral Entity)
**Patient Information:**
- `patientName` - Full name of patient
- `patientContact` - Phone number or contact info
- `patientAge` - Age of patient
- `prenatalPatientId` - Link to prenatal patient record (optional)
- `neonatalPatientId` - Link to neonatal patient record (optional)

**Referral Details:**
- `referralCode` - Unique identifier (auto-generated)
- `reason` - Reason for referral (enum: 12 options)
- `clinicalSummary` - Detailed clinical information
- `urgencyNotes` - Urgency level and notes
- `status` - Current status (7 states)

**Facility Information:**
- `referringFacilityId` - Facility sending referral
- `receivingFacilityId` - Facility receiving referral
- `referringClinicianId` - Clinician creating referral
- `receivingClinicianId` - Clinician receiving referral (assigned on accept)

**Transport Information:**
- `transportMode` - Mode of transport (5 options)
- `transportProvider` - Name of transport provider
- `transportContact` - Contact for transport
- `departureTime` - When patient departs
- `arrivalTime` - When patient arrives
- `transportNotes` - Additional transport notes

**Status Tracking:**
- `acceptedAt` - Timestamp when accepted
- `rejectionReason` - Reason if rejected
- `rejectedAt` - Timestamp when rejected
- `treatmentOutcome` - Outcome of treatment
- `completedAt` - Timestamp when completed

**Metadata:**
- `metadata` - JSONB field for custom data
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp

#### Enums

**ReferralReason (12 options):**
- Hypertension
- Bleeding
- Infection
- Fetal Distress
- Premature Labor
- Placental Issues
- Neonatal Emergency
- Neonatal Infection
- Low Birth Weight
- Respiratory Distress
- Jaundice
- Other

**ReferralStatus (7 states):**
- `pending` - Awaiting facility response
- `accepted` - Accepted by receiving facility
- `rejected` - Rejected by receiving facility
- `in_transit` - Patient in transport
- `arrived` - Patient arrived at facility
- `completed` - Treatment completed
- `cancelled` - Referral cancelled

**TransportMode (5 options):**
- Ambulance
- Personal Vehicle
- Motorcycle
- Walking
- Other

#### Business Logic (ReferralsService)

**Create Referral:**
- Validates all required fields
- Generates unique referral code
- Creates referral record
- Notifies receiving facility
- Logs activity
- Emits WebSocket event

**Accept Referral:**
- Assigns receiving clinician
- Updates status to accepted
- Records acceptance timestamp
- Notifies referring facility
- Logs activity
- Emits WebSocket event

**Reject Referral:**
- Records rejection reason
- Updates status to rejected
- Records rejection timestamp
- Notifies referring facility
- Logs activity
- Emits WebSocket event

**Update Transport Status:**
- Updates status (in_transit/arrived)
- Records timestamp
- Notifies both facilities
- Logs activity
- Emits WebSocket event

**Complete Referral:**
- Records treatment outcome
- Updates status to completed
- Records completion timestamp
- Notifies referring facility
- Logs activity
- Emits WebSocket event

**Cancel Referral:**
- Updates status to cancelled
- Notifies both facilities
- Logs activity
- Emits WebSocket event

#### Authorization
- **Clinician**: Can create referrals, accept/reject, update transport, complete
- **DHO**: Can view all referrals, manage facility referrals
- **Admin**: Full access to all referrals
- **Prenatal/Neonatal**: Can view patient referrals only

---

### 2. Frontend Components

#### Referral Service (referral_service.dart)
**Models:**
- `Referral` - Complete referral data model with JSON serialization
- `CreateReferralRequest` - DTO for creating referrals

**Methods:**
- `createReferral(request)` - Create new referral
- `getAllReferrals()` - Fetch all referrals
- `getReferralsByFacility(facilityId, type)` - Get facility referrals
- `getReferralById(id)` - Get specific referral
- `getReferralByCode(code)` - Get by referral code
- `acceptReferral(id)` - Accept referral
- `rejectReferral(id, reason)` - Reject referral
- `updateTransportStatus(id, status)` - Update transport
- `completeReferral(id, outcome)` - Complete referral
- `cancelReferral(id)` - Cancel referral

#### Referral Page (referral_page.dart)

**Features:**
1. **List View**
   - Display all referrals with status filtering
   - Color-coded status badges
   - Quick action buttons
   - Click for detailed view

2. **Create Referral**
   - Form with validation
   - Dropdown for referral reasons
   - Facility selection dropdown
   - Transport mode dropdown
   - Patient information fields
   - Clinical summary field

3. **Status Filtering**
   - All
   - Pending
   - Accepted
   - In Transit
   - Completed

4. **Referral Details Modal**
   - Complete referral information
   - Patient details
   - Facility information
   - Clinician information
   - Transport details
   - Status history
   - Timestamps

5. **Actions**
   - Accept pending referrals
   - Reject with reason
   - Update transport status
   - View complete details

6. **Real-time Updates**
   - WebSocket listener for referral events
   - Auto-refresh on status changes
   - Toast notifications for updates
   - Live status indicators

#### WebSocket Integration
**Events Listened:**
- `referral:created` - New referral created
- `referral:updated` - Referral updated
- `referral:accepted` - Referral accepted
- `referral:rejected` - Referral rejected
- `referral:completed` - Referral completed

**Behavior:**
- Auto-refresh referral list on event
- Show toast notification
- Update UI in real-time
- No manual refresh needed

---

### 3. Database Schema

**Table: referrals**

| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| id | UUID | PRIMARY KEY | Unique identifier |
| referralCode | VARCHAR | UNIQUE | Human-readable code |
| patientName | VARCHAR | NOT NULL | Patient name |
| patientContact | VARCHAR | NULLABLE | Patient phone |
| patientAge | VARCHAR | NULLABLE | Patient age |
| prenatalPatientId | UUID | FK, NULLABLE | Link to prenatal |
| neonatalPatientId | UUID | FK, NULLABLE | Link to neonatal |
| reason | ENUM | NOT NULL | Referral reason |
| clinicalSummary | TEXT | NOT NULL | Clinical details |
| urgencyNotes | TEXT | NULLABLE | Urgency info |
| status | ENUM | NOT NULL | Current status |
| referringFacilityId | UUID | FK, NOT NULL | Sending facility |
| receivingFacilityId | UUID | FK, NOT NULL | Receiving facility |
| referringClinicianId | UUID | FK, NOT NULL | Sending clinician |
| receivingClinicianId | UUID | FK, NULLABLE | Receiving clinician |
| transportMode | ENUM | NULLABLE | Transport type |
| transportProvider | VARCHAR | NULLABLE | Provider name |
| transportContact | VARCHAR | NULLABLE | Provider contact |
| departureTime | TIMESTAMP | NULLABLE | Departure time |
| arrivalTime | TIMESTAMP | NULLABLE | Arrival time |
| transportNotes | TEXT | NULLABLE | Transport notes |
| acceptedByReceivingFacility | BOOLEAN | DEFAULT false | Acceptance flag |
| acceptedAt | TIMESTAMP | NULLABLE | Acceptance time |
| rejectionReason | TEXT | NULLABLE | Rejection reason |
| rejectedAt | TIMESTAMP | NULLABLE | Rejection time |
| treatmentOutcome | TEXT | NULLABLE | Treatment result |
| completedAt | TIMESTAMP | NULLABLE | Completion time |
| metadata | JSONB | NULLABLE | Custom data |
| createdAt | TIMESTAMP | NOT NULL | Creation time |
| updatedAt | TIMESTAMP | NULLABLE | Update time |

**Indexes:**
- `referringFacilityId + status` - Query by referring facility
- `receivingFacilityId + status` - Query by receiving facility
- `prenatalPatientId + status` - Query by prenatal patient
- `neonatalPatientId + status` - Query by neonatal patient
- `createdAt + status` - Query by date

**Foreign Keys:**
- `prenatalPatientId` → prenatal_patients.id (CASCADE DELETE)
- `neonatalPatientId` → neonatal_patients.id (CASCADE DELETE)
- `referringFacilityId` → health_facilities.id (CASCADE DELETE)
- `receivingFacilityId` → health_facilities.id (CASCADE DELETE)
- `referringClinicianId` → users.id (CASCADE DELETE)
- `receivingClinicianId` → users.id (CASCADE DELETE)

---

### 4. Notification System

**Notification Types:**
- INFO - Informational messages
- ALERT - Important alerts
- APPOINTMENT - Appointment reminders

**Referral Notifications:**

| Event | Recipient | Title | Type | Status |
|-------|-----------|-------|------|--------|
| Referral Created | Receiving Facility | New Referral | ALERT | ✅ |
| Referral Accepted | Referring Clinician | Referral Accepted | ALERT | ✅ |
| Referral Rejected | Referring Clinician | Referral Rejected | ALERT | ✅ |
| Patient Arrived | Receiving Clinician | Patient Arrived | ALERT | ✅ |
| Referral Completed | Referring Clinician | Referral Completed | ALERT | ✅ |

**Features:**
- In-app notifications
- Notification persistence
- Read/unread tracking
- Activity logging
- Broadcast to multiple users

---

### 5. Activity Logging

**Logged Actions:**
- Referral created
- Referral accepted
- Referral rejected
- Transport status updated
- Referral completed
- Referral cancelled

**Log Information:**
- Actor (user who performed action)
- Action type
- Description
- Metadata (referral details)
- Timestamp

---

## Complete Referral Workflow

### Step 1: Create Referral
```
Clinician at Facility A:
1. Opens Referrals page
2. Clicks "Create Referral"
3. Fills form:
   - Patient name, contact, age
   - Selects reason from dropdown
   - Enters clinical summary
   - Selects referring facility (auto-filled)
   - Selects receiving facility
   - Selects transport mode
4. Submits form
5. System:
   - Validates all fields
   - Generates unique referral code
   - Creates referral record
   - Sends notification to receiving facility
   - Emits WebSocket event
   - Logs activity
   - Shows success message
```

### Step 2: Receive & Review
```
Clinician at Facility B:
1. Receives notification: "New Referral"
2. Opens Referrals page
3. Sees new referral in "Pending" filter
4. Clicks referral to view details:
   - Patient information
   - Clinical summary
   - Referral reason
   - Urgency notes
   - Facility information
5. Reviews clinical information
```

### Step 3: Accept or Reject
```
Option A - Accept:
1. Clicks "Accept" button
2. System:
   - Assigns receiving clinician
   - Updates status to "accepted"
   - Records acceptance timestamp
   - Sends notification to referring facility
   - Emits WebSocket event
   - Logs activity
3. Referral moves to "Accepted" status

Option B - Reject:
1. Clicks "Reject" button
2. Enters rejection reason
3. System:
   - Records rejection reason
   - Updates status to "rejected"
   - Records rejection timestamp
   - Sends notification to referring facility
   - Emits WebSocket event
   - Logs activity
4. Referral moves to "Rejected" status
```

### Step 4: Arrange Transport
```
Transport Coordinator:
1. Receives accepted referral
2. Arranges transport:
   - Selects transport mode
   - Contacts transport provider
   - Schedules pickup/delivery
3. Updates referral with transport details:
   - Transport provider name
   - Provider contact
   - Departure time
   - Transport notes
```

### Step 5: Track Transport
```
During Transport:
1. Transport provider updates status
2. System updates referral:
   - Status: "in_transit"
   - Records departure time
   - Sends notification
   - Emits WebSocket event
3. On arrival:
   - Status: "arrived"
   - Records arrival time
   - Sends notification
   - Emits WebSocket event
```

### Step 6: Complete Treatment
```
Receiving Clinician:
1. Provides treatment
2. Documents outcome
3. Completes referral:
   - Enters treatment outcome
   - Clicks "Complete"
4. System:
   - Updates status to "completed"
   - Records completion timestamp
   - Records treatment outcome
   - Sends notification to referring facility
   - Emits WebSocket event
   - Logs activity
5. Referral marked as complete
```

### Step 7: Follow-up
```
Referring Clinician:
1. Receives notification: "Referral Completed"
2. Views referral details:
   - Treatment outcome
   - Completion timestamp
   - Full referral history
3. Can view in "Completed" filter
4. Can export/print for records
```

---

## Features Implemented

### ✅ Core Features
- [x] Create referrals with validation
- [x] View all referrals with filtering
- [x] Accept/reject referrals
- [x] Update transport status
- [x] Complete referrals with outcomes
- [x] Cancel referrals
- [x] View referral details
- [x] Status tracking (7 states)
- [x] Unique referral codes
- [x] Facility selection
- [x] Clinician assignment
- [x] Transport tracking

### ✅ Enhanced Features
- [x] WebSocket real-time updates
- [x] Facility dropdown selector
- [x] Reason dropdown selector
- [x] Transport mode dropdown
- [x] Status color coding
- [x] Toast notifications
- [x] Error handling
- [x] Loading states
- [x] Form validation
- [x] Activity logging

### ✅ Notification System
- [x] In-app notifications
- [x] Notification persistence
- [x] Read/unread tracking
- [x] Broadcast notifications
- [x] Activity logging

### ⚠️ Partial Features
- [⚠️] Patient selection (manual entry, not linked)
- [⚠️] Facility notifications (in-app only, no SMS/email)

### ❌ Future Enhancements
- [ ] SMS notifications
- [ ] Email notifications
- [ ] Push notifications
- [ ] GPS transport tracking
- [ ] Inter-facility messaging
- [ ] Document attachment
- [ ] Counter-referrals
- [ ] SLA tracking
- [ ] Escalation alerts
- [ ] Referral analytics
- [ ] Export/print functionality
- [ ] Offline support

---

## API Usage Examples

### Create Referral
```bash
POST /referrals
Content-Type: application/json
Authorization: Bearer {token}

{
  "patientName": "Jane Doe",
  "patientContact": "+265999123456",
  "patientAge": "28",
  "reason": "Hypertension",
  "clinicalSummary": "Patient with severe hypertension, BP 180/110",
  "urgencyNotes": "Urgent - requires immediate specialist care",
  "referringFacilityId": "facility-1",
  "receivingFacilityId": "facility-2",
  "transportMode": "ambulance"
}
```

### Accept Referral
```bash
PUT /referrals/{referralId}/accept
Authorization: Bearer {token}
```

### Reject Referral
```bash
PUT /referrals/{referralId}/reject
Content-Type: application/json
Authorization: Bearer {token}

{
  "rejectionReason": "Facility at capacity, cannot accept at this time"
}
```

### Update Transport Status
```bash
PUT /referrals/{referralId}/transport
Content-Type: application/json
Authorization: Bearer {token}

{
  "status": "in_transit",
  "timestamp": "2024-05-29T14:30:00Z"
}
```

### Complete Referral
```bash
PUT /referrals/{referralId}/complete
Content-Type: application/json
Authorization: Bearer {token}

{
  "treatmentOutcome": "Patient stabilized, hypertension controlled with medication"
}
```

---

## Testing Checklist

### Create Referral
- [ ] Form validates all required fields
- [ ] Dropdown selectors work correctly
- [ ] Referral code generated
- [ ] Notification sent to receiving facility
- [ ] WebSocket event emitted
- [ ] Activity logged

### Accept Referral
- [ ] Status updated to "accepted"
- [ ] Receiving clinician assigned
- [ ] Notification sent to referring facility
- [ ] WebSocket event emitted
- [ ] Activity logged

### Reject Referral
- [ ] Status updated to "rejected"
- [ ] Rejection reason recorded
- [ ] Notification sent to referring facility
- [ ] WebSocket event emitted
- [ ] Activity logged

### Transport Status
- [ ] Status updated to "in_transit"
- [ ] Departure time recorded
- [ ] Status updated to "arrived"
- [ ] Arrival time recorded
- [ ] Notifications sent
- [ ] WebSocket events emitted

### Complete Referral
- [ ] Status updated to "completed"
- [ ] Treatment outcome recorded
- [ ] Completion timestamp recorded
- [ ] Notification sent to referring facility
- [ ] WebSocket event emitted
- [ ] Activity logged

### Real-time Updates
- [ ] WebSocket connects on page load
- [ ] Referral list auto-refreshes on event
- [ ] Toast notifications appear
- [ ] Status badges update in real-time
- [ ] No manual refresh needed

---

## Deployment Checklist

- [ ] Backend API endpoints tested
- [ ] Database migrations applied
- [ ] WebSocket server configured
- [ ] Notification service running
- [ ] Activity logging enabled
- [ ] Frontend WebSocket listener active
- [ ] Dropdown data loading correctly
- [ ] Error handling working
- [ ] Loading states displaying
- [ ] Toast notifications showing
- [ ] Real-time updates working
- [ ] All tests passing

---

## Support & Troubleshooting

### WebSocket Connection Issues
- Check WebSocket server is running
- Verify CORS configuration
- Check network connectivity
- Review browser console for errors

### Notification Not Appearing
- Verify notification service is running
- Check user permissions
- Review activity logs
- Check notification preferences

### Referral Not Updating
- Refresh page manually
- Check WebSocket connection
- Verify API endpoint
- Review error logs

### Dropdown Not Loading
- Check facility API endpoint
- Verify authentication token
- Check network requests
- Review browser console

---

## Files & Locations

**Backend:**
- `backend/backend/src/referrals/` - Referral module
- `backend/backend/src/referrals/entities/referral.entity.ts` - Data model
- `backend/backend/src/referrals/referrals.service.ts` - Business logic
- `backend/backend/src/referrals/referrals.controller.ts` - API endpoints
- `backend/backend/src/events/events.gateway.ts` - WebSocket events
- `backend/backend/src/notifications/` - Notification system

**Frontend:**
- `safe-mother-malawi/lib/services/referral_service.dart` - Service layer
- `safe-mother-malawi/lib/screens/clinician/pages/referral_page.dart` - UI

**Documentation:**
- `backend/backend/REFERRAL_SYSTEM_IMPLEMENTATION.md` - Backend docs
- `safe-mother-malawi/REFERRAL_SYSTEM_COMPLETE.md` - This file

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-05-29 | Initial complete implementation |
| 1.1 | 2024-05-29 | Added WebSocket real-time updates |
| 1.2 | 2024-05-29 | Added facility/reason dropdowns |

---

## Contact & Support

For issues or questions about the referral system, contact the development team.

---

**Last Updated:** 2024-05-29
**Status:** Production Ready ✅
