import 'package:flutter/material.dart';
import '../models/reclamation_model.dart';

class ReclamationCard extends StatelessWidget {
  final Reclamation reclamation;

  const ReclamationCard({super.key, required this.reclamation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.report_problem, color: Colors.redAccent),
        title: Text(reclamation.title),
        subtitle: Text(
          reclamation.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          reclamation.createdAt.toLocal().toString().split(' ')[0],
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
