import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../services/plan_service.dart';

class PlanFormScreen extends StatefulWidget {
  final Plan? initial;
  final PlanService service;
  PlanFormScreen({super.key, this.initial, PlanService? service})
      : service = service ?? PlanService();

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _descC;
  late final TextEditingController _priceC;
  String _currency = 'USD';
  String _interval = 'month';
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameC = TextEditingController(text: p?.name ?? '');
    _descC = TextEditingController(text: p?.description ?? '');
    _priceC = TextEditingController(text: p != null ? (p.priceCents / 100).toStringAsFixed(2) : '');
    _currency = p?.currency ?? 'USD';
    _interval = p?.interval ?? 'month';
    _active = p?.active ?? true;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final cents = ((double.tryParse(_priceC.text.trim()) ?? 0) * 100).round();
    final plan = Plan(
      id: widget.initial?.id,
      name: _nameC.text.trim(),
      description: _descC.text.trim().isEmpty ? null : _descC.text.trim(),
      priceCents: cents,
      currency: _currency,
      interval: _interval,
      active: _active,
    );
    try {
      final saved = widget.initial == null
          ? await widget.service.create(plan)
          : await widget.service.update(plan);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'Create Plan' : 'Edit Plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameC,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descC,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceC,
              decoration: const InputDecoration(labelText: 'Price (e.g. 9.99)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Required';
                final d = double.tryParse(t);
                if (d == null || d <= 0) return 'Enter a positive number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                    ],
                    onChanged: (v) => setState(() => _currency = v ?? _currency),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _interval,
                    decoration: const InputDecoration(labelText: 'Interval'),
                    items: const [
                      DropdownMenuItem(value: 'month', child: Text('month')),
                      DropdownMenuItem(value: 'year', child: Text('year')),
                    ],
                    onChanged: (v) => setState(() => _interval = v ?? _interval),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: const Text('Active'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : (widget.initial == null ? 'Create' : 'Save')),
            ),
          ],
        ),
      ),
    );
  }
}
