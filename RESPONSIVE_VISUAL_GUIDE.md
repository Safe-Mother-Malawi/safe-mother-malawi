# Responsive Design - Visual Guide

## Dashboard Layouts at Different Screen Sizes

---

## 📱 Mobile (375px - iPhone SE)

### Admin Dashboard
```
┌─────────────────────────────┐
│ ☰  Admin Dashboard          │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐    │
│  │ Total Clinicians    │    │
│  │ 1,234               │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ Total Mothers       │    │
│  │ 5,678               │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ High-Risk Cases     │    │
│  │ 234                 │    │
│  │ 4.1% of total       │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ Active Alerts       │    │
│  │ 12                  │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ Monthly             │    │
│  │ Registrations       │    │
│  │                     │    │
│  │  ╱╲                 │    │
│  │ ╱  ╲╱╲              │    │
│  │╱      ╲             │    │
│  │        ╲╱           │    │
│  │ (150px height)      │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ Risk Distribution   │    │
│  │                     │    │
│  │      ◯◯◯            │    │
│  │    ◯     ◯          │    │
│  │   ◯       ◯         │    │
│  │    ◯     ◯          │    │
│  │      ◯◯◯            │    │
│  │ (150px height)      │    │
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘

Features:
- 1 column layout
- Drawer sidebar (hamburger menu)
- Charts stack vertically
- 12px padding
- Readable text
- No horizontal scroll
```

### DHO Dashboard
```
┌─────────────────────────────┐
│ ☰  DHO Dashboard            │
├─────────────────────────────┤
│ District Name               │
│ On Track ✓                  │
├─────────────────────────────┤
│ CRITICAL STATUS             │
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │ Active Alerts       │    │
│  │ 5                   │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ High-Risk Patients  │    │
│  │ 234                 │    │
│  │ 4.1% of total       │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ Missed Visits       │    │
│  │ 15%                 │    │
│  │ This month          │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ Patients Need       │    │
│  │ Follow-up           │    │
│  │ 89                  │    │
│  │ Poor compliance     │    │
│  └─────────────────────┘    │
│                             │
│ PROGRAM PERFORMANCE         │
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │ Mothers Enrolled    │    │
│  │ 5,678               │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ ANC Attendance      │    │
│  │ 85%                 │    │
│  │ Target: 90%         │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ ANC Compliance      │    │
│  │ 78%                 │    │
│  │ Target: 85%         │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ IVR Usage           │    │
│  │ 1,234               │    │
│  │ Calls this month    │    │
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘

Features:
- 1 column layout
- Stacked header
- 4 KPI cards per section
- Charts stack vertically
- Drawer sidebar
- 12px padding
```

---

## 📱 Tablet (768px - iPad)

### Admin Dashboard
```
┌──────────┬──────────────────────────────┐
│ ☰ Admin  │ Admin Dashboard              │
├──────────┼──────────────────────────────┤
│ Overview │ ┌──────────────┬──────────────┐
│          │ │ Total        │ Total        │
│ System   │ │ Clinicians   │ Mothers      │
│ Users    │ │ 1,234        │ 5,678        │
│          │ └──────────────┴──────────────┘
│ Health   │ ┌──────────────┬──────────────┐
│ Facilities
│          │ │ High-Risk    │ Active       │
│ Audit    │ │ Cases        │ Alerts       │
│ Logs     │ │ 234 (4.1%)   │ 12           │
│          │ └──────────────┴──────────────┘
│ Reports  │
│          │ ┌──────────────────────────────┐
│ Broadcast│ │ Monthly Registrations        │
│ Messages │ │                              │
│          │ │  ╱╲                          │
│          │ │ ╱  ╲╱╲                       │
│          │ │╱      ╲                      │
│          │ │        ╲╱                    │
│          │ │ (180px height)               │
│          │ └──────────────────────────────┘
│          │
│          │ ┌──────────────┬──────────────┐
│          │ │ Risk         │ Appointment  │
│          │ │ Distribution │ Statuses     │
│          │ │              │              │
│          │ │    ◯◯◯       │    ◯◯◯       │
│          │ │  ◯     ◯     │  ◯     ◯     │
│          │ │ ◯       ◯    │ ◯       ◯    │
│          │ │  ◯     ◯     │  ◯     ◯     │
│          │ │    ◯◯◯       │    ◯◯◯       │
│          │ │ (180px)      │ (180px)      │
│          │ └──────────────┴──────────────┘
│          │
└──────────┴──────────────────────────────┘

Features:
- 2 column layout for KPI cards
- Collapsible sidebar (240px expanded)
- Charts stack vertically
- 16px padding
- Readable content
- No horizontal scroll
```

### DHO Dashboard
```
┌──────────┬──────────────────────────────┐
│ ☰ DHO    │ District Name    On Track ✓  │
├──────────┼──────────────────────────────┤
│ Overview │ CRITICAL STATUS              │
│          │ ┌──────────────┬──────────────┐
│ Clinician│ │ Active       │ High-Risk    │
│ Mgmt     │ │ Alerts       │ Patients     │
│          │ │ 5            │ 234 (4.1%)   │
│ Analytics│ └──────────────┴──────────────┘
│          │ ┌──────────────┬──────────────┐
│ Generate │ │ Missed       │ Patients     │
│ Analytics│ │ Visits       │ Need Follow- │
│          │ │ 15%          │ up: 89       │
│ Task     │ └──────────────┴──────────────┘
│ Analytics│
│          │ PROGRAM PERFORMANCE          │
│ Question │ ┌──────────────┬──────────────┐
│ Insights │ │ Mothers      │ ANC          │
│          │ │ Enrolled     │ Attendance   │
│ Reports  │ │ 5,678        │ 85%          │
│          │ └──────────────┴──────────────┘
│ Health   │ ┌──────────────┬──────────────┐
│ Facilities
│          │ │ ANC          │ IVR Usage    │
│          │ │ Compliance   │ 1,234        │
│          │ │ 78%          │ calls        │
│          │ └──────────────┴──────────────┘
│          │
│          │ ┌──────────────────────────────┐
│          │ │ Monthly Registration Trend   │
│          │ │                              │
│          │ │  ╱╲                          │
│          │ │ ╱  ╲╱╲                       │
│          │ │╱      ╲                      │
│          │ │        ╲╱                    │
│          │ │ (180px height)               │
│          │ └──────────────────────────────┘
│          │
│          │ ┌──────────────────────────────┐
│          │ │ Risk Level Distribution      │
│          │ │                              │
│          │ │        ◯◯◯                   │
│          │ │      ◯     ◯                 │
│          │ │     ◯       ◯                │
│          │ │      ◯     ◯                 │
│          │ │        ◯◯◯                   │
│          │ │ (180px height)               │
│          │ └──────────────────────────────┘
│          │
└──────────┴──────────────────────────────┘

Features:
- 2 column layout for KPI cards
- Collapsible sidebar
- Charts stack vertically
- 16px padding
- Readable content
```

---

## 🖥️ Desktop (1200px - Full HD)

### Admin Dashboard
```
┌────────────┬──────────────────────────────────────────┐
│ Logo       │ Admin Dashboard                          │
├────────────┼──────────────────────────────────────────┤
│ Overview   │ ┌──────────┬──────────┬──────────┬──────┐
│            │ │ Total    │ Total    │ High-    │ Active
│ System     │ │ Clinics  │ Mothers  │ Risk     │ Alerts
│ Users      │ │ 1,234    │ 5,678    │ 234      │ 12
│            │ │          │          │ (4.1%)   │
│ Health     │ └──────────┴──────────┴──────────┴──────┘
│ Facilities │
│            │ ┌──────────────────────────────────────────┐
│ Audit      │ │ Monthly Registrations                    │
│ Logs       │ │                                          │
│            │ │  ╱╲                                      │
│ Reports    │ │ ╱  ╲╱╲                                   │
│            │ │╱      ╲                                  │
│ Broadcast  │ │        ╲╱                                │
│ Messages   │ │ (200px height)                           │
│            │ └──────────────────────────────────────────┘
│            │
│            │ ┌──────────────────────┬──────────────────┐
│            │ │ Risk Distribution    │ Appointment      │
│            │ │                      │ Statuses         │
│            │ │      ◯◯◯             │      ◯◯◯         │
│            │ │    ◯     ◯           │    ◯     ◯       │
│            │ │   ◯       ◯          │   ◯       ◯      │
│            │ │    ◯     ◯           │    ◯     ◯       │
│            │ │      ◯◯◯             │      ◯◯◯         │
│            │ │ (200px)              │ (200px)          │
│            │ └──────────────────────┴──────────────────┘
│            │
└────────────┴──────────────────────────────────────────┘

Features:
- 3 column layout for KPI cards
- Full sidebar (280px)
- Charts side-by-side
- 20px padding
- Professional appearance
- Optimal spacing
```

### DHO Dashboard
```
┌────────────┬──────────────────────────────────────────┐
│ Logo       │ District Name              On Track ✓    │
├────────────┼──────────────────────────────────────────┤
│ Overview   │ CRITICAL STATUS                          │
│            │ ┌──────────┬──────────┬──────────┬──────┐
│ Clinician  │ │ Active   │ High-    │ Missed   │ Patients
│ Mgmt       │ │ Alerts   │ Risk     │ Visits   │ Need
│            │ │ 5        │ Patients │ 15%      │ Follow-up
│ Analytics  │ │          │ 234      │          │ 89
│            │ │          │ (4.1%)   │          │
│ Generate   │ └──────────┴──────────┴──────────┴──────┘
│ Analytics  │
│            │ PROGRAM PERFORMANCE                      │
│ Task       │ ┌──────────┬──────────┬──────────┬──────┐
│ Analytics  │ │ Mothers  │ ANC      │ ANC      │ IVR
│            │ │ Enrolled │ Attendance
│ Compliance │ │ 5,678    │ 85%      │ 78%      │ 1,234
│            │ │          │ (Target: │ (Target: │ calls
│ Question   │ │          │ 90%)     │ 85%)     │
│ Insights   │ └──────────┴──────────┴──────────┴──────┘
│            │
│ Reports    │ ┌──────────────────────┬──────────────────┐
│            │ │ Monthly Registration │ Risk Distribution│
│ Health     │ │ Trend                │                  │
│ Facilities │ │                      │      ◯◯◯         │
│            │ │  ╱╲                  │    ◯     ◯       │
│            │ │ ╱  ╲╱╲               │   ◯       ◯      │
│            │ │╱      ╲              │    ◯     ◯       │
│            │ │        ╲╱            │      ◯◯◯         │
│            │ │ (200px)              │ (200px)          │
│            │ └──────────────────────┴──────────────────┘
│            │
│            │ DISTRICT ALERTS & ACTIONS                │
│            │ ┌──────────────────────────────────────────┐
│            │ │ ⚠️  Alert 1: Description                 │
│            │ │ ⚠️  Alert 2: Description                 │
│            │ │ ⚠️  Alert 3: Description                 │
│            │ └──────────────────────────────────────────┘
│            │
└────────────┴──────────────────────────────────────────┘

Features:
- 3 column layout for KPI cards
- Full sidebar (280px)
- Charts side-by-side
- 20px padding
- Professional appearance
- Optimal spacing
```

---

## 🖥️ Large Desktop (1920px - 4K)

### Admin Dashboard
```
┌────────────┬────────────────────────────────────────────────────────────┐
│ Logo       │ Admin Dashboard                                            │
├────────────┼────────────────────────────────────────────────────────────┤
│ Overview   │ ┌──────────┬──────────┬──────────┬──────────┬──────────┐   │
│            │ │ Total    │ Total    │ High-    │ Active   │ ANC      │   │
│ System     │ │ Clinics  │ Mothers  │ Risk     │ Alerts   │ Appts    │   │
│ Users      │ │ 1,234    │ 5,678    │ 234      │ 12       │ 890      │   │
│            │ │          │          │ (4.1%)   │          │          │   │
│ Health     │ └──────────┴──────────┴──────────┴──────────┴──────────┘   │
│ Facilities │
│            │ ┌──────────────────────────────────────────────────────────┐
│ Audit      │ │ Monthly Registrations                                    │
│ Logs       │ │                                                          │
│            │ │  ╱╲                                                      │
│ Reports    │ │ ╱  ╲╱╲                                                   │
│            │ │╱      ╲                                                  │
│ Broadcast  │ │        ╲╱                                                │
│ Messages   │ │ (220px height)                                           │
│            │ └──────────────────────────────────────────────────────────┘
│            │
│            │ ┌──────────────────────┬──────────────────┬──────────────┐
│            │ │ Risk Distribution    │ Appointment      │ Clinician    │
│            │ │                      │ Statuses         │ Activity     │
│            │ │      ◯◯◯             │      ◯◯◯         │      ◯◯◯     │
│            │ │    ◯     ◯           │    ◯     ◯       │    ◯     ◯   │
│            │ │   ◯       ◯          │   ◯       ◯      │   ◯       ◯  │
│            │ │    ◯     ◯           │    ◯     ◯       │    ◯     ◯   │
│            │ │      ◯◯◯             │      ◯◯◯         │      ◯◯◯     │
│            │ │ (220px)              │ (220px)          │ (220px)      │
│            │ └──────────────────────┴──────────────────┴──────────────┘
│            │
└────────────┴────────────────────────────────────────────────────────────┘

Features:
- 4 column layout for KPI cards
- Full sidebar (280px)
- Maximum content width (1400px)
- Charts side-by-side
- 28px padding
- Generous spacing
- Professional appearance
```

---

## 📊 Responsive Behavior Summary

### KPI Cards
```
Mobile (1 col):    Tablet (2 col):    Desktop (3 col):   Large (4 col):
┌─────────┐        ┌────┬────┐       ┌────┬────┬────┐   ┌────┬────┬────┬────┐
│ Card 1  │        │ C1 │ C2 │       │ C1 │ C2 │ C3 │   │ C1 │ C2 │ C3 │ C4 │
├─────────┤        ├────┼────┤       ├────┼────┼────┤   └────┴────┴────┴────┘
│ Card 2  │        │ C3 │ C4 │       │ C4 │    │    │
├─────────┤        └────┴────┘       └────┴────┴────┘
│ Card 3  │
├─────────┤
│ Card 4  │
└─────────┘
```

### Charts
```
Mobile:            Tablet:            Desktop:           Large:
┌─────────┐        ┌─────────┐        ┌────────┬────────┐ ┌────────┬────────┐
│ Chart 1 │        │ Chart 1 │        │ Chart1 │ Chart2 │ │ Chart1 │ Chart2 │
├─────────┤        ├─────────┤        ├────────┼────────┤ ├────────┼────────┤
│ Chart 2 │        │ Chart 2 │        │ Chart3 │ Chart4 │ │ Chart3 │ Chart4 │
├─────────┤        ├─────────┤        └────────┴────────┘ └────────┴────────┘
│ Chart 3 │        │ Chart 3 │
├─────────┤        ├─────────┤
│ Chart 4 │        │ Chart 4 │
└─────────┘        └─────────┘
```

### Sidebar
```
Mobile:            Tablet:            Desktop:
┌─────────┐        ┌──┬──────────┐    ┌────────┬──────────┐
│ ☰ Menu  │        │☰ │ Content  │    │ Sidebar│ Content  │
├─────────┤        ├──┼──────────┤    ├────────┼──────────┤
│ Content │        │  │          │    │ Nav    │          │
│         │        │  │          │    │ Items  │          │
│         │        │  │          │    │        │          │
└─────────┘        └──┴──────────┘    └────────┴──────────┘
Drawer             Collapsible        Full Width
```

---

## 🎯 Key Responsive Features

### 1. Adaptive Grid
- Mobile: 1 column
- Tablet: 2 columns
- Desktop: 3 columns
- Large: 4 columns

### 2. Stacking Charts
- Mobile/Tablet: Stack vertically
- Desktop: Side-by-side

### 3. Responsive Sidebar
- Mobile: Drawer (hamburger menu)
- Tablet: Collapsible (240px/70px)
- Desktop: Full width (280px)

### 4. Responsive Padding
- Mobile: 12px
- Tablet: 16px
- Desktop: 20px
- Large: 28px

### 5. Responsive Font Sizes
- Mobile: 85% of base
- Tablet: 90% of base
- Desktop: 95% of base
- Large: 100% of base

---

## ✨ Summary

The responsive design ensures optimal viewing experience across all devices:

✅ **Mobile** - Single column, drawer navigation, optimized for touch
✅ **Tablet** - Two columns, collapsible sidebar, readable content
✅ **Desktop** - Three columns, full sidebar, professional appearance
✅ **Large Desktop** - Four columns, maximum efficiency, generous spacing

All dashboards adapt seamlessly to any screen size!
