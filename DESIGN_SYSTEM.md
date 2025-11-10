# Avanti E-Learning App - Design System Documentation

## 📱 **Project Overview**
Avanti is a modern e-learning mobile application built with Flutter, featuring a clean and professional design system optimized for educational content delivery and user engagement.

## 🎨 **Design Philosophy**
- **Modern & Clean**: Material 3 design with custom styling
- **Educational Focus**: UI optimized for learning experiences
- **User-Centric**: Intuitive navigation and clear visual hierarchy
- **Professional**: Corporate-ready design suitable for educational institutions
- **Accessible**: High contrast ratios and readable typography

## 🎯 **Target Audience**
- Students and learners of all ages
- Educational institutions
- Corporate training programs
- Online course platforms

---

## 🎨 **Color System**

### **Primary Colors**
```dart
- Primary: #4F46E5 (Indigo) - Main brand color, buttons, links
- Primary Light: #6366F1 - Hover states, secondary accents
- Primary Dark: #3730A3 - Active states, pressed buttons
```

### **Secondary Colors**
```dart
- Secondary: #06B6D4 (Cyan) - Progress indicators, highlights
- Secondary Light: #22D3EE - Success states, completion badges
- Secondary Dark: #0891B2 - Active secondary elements
```

### **Status Colors**
```dart
- Success: #10B981 (Emerald) - Completed courses, achievements
- Success Light: #34D399 - Progress completion
- Warning: #F59E0B (Amber) - Pending items, notifications
- Error: #EF4444 (Red) - Error states, failed operations
```

### **Neutral Colors**
```dart
- Background: #FAFAFA - Main app background
- Surface: #FFFFFF - Card backgrounds, elevated surfaces
- Surface Variant: #F5F5F5 - Input fields, disabled states
- Text Primary: #1F2937 - Main text content
- Text Secondary: #6B7280 - Secondary information
- Text Tertiary: #9CA3AF - Captions, metadata
```

### **Gradients**
- **Primary Gradient**: Primary → Primary Light (top-left to bottom-right)
- **Secondary Gradient**: Secondary → Secondary Light
- **Success Gradient**: Success → Success Light

---

## 📐 **Typography System**

### **Headings**
- **H1**: 32px, Bold - Page titles, main headings
- **H2**: 28px, Bold - Section headers
- **H3**: 24px, SemiBold - Subsection titles
- **H4**: 20px, SemiBold - Card titles, feature headers

### **Body Text**
- **Body Large**: 18px, Normal - Important content
- **Body Medium**: 16px, Normal - Standard content
- **Body Small**: 14px, Normal - Secondary content

### **Labels & UI**
- **Label Large**: 16px, Medium - Button text, form labels
- **Label Medium**: 14px, Medium - Small buttons, chips
- **Caption**: 12px, Normal - Metadata, timestamps

### **Font Weights**
- Normal: 400
- Medium: 500
- SemiBold: 600
- Bold: 700

---

## 📏 **Spacing System**

```dart
- XS: 4px - Tight spacing, icon gaps
- SM: 8px - Small margins, button padding
- MD: 16px - Standard spacing, card padding
- LG: 24px - Section spacing, large margins
- XL: 32px - Page margins, major sections
- XXL: 48px - Hero sections, large separations
```

---

## 🔲 **Border Radius System**

```dart
- SM: 8px - Small elements, chips
- MD: 12px - Cards, buttons, inputs
- LG: 16px - Large cards, modals
- XL: 24px - Hero elements
- Circular: 50px - Fully rounded elements
```

---

## 🌟 **Shadow System**

### **Soft Shadow** (Subtle depth)
```dart
- Color: rgba(0,0,0,0.06)
- Blur: 8px
- Offset: (0, 2px)
- Usage: Cards, small elevations
```

### **Medium Shadow** (Standard depth)
```dart
- Color: rgba(0,0,0,0.08)
- Blur: 16px
- Offset: (0, 4px)
- Usage: Floating elements, modals
```

### **Strong Shadow** (High emphasis)
```dart
- Color: rgba(0,0,0,0.10)
- Blur: 24px
- Offset: (0, 8px)
- Usage: Hero elements, important CTAs
```

---

## 🧩 **Component Library**

### **1. CourseCard**
**Purpose**: Display course information with progress tracking
**Key Features**:
- Course thumbnail placeholder with play icon
- Title, instructor, and duration
- Progress bar with percentage
- Featured state highlighting
- Tap interaction

**Usage**:
```dart
CourseCard(
  title: 'Flutter Development Basics',
  instructor: 'John Doe',
  duration: '4h 30m',
  progress: 0.65,
  imageUrl: '',
  onTap: () => navigateToCourse(),
  isFeatured: true,
)
```

### **2. FeatureCard**
**Purpose**: Quick action buttons with gradient backgrounds
**Key Features**:
- Gradient background with custom colors
- Icon with semi-transparent background
- Title and subtitle text
- Tap interaction with feedback

**Usage**:
```dart
FeatureCard(
  title: 'My Courses',
  subtitle: 'View all enrolled courses',
  icon: Icons.school,
  color: AppColors.primary,
  onTap: () => navigateToMyCourses(),
)
```

### **3. ProgressCard**
**Purpose**: Display learning progress and achievements
**Key Features**:
- Icon with gradient background
- Title and description
- Progress bar with percentage
- Horizontal layout

**Usage**:
```dart
ProgressCard(
  title: 'Weekly Learning Goal',
  subtitle: '4 of 7 days completed this week',
  progress: 0.57,
  progressText: '57%',
  icon: Icons.emoji_events,
)
```

### **4. CategoryChip**
**Purpose**: Filter categories with selection states
**Key Features**:
- Selected/unselected states
- Rounded pill design
- Color changes based on state
- Tap interaction

**Usage**:
```dart
CategoryChip(
  label: 'Programming',
  isSelected: false,
  onTap: () => filterByCategory('programming'),
)
```

### **5. CustomSearchBar**
**Purpose**: Search interface for courses and content
**Key Features**:
- Rounded design with search icon
- Placeholder text
- Tap and text input handling
- Subtle shadow elevation

**Usage**:
```dart
CustomSearchBar(
  hintText: 'Search courses, topics...',
  onTap: () => openSearchPage(),
  onChanged: (query) => performSearch(query),
)
```

---

## 📱 **Screen Architecture**

### **Home Screen Layout**
1. **Header Section** (Gradient background)
   - Welcome message with user name
   - Notification and logout buttons
   - Search bar

2. **Progress Section**
   - Weekly learning goal card
   - Achievement progress

3. **Categories Section**
   - Horizontal scrolling category chips
   - Filter functionality

4. **Continue Learning Section**
   - Horizontal scrolling course cards
   - Featured course highlighting
   - "View All" navigation

5. **Quick Actions Section**
   - 2x2 grid of feature cards
   - Color-coded actions
   - Navigation to main features

---

## 🎯 **UI Patterns & Best Practices**

### **Cards**
- Always use subtle shadows for depth
- Consistent padding (16px standard)
- Rounded corners (12px for standard cards)
- White background on light theme

### **Buttons**
- Primary: Gradient or solid primary color
- Secondary: Outline with primary color
- Text: Primary color, no background
- Consistent padding: 16px horizontal, 12px vertical

### **Typography Hierarchy**
- Use consistent text styles from the system
- Maintain proper contrast ratios
- Limit to 3-4 text sizes per screen
- Use color to create hierarchy

### **Spacing**
- Use the defined spacing system
- Consistent margins and padding
- Avoid arbitrary spacing values
- Group related elements with appropriate spacing

### **Colors**
- Primary color for main actions and highlights
- Secondary color for progress and success states
- Neutral colors for content and backgrounds
- Status colors for feedback and states

---

## 🔧 **Technical Implementation**

### **Theme Configuration**
- Located in: `lib/core/theme/app_theme.dart`
- Uses Material 3 design system
- Custom color scheme implementation
- Consistent component theming

### **Widget Organization**
- Reusable components in: `lib/shared/widgets/custom_widgets.dart`
- Screen-specific widgets within feature folders
- Clear separation of concerns

### **File Structure**
```
lib/
├── core/
│   ├── config/          # App configuration
│   └── theme/           # Theme and styling
├── features/
│   ├── auth/            # Authentication
│   ├── home/            # Home dashboard
│   └── profile/         # User profile and settings
├── shared/
│   ├── navigation/      # App navigation
│   └── widgets/         # Reusable components
└── main.dart           # App entry point
```

---

## 🚀 **Future Enhancements**

### **Planned Features**
1. **Dark Theme Support**
   - Dark color variants
   - Theme switching capability
   - Proper contrast adjustments

2. **Animation System**
   - Page transitions
   - Loading animations
   - Micro-interactions

3. **Responsive Design**
   - Tablet layouts
   - Desktop adaptations
   - Breakpoint system

4. **Accessibility**
   - Screen reader support
   - High contrast mode
   - Font scaling support

### **Component Extensions**
- Video player component
- Quiz/assessment widgets
- Discussion forum UI
- Notification system
- Profile management UI

---

## 📋 **Development Guidelines**

### **When Adding New Components**
1. Follow the established color system
2. Use consistent spacing values
3. Implement proper hover/focus states
4. Add documentation and usage examples
5. Test on different screen sizes

### **Code Standards**
- Use the defined text styles
- Follow Flutter widget naming conventions
- Implement proper error handling
- Add accessibility labels
- Use const constructors where possible

### **Testing Checklist**
- [ ] Component renders correctly
- [ ] Interactions work as expected
- [ ] Colors match design system
- [ ] Typography is consistent
- [ ] Spacing follows guidelines
- [ ] Accessibility features work

---

## 📞 **Resources & References**

### **Design Inspiration**
- Material Design 3 Guidelines
- Modern e-learning platforms (Coursera, Udemy)
- Educational app design patterns

### **Flutter Documentation**
- [Material 3 Theme Builder](https://m3.material.io/theme-builder)
- [Flutter Theming Guide](https://docs.flutter.dev/cookbook/design/themes)
- [Accessibility Guidelines](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

---

**Last Updated**: October 12, 2025
**Design System Version**: 1.0.0
**Flutter Version**: Latest Stable

This documentation should be updated whenever design changes are made to maintain consistency across the development team.
