# AAS App Theme System

This directory contains the complete theme system for the All Africa Supplies (AAS) Flutter application.

## Color Palette

The app uses a carefully selected color palette:

- **Jet** (`#3D3C40`) - Primary dark color for text and surfaces
- **Timberwolf** (`#D2D2D2`) - Neutral gray for backgrounds and surfaces
- **Red CMYK** (`#DE2820`) - Primary accent color for brand elements
- **Orange Crayola** (`#E57136`) - Secondary accent color for highlights

## File Structure

```
lib/core/theme/
├── app_colors.dart          # Color definitions and palette
├── app_theme.dart           # Material 3 theme configuration
├── status_colors.dart       # Status and stage-specific colors
├── theme_extension.dart     # Context extensions for easy access
├── index.dart              # Export file for easy importing
└── README.md               # This documentation
```

## Usage

### Basic Import

```dart
import 'package:aas_app/core/theme/index.dart';
```

### Using Colors

```dart
// Direct color access
Container(
  color: AppColors.primary,
  child: Text('Hello World'),
)

// Using context extensions
Container(
  color: context.primary,
  child: Text('Hello World'),
)
```

### Using Themes

```dart
// In your MaterialApp
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  // ... other properties
)
```

### Status Colors

```dart
// Get status color
Color statusColor = StatusColors.getOrderStatusColor('in_progress');

// Create status badge
Widget badge = StatusColors.createStatusBadge(
  status: 'in_progress',
  label: 'In Progress',
);

// Create status chip
Widget chip = StatusColors.createStatusChip(
  status: 'approved',
  label: 'Approved',
  onTap: () => print('Status tapped'),
);
```

### Context Extensions

```dart
// Color access
Container(
  color: context.primary,
  child: Text('Primary color'),
)

// Text styles
Text(
  'Headline',
  style: context.headlineLarge,
)

// Spacing
Container(
  padding: EdgeInsets.all(context.spacing16),
  margin: EdgeInsets.all(context.spacing8),
)

// Responsive design
if (context.isLargeScreen) {
  // Show desktop layout
} else {
  // Show mobile layout
}

// Common widgets
context.showSnackBar('Message');
context.showErrorSnackBar('Error message');
context.showSuccessSnackBar('Success message');

// Decorations
Container(
  decoration: context.cardDecoration,
  child: Text('Card content'),
)
```

## Color System

### Semantic Colors

- **Primary**: Red CMYK - Main brand color
- **Secondary**: Orange Crayola - Supporting brand color
- **Surface**: Timberwolf - Background surfaces
- **Background**: Timberwolf - App background
- **Error**: Red CMYK - Error states
- **Success**: Green - Success states
- **Warning**: Orange Crayola - Warning states
- **Info**: Blue - Information states

### Status Colors

Each order status and stage has its own color:

- **Draft**: Gray
- **In Progress**: Blue
- **Waiting Approval**: Orange
- **Approved**: Green
- **In Production**: Orange
- **Complete**: Green
- **Cancelled**: Red

### Stage Colors

Each pipeline stage has its own color:

- **Order Captured**: Blue
- **Wash Bay**: Cyan
- **Assessment**: Orange
- **Quotation**: Orange
- **Approval**: Orange
- **Job Commence**: Red
- **Paint**: Orange
- **Dispatch**: Green

## Material 3 Integration

The theme system is built on Material 3 design principles:

- **Color Scheme**: Complete light and dark color schemes
- **Typography**: Material 3 text styles
- **Component Themes**: All Material components themed
- **Elevation**: Proper shadow and elevation system
- **Responsive**: Adaptive to different screen sizes

## Best Practices

1. **Use Context Extensions**: Prefer `context.primary` over `AppColors.primary`
2. **Status Colors**: Use `StatusColors` for order-related UI
3. **Responsive Design**: Use responsive extensions for adaptive layouts
4. **Consistent Spacing**: Use spacing extensions for consistent layouts
5. **Theme-Aware**: Always consider both light and dark themes

## Customization

To customize the theme:

1. Modify colors in `app_colors.dart`
2. Update component themes in `app_theme.dart`
3. Add new status colors in `status_colors.dart`
4. Extend context extensions in `theme_extension.dart`

## Accessibility

The color system is designed with accessibility in mind:

- High contrast ratios
- Color-blind friendly palette
- Proper text contrast
- Semantic color usage

## Performance

- Colors are defined as constants for optimal performance
- Theme extensions use getters for lazy evaluation
- No unnecessary widget rebuilds
- Efficient color calculations
