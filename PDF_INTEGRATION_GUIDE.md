# 📄 PDF Integration Guide - Course with PDF Files

## ✅ What Was Added

You now have complete PDF support in the course creation/editing feature:

### 1. **Database Schema Update**
Add a `pdf_url` column to your `courses` table in Supabase:

```sql
-- Run this in Supabase SQL Editor
ALTER TABLE courses ADD COLUMN pdf_url TEXT;
```

### 2. **Created/Updated Files**

| File | Change |
|------|--------|
| `lib/features/course/models/course.dart` | Added `pdfUrl` field to Course & CourseInput |
| `lib/features/course/services/course_service.dart` | Added `uploadPdf()` and `deletePdf()` methods |
| `lib/features/course/screens/course_form_screen.dart` | Added PDF picker UI in course form |
| `pubspec.yaml` | Added `file_picker: ^5.5.0` dependency |

### 3. **New Bucket Required**
Create a new storage bucket in Supabase:

1. Go to **Supabase Dashboard**
2. **Storage** → **Create a new bucket**
3. Name: `course-pdfs`
4. Make it **Public**

## 🔐 Storage Policies

Add these RLS policies to your `course-pdfs` bucket:

**Allow authenticated users to upload:**
```sql
CREATE POLICY "Authenticated users can upload PDFs"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'course-pdfs' AND auth.role() = 'authenticated');
```

**Allow public read access:**
```sql
CREATE POLICY "Public can view PDFs"
ON storage.objects
FOR SELECT
USING (bucket_id = 'course-pdfs');
```

**Allow users to delete their own PDFs:**
```sql
CREATE POLICY "Users can delete own PDFs"
ON storage.objects
FOR DELETE
USING (bucket_id = 'course-pdfs' AND auth.uid()::text = owner);
```

## 🎯 How to Use in the App

### Creating a Course with PDF

1. Go to **Create Course** screen
2. Fill in:
   - **Title** (required)
   - **Description** (optional)
   - **Image** (optional)
   - **PDF Content** (optional) ← Click "Choose PDF"
3. Select a PDF file from your device
4. Click **Create**

### Editing a Course PDF

1. Go to **Edit Course** screen
2. The current PDF will be shown
3. Click the **X** button to remove the current PDF
4. Click **Choose PDF** to upload a new one
5. Click **Save changes**

## 📊 How It Works

```
User selects PDF file
    ↓
File picked via FilePicker
    ↓
Form submission validates
    ↓
PDF uploaded to 'course-pdfs' bucket
    ↓
Public URL generated
    ↓
URL saved to courses table (pdf_url column)
    ↓
Course created/updated
```

## 🔍 Browsing/Viewing PDFs

The PDF URL is now stored in the database. You can:

1. **Display as a link** in course detail screen
2. **Open with url_launcher** package:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> _viewPdf(String pdfUrl) async {
  if (await canLaunchUrl(Uri.parse(pdfUrl))) {
    await launchUrl(Uri.parse(pdfUrl));
  }
}
```

3. **Embed in a PDF viewer** widget using `pdfrx` or `pdfx` package

## 📝 Example: Display PDF in Course Detail

```dart
class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: Column(
        children: [
          if (course.imageUrl != null)
            Image.network(course.imageUrl!, height: 200, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (course.description != null)
                  Text(course.description!),
                if (course.pdfUrl != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _viewPdf(context, course.pdfUrl!),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View PDF Content'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewPdf(BuildContext context, String pdfUrl) async {
    try {
      if (await canLaunchUrl(Uri.parse(pdfUrl))) {
        await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

## 🚀 Next Steps

1. **Run migrations** to add `pdf_url` column:
   ```bash
   cd /home/noya/dev/avanti_mobile
   flutter pub get
   ```

2. **Create the bucket** in Supabase dashboard

3. **Add RLS policies** to the bucket

4. **Test the feature**:
   - Create a course with a PDF
   - View course details
   - Verify PDF URL is saved

## ✨ Features Summary

| Feature | Status |
|---------|--------|
| Upload PDF during course creation | ✅ Done |
| Upload PDF during course editing | ✅ Done |
| Remove/Replace PDF | ✅ Done |
| Store PDF URL in database | ✅ Done |
| Display PDF in course details | ⏳ Add to your course detail screen |
| Open PDF in browser/app | ⏳ Use url_launcher |
| PDF viewer widget | ⏳ Optional - use `pdfrx` or `pdfx` |

---

**Your PDF integration is ready to use! 🎉**
