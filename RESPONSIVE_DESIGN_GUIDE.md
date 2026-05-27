# Staff Portal Responsive Design Guide

## Overview

The Safe Mother Malawi staff portal is now fully responsive and works seamlessly across all device sizes: mobile phones, tablets, and desktop computers.

## Breakpoints

The responsive design uses three main breakpoints:

| Device Type | Screen Width | Layout |
|-------------|-------------|--------|
| **Mobile** | < 768px | Drawer navigation, full-width content |
| **Tablet** | 768px - 1023px | Collapsible sidebar, adaptive content |
| **Desktop** | ≥ 1024px | Full sidebar, optimized spacing |

## Mobile Layout (< 768px)

### Navigation
- **Drawer Menu**: Hamburger menu button in top-left opens a full-screen drawer
- **Drawer Content**: All navigation items are accessible in the drawer
- **Auto-close**: Drawer automatically closes after navigation
- **Smooth Animation**: Drawer slides in from the left with smooth animation

### Top Navbar
- **Compact Design**: Reduced padding and spacing
- **Responsive Font**: Title font size reduces to 14px on very small screens (< 480px)
- **Button Layout**: 
  - Menu button (hamburger icon)
  - Page title (truncated if needed)
  - Notifications bell
  - Profile icon (avatar only, no text)

### Content Area
- **Full Width**: Content takes up the entire screen width
- **Scrollable**: Content scrolls vertically as needed
- **Touch-Friendly**: Buttons and interactive elements are sized for touch (minimum 44px)

### Dialogs
- **Responsive Sizing**: Dialogs adapt to screen size with 16px margins
- **Full Height**: Dialogs can take up to 70-80% of screen height
- **Scrollable Content**: Long content scrolls within the dialog

## Tablet Layout (768px - 1023px)

### Navigation
- **Collapsible Sidebar**: Sidebar can be toggled between expanded (240px) and collapsed (70px)
- **Toggle Button**: Menu button in navbar toggles sidebar state
- **Persistent State**: Sidebar state persists during navigation
- **Icon Tooltips**: Collapsed sidebar shows tooltips on hover

### Top Navbar
- **Standard Design**: Full navbar with all controls visible
- **Responsive Font**: Title font size is 16px
- **Profile Button**: Shows avatar only (no text) to save space

### Content Area
- **Flexible Width**: Content width adjusts based on sidebar state
- **Smooth Transitions**: Sidebar collapse/expand animates smoothly (300ms)

### Sidebar Features
- **Expanded (240px)**:
  - Full logo and branding
  - Role badge
  - Full navigation labels
  - Grouped sections with expand/collapse
  - Footer text

- **Collapsed (70px)**:
  - Icon-only logo
  - Icon-only navigation items
  - Tooltips on hover
  - No text labels
  - No footer

## Desktop Layout (≥ 1024px)

### Navigation
- **Full Sidebar**: Always visible, never collapses
- **Fixed Width**: 240px sidebar width
- **Full Features**: All navigation items with labels and icons

### Top Navbar
- **Full Design**: All controls visible with full spacing
- **Profile Chip**: Shows avatar + name + role
- **Responsive Font**: Title font size is 18px

### Content Area
- **Optimized Spacing**: Generous padding and margins
- **Multi-column Layouts**: Content can use multiple columns
- **Full Width**: Content uses available space efficiently

## Component Responsiveness

### Sidebar Navigation
```dart
// Mobile: Drawer
Drawer(
  width: 280,
  child: AppSidebar(isMobile: true)
)

// Tablet: Collapsible
AnimatedContainer(
  width: _sidebarOpen ? 240 : 70,
  child: AppSidebar(isCollapsed: !_sidebarOpen)
)

// Desktop: Full
AppSidebar(isMobile: false)
```

### Top Navbar
- **Menu Button**: Visible on mobile/tablet, hidden on desktop
- **Page Title**: Responsive font size (14px → 16px → 18px)
- **Notifications**: Always visible
- **Profile**: Adaptive layout (icon → button → chip)

### Dialogs
- **Notifications Dialog**:
  - Mobile: Full width with 16px margins, 70% height
  - Desktop: 440px width, 560px height
  - Mobile Actions: Buttons at bottom
  - Desktop Actions: Buttons in header

- **Profile Dialog**:
  - Mobile: Full width with 16px margins, 80% height
  - Desktop: 560px width, 680px height

## Navigation Flow

### Mobile Navigation
1. User taps hamburger menu
2. Drawer slides in from left
3. User taps navigation item
4. Drawer automatically closes
5. Page content updates

### Tablet Navigation
1. User taps menu button to toggle sidebar
2. Sidebar animates between expanded/collapsed
3. User taps navigation item
4. Sidebar stays in current state
5. Page content updates

### Desktop Navigation
1. User clicks navigation item in sidebar
2. Page content updates immediately
3. Sidebar remains visible

## Accessibility Features

### Touch Targets
- Minimum 44px × 44px for all interactive elements
- Adequate spacing between buttons (8px minimum)
- Larger touch targets on mobile

### Visual Feedback
- Hover effects on desktop
- Active state highlighting
- Smooth transitions and animations
- Clear visual hierarchy

### Navigation Clarity
- Clear page titles
- Active navigation item highlighting
- Breadcrumb-like page titles
- Consistent navigation structure

### Keyboard Navigation
- All interactive elements are keyboard accessible
- Tab order is logical and intuitive
- Escape key closes dialogs and drawers

## Testing Responsive Design

### Mobile Testing (< 768px)
- [ ] Hamburger menu opens drawer
- [ ] All navigation items are accessible
- [ ] Drawer closes after navigation
- [ ] Page title is readable
- [ ] Notifications bell works
- [ ] Profile button opens dialog
- [ ] Dialogs are readable and usable
- [ ] Content scrolls properly
- [ ] No horizontal scrolling

### Tablet Testing (768px - 1023px)
- [ ] Sidebar toggle button works
- [ ] Sidebar collapses/expands smoothly
- [ ] Navigation items are accessible
- [ ] Collapsed sidebar shows tooltips
- [ ] Page content adjusts width
- [ ] All features are accessible
- [ ] Dialogs are properly sized

### Desktop Testing (≥ 1024px)
- [ ] Sidebar is always visible
- [ ] Full navigation is displayed
- [ ] Profile chip shows all info
- [ ] Dialogs are properly sized
- [ ] Content uses full width
- [ ] All features are accessible

## Common Issues and Solutions

### Issue: Drawer doesn't open on mobile
**Solution**: Ensure `ScaffoldKey` is properly initialized and passed to `Scaffold`

### Issue: Sidebar doesn't collapse on tablet
**Solution**: Check that `_sidebarOpen` state is properly managed in `_AppShellState`

### Issue: Navigation items are cut off
**Solution**: Ensure sidebar has `ListView` with proper scrolling enabled

### Issue: Dialogs overflow on mobile
**Solution**: Use `insetPadding` and `maxHeight` constraints in `Dialog` widget

### Issue: Text is too small on mobile
**Solution**: Use responsive font sizes based on `MediaQuery.of(context).size.width`

## Future Improvements

- [ ] Add landscape orientation support
- [ ] Implement swipe gestures for drawer
- [ ] Add bottom navigation bar for mobile
- [ ] Optimize for very large screens (> 1920px)
- [ ] Add dark mode support
- [ ] Implement adaptive layouts for different content types

## Related Files

- `lib/web/shared/app_shell.dart` - Main responsive layout container
- `lib/web/shared/sidebar.dart` - Navigation sidebar with responsive features
- `lib/web/shared/top_navbar.dart` - Top navigation bar with responsive controls
- `lib/web/shared/widgets/error_boundary.dart` - Error handling wrapper
- `lib/theme/app_colors.dart` - Color scheme and theming

## Support

For issues or questions about the responsive design, please refer to the implementation files or contact the development team.
