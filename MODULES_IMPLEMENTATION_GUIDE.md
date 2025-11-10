# Module Management Implementation Guide

## Overview
This guide explains how the Module management system is integrated into your Avanti Mobile app. Modules are containers that hold courses, allowing for better course organization.

---

## Database Setup (Supabase)

### Step 1: Create Tables
Run the SQL commands from `MODULES_SQL_SETUP.sql` in your Supabase SQL Editor.

This creates:
- **`modules` table**: Stores module information
- **`module_courses` table**: Junction table for many-to-many relationship between modules and courses

### Step 2: Key Schema Details

#### Modules Table
```sql
CREATE TABLE modules (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  course_id UUID NOT NULL (REFERENCES courses),
  "order" INTEGER DEFAULT 0,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

#### Module Courses Junction Table
```sql
CREATE TABLE module_courses (
  id UUID PRIMARY KEY,
  module_id UUID NOT NULL (REFERENCES modules),
  course_id UUID NOT NULL (REFERENCES courses),
  created_at TIMESTAMP,
  UNIQUE(module_id, course_id)
);
```

---

## Dart Implementation

### 1. Models (`lib/features/course/models/`)

#### Module Model (`module.dart`)
- **Module class**: Represents a module with courses
- **ModuleInput class**: For creating/updating modules

Key fields:
- `id`: Unique identifier
- `title`: Module name
- `courseId`: Parent course reference
- `courses`: List of Course objects
- `order`: Sequence number

#### Course Model (already exists)
- No changes needed - works with modules as-is

### 2. Services (`lib/features/course/services/`)

#### ModuleService (`module_service.dart`)
Main methods:
- `list()`: Get all modules
- `listByCourse(courseId)`: Get modules for a specific course
- `getById(id)`: Get module by ID
- `create()`: Create new module
- `update()`: Update module
- `delete()`: Delete module
- `addCourseToModule()`: Add a course to module
- `removeCourseFromModule()`: Remove a course from module
- `getCoursesInModule()`: Get all courses in a module

### 3. UI Screens (`lib/features/course/screens/`)

#### ModuleFormScreen (`module_form_screen.dart`)
Form for creating and editing modules with:
- Title field
- Description field
- Order field
- Course selection (checkboxes)
- Save button

### 4. Admin Dashboard Integration

#### AdminDashboardScreen (`lib/features/admin/screens/admin_dashboard_screen.dart`)
Added:
- **Modules Tab**: View all modules
- **Add Module Button**: FAB to create new modules
- **Edit Module**: Click edit icon on any module to modify it
- Integration with ModuleService

---

## How to Use

### Creating a Module

1. Go to Admin Dashboard → **Modules Tab**
2. Click the **+ button** (FAB)
3. Fill in:
   - **Module Title** (required)
   - **Description** (optional)
   - **Order** (optional - for sorting)
   - **Select Courses** (checkbox list)
4. Click **Create Module**

### Editing a Module

1. Go to Admin Dashboard → **Modules Tab**
2. Click **Edit icon** on any module
3. Modify details
4. Adjust course selection
5. Click **Update Module**

### Adding Courses to Modules

In ModuleFormScreen:
- Select/deselect courses from the checkbox list
- Courses will be added to the `module_courses` table

### Backend Relationships

```
Module (1) ──→ (Many) Courses
   ↓
Course (parent)
   ↓
Module ──junction─→ Course (many-to-many)
```

---

## File Structure

```
lib/features/course/
├── models/
│   ├── course.dart
│   ├── module.dart          ← NEW
│   └── index.dart
├── services/
│   ├── course_service.dart
│   └── module_service.dart  ← NEW
└── screens/
    ├── course_form_screen.dart
    ├── course_view_screen.dart
    ├── course_list_screen.dart
    ├── course_recommendation_screen.dart
    └── module_form_screen.dart  ← NEW

lib/features/admin/
└── screens/
    └── admin_dashboard_screen.dart  ← UPDATED (added Modules tab)
```

---

## Database Queries Examples

### Get all modules with their courses
```sql
SELECT 
  m.*,
  json_agg(
    json_build_object(
      'id', c.id,
      'title', c.title,
      'description', c.description
    )
  ) as courses
FROM modules m
LEFT JOIN module_courses mc ON m.id = mc.module_id
LEFT JOIN courses c ON mc.course_id = c.id
GROUP BY m.id;
```

### Get modules by course
```sql
SELECT m.* FROM modules m 
WHERE m.course_id = 'YOUR_COURSE_ID' 
ORDER BY m."order";
```

### Get courses in a module
```sql
SELECT c.* FROM courses c
JOIN module_courses mc ON c.id = mc.course_id
WHERE mc.module_id = 'YOUR_MODULE_ID';
```

---

## Row Level Security (RLS) Policies

- **Modules**: Anyone can read, instructors can manage their course modules
- **Module Courses**: Anyone can read, instructors can manage

These are automatically applied when you run the SQL setup.

---

## Next Steps

1. ✅ Run `MODULES_SQL_SETUP.sql` in Supabase
2. ✅ Review `ModuleService` for additional customization
3. ✅ Test creating modules in Admin Dashboard
4. ✅ Integrate module display in course view screens
5. ✅ Add course enrollment to modules if needed

---

## Common Issues & Solutions

### Issue: "Course not found" error
**Solution**: Ensure your courses exist in the database before creating modules.

### Issue: Modules don't appear in list
**Solution**: Verify the RLS policies are correctly applied. Check Supabase SQL logs.

### Issue: Can't add courses to module
**Solution**: Make sure you're logged in as an instructor/admin and have permission.

---

## Future Enhancements

- Add lesson/content management within modules
- Add module completion tracking
- Module-specific quizzes
- Progress indicators per module
- Module prerequisites
- Reordering modules via drag-and-drop
