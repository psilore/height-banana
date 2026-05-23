import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/target_face.dart';
import '../providers/session_providers.dart';

/// Screen displaying details of a training session
class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({
    required this.sessionId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionByIdProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return const Center(
              child: Text('Session not found'),
            );
          }

          final dateFormat = DateFormat('MMMM dd, yyyy');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(session.date),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.location_on,
                          'Location',
                          session.location,
                        ),
                        _buildInfoRow(
                          Icons.adjust,
                          'Bow',
                          session.bowType,
                        ),
                        _buildInfoRow(
                          Icons.straighten,
                          'Distance',
                          '${session.distanceMeters}m',
                        ),
                        _buildInfoRow(
                          Icons.gps_fixed,
                          'Target',
                          _targetTypeToString(session.targetFace.type),
                        ),
                        if (session.notes != null) ...[
                          const Divider(),
                          Text(
                            'Notes',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(session.notes!),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Statistics Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              'Ends',
                              session.ends.length.toString(),
                              Icons.format_list_numbered,
                            ),
                            _buildStatColumn(
                              'Arrows',
                              session.totalArrows.toString(),
                              Icons.arrow_forward,
                            ),
                            _buildStatColumn(
                              'Total',
                              session.totalScore.toString(),
                              Icons.emoji_events,
                            ),
                            _buildStatColumn(
                              'Average',
                              session.averageScore.toStringAsFixed(1),
                              Icons.star,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Ends List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ends',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/end-logger',
                          arguments: sessionId,
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add End'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (session.ends.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text('No ends logged yet'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/end-logger',
                                  arguments: sessionId,
                                );
                              },
                              child: const Text('Log First End'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...session.ends.asMap().entries.map((entry) {
                    final index = entry.key;
                    final end = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text('End ${end.endNumber}'),
                        subtitle: Text(
                          '${end.arrows.length} arrows • Score: ${end.totalScore}',
                        ),
                        trailing: Text(
                          end.averageScore.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () {
                          // TODO: Show end details dialog
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  String _targetTypeToString(TargetType type) {
    switch (type) {
      case TargetType.fita:
        return 'FITA/WA 10-ring';
      case TargetType.field:
        return 'Field';
      case TargetType.threeD:
        return '3D';
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this session? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final deleteSession = ref.read(deleteSessionProvider);
              await deleteSession(sessionId);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close detail screen
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
