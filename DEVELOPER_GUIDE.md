# Avanti E-Learning App - Quick Developer Reference

## 🎨 **Theme Usage**

### Import Theme
```dart
import '../../../core/theme/app_theme.dart';
```

### Common Colors
```dart
AppColors.primary          // #4F46E5 - Main brand color
AppColors.secondary        // #06B6D4 - Accent color  
AppColors.success          // #10B981 - Success states
AppColors.background       // #FAFAFA - App background
AppColors.surface          // #FFFFFF - Card backgrounds
AppColors.textPrimary      // #1F2937 - Main text
AppColors.textSecondary    // #6B7280 - Secondary text
```

### Typography Styles
```dart
AppTextStyles.h1           // 32px Bold - Page titles
AppTextStyles.h2           // 28px Bold - Section headers  
AppTextStyles.h3           // 24px SemiBold - Subsections
AppTextStyles.h4           // 20px SemiBold - Card titles
AppTextStyles.bodyLarge    // 18px Normal - Important content
AppTextStyles.bodyMedium   // 16px Normal - Standard content
AppTextStyles.bodySmall    // 14px Normal - Secondary content
AppTextStyles.labelLarge   // 16px Medium - Button text
AppTextStyles.caption      // 12px Normal - Small text
```

### Spacing
```dart
AppSpacing.xs     // 4px
AppSpacing.sm     // 8px  
AppSpacing.md     // 16px
AppSpacing.lg     // 24px
AppSpacing.xl     // 32px
AppSpacing.xxl    // 48px
```

### Border Radius
```dart
AppRadius.sm       // 8px
AppRadius.md       // 12px
AppRadius.lg       // 16px
AppRadius.xl       // 24px
AppRadius.circular // 50px
```

### Shadows
```dart
AppShadows.soft    // Subtle shadow for cards
AppShadows.medium  // Standard elevation
AppShadows.strong  // High emphasis elements
```

## 🧩 **Custom Widgets**

### Import Widgets
```dart
import '../../../shared/widgets/custom_widgets.dart';
```

### CourseCard
```dart
CourseCard(
  title: 'Course Title',
  instructor: 'Instructor Name',
  duration: '4h 30m',
  progress: 0.65, // 0.0 to 1.0
  imageUrl: '', // Placeholder for now
  onTap: () => navigateToCourse(),
  isFeatured: false, // Optional highlighting
)
```

### FeatureCard  
```dart
FeatureCard(
  title: 'Feature Name',
  subtitle: 'Feature description',
  icon: Icons.school,
  color: AppColors.primary, // Optional custom color
  onTap: () => navigateToFeature(),
)
```

### ProgressCard
```dart
ProgressCard(
  title: 'Progress Title',
  subtitle: 'Progress description',
  progress: 0.75, // 0.0 to 1.0
  progressText: '75%',
  icon: Icons.emoji_events,
)
```

### CategoryChip
```dart
CategoryChip(
  label: 'Category Name',
  isSelected: false,
  onTap: () => selectCategory(),
)
```

### CustomSearchBar
```dart
CustomSearchBar(
  hintText: 'Search placeholder...',
  controller: searchController, // Optional
  onChanged: (query) => handleSearch(query), // Optional
  onTap: () => openSearchPage(), // Optional
)
```

## 📱 **Layout Patterns**

### Standard Page Structure
```dart
Scaffold(
  body: SafeArea(
    child: CustomScrollView(
      slivers: [
        // Header content
        SliverToBoxAdapter(child: headerWidget),
        
        // Main content  
        SliverToBoxAdapter(child: contentWidget),
        
        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xl),
        ),
      ],
    ),
  ),
)
```

### Card Container
```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    boxShadow: const [AppShadows.soft],
  ),
  child: content,
)
```

### Gradient Container
```dart
Container(
  decoration: const BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
  child: content,
)
```

## 🎯 **Common Patterns**

### Section Header with Action
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Section Title', style: AppTextStyles.h4),
    TextButton(
      onPressed: () => viewAll(),
      child: const Text('View All'),
    ),
  ],
)
```

### Horizontal Scrolling List
```dart
SizedBox(
  height: 200, // Fixed height
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: [
      // List items
    ],
  ),
)
```

### Grid Layout
```dart
GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: 2,
  crossAxisSpacing: AppSpacing.md,
  mainAxisSpacing: AppSpacing.md,
  childAspectRatio: 1.2,
  children: [
    // Grid items
  ],
)
```

## 📋 **File Locations**

- **Theme**: `lib/core/theme/app_theme.dart`
- **Widgets**: `lib/shared/widgets/custom_widgets.dart`  
- **Home Screen**: `lib/features/home/screens/home_screen.dart`
- **Auth Screen**: `lib/features/auth/screens/auth_screen.dart`
- **Main App**: `lib/main.dart`

## 🔧 **Quick Tips**

1. **Always use AppColors**: Don't hardcode color values
2. **Consistent Spacing**: Use AppSpacing constants
3. **Text Styles**: Use AppTextStyles for consistency
4. **Shadows**: Use AppShadows for depth
5. **Import Order**: Theme first, then widgets
6. **Widget Keys**: Add keys for testing
7. **Const Constructors**: Use const where possible

## 🚨 **Common Mistakes to Avoid**

- ❌ Hardcoding colors: `Color(0xFF123456)`
- ✅ Use theme colors: `AppColors.primary`

- ❌ Arbitrary spacing: `SizedBox(height: 15)`
- ✅ Use spacing system: `SizedBox(height: AppSpacing.md)`

- ❌ Inline text styles: `TextStyle(fontSize: 16)`
- ✅ Use text styles: `AppTextStyles.bodyMedium`

- ❌ No shadows on cards: `elevation: 0`
- ✅ Use shadow system: `boxShadow: [AppShadows.soft]`

---

**Need help?** Check the full `DESIGN_SYSTEM.md` for detailed documentation.
