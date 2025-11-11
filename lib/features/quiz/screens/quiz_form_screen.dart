import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/quiz_service.dart';
import '../../../core/utils/validators.dart';

class QuizFormScreen extends StatefulWidget {
  final String courseId;
  const QuizFormScreen({super.key, required this.courseId});

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '0');
  bool _submitting = false;
  final _service = QuizService();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await _service.createQuiz(
        courseId: widget.courseId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        timeLimitSeconds: int.tryParse(_timeCtrl.text.trim()) ?? 0,
        instructorId: user?.id,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Quiz')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => Validators.combine(v, [
                Validators.required,
                (val) => Validators.minLength(val, 3, fieldName: 'Title'),
                (val) => Validators.maxLength(val, 100, fieldName: 'Title'),
              ]),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (v) => Validators.maxLength(v, 500, fieldName: 'Description'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _timeCtrl,
              decoration: const InputDecoration(labelText: 'Time limit (seconds, 0 = none)'),
              keyboardType: TextInputType.number,
              validator: (v) => Validators.nonNegativeInteger(v, fieldName: 'Time limit'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: const Icon(Icons.save),
              label: Text(_submitting ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
