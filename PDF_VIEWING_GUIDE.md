# 📄 PDF Viewing in Course Details - Complete Guide

## ✅ What's Been Added

You can now **view PDFs directly from course details screens**!

### **Changes Made:**

1. **Course View Screen** (`course_view_screen.dart`)
   - Added `url_launcher` import
   - Added `_openPdf()` method to open PDFs in browser/app
   - Added PDF section with beautiful UI (red card)
   - Shows "View PDF" button if PDF exists
   - Shows "No PDF available" message if no PDF

2. **Course List Screen** (`course_list_screen.dart`)
   - Added PDF indicator icon (red PDF icon) next to course title
   - Shows only for courses with PDFs
   - Visual indicator that course has content

3. **Dependencies**
   - Already have `url_launcher: ^6.2.5` in pubspec.yaml ✅

---

## 🎯 How It Works

### Course List View
```
Course Title  📄 ← PDF indicator (if PDF exists)
Description
```

Click on course to open details.

### Course Detail View
```
[Course Image]
Course Title
Course Description

┌─────────────────────────────┐
│ 📄 Course PDF Content       │
│                             │
│ [View PDF] [Download]       │
└─────────────────────────────┘

[Quizzes Button]
[Edit Button] (if admin)
```

---

## 🚀 Features

### ✅ View PDF
- Click "View PDF" button
- Opens in browser/app (system default)
- Supports all devices

### ✅ Download PDF
- Click "Download" button
- Can save PDF locally (optional enhancement)

### ✅ No PDF State
- Shows friendly message if course has no PDF
- Doesn't show section if no PDF

### ✅ Admin Editing
- Admins can edit course and change PDF
- Old PDF removed, new PDF uploaded

---

## 📱 UI Components

### Course View - PDF Card (With PDF)
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.red.shade50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.red.shade200),
  ),
  child: [
    Icon: 📄
    Title: "Course PDF Content"
    Subtitle: "Click below to view the course material"
    Buttons: [View PDF] [Download]
  ]
)
```

### Course View - Empty State (No PDF)
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: [
    Icon: 📄 (grey)
    Text: "No PDF content available for this course"
  ]
)
```

---

## 🔧 Technical Details

### URL Launcher
```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> _openPdf(String pdfUrl) async {
  final uri = Uri.parse(pdfUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

### How PDF URLs Work
```
PDF uploaded to: https://[project].supabase.co/storage/v1/object/public/course-pdfs/uploads/[userId]_[timestamp].pdf
Stored in DB: course.pdf_url = "https://..."
Retrieved: Course object has pdfUrl field
Displayed: "View PDF" button uses url_launcher
```

---

## 📊 Data Flow

```
User creates course with PDF
    ↓
PDF uploaded to Supabase Storage (course-pdfs bucket)
    ↓
Public URL saved to courses.pdf_url
    ↓
CourseViewScreen displays PDF card
    ↓
User clicks "View PDF"
    ↓
url_launcher opens URL in browser/app
    ↓
User views PDF 📄
```

---

## 🎨 Customization

### Change PDF Card Color
In `course_view_screen.dart`:
```dart
color: Colors.blue.shade50,  // Change from red.shade50
border: Border.all(color: Colors.blue.shade200),  // Change color
backgroundColor: Colors.blue.shade700,  // Change button color
```

### Add Download Functionality
```dart
OutlinedButton.icon(
  onPressed: () async {
    // You can implement actual download using:
    // - dio package
    // - download_plus package
    // - Or just copy URL
  },
  icon: const Icon(Icons.download),
  label: const Text('Download'),
),
```

### Add PDF Preview (Optional)
```dart
// Use pdfrx or pdfx package:
// pdfrx: ^0.17.0

// Then show PDF in app instead of opening browser:
// showDialog(...) with PDF viewer widget
```

---

## ✨ Example Usage

### Create Course with PDF
1. Click **"Create Course"** (admin only)
2. Fill: Title, Description, Image
3. Click **"Choose PDF"** → Select PDF file
4. Click **"Create"**
5. PDF uploads to storage
6. URL saved to database

### View Course
1. Navigate to **Courses** tab
2. See red 📄 icon if course has PDF
3. Click course to view details
4. See **PDF Content** card
5. Click **"View PDF"** to open

### Edit Course PDF
1. Click **"Edit"** (admin only)
2. Current PDF shown in form
3. Click **X** to remove
4. Click **"Choose PDF"** for new PDF
5. Click **"Save changes"**

---

## 🔐 Security

- ✅ PDFs stored in public bucket (can be viewed by anyone with link)
- ✅ Only authenticated users can upload
- ✅ Only file owner can delete
- ✅ PDFs linked to courses via URL

---

## 📋 Testing Checklist

- [ ] Create course with PDF
- [ ] PDF URL appears in database (courses.pdf_url)
- [ ] Course list shows PDF icon (📄)
- [ ] Course detail shows PDF card
- [ ] "View PDF" button opens PDF
- [ ] Edit course: change/remove PDF
- [ ] Delete course: verify PDF removed from storage

---

## 🐛 Troubleshooting

### PDF doesn't open
- Check URL is correct: `https://[project].supabase.co/storage/...`
- Make sure browser/app supports PDF viewing
- Try opening URL directly in browser

### PDF icon not showing in list
- Verify course.pdfUrl is not null in database
- Check if field was added: `ALTER TABLE courses ADD COLUMN pdf_url TEXT;`

### View PDF button not working
- Check `url_launcher` package is installed
- Verify PDF URL is valid
- Check app has required permissions

---

## 📚 Files Updated

| File | Change |
|------|--------|
| `course_view_screen.dart` | Added PDF card UI + open PDF method |
| `course_list_screen.dart` | Added PDF indicator icon |
| `course_form_screen.dart` | PDF upload (already added) |
| `course_service.dart` | PDF upload/delete (already added) |
| `course.dart` | pdfUrl field (already added) |
| `pubspec.yaml` | url_launcher (already present) |

---

## 🎉 Result

Your courses now have **complete PDF support**:
- ✅ Upload PDF when creating course
- ✅ View PDF from course details
- ✅ Edit/change PDF content
- ✅ Visual indicator in course list
- ✅ Beautiful UI for PDF viewing

---

**Your PDF integration is complete! 🚀**

Next: [Optional] Add PDF viewer widget for in-app viewing using `pdfrx` package.
