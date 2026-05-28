# Dashboard Redesign Specification

## Current Problems

1. **Vague Metrics**: "18 Total Members" - unclear what this represents
2. **Confusing Labels**: "76.8% This month" - 76.8% of what?
3. **Empty Visualizations**: "District Trends" shows "No data yet"
4. **Unclear Abbreviations**: Risk Breakdown pie chart (HR, LR, OR, CR)
5. **No Context**: Missing time periods, comparisons, trends
6. **Not Actionable**: Numbers alone don't drive decisions

---

## Redesigned Overview Dashboard Structure

### **Section 1: Critical Status (Top Priority)**
**Purpose**: Immediate action items that need attention

#### Card 1: 🚨 Active Alerts Requiring Action
- **Metric**: `activeAlerts` (unattended alerts)
- **Display**: Large red number with icon
- **Context**: "Alerts waiting for clinician response"
- **Action**: Click to view alert list
- **Example**: "8 Active Alerts" (vs current "8 High-Risk Cases")

#### Card 2: ⚠️ High-Risk Patients Needing Follow-up
- **Metric**: `highRiskCases` (High Risk + Critical)
- **Display**: Orange number with trend indicator
- **Context**: "Patients requiring immediate attention"
- **Trend**: "↑ 2 from last week" or "↓ 1 from last week"
- **Action**: Click to view high-risk patient list
- **Example**: "12 High-Risk Patients" (vs current "8 High-Risk Cases")

#### Card 3: 📋 Missed Appointments This Month
- **Metric**: `missedVisitsRate` (percentage)
- **Display**: Percentage with comparison
- **Context**: "% of scheduled ANC visits not attended"
- **Comparison**: "vs 15% last month"
- **Action**: Click to view missed appointment details
- **Example**: "14% Missed Visits" (vs current "0 Null Values")

---

### **Section 2: Program Performance (Key Indicators)**
**Purpose**: Track program effectiveness and compliance

#### Card 1: 👶 Total Mothers Enrolled
- **Metric**: `totalPrenatal` (prenatal patients)
- **Display**: Large number with growth indicator
- **Context**: "Active prenatal patients in system"
- **Growth**: "↑ 23 this month" or "↑ 12% vs last month"
- **Example**: "1,420 Mothers" (vs current "18 Total Members")

#### Card 2: 🏥 ANC Attendance Rate
- **Metric**: `ancAttendanceRate` (percentage)
- **Display**: Percentage with visual gauge
- **Context**: "% of scheduled ANC appointments attended"
- **Target**: "Target: 90%" (show if below target)
- **Example**: "85% Attendance" (vs current "76.8% This month")

#### Card 3: 👨‍⚕️ Active Clinicians
- **Metric**: `totalClinicians` (active clinicians)
- **Display**: Number with status indicator
- **Context**: "Clinicians actively managing patients"
- **Status**: "All active" or "2 inactive (30+ days)"
- **Example**: "18 Clinicians" (vs current "18 Total Members")

#### Card 4: 👶 Neonatal Patients
- **Metric**: `totalNeonatal` (neonatal patients)
- **Display**: Number with growth
- **Context**: "Babies currently being tracked"
- **Growth**: "↑ 5 this month"
- **Example**: "342 Babies" (new metric)

---

### **Section 3: Delivery Outcomes (Program Success)**
**Purpose**: Show maternal and neonatal health outcomes

#### Card 1: 👶 Live Births
- **Metric**: `liveBirths` (count)
- **Display**: Green number
- **Context**: "Successful deliveries this month"
- **Example**: "156 Live Births"

#### Card 2: ⚠️ Stillbirths
- **Metric**: `stillbirths` (count)
- **Display**: Red number with rate
- **Context**: "Stillbirths this month (rate: X per 1000)"
- **Example**: "2 Stillbirths (rate: 1.3%)"

#### Card 3: 📊 Maternal Complications
- **Metric**: Top 3 complications from alerts
- **Display**: List with counts
- **Context**: "Most common complications reported"
- **Example**: 
  - Gestational Diabetes: 12
  - Preeclampsia: 8
  - Anemia: 15

---

### **Section 4: Geographic Performance (District Comparison)**
**Purpose**: Identify high-performing and struggling districts

#### Chart: District Performance Heatmap
- **Rows**: District names
- **Columns**: 
  - Prenatal Patients
  - High-Risk Cases
  - ANC Attendance Rate
  - Missed Visits
- **Color Coding**: Green (good), Yellow (fair), Red (poor)
- **Sorting**: By high-risk cases (descending)
- **Example**:
  ```
  District          | Patients | High-Risk | ANC Rate | Missed
  Lilongwe          | 450      | 12        | 92%      | 8%
  Blantyre          | 380      | 18        | 78%      | 22%
  Mzuzu             | 290      | 8         | 88%      | 12%
  ```

---

### **Section 5: Risk Distribution (Visual Breakdown)**
**Purpose**: Show risk level distribution at a glance

#### Pie Chart: Risk Level Distribution
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

### **Section 6: Trends (Historical Performance)**
**Purpose**: Show trends over time for decision-making

#### Chart 1: Monthly Registration Trend (12 months)
- **X-axis**: Month names
- **Y-axis**: Number of registrations
- **Lines**: 
  - Prenatal registrations (blue)
  - Neonatal registrations (green)
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

### **Section 7: System Health (Operational Status)**
**Purpose**: Monitor system and clinician performance

#### Status Indicators:
1. **Clinician Activity**
   - "All clinicians active" (green)
   - "2 clinicians inactive 30+ days" (yellow)
   - "5 clinicians inactive 60+ days" (red)

2. **Data Quality**
   - "98% of records complete" (green)
   - "92% of records complete" (yellow)
   - "85% of records complete" (red)

3. **Alert Response Time**
   - "Average response: 2.3 hours" (green if <4 hours)
   - "Average response: 6.1 hours" (yellow if 4-8 hours)
   - "Average response: 12+ hours" (red if >8 hours)

---

## Implementation Details

### **For Admin Dashboard** (`admin_overview.dart`)
Show all metrics above (Sections 1-7)

### **For DHO Dashboard** (new)
Show:
- Section 1: Critical Status (alerts, high-risk)
- Section 2: Program Performance (mothers, clinicians, ANC rate)
- Section 3: Delivery Outcomes
- Section 4: Geographic Performance (their district only)
- Section 5: Risk Distribution
- Section 6: Trends

### **For Clinician Dashboard** (new)
Show:
- Section 1: Critical Status (their alerts, their high-risk patients)
- Section 2: Their Performance (their patients, their ANC rate)
- Section 3: Their Delivery Outcomes
- Section 5: Their Risk Distribution
- Section 6: Their Trends

---

## Data Mapping

| Current Metric | New Metric | Source | Clarity |
|---|---|---|---|
| "18 Total Members" | "18 Active Clinicians" | `totalClinicians` | ✅ Clear |
| "8 High-Risk Cases" | "12 High-Risk Patients" | `highRiskCases` | ✅ Clear |
| "76.8% This month" | "85% ANC Attendance Rate" | `ancAttendanceRate` | ✅ Clear |
| "0 Null Values" | "14% Missed Visits" | `missedVisitsRate` | ✅ Clear |
| "No data yet" | "1,420 Mothers Enrolled" | `totalPrenatal` | ✅ Clear |
| Risk Breakdown (HR, LR, OR, CR) | Risk Distribution (Low, Moderate, High, Critical) | `getRiskDistribution()` | ✅ Clear |

---

## Benefits of Redesign

1. **Clarity**: Every metric has a clear label and context
2. **Actionability**: Metrics drive specific actions (view alerts, follow up, etc.)
3. **Comparability**: Trends and comparisons show performance
4. **Completeness**: All important data visible at a glance
5. **Role-Based**: Different views for admin, DHO, clinician
6. **Mobile-Friendly**: Cards stack on mobile, charts responsive
7. **Accessible**: Color-blind friendly (use patterns + colors)

---

## Next Steps

1. Update `admin_overview.dart` to implement new layout
2. Create `dho_overview.dart` for DHO-specific view
3. Create `clinician_dashboard.dart` for clinician view
4. Update backend analytics endpoints if needed
5. Add missing metrics to analytics service (e.g., alert response time)
6. Test with real data
7. Gather user feedback and iterate

---

## Files to Modify

- `safe-mother-malawi/lib/web/admin/admin_overview.dart` - Main admin dashboard
- `safe-mother-malawi/lib/web/dho/dho_overview.dart` - New DHO dashboard
- `safe-mother-malawi/lib/mobile/clinician/clinician_dashboard.dart` - New clinician dashboard
- `backend/backend/src/analytics/analytics.service.ts` - Add missing metrics
- `backend/backend/src/analytics/analytics.controller.ts` - Add new endpoints if needed

---

**Status**: Ready for implementation
**Priority**: High (improves user experience significantly)
**Estimated Effort**: 2-3 days for full implementation
