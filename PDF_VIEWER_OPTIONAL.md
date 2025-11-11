# 📖 OPTIONAL: In-App PDF Viewer (Advanced)

## Current Implementation
Your app currently opens PDFs in the **browser/external app** using `url_launcher`.

## Option 1: In-App Viewing with PDFrx (Recommended)

### Why Use In-App Viewer?
- ✅ Better UX (no switching apps)
- ✅ Offline support
- ✅ Full control over UI
- ❌ More code/dependencies

### Installation

Add to `pubspec.yaml`:
```yaml
dependencies:
  pdfrx: ^0.17.0  # PDF viewer
```

Run:
```bash
flutter pub get
```

### Create PDF Viewer Widget

Create `lib/features/pdf/screens/pdf_viewer_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: PdfViewer.openUrl(
        widget.pdfUrl,
        viewerController: _pdfViewerController,
        params: const PdfViewerParams(
          padding: 16,
        ),
      ),
    );
  }
}
```

### Update course_view_screen.dart

Replace the `_openPdf` method:

```dart
Future<void> _openPdf(String pdfUrl) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PdfViewerScreen(
        pdfUrl: pdfUrl,
        title: 'PDF Viewer',
      ),
    ),
  );
}
```

And update the button:
```dart
FilledButton.icon(
  onPressed: () => _openPdf(course.pdfUrl!),
  icon: const Icon(Icons.picture_as_pdf),  // Changed icon
  label: const Text('View PDF'),
  style: FilledButton.styleFrom(
    backgroundColor: Colors.red.shade700,
  ),
),
```

---

## Option 2: Using PDFx Package

### Installation

```yaml
dependencies:
  pdfx: ^2.5.0
```

### Simple Implementation

```dart
import 'package:pdfx/pdfx.dart';

class SimplePdfViewer extends StatefulWidget {
  final String pdfUrl;
  
  const SimplePdfViewer({required this.pdfUrl});

  @override
  State<SimplePdfViewer> createState() => _SimplePdfViewerState();
}

class _SimplePdfViewerState extends State<SimplePdfViewer> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      PdfDocument.openUrl(widget.pdfUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PdfViewPinch(
        controller: _pdfController,
      ),
    );
  }
}
```

---

## Option 3: Keep Current Implementation (Browser)

This is what you have now:
- ✅ Simple
- ✅ Works everywhere
- ✅ No extra dependencies
- ✅ Minimal code

Just click "View PDF" → Opens in browser

---

## Comparison

| Feature | Browser | PDFrx | PDFx |
|---------|---------|-------|------|
| Setup | Minimal | Medium | Easy |
| Dependencies | 0 | 1 | 1 |
| UX | Good | Excellent | Good |
| Offline | ❌ | ✅ | ✅ |
| Performance | Good | Excellent | Good |
| Platform Support | All | All | All |

---

## Recommendation

### For Quick Implementation
**Keep current (browser)** - Already works, no extra code

### For Better UX  
**Add PDFrx** - Best features and performance

### For Simple Solution
**Add PDFx** - Lighter weight option

---

## Complete Example with PDFrx

### course_view_screen.dart (Full with PDF Viewer)

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/models/profile.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import 'course_form_screen.dart';
import '../../quiz/screens/quiz_list_screen.dart';
import 'pdf_viewer_screen.dart';

// ... existing code ...

Future<void> _openPdf(String pdfUrl) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PdfViewerScreen(
        pdfUrl: pdfUrl,
        title: 'Course PDF',
      ),
    ),
  );
}

// ... rest of code ...
```

---

## Troubleshooting In-App Viewer

### PDF not loading
- Check URL is accessible from device
- Verify SSL certificate (HTTPS)
- Check internet connection

### Rendering issues
- Try PDFx instead of PDFrx
- Clear app cache
- Restart app

### Performance issues
- Add caching strategy
- Load smaller PDFs first
- Show loading indicator while rendering

---

## My Recommendation

🎯 **For your use case:**
1. **Start with current (browser)** - Already working
2. **Later add PDFrx** - When you want better UX
3. **Easy to swap** - Just add widget, no DB changes

The current implementation is perfect for MVP. Upgrade later if needed!

---

**Current Status:** ✅ Browser/App PDF opening working
**Optional Upgrade:** 📖 In-app PDF viewer with PDFrx
