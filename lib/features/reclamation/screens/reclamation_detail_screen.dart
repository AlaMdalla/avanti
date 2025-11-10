import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/reclamation.dart';
import '../services/reclamation_service.dart';

class ReclamationDetailScreen extends StatefulWidget {
  final Reclamation reclamation;
  final bool isAdminView;

  const ReclamationDetailScreen({
    super.key,
    required this.reclamation,
    this.isAdminView = false,
  });

  @override
  State<ReclamationDetailScreen> createState() =>
      _ReclamationDetailScreenState();
}

class _ReclamationDetailScreenState extends State<ReclamationDetailScreen> {
  late Reclamation _reclamation;
  late Future<List<dynamic>> _responsesFuture;
  final _reclamationService = ReclamationService();
  late TextEditingController _responseController;
  late TextEditingController _reasonController;
  bool _isLoadingResponse = false;
  bool _isUpdatingStatus = false;
  ReclamationStatus? _selectedNewStatus;

  @override
  void initState() {
    super.initState();
    _reclamation = widget.reclamation;
    _responsesFuture =
        _reclamationService.getReclamationResponses(_reclamation.id);
    _responseController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _addResponse() async {
    if (_responseController.text.isEmpty) return;

    setState(() => _isLoadingResponse = true);

    try {
      await _reclamationService.addResponse(
        reclamationId: _reclamation.id,
        responseText: _responseController.text,
      );

      _responseController.clear();

      // Refresh responses
      setState(() {
        _responsesFuture =
            _reclamationService.getReclamationResponses(_reclamation.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Response added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingResponse = false);
    }
  }

  Future<void> _updateReclamationStatus() async {
    if (_selectedNewStatus == null) return;

    setState(() => _isUpdatingStatus = true);

    try {
      await _reclamationService.updateReclamationStatus(
        reclamationId: _reclamation.id,
        newStatus: _selectedNewStatus!.value,
        changeReason:
            _reasonController.text.isNotEmpty ? _reasonController.text : null,
      );

      // Refresh reclamation
      final updated =
          await _reclamationService.getReclamationById(_reclamation.id);
      if (updated != null) {
        setState(() {
          _reclamation = updated;
          _selectedNewStatus = null;
          _reasonController.clear();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status updated to ${_selectedNewStatus!.label}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUpdatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reclamation Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and priority row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _reclamation.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _reclamation.status.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _reclamation.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _reclamation.status.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Category and priority chips
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _reclamation.category.icon,
                              size: 14,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _reclamation.category.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _reclamation.priority.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _reclamation.priority.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _reclamation.priority.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      _reclamation.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'ID',
                    value: _reclamation.id.substring(0, 8) + '...',
                  ),
                  _DetailRow(
                    label: 'Created',
                    value: _formatDate(_reclamation.createdAt),
                  ),
                  if (_reclamation.resolvedAt != null)
                    _DetailRow(
                      label: 'Resolved',
                      value: _formatDate(_reclamation.resolvedAt!),
                    ),
                  if (_reclamation.ratingBefore != null)
                    _DetailRow(
                      label: 'Rating Before',
                      value: '${_reclamation.ratingBefore} / 5 ⭐',
                    ),
                  if (_reclamation.ratingAfter != null)
                    _DetailRow(
                      label: 'Rating After',
                      value: '${_reclamation.ratingAfter} / 5 ⭐',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Responses section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Responses',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<dynamic>>(
                    future: _responsesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final responses = snapshot.data ?? [];

                      if (responses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Center(
                            child: Text(
                              'No responses yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: responses.map((response) {
                          final resp = response as dynamic;
                          return _ResponseCard(
                            responseText:
                                resp['response_text'] as String? ?? '',
                            createdAt: DateTime.parse(resp['created_at'] as String? ?? ''),
                            isAdmin:
                                resp['is_admin_response'] as bool? ?? true,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Add response section (if reclamation is not closed)
            if (_reclamation.status.value != 'closed')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Response',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _responseController,
                            decoration: InputDecoration(
                              hintText: 'Write a response...',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              suffixIcon: _isLoadingResponse
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 100,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoadingResponse ? null : _addResponse,
                            icon: const Icon(Icons.send),
                            label: const Text('Send'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Admin Status Update Section (only for admin view)
            if (widget.isAdminView && _reclamation.status.value != 'closed')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Admin: Update Status',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status dropdown
                          Text(
                            'New Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<ReclamationStatus>(
                              value: _selectedNewStatus,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: const Text('Select new status...'),
                              items: ReclamationStatus.values
                                  .where((s) => s.value != 'open')
                                  .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: status.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(status.label),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedNewStatus = value);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Reason text field
                          Text(
                            'Reason (Optional)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _reasonController,
                            decoration: InputDecoration(
                              hintText: 'Why are you changing the status?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          // Update button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _selectedNewStatus == null ||
                                      _isUpdatingStatus
                                  ? null
                                  : _updateReclamationStatus,
                              icon: _isUpdatingStatus
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(_isUpdatingStatus
                                  ? 'Updating...'
                                  : 'Update Status'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  final String responseText;
  final DateTime createdAt;
  final bool isAdmin;

  const _ResponseCard({
    required this.responseText,
    required this.createdAt,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAdmin ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isAdmin)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Support Team',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              Text(
                '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            responseText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
