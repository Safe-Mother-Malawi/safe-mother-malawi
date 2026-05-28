# DHO Dashboard Redesign Specification

## Context: What is a DHO?
**DHO** = District Health Officer
- Responsible for **one district** (not all districts)
- Manages **all clinicians** in their district
- Oversees **all health facilities** in their district
- Needs **district-level performance metrics**
- Focuses on **compliance, quality, and outcomes**

---

## Current Problems

1. **Generic metrics** - Shows system-wide data, not district-specific
2. **Vague labels** - "18 Total Members", "76.8% Task Completion"
3. **No district context** - Doesn't show which district or facility
4. **Empty visualizations** - "No data yet" in District Trends
5. **Unclear abbreviations** - HR, LR, OR, CR in Risk Breakdown
6. **Not actionable** - Doesn't drive district-level decisions
7. **Missing facility view** - Can't see individual facility performance

---

## DHO Role & Responsibilities

### Primary Goals
1. **Ensure ANC Compliance** - Track attendance and completion rates
2. **Manage High-Risk Cases** - Monitor and follow up on high-risk patients
3. **Oversee Clinicians** - Track clinician activity and performance
4. **Monitor Facilities** - Ensure all facilities are functioning
5. **Improve Outcomes** - Reduce maternal/neonatal mortality
6. **Ensure Data Quality** - Verify data completeness and accuracy

### Key Questions DHO Needs Answered
- How many pregnant mothers are in my district?
- How many are high-risk and need follow-up?
- What's my ANC attendance rate vs target?
- Which facilities are underperforming?
- Which clinicians are inactive?
- What are the top complications in my district?
- Are we meeting delivery outcome targets?
- What's my district's performance vs other districts?

---

## Redesigned DHO Dashboard Structure

### **Section 1: District Overview (Top Priority)**
**Purpose**: Quick snapshot of district health status

#### Card 1: 📍 District Name & Status
- **Display**: District name with status badge
- **Status**: "On Track" (green), "At Risk" (yellow), "Critical" (red)
- **Metric**: Overall district health score (0-100)
- **Example**: "Lilongwe District - On Track (92/100)"

#### Card 2: 👶 Total Mothers in District
- **Metric**: `totalPrenatal` (filtered by district)
- **Display**: Large number with growth
- **Context**: "Active prenatal patients"
- **Growth**: "↑ 23 this month" or "↑ 12% vs last month"
- **Example**: "1,420 Mothers" (vs current "18 Total Members")

#### Card 3: ⚠️ High-Risk Patients Needing Follow-up
- **Metric**: `highRiskCases` (filtered by district)
- **Display**: Red number with trend
- **Context**: "Patients requiring immediate attention"
- **Trend**: "↑ 2 from last week" or "↓ 1 from last week"
- **Action**: Click to view high-risk patient list
- **Example**: "45 High-Risk Patients"

#### Card 4: 🚨 Active Alerts This Week
- **Metric**: `activeAlerts` (filtered by district, last 7 days)
- **Display**: Orange number with severity breakdown
- **Context**: "Alerts waiting for clinician response"
- **Breakdown**: "3 Critical, 5 High, 2 Medium"
- **Action**: Click to view alert details
- **Example**: "10 Active Alerts"

---

### **Section 2: ANC Compliance (Program Performance)**
**Purpose**: Track ANC program effectiveness

#### Card 1: 🏥 ANC Attendance Rate
- **Metric**: `ancAttendanceRate` (district-specific)
- **Display**: Percentage with visual gauge
- **Context**: "% of scheduled ANC appointments attended"
- **Target**: "Target: 90%" (show if below target)
- **Comparison**: "vs 82% last month"
- **Status**: Green (≥90%), Yellow (75-89%), Red (<75%)
- **Example**: "85% Attendance"

#### Card 2: ✅ ANC Compliance Rate
- **Metric**: `ancComplianceRate` (district-specific)
- **Display**: Percentage with status
- **Context**: "% of mothers following WHO ANC schedule"
- **Target**: "Target: 85%"
- **Example**: "78% Compliance"

#### Card 3: 📋 Missed Appointments This Month
- **Metric**: `missedVisitsRate` (district-specific)
- **Display**: Percentage with trend
- **Context**: "% of scheduled ANC visits not attended"
- **Comparison**: "vs 15% last month"
- **Action**: Click to view missed appointment details
- **Example**: "14% Missed Visits"

#### Card 4: 👥 Patients with Poor Compliance
- **Metric**: `poorCompliancePatients` (district-specific)
- **Display**: Number with action button
- **Context**: "Mothers needing follow-up"
- **Action**: "Send Reminder" button
- **Example**: "87 Patients Need Follow-up"

---

### **Section 3: Delivery Outcomes (Program Success)**
**Purpose**: Show maternal and neonatal health outcomes

#### Card 1: 👶 Live Births This Month
- **Metric**: `liveBirths` (district-specific)
- **Display**: Green number with growth
- **Context**: "Successful deliveries"
- **Growth**: "↑ 12 vs last month"
- **Example**: "156 Live Births"

#### Card 2: ⚠️ Stillbirths This Month
- **Metric**: `stillbirths` (district-specific)
- **Display**: Red number with rate
- **Context**: "Stillbirths (rate per 1000)"
- **Rate**: "1.3% (2 per 1000 births)"
- **Trend**: "↓ 1 vs last month"
- **Example**: "2 Stillbirths"

#### Card 3: 📊 Top Maternal Complications
- **Metric**: Top 3 complications from alerts (district-specific)
- **Display**: List with counts
- **Context**: "Most common complications reported"
- **Example**:
  - Gestational Diabetes: 12
  - Preeclampsia: 8
  - Anemia: 15

#### Card 4: 👨‍⚕️ Neonatal Health Status
- **Metric**: Neonatal patient distribution (district-specific)
- **Display**: Status breakdown
- **Context**: "Current health status of babies"
- **Example**:
  - Healthy: 298 (87%)
  - At Risk: 32 (9%)
  - Sick: 8 (2%)
  - Hospitalized: 4 (1%)

---

### **Section 4: Facility Performance (Facility Comparison)**
**Purpose**: Identify high-performing and struggling facilities

#### Table: Facility Performance Scorecard
- **Rows**: Health facilities in district
- **Columns**:
  - Facility Name
  - Patients
  - High-Risk Cases
  - ANC Attendance Rate
  - Missed Visits
  - Clinicians
  - Status
- **Color Coding**: Green (good), Yellow (fair), Red (poor)
- **Sorting**: By high-risk cases (descending)
- **Action**: Click facility to see details

**Example**:
```
Facility              | Patients | High-Risk | ANC Rate | Missed | Clinicians | Status
Lilongwe Central      | 450      | 12        | 92%      | 8%     | 5          | ✅ Good
Lilongwe District     | 380      | 18        | 78%      | 22%    | 4          | ⚠️ Fair
Lilongwe Rural        | 290      | 8         | 88%      | 12%    | 3          | ✅ Good
```

---

### **Section 5: Clinician Performance (Staff Management)**
**Purpose**: Monitor clinician activity and performance

#### Table: Clinician Activity & Performance
- **Rows**: Clinicians in district
- **Columns**:
  - Clinician Name
  - Facility
  - Patients
  - High-Risk Cases
  - Appointments This Month
  - Last Active
  - Status
- **Color Coding**: Green (active), Yellow (inactive 7-30 days), Red (inactive 30+ days)
- **Sorting**: By last active (most recent first)
- **Action**: Click clinician to see details

**Example**:
```
Clinician Name    | Facility          | Patients | High-Risk | Appointments | Last Active | Status
Dr. Banda         | Lilongwe Central  | 120      | 8         | 45           | Today       | ✅ Active
Nurse Mwale       | Lilongwe District | 95       | 6         | 38           | 2 days ago  | ✅ Active
Dr. Phiri         | Lilongwe Rural    | 85       | 4         | 32           | 15 days ago | ⚠️ Inactive
```

---

### **Section 6: Risk Distribution (Visual Breakdown)**
**Purpose**: Show risk level distribution at a glance

#### Pie Chart: Risk Level Distribution (District)
- **Segments**:
  - Low Risk (Green)
  - Moderate Risk (Yellow)
  - High Risk (Orange)
  - Critical/Seek Help Immediately (Red)
- **Labels**: Clear names + percentages
- **Example**:
  ```
  Low Risk: 1,200 (75%)
  Moderate Risk: 280 (18%)
  High Risk: 80 (5%)
  Critical: 12 (2%)
  ```

---

### **Section 7: Trends (Historical Performance)**
**Purpose**: Show trends over time for decision-making

#### Chart 1: Monthly Registration Trend (6 months)
- **X-axis**: Month names
- **Y-axis**: Number of registrations
- **Lines**: Prenatal registrations (blue)
- **Purpose**: Identify seasonal patterns, growth trends
- **Example**: Shows if registrations are increasing/decreasing

#### Chart 2: ANC Compliance Trend (6 months)
- **X-axis**: Month names
- **Y-axis**: Percentage
- **Lines**:
  - Attendance Rate (blue)
  - Completion Rate (green)
  - Missed Visits Rate (red)
- **Purpose**: Track compliance improvements/declines

#### Chart 3: High-Risk Case Trend (6 months)
- **X-axis**: Month names
- **Y-axis**: Number of cases
- **Lines**:
  - High-Risk Cases (orange)
  - Critical Cases (red)
- **Purpose**: Identify spikes requiring intervention

---

### **Section 8: System Health (Operational Status)**
**Purpose**: Monitor district operational health

#### Status Indicators:
1. **Clinician Activity**
   - "All clinicians active" (green)
   - "2 clinicians inactive 7-30 days" (yellow)
   - "1 clinician inactive 30+ days" (red)

2. **Data Quality**
   - "98% of records complete" (green)
   - "92% of records complete" (yellow)
   - "85% of records complete" (red)

3. **Facility Status**
   - "All facilities operational" (green)
   - "1 facility with issues" (yellow)
   - "2+ facilities with issues" (red)

4. **Alert Response Time**
   - "Average response: 2.3 hours" (green if <4 hours)
   - "Average response: 6.1 hours" (yellow if 4-8 hours)
   - "Average response: 12+ hours" (red if >8 hours)

---

## Before & After Comparison

### BEFORE (Current)
```
DHO Overview
├─ 18 Total Members (unclear - clinicians? patients?)
├─ 9 High-Risk Cases (no district context)
├─ 76.8% Task Completion (unclear metric)
├─ 0 IVR Usage (confusing)
├─ District Trends: "No data yet" (empty)
└─ Risk Breakdown: HR, LR, OR, CR (abbreviations)
```

### AFTER (Redesigned)
```
DHO Overview - Lilongwe District
├─ DISTRICT OVERVIEW
│  ├─ 📍 Lilongwe District - On Track (92/100)
│  ├─ 👶 1,420 Mothers Enrolled (↑ 23 this month)
│  ├─ ⚠️ 45 High-Risk Patients (↑ 2 from last week)
│  └─ 🚨 10 Active Alerts (3 Critical, 5 High, 2 Medium)
├─ ANC COMPLIANCE
│  ├─ 🏥 85% ANC Attendance (Target: 90%)
│  ├─ ✅ 78% ANC Compliance (Target: 85%)
│  ├─ 📋 14% Missed Visits (vs 15% last month)
│  └─ 👥 87 Patients Need Follow-up
├─ DELIVERY OUTCOMES
│  ├─ 👶 156 Live Births (↑ 12 vs last month)
│  ├─ ⚠️ 2 Stillbirths (1.3% rate)
│  ├─ 📊 Top Complications (Gestational DM, Preeclampsia, Anemia)
│  └─ 👨‍⚕️ Neonatal Status (Healthy: 298, At Risk: 32, Sick: 8)
├─ FACILITY PERFORMANCE
│  └─ [Facility Scorecard Table with color-coded metrics]
├─ CLINICIAN PERFORMANCE
│  └─ [Clinician Activity Table with status indicators]
├─ RISK DISTRIBUTION
│  └─ [Pie Chart: Low (75%), Moderate (18%), High (5%), Critical (2%)]
├─ TRENDS
│  ├─ Monthly Registration (6 months)
│  ├─ ANC Compliance (6 months)
│  └─ High-Risk Cases (6 months)
└─ SYSTEM HEALTH
   ├─ ✅ Clinician Activity: All active
   ├─ ✅ Data Quality: 98% complete
   ├─ ✅ Facility Status: All operational
   └─ ⚠️ Alert Response: 6.1 hours avg
```

---

## Key Differences from Admin Dashboard

| Aspect | Admin Dashboard | DHO Dashboard |
|--------|-----------------|---------------|
| **Scope** | System-wide | District-only |
| **Facilities** | Not shown | Facility scorecard |
| **Clinicians** | System-wide list | District clinicians only |
| **Metrics** | Global KPIs | District-specific KPIs |
| **Comparison** | All districts | N/A (single district) |
| **Focus** | System health | District performance |
| **Actions** | System-wide | District-level interventions |

---

## Data Filtering

All metrics should be **filtered by district**:
- `totalPrenatal` → WHERE district = currentUser.district
- `highRiskCases` → WHERE district = currentUser.district
- `ancAttendanceRate` → WHERE district = currentUser.district
- `facilities` → WHERE district = currentUser.district
- `clinicians` → WHERE district = currentUser.district

---

## Implementation

### Files to Create
1. `lib/web/dho/dho_dashboard_redesigned.dart` - New DHO dashboard
2. `lib/web/shared/widgets/facility_scorecard.dart` - Facility performance table
3. `lib/web/shared/widgets/clinician_performance_table.dart` - Clinician activity table

### Files to Modify
1. `lib/web/dho/dho_overview.dart` - Update current implementation
2. `lib/web/shared/widgets/kpi_card.dart` - Add trend, target, comparison support
3. `backend/backend/src/analytics/analytics.service.ts` - Add district filtering

### Backend Endpoints Needed
- `GET /analytics/overview?district=:district` - District-specific overview
- `GET /analytics/facilities?district=:district` - Facility list with metrics
- `GET /analytics/clinicians?district=:district` - Clinician list with activity
- `GET /analytics/anc-analytics?district=:district` - District ANC metrics
- `GET /analytics/risk-distribution?district=:district` - District risk distribution

### Estimated Effort
- **Phase 1**: Update KPI cards (1 day)
- **Phase 2**: Create facility and clinician tables (1 day)
- **Phase 3**: Add district filtering to backend (0.5 day)
- **Phase 4**: Testing and refinement (0.5 day)
- **Total**: 3 days

---

## Success Metrics

✅ Every metric is district-specific
✅ Facility performance is visible
✅ Clinician activity is tracked
✅ All metrics have clear labels
✅ Trends and comparisons are shown
✅ Dashboard is actionable
✅ No empty visualizations
✅ Color-coded status indicators
✅ Responsive design
✅ Real-time data updates

---

## Next Steps

1. **Review** this redesign with DHO stakeholders
2. **Approve** the new structure
3. **Implement** following the implementation guide
4. **Test** with real district data
5. **Gather** DHO feedback
6. **Iterate** based on feedback

---

**Status**: Ready for implementation
**Priority**: High (improves DHO UX significantly)
**Owner**: Frontend team
**Timeline**: 3 days
