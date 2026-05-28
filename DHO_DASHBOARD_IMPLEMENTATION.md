# DHO Dashboard Implementation Guide

## Overview
This guide provides step-by-step instructions to restructure the DHO dashboard for clarity, meaningfulness, and district-specific focus.

---

## Key Implementation Principles

### 1. **District-Specific Filtering**
All data must be filtered by the current user's district:

```dart
// Get current user's district
final user = AuthServiceWeb.instance.currentUser;
final district = user?['district'] as String? ?? '';

// Pass district to all API calls
final overview = await ApiService.instance.get('/analytics/overview?district=$district');
final facilities = await ApiService.instance.get('/analytics/facilities?district=$district');
final clinicians = await ApiService.instance.get('/analytics/clinicians?district=$district');
```

### 2. **Clear Labeling**
Every metric must have:
- Clear title (not abbreviations)
- Context (what it measures)
- Target (if applicable)
- Comparison (vs last month/week)
- Status indicator (green/yellow/red)

### 3. **Actionability**
Every card should be clickable and lead to:
- Detailed view
- List of affected patients/clinicians
- Action buttons (send reminder, follow up, etc.)

---

## Section-by-Section Implementation

### Section 1: District Overview

#### Card 1: District Status
```dart
KPICard(
  icon: Icons.location_on,
  title: 'District Status',
  value: _districtName,
  subtitle: 'Overall health score',
  status: _districtStatus, // "On Track", "At Risk", "Critical"
  statusColor: _getStatusColor(_districtScore),
  score: '$_districtScore/100',
  onTap: () => _viewDistrictDetails(),
)
```

#### Card 2: Total Mothers
```dart
KPICard(
  icon: Icons.pregnant_woman,
  title: 'Mothers Enrolled',
  value: '$_totalMothers',
  subtitle: 'Active prenatal patients in district',
  trend: _mothersTrend, // "↑ 23 this month"
  trendColor: Colors.green,
  comparison: 'vs $_mothersLastMonth last month',
  onTap: () => _viewMothersList(),
)
```

#### Card 3: High-Risk Patients
```dart
KPICard(
  icon: Icons.warning,
  title: 'High-Risk Patients',
  value: '$_highRiskCases',
  subtitle: 'Requiring immediate attention',
  trend: _highRiskTrend, // "↑ 2 from last week"
  trendColor: _highRiskTrend.startsWith('↑') ? Colors.red : Colors.green,
  percentage: '${(_highRiskCases / _totalMothers * 100).toStringAsFixed(1)}% of total',
  onTap: () => _viewHighRiskPatients(),
)
```

#### Card 4: Active Alerts
```dart
KPICard(
  icon: Icons.notifications_active,
  title: 'Active Alerts',
  value: '$_activeAlerts',
  subtitle: 'Alerts waiting for clinician response',
  breakdown: '$_criticalAlerts Critical, $_highAlerts High, $_mediumAlerts Medium',
  onTap: () => _viewAlerts(),
)
```

---

### Section 2: ANC Compliance

#### Card 1: ANC Attendance Rate
```dart
KPICard(
  icon: Icons.check_circle,
  title: 'ANC Attendance Rate',
  value: '$_ancAttendanceRate%',
  subtitle: 'Scheduled appointments attended',
  target: '90%',
  targetColor: _ancAttendanceRate >= 90 ? Colors.green : Colors.orange,
  comparison: 'vs $_ancAttendanceLastMonth% last month',
  gauge: _buildGauge(_ancAttendanceRate, 90),
  onTap: () => _viewANCDetails(),
)
```

#### Card 2: ANC Compliance Rate
```dart
KPICard(
  icon: Icons.verified,
  title: 'ANC Compliance Rate',
  value: '$_ancComplianceRate%',
  subtitle: 'Mothers following WHO ANC schedule',
  target: '85%',
  targetColor: _ancComplianceRate >= 85 ? Colors.green : Colors.orange,
  onTap: () => _viewComplianceDetails(),
)
```

#### Card 3: Missed Visits
```dart
KPICard(
  icon: Icons.event_busy,
  title: 'Missed Visits',
  value: '$_missedVisitsRate%',
  subtitle: 'Scheduled ANC visits not attended',
  comparison: 'vs $_missedVisitsLastMonth% last month',
  trend: _missedVisitsTrend,
  trendColor: _missedVisitsTrend.startsWith('↓') ? Colors.green : Colors.red,
  onTap: () => _viewMissedVisits(),
)
```

#### Card 4: Patients Needing Follow-up
```dart
KPICard(
  icon: Icons.people,
  title: 'Patients Need Follow-up',
  value: '$_poorCompliancePatients',
  subtitle: 'Mothers with poor compliance',
  action: 'Send Reminder',
  onAction: () => _sendReminders(),
  onTap: () => _viewPoorCompliancePatients(),
)
```

---

### Section 3: Delivery Outcomes

#### Card 1: Live Births
```dart
KPICard(
  icon: Icons.child_care,
  title: 'Live Births',
  value: '$_liveBirths',
  subtitle: 'Successful deliveries this month',
  growth: '↑ $_liveBirthsGrowth vs last month',
  growthColor: Colors.green,
  onTap: () => _viewLiveBirths(),
)
```

#### Card 2: Stillbirths
```dart
KPICard(
  icon: Icons.warning,
  title: 'Stillbirths',
  value: '$_stillbirths',
  subtitle: 'Stillbirths this month',
  rate: '${_stillbirthRate.toStringAsFixed(1)}% (per 1000 births)',
  trend: _stillbirthTrend,
  trendColor: _stillbirthTrend.startsWith('↓') ? Colors.green : Colors.red,
  onTap: () => _viewStillbirths(),
)
```

#### Card 3: Top Complications
```dart
ChartCard(
  title: 'Top Maternal Complications',
  child: Column(
    children: _topComplications.map((c) => Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(c['name']),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${c['count']} cases', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    )).toList(),
  ),
)
```

#### Card 4: Neonatal Health Status
```dart
ChartCard(
  title: 'Neonatal Health Status',
  child: Column(
    children: [
      _buildStatusRow('Healthy', _healthyBabies, Colors.green),
      _buildStatusRow('At Risk', _atRiskBabies, Colors.orange),
      _buildStatusRow('Sick', _sickBabies, Colors.red),
      _buildStatusRow('Hospitalized', _hospitalizedBabies, Colors.purple),
    ],
  ),
)

Widget _buildStatusRow(String label, int count, Color color) {
  final total = _healthyBabies + _atRiskBabies + _sickBabies + _hospitalizedBabies;
  final percentage = (count / total * 100).toStringAsFixed(1);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text('$count ($percentage%)', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
```

---

### Section 4: Facility Performance

#### Facility Scorecard Table
```dart
ChartCard(
  title: 'Facility Performance Scorecard',
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: [
        DataColumn(label: Text('Facility')),
        DataColumn(label: Text('Patients')),
        DataColumn(label: Text('High-Risk')),
        DataColumn(label: Text('ANC Rate')),
        DataColumn(label: Text('Missed')),
        DataColumn(label: Text('Clinicians')),
        DataColumn(label: Text('Status')),
      ],
      rows: _facilities.map((f) => DataRow(
        onSelectChanged: (_) => _viewFacilityDetails(f['id']),
        cells: [
          DataCell(Text(f['name'])),
          DataCell(_buildCell('${f['patients']}', 'neutral')),
          DataCell(_buildCell('${f['highRisk']}', f['highRisk'] > 10 ? 'bad' : 'good')),
          DataCell(_buildCell('${f['ancRate']}%', f['ancRate'] >= 90 ? 'good' : f['ancRate'] >= 75 ? 'fair' : 'bad')),
          DataCell(_buildCell('${f['missedRate']}%', f['missedRate'] <= 15 ? 'good' : f['missedRate'] <= 20 ? 'fair' : 'bad')),
          DataCell(_buildCell('${f['clinicians']}', 'neutral')),
          DataCell(_buildStatusBadge(f['status'])),
        ],
      )).toList(),
    ),
  ),
)

Widget _buildCell(String value, String status) {
  final color = status == 'good' ? Colors.green : 
                status == 'fair' ? Colors.orange : 
                status == 'bad' ? Colors.red : Colors.grey;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}

Widget _buildStatusBadge(String status) {
  final color = status == 'good' ? Colors.green : status == 'fair' ? Colors.orange : Colors.red;
  final icon = status == 'good' ? Icons.check_circle : status == 'fair' ? Icons.warning : Icons.error;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    ),
  );
}
```

---

### Section 5: Clinician Performance

#### Clinician Activity Table
```dart
ChartCard(
  title: 'Clinician Performance & Activity',
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: [
        DataColumn(label: Text('Clinician')),
        DataColumn(label: Text('Facility')),
        DataColumn(label: Text('Patients')),
        DataColumn(label: Text('High-Risk')),
        DataColumn(label: Text('Appointments')),
        DataColumn(label: Text('Last Active')),
        DataColumn(label: Text('Status')),
      ],
      rows: _clinicians.map((c) => DataRow(
        onSelectChanged: (_) => _viewClinicianDetails(c['id']),
        cells: [
          DataCell(Text(c['name'])),
          DataCell(Text(c['facility'])),
          DataCell(_buildCell('${c['patients']}', 'neutral')),
          DataCell(_buildCell('${c['highRisk']}', c['highRisk'] > 5 ? 'fair' : 'good')),
          DataCell(_buildCell('${c['appointments']}', 'neutral')),
          DataCell(Text(c['lastActive'])),
          DataCell(_buildActivityBadge(c['status'], c['daysSinceActive'])),
        ],
      )).toList(),
    ),
  ),
)

Widget _buildActivityBadge(String status, int daysSinceActive) {
  Color color;
  String label;
  
  if (daysSinceActive == 0) {
    color = Colors.green;
    label = 'Active Today';
  } else if (daysSinceActive <= 7) {
    color = Colors.green;
    label = 'Active';
  } else if (daysSinceActive <= 30) {
    color = Colors.orange;
    label = 'Inactive $daysSinceActive days';
  } else {
    color = Colors.red;
    label = 'Inactive $daysSinceActive days';
  }
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}
```

---

### Section 6: Risk Distribution

```dart
ChartCard(
  title: 'Risk Level Distribution',
  child: SizedBox(
    height: 300,
    child: PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: _lowRiskCount.toDouble(),
            color: Colors.green,
            title: 'Low Risk\n${_lowRiskPercent.toStringAsFixed(0)}%',
            titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: _moderateRiskCount.toDouble(),
            color: Colors.yellow,
            title: 'Moderate\n${_moderateRiskPercent.toStringAsFixed(0)}%',
            titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          PieChartSectionData(
            value: _highRiskCount.toDouble(),
            color: Colors.orange,
            title: 'High Risk\n${_highRiskPercent.toStringAsFixed(0)}%',
            titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: _criticalCount.toDouble(),
            color: Colors.red,
            title: 'Critical\n${_criticalPercent.toStringAsFixed(0)}%',
            titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    ),
  ),
)
```

---

### Section 7: Trends

```dart
Row(
  children: [
    Expanded(
      child: ChartCard(
        title: 'Monthly Registration (6 months)',
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: _registrationSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    Expanded(
      child: ChartCard(
        title: 'ANC Compliance Trend (6 months)',
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: _attendanceSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: _complianceSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
)
```

---

### Section 8: System Health

```dart
ChartCard(
  title: 'System Health Status',
  child: Column(
    children: [
      _buildHealthIndicator(
        'Clinician Activity',
        _clinicianActivityStatus,
        _clinicianActivityMessage,
      ),
      Divider(),
      _buildHealthIndicator(
        'Data Quality',
        _dataQualityStatus,
        _dataQualityMessage,
      ),
      Divider(),
      _buildHealthIndicator(
        'Facility Status',
        _facilityStatus,
        _facilityMessage,
      ),
      Divider(),
      _buildHealthIndicator(
        'Alert Response Time',
        _alertResponseStatus,
        _alertResponseMessage,
      ),
    ],
  ),
)

Widget _buildHealthIndicator(String label, String status, String message) {
  final color = status == 'good' ? Colors.green : status == 'fair' ? Colors.orange : Colors.red;
  final icon = status == 'good' ? Icons.check_circle : status == 'fair' ? Icons.warning : Icons.error;
  
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(message, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    ),
  );
}
```

---

## Backend Changes Required

### Update Analytics Service
Add district filtering to all methods:

```typescript
// Before
async getOverview() {
  const totalPrenatal = await this.prenatalRepo.count();
  // ...
}

// After
async getOverview(district?: string) {
  const where = district ? { district } : {};
  const totalPrenatal = await this.prenatalRepo.count({ where });
  // ...
}
```

### Update Analytics Controller
Add district parameter to endpoints:

```typescript
@Get('overview')
getOverview(@Query('district') district?: string) {
  return this.service.getOverview(district);
}

@Get('facilities')
getFacilities(@Query('district') district?: string) {
  return this.service.getFacilities(district);
}

@Get('clinicians')
getClinicians(@Query('district') district?: string) {
  return this.service.getClinicians(district);
}
```

---

## Testing Checklist

- [ ] All metrics are district-specific
- [ ] Facility scorecard displays correctly
- [ ] Clinician activity table shows correct status
- [ ] Risk distribution pie chart labels are clear
- [ ] Trend charts display data correctly
- [ ] System health status updates
- [ ] All cards are clickable and navigate correctly
- [ ] Dashboard is responsive on mobile
- [ ] Data updates in real-time (polling works)
- [ ] No console errors
- [ ] DHO can only see their own district data

---

## Files to Modify

1. `lib/web/dho/dho_overview.dart` - Update main DHO dashboard
2. `lib/web/shared/widgets/kpi_card.dart` - Add new features
3. `backend/backend/src/analytics/analytics.service.ts` - Add district filtering
4. `backend/backend/src/analytics/analytics.controller.ts` - Add district parameter

---

## Estimated Timeline

- **Phase 1** (1 day): Update KPI cards and layout
- **Phase 2** (1 day): Create facility and clinician tables
- **Phase 3** (0.5 day): Add district filtering to backend
- **Phase 4** (0.5 day): Testing and refinement

**Total**: 3 days

---

## Success Criteria

✅ All metrics are district-specific
✅ Facility performance is visible and actionable
✅ Clinician activity is tracked and visible
✅ Every metric has a clear label
✅ Trends and comparisons are shown
✅ Dashboard drives district-level decisions
✅ No empty visualizations
✅ Color-coded status indicators
✅ Responsive design works on all screen sizes
✅ Real-time data updates
✅ DHO feedback is positive

---

**Status**: Ready for implementation
**Priority**: High
**Owner**: Frontend team
