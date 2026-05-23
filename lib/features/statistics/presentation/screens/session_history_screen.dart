import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../session_logger/presentation/providers/session_providers.dart';
import '../../../session_logger/domain/models/training_session.dart';

/// Session history screen with filtering and export capabilities
class SessionHistoryScreen extends ConsumerStatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  ConsumerState<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  String _sortBy = 'date';
  bool _sortAscending = false;
  String? _filterBowType;
  String? _filterLocation;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportData(sessionsAsync.value ?? []),
            tooltip: 'Export',
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          var filtered = _applyFilters(sessions);
          var sorted = _applySorting(filtered);

          if (sorted.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    return _buildSessionCard(sorted[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No sessions found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          if (_filterBowType != null || _filterLocation != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_filterBowType == null && _filterLocation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filterBowType != null)
            Chip(
              label: Text('Bow: $_filterBowType'),
              onDeleted: () => setState(() => _filterBowType = null),
            ),
          if (_filterLocation != null)
            Chip(
              label: Text('Location: $_filterLocation'),
              onDeleted: () => setState(() => _filterLocation = null),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(TrainingSession session) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/session-detail',
            arguments: session.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.location,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateFormat.format(session.date),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.sports_baseball,
                    session.bowType,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.straighten,
                    '${session.distanceMeters}m',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.arrow_forward,
                    '${session.totalArrows} arrows',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Total', session.totalScore.toString()),
                  _buildStatColumn('Average', session.averageScore.toStringAsFixed(1)),
                  _buildStatColumn('Ends', session.ends.length.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  List<TrainingSession> _applyFilters(List<TrainingSession> sessions) {
    var result = sessions;

    if (_filterBowType != null) {
      result = result.where((s) => s.bowType == _filterBowType).toList();
    }

    if (_filterLocation != null) {
      result = result.where((s) => s.location == _filterLocation).toList();
    }

    return result;
  }

  List<TrainingSession> _applySorting(List<TrainingSession> sessions) {
    var sorted = List<TrainingSession>.from(sessions);

    switch (_sortBy) {
      case 'date':
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'score':
        sorted.sort((a, b) => a.averageScore.compareTo(b.averageScore));
        break;
      case 'location':
        sorted.sort((a, b) => a.location.compareTo(b.location));
        break;
    }

    if (!_sortAscending) {
      sorted = sorted.reversed.toList();
    }

    return sorted;
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Date'),
              value: 'date',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Score'),
              value: 'score',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Location'),
              value: 'location',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: const Text('Ascending'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() => _sortAscending = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter'),
        content: const Text('Advanced filters coming soon!'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filterBowType = null;
      _filterLocation = null;
    });
  }

  Future<void> _exportData(List<TrainingSession> sessions) async {
    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    // TODO: Implement CSV/JSON export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
