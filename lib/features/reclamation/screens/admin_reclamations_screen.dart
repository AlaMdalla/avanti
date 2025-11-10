import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/reclamation.dart';
import '../services/reclamation_service.dart';
import 'reclamation_detail_screen.dart';

class AdminReclamationsScreen extends StatefulWidget {
  const AdminReclamationsScreen({super.key});

  @override
  State<AdminReclamationsScreen> createState() =>
      _AdminReclamationsScreenState();
}

class _AdminReclamationsScreenState extends State<AdminReclamationsScreen> {
  late Future<List<Reclamation>> _reclamationsFuture;
  final _reclamationService = ReclamationService();
  String _selectedStatus = 'all'; // all, open, in_progress, resolved, closed
  String _selectedPriority = 'all'; // all, low, medium, high, urgent

  @override
  void initState() {
    super.initState();
    _reclamationsFuture = _reclamationService.getAllReclamations();
  }

  void _refreshReclamations() {
    setState(() {
      _reclamationsFuture = _reclamationService.getAllReclamations();
    });
  }

  List<Reclamation> _filterReclamations(List<Reclamation> reclamations) {
    var filtered = reclamations;

    if (_selectedStatus != 'all') {
      filtered =
          filtered.where((r) => r.status.value == _selectedStatus).toList();
    }

    if (_selectedPriority != 'all') {
      filtered =
          filtered.where((r) => r.priority.value == _selectedPriority).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reclamations - Admin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReclamations,
          ),
        ],
      ),
      body: FutureBuilder<List<Reclamation>>(
        future: _reclamationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final allReclamations = snapshot.data ?? [];
          final filteredReclamations =
              _filterReclamations(allReclamations);

          if (allReclamations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.speaker_notes_off,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No reclamations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All systems clear!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistics card
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.inversePrimary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      label: 'Total',
                      value: allReclamations.length.toString(),
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: 'Open',
                      value: allReclamations
                          .where((r) => r.status.value == 'open')
                          .length
                          .toString(),
                      color: Colors.orange,
                    ),
                    _StatCard(
                      label: 'Resolved',
                      value: allReclamations
                          .where((r) => r.status.value == 'resolved')
                          .length
                          .toString(),
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: 'Closed',
                      value: allReclamations
                          .where((r) => r.status.value == 'closed')
                          .length
                          .toString(),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Status filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        underline: const SizedBox(),
                        items: [
                          'all',
                          'open',
                          'in_progress',
                          'resolved',
                          'closed'
                        ]
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(_getStatusLabel(status)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Priority filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedPriority,
                        underline: const SizedBox(),
                        items: ['all', 'low', 'medium', 'high', 'urgent']
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(_getPriorityLabel(priority)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPriority = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Reclamations list
              Expanded(
                child: filteredReclamations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_list_off,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text('No reclamations match filters'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredReclamations.length,
                        itemBuilder: (context, index) {
                          final reclamation = filteredReclamations[index];
                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReclamationDetailScreen(
                                        reclamation: reclamation,
                                        isAdminView: true,
                                      ),
                                ),
                              );
                              if (result == true) {
                                _refreshReclamations();
                              }
                            },
                            child: _AdminReclamationCard(
                              reclamation: reclamation,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    const statusMap = {
      'all': 'All Status',
      'open': 'Open',
      'in_progress': 'In Progress',
      'resolved': 'Resolved',
      'closed': 'Closed',
    };
    return statusMap[status] ?? status;
  }

  String _getPriorityLabel(String priority) {
    const priorityMap = {
      'all': 'All Priority',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'urgent': 'Urgent',
    };
    return priorityMap[priority] ?? priority;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _AdminReclamationCard extends StatelessWidget {
  final Reclamation reclamation;

  const _AdminReclamationCard({required this.reclamation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title, status, and priority
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reclamation.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            reclamation.category.icon,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reclamation.category.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // User ID
                          Expanded(
                            child: Text(
                              'User: ${reclamation.userId.substring(0, 8)}...',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Status and priority badges
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: reclamation.status.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        reclamation.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: reclamation.status.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: reclamation.priority.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reclamation.priority.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: reclamation.priority.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              reclamation.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Footer with date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _formatDate(reclamation.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                if (reclamation.resolvedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Resolved: ${_formatDate(reclamation.resolvedAt!)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
