import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../session_logger/domain/models/arrow.dart';
import '../../../session_logger/domain/models/end.dart';
import '../../../session_logger/presentation/providers/session_providers.dart';

/// Screen for logging arrows in an end.
/// Supports both manual score entry and camera capture for arrow detection.
class EndLoggerScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final int endNumber;

  const EndLoggerScreen({
    super.key,
    required this.sessionId,
    required this.endNumber,
  });

  @override
  ConsumerState<EndLoggerScreen> createState() => _EndLoggerScreenState();
}

class _EndLoggerScreenState extends ConsumerState<EndLoggerScreen> {
  final List<Arrow> _arrows = [];
  final int _maxArrows = 6; // Standard archery end
  bool _isSaving = false;
  String? _selectedScore;

  void _addArrowManually(String score) {
    if (_arrows.length >= _maxArrows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End is full (max $_maxArrows arrows)')),
      );
      return;
    }

    final arrow = Arrow(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: score,
      x: 0.0, // Manual entry doesn't have coordinates
      y: 0.0,
      timestamp: DateTime.now(),
    );

    setState(() {
      _arrows.add(arrow);
      _selectedScore = null;
    });
  }

  void _removeArrow(Arrow arrow) {
    setState(() {
      _arrows.remove(arrow);
    });
  }

  void _editArrow(Arrow arrow) {
    showDialog(
      context: context,
      builder: (context) => _EditArrowScoreDialog(
        currentScore: arrow.score,
        onSave: (newScore) {
          setState(() {
            final index = _arrows.indexOf(arrow);
            if (index != -1) {
              _arrows[index] = arrow.copyWith(score: newScore);
            }
          });
        },
      ),
    );
  }

  Future<void> _openCamera() async {
    if (_arrows.length >= _maxArrows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End is full (max $_maxArrows arrows)')),
      );
      return;
    }

    // Generate temporary end ID
    final endId = 'end_${widget.endNumber}_${DateTime.now().millisecondsSinceEpoch}';

    // Navigate to camera capture screen
    Navigator.pushNamed(
      context,
      '/camera-capture',
      arguments: {
        'sessionId': widget.sessionId,
        'endId': endId,
      },
    );
  }

  Future<void> _saveEnd() async {
    if (_arrows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one arrow')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final sessionRepository = ref.read(sessionRepositoryProvider);

      // Create End object
      final end = End(
        id: 'end_${widget.endNumber}_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: widget.sessionId,
        endNumber: widget.endNumber,
        arrows: _arrows,
        timestamp: DateTime.now(),
      );

      // TODO: Update session with new end via repository
      // This requires adding an updateSession method or addEnd method

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'End ${widget.endNumber} saved: ${end.totalScore} points',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to session detail
      Navigator.pop(context, end);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('End ${widget.endNumber}'),
        actions: [
          if (_arrows.isNotEmpty)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveEnd,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Save'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Score summary card
          _buildScoreSummary(),

          // Arrow list
          Expanded(
            child: _arrows.isEmpty
                ? _buildEmptyState()
                : _buildArrowList(),
          ),

          // Score input panel
          _buildScoreInputPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCamera,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Use Camera'),
      ),
    );
  }

  Widget _buildScoreSummary() {
    final totalScore = _arrows.fold<int>(
      0,
      (sum, arrow) {
        final score = arrow.score == 'X'
            ? 10
            : arrow.score == 'M'
                ? 0
                : int.tryParse(arrow.score) ?? 0;
        return sum + score;
      },
    );

    final averageScore = _arrows.isEmpty ? 0.0 : totalScore / _arrows.length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Arrows',
              '${_arrows.length}/$_maxArrows',
              Icons.sports_baseball,
            ),
            _buildStatItem(
              'Total',
              totalScore.toString(),
              Icons.emoji_events,
            ),
            _buildStatItem(
              'Average',
              averageScore.toStringAsFixed(1),
              Icons.show_chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
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
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'No arrows logged yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap scores below or use camera',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _arrows.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final arrow = _arrows.removeAt(oldIndex);
          _arrows.insert(newIndex, arrow);
        });
      },
      itemBuilder: (context, index) {
        final arrow = _arrows[index];
        return Card(
          key: ValueKey(arrow.id),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getScoreColor(arrow.score),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Arrow ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('Score: ${arrow.score}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(arrow.score),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    arrow.score,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editArrow(arrow),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _removeArrow(arrow),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreInputPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Score Entry:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['X', '10', '9', '8', '7', '6', '5', '4', '3', '2', '1', 'M']
                  .map((score) => _buildScoreButton(score))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreButton(String score) {
    final isDisabled = _arrows.length >= _maxArrows;
    final isSelected = _selectedScore == score;

    return Material(
      color: isDisabled
          ? Colors.grey[300]
          : isSelected
              ? _getScoreColor(score)
              : Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: isDisabled ? null : () => _addArrowManually(score),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? _getScoreColor(score)
                  : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Text(
            score,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDisabled
                  ? Colors.grey
                  : isSelected
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(String score) {
    if (score == 'X' || score == '10') return Colors.amber[700]!;
    if (score == '9' || score == '8') return Colors.red[700]!;
    if (score == '7' || score == '6') return Colors.blue[700]!;
    if (score == '5' || score == '4') return Colors.black;
    return Colors.grey[600]!;
  }
}

/// Dialog for editing an arrow's score.
class _EditArrowScoreDialog extends StatefulWidget {
  final String currentScore;
  final Function(String) onSave;

  const _EditArrowScoreDialog({
    required this.currentScore,
    required this.onSave,
  });

  @override
  State<_EditArrowScoreDialog> createState() => _EditArrowScoreDialogState();
}

class _EditArrowScoreDialogState extends State<_EditArrowScoreDialog> {
  late String _selectedScore;

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.currentScore;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Score'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ['X', '10', '9', '8', '7', '6', '5', '4', '3', '2', '1', 'M']
            .map((score) => ChoiceChip(
                  label: Text(
                    score,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: _selectedScore == score,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedScore = score);
                    }
                  },
                ),)
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_selectedScore);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
