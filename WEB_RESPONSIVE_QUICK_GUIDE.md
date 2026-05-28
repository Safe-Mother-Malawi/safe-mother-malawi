# Web Responsive Design - Quick Guide

## What's Fixed

✅ **Admin Overview Dashboard** - Now fully responsive
- Mobile: 1 column, 12px padding
- Tablet: 2 columns, 16px padding
- Desktop: 3-4 columns, 20-28px padding

## How to Use

### Import
```dart
import '../shared/utils/responsive_helper.dart';
```

### Quick Access (Recommended)
```dart
// In any build method
context.isMobile          // true if < 600px
context.isTablet          // true if 600-900px
context.isDesktop         // true if > 900px
context.gridColumns       // 1, 2, 3, or 4
context.responsivePadding // 12, 16, 20, or 28
context.responsiveSpacing // 12, 16, 20, or 28
context.chartHeight       // 150, 180, 200, or 220
context.shouldStackLayout // true for mobile/tablet
```

### Common Patterns

#### 1. Responsive Grid
```dart
GridView.count(
  crossAxisCount: context.gridColumns,
  crossAxisSpacing: context.responsiveSpacing,
  mainAxisSpacing: context.responsiveSpacing,
  childAspectRatio: ResponsiveHelper.getGridAspectRatio(context),
  children: [...]
)
```

#### 2. Responsive Padding
```dart
padding: EdgeInsets.all(context.responsivePadding)
```

#### 3. Stack on Mobile, Side-by-Side on Desktop
```dart
if (context.shouldStackLayout)
  Column(children: [...])
else
  Row(children: [...])
```

#### 4. Responsive Chart Height
```dart
SizedBox(
  height: context.chartHeight,
  child: LineChart(...)
)
```

#### 5. Responsive Side Panel
```dart
SizedBox(
  width: ResponsiveHelper.getSidePanelWidth(context),
  child: ...
)
```

## Breakpoints

| Screen Size | Width | Columns | Padding | Use Case |
|------------|-------|---------|---------|----------|
| Mobile | < 600px | 1 | 12px | Phones |
| Tablet | 600-900px | 2 | 16px | Tablets |
| Desktop | 900-1200px | 3 | 20px | Laptops |
| Large Desktop | > 1200px | 4 | 28px | Large monitors |

## Testing

### Mobile (< 600px)
```
iPhone 12: 390px
iPhone SE: 375px
Pixel 5: 393px
```

### Tablet (600-900px)
```
iPad Mini: 768px
iPad Air: 820px
```

### Desktop (> 900px)
```
Laptop: 1366px+
Desktop: 1920px+
```

## Files to Update

All pages in:
- `lib/web/admin/` - 24 pages
- `lib/web/dho/` - 8 pages

## Example: Before & After

### Before (Not Responsive)
```dart
GridView.count(
  crossAxisCount: 4,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  childAspectRatio: 1.1,
  children: [...]
)

Row(
  children: [
    Expanded(child: ChartCard(...)),
    SizedBox(width: 28),
    Expanded(child: ChartCard(...)),
  ],
)

padding: const EdgeInsets.all(28)
```

### After (Responsive)
```dart
GridView.count(
  crossAxisCount: context.gridColumns,
  crossAxisSpacing: context.responsiveSpacing,
  mainAxisSpacing: context.responsiveSpacing,
  childAspectRatio: ResponsiveHelper.getGridAspectRatio(context),
  children: [...]
)

if (context.shouldStackLayout)
  Column(children: [...])
else
  Row(children: [...])

padding: EdgeInsets.all(context.responsivePadding)
```

## Status

- ✅ Responsive helper created
- ✅ Admin overview fixed
- 🔄 Other pages in progress

## Next Steps

1. Apply to all admin pages
2. Apply to all DHO pages
3. Test on real devices
4. Deploy

## Questions?

Refer to `WEB_RESPONSIVE_DESIGN.md` for detailed documentation.
